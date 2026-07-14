import Kingfisher
import SwiftUI

/// 初期手札チェック: 5枚ドロー → 0〜5枚選択して1回だけ引き直し
struct HandSimulatorSheet: View {
    let deck: DeckModel

    @Environment(\.dismiss) private var dismiss
    @State private var dealt: HandSimulator.DealtHand
    @State private var selectedIds: Set<Int> = []
    // nil=選択フェーズ / 非nil=結果フェーズ (1回のみの引き直しをフェーズで担保)
    @State private var result: [HandCard]?

    init(deck: DeckModel) {
        self.deck = deck
        _dealt = State(initialValue: HandSimulator.deal(deck: deck))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                HStack(spacing: 4) {
                    ForEach(result ?? dealt.hand) { handCard in
                        HandCardView(
                            handCard: handCard,
                            isSelected: result == nil && selectedIds.contains(handCard.instanceId),
                            showNewBadge: result != nil && handCard.isRedrawn
                        )
                        .onTapGesture {
                            guard result == nil else { return }
                            if selectedIds.contains(handCard.instanceId) {
                                selectedIds.remove(handCard.instanceId)
                            } else {
                                selectedIds.insert(handCard.instanceId)
                            }
                        }
                    }
                }

                Text(result == nil ? "引き直すカードを選択 (0〜5枚・1回のみ)" : "これが最終手札です")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if result == nil {
                    Button {
                        if selectedIds.isEmpty {
                            result = dealt.hand
                        } else {
                            result = HandSimulator.mulligan(
                                hand: dealt.hand,
                                selectedIds: selectedIds,
                                pile: dealt.pile
                            )
                        }
                    } label: {
                        Text(selectedIds.isEmpty ? "このままキープ" : "\(selectedIds.count)枚引き直す")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button {
                        dealt = HandSimulator.deal(deck: deck)
                        selectedIds = []
                        result = nil
                    } label: {
                        Text("もう一度")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button("閉じる") {
                        dismiss()
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .navigationTitle("初期手札チェック")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

private struct HandCardView: View {
    let handCard: HandCard
    let isSelected: Bool
    let showNewBadge: Bool

    var body: some View {
        let url = URL(string: handCard.card.img)
        let modifier = AnyModifier { request in
            var r = request
            r.setValue("https://zutomayocard.net/", forHTTPHeaderField: "Referer")
            return r
        }

        KFImage.url(url)
            .requestModifier(modifier)
            .placeholder {
                ProgressView()
            }
            .resizable()
            .aspectRatio(0.715, contentMode: .fill)
            .overlay {
                if isSelected {
                    ZStack {
                        Color.black.opacity(0.4)
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
            }
            .overlay(alignment: .topLeading) {
                if showNewBadge {
                    Text("NEW")
                        .font(.caption2.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color.accentColor)
                        .clipShape(Capsule())
                        .padding(3)
                }
            }
            .contentShape(Rectangle())
    }
}
