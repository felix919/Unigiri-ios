import SwiftUI
import WebKit

struct AboutScreen: View {
    // Android版と同じGitHub Pages (内容は両OS共通)
    private static let baseURL = "https://felix919.github.io/Unigiri-android"

    @State private var webLink: WebLinkItem?

    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "-"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("うにぎり")
                    .font(.system(size: 24, weight: .bold))

                Text("バージョン \(appVersion)")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .padding(.top, 4)

                Divider()
                    .padding(.vertical, 16)

                linkRow("利用規約") {
                    webLink = WebLinkItem(
                        title: "利用規約",
                        urlString: "\(Self.baseURL)/terms-of-service.html"
                    )
                }

                linkRow("プライバシーポリシー") {
                    webLink = WebLinkItem(
                        title: "プライバシーポリシー",
                        urlString: "\(Self.baseURL)/privacy-policy.html"
                    )
                }

                Divider()
                    .padding(.vertical, 16)

                sectionTitle("免責事項")
                bodyText(
                    "本アプリは、ZUTOMAYO CARD のファンメイドアプリです。" +
                    "「ずっと真夜中でいいのに。」、株式会社ETB RIGHTS、および ZUTOMAYO CARD 公式とは一切関係がありません。"
                )

                subSectionTitle("著作権について")
                bodyText(
                    "本アプリに表示されるカード画像、カード名、カードテキスト、イラスト等のすべてのコンテンツに関する著作権は、" +
                    "「ずっと真夜中でいいのに。」および株式会社ETB RIGHTS、その他の権利者に帰属します。" +
                    "本アプリはこれらの権利を侵害する意図を持つものではありません。"
                )

                subSectionTitle("データの出典")
                bodyText(
                    "本アプリで表示されるカード情報は、ZUTOMAYO CARD 公式サイト（zutomayocard.net）から取得しています。" +
                    "情報の正確性については保証いたしかねますので、正確な情報は公式サイトをご確認ください。"
                )

                subSectionTitle("免責")
                bodyText(
                    "本アプリは非公式のプレイヤーサポートツールです。" +
                    "本アプリの利用により生じたいかなる損害についても、開発者は一切の責任を負いません。\n\n" +
                    "権利者からの要請があった場合は、速やかに対応いたします。"
                )

                Spacer()
                    .frame(height: 32)
            }
            .padding(16)
        }
        .background(Color.mainPurple.ignoresSafeArea())
        .sheet(item: $webLink) { link in
            if let url = link.url {
                WebViewSheet(title: link.title, url: url)
            }
        }
    }

    // MARK: - Parts

    private func linkRow(_ title: String, action: @escaping () -> Void) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 16))
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 14)
        .contentShape(Rectangle())
        .onTapGesture(perform: action)
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 18, weight: .bold))
            .padding(.bottom, 8)
    }

    private func subSectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 15, weight: .semibold))
            .padding(.top, 12)
            .padding(.bottom, 4)
    }

    private func bodyText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14))
            .lineSpacing(6)
    }
}

private struct WebLinkItem: Identifiable {
    let id = UUID()
    let title: String
    let urlString: String

    var url: URL? { URL(string: urlString) }
}

// URLバーを見せないアプリ内WebView (Android版WebViewScreenと同等)
private struct WebViewSheet: View {
    let title: String
    let url: URL

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            WebView(url: url)
                .ignoresSafeArea(edges: .bottom)
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("閉じる") { dismiss() }
                    }
                }
        }
    }
}

private struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
