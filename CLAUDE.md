# Unigiri-ios

ずとまよカード (ZUTOMAYO CARD) のファンアプリ「うにぎり」の iOS 版。
兄弟プロジェクト `../Unigiri-android` があり、**機能は両OSで同等に保つ**方針。片方に機能を追加したら、もう片方にも同じ仕様で実装するのが基本。

## ビルド・実行

```bash
# xcode-select が CommandLineTools を向いているため DEVELOPER_DIR 指定が必須
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  xcodebuild -scheme Unigiri-ios -destination 'generic/platform=iOS Simulator' build
```

- テストターゲットは無い (検証は手動 + シミュレータ)
- Xcode 16+ の synchronized folder group を使用 — `Unigiri-ios/` 配下に .swift を置くだけでターゲットに入る (pbxproj 編集不要)
- デプロイメントターゲット: iOS 26.2 / Swift 5 モード
- SPM 依存: Kingfisher のみ

## アーキテクチャ (クリーンアーキテクチャ)

レイヤーはフォルダで分離。依存方向は Scenes → Domain ← Data。

| フォルダ | 役割 | 命名 |
|---|---|---|
| `Model/` | ドメインエンティティ (plain struct) | `*Model`, `SearchCondition` |
| `Domain/` | Repository プロトコル・UseCase・Interactor・Validator | `*Repository` (protocol), `*UseCase`, `*Interactor` |
| `Data/` | Repository 実装・API・DTO・SwiftData | `*RepositoryImpl`, `APIService`, `*Request`/`*Response`, `*Entity` |
| `Scenes/<機能>/` | View・ViewModel・UiState | `*Screen`, `*ViewModel`, `*UiState` |

代表的な縦のスライス: `SearchScreen` → `SearchViewModel` → `SearchInteractor` → `GetSearchResultUseCase` → `SearchRepository`(protocol) → `SearchRepositoryImpl` → `APIService`

### 規約・パターン

- **DIコンテナ無し**。ViewModel の `init()` 内で依存チェーンを手動組み立て (`SearchViewModel.init` / `DeckListViewModel.init` 参照)。外部から注入するのは `ModelContext` などスワップしたいものだけ
- ViewModel: `@MainActor class ... : ObservableObject` + `@Published var uiState`。**`@Observable` マクロは未使用**
- UiState は `struct *UiState` に isLoading / error / データをまとめる
- SwiftData の `@Model` クラスは **Data層のみ** (`DeckEntity`)。Domain/Scenes には plain struct (`DeckModel`) をマッピングして渡す。`ModelContainer` は `Unigiri_iosApp` で生成し `mainContext` を注入
- 画面遷移: TabView (`ContentView.swift` の `enum Tab`) + sheet / fullScreenCover。NavigationStack push は不使用
- Interactor は UseCase を束ねる薄いファサード (`SearchInteractor`, `DeckInteractor`)

### ハマりどころ

- **upcoming feature `MemberImportVisibility` が有効** — `ObservableObject`/`@Published` を使うファイルには `import Combine` を明示しないとビルドエラーになる (SwiftUI 経由の暗黙 re-export に頼れない)
- default isolation は MainActor (`-default-isolation=MainActor`)。Deck 系の Repository protocol / UseCase / Interactor は `@MainActor` 付き (mainContext を同期利用するため)
- SourceKit が新規ファイルの型を「Cannot find type」と誤検知することがある — xcodebuild が通れば無視してよい
- カード画像は `Referer: https://zutomayocard.net/` ヘッダ必須 (Kingfisher の `requestModifier`)。画像表示は `CardView` / `SelectedCardCell` を再利用すること

## テーマ (公式サイト準拠・ダークモード固定)

- ブランドカラーは `Theme/AppTheme.swift` の `Color` extension に集約 (Android版 `ui/theme/Color.kt` と同一値): 背景 `#422881` / primary `#8B7FD6` (AccentColor アセットも同値) / アクセント `#36AE37` (公式グリーン) / バー類 `#2E1B5B` / シート類 `#37216C`
- NavigationBar / TabBar は `AppAppearance.configure()` (App init で呼ぶ) の UIKit appearance proxy で紫トーンに統一。タブ選択色は公式グリーン
- **全画面ダークモード固定**: ルートで `.preferredColorScheme(.dark)`
- 各画面の背景は `Color.mainPurple`、List は `.scrollContentBackground(.hidden)` + `.listRowBackground` で統一。新しい画面を追加するときも同じパターンに従うこと

## API

- Meilisearch: POST `https://search.zutomayocard.net/indexes/zutomayocard_cards/search` (`APIService`、Bearer トークンはハードコード)
- 起動時に全カード取得 (limit 999, `public != "非公開"`) → 絞り込みは **クライアントサイド** (`SearchViewModel.filterResult`)
- 検索条件UIは `FilterBottomSheet` (SearchViewModel 結合)。他画面でフィルタが要る場合は SearchViewModel の専用インスタンスを持たせて再利用する (DeckEditScreen 方式)

## ドメイン知識: デッキ構築ルール (公式準拠)

`Domain/DeckValidator.swift` に集約。Android 側 `DeckValidator.kt` と完全同仕様。

- デッキは **20枚** (`deckSize`)。作りかけ (<20枚) でも保存は許可する仕様
- 同名カード (同一 `id` = 同一パック・同一ナンバー) は **最大2枚** (`maxCopies`) — 追加時にブロック
- キャラクターカード (`cardType == "Character"`) 50%以上は**推奨** — 警告表示のみで保存はブロックしない
- `cardType` の値: `"Character"` / `"Enchant"` / `"Area Enchant"` (英語)
