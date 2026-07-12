import SwiftUI

enum DeckEditTarget: Identifiable {
    case new
    case edit(DeckModel)

    var id: String {
        switch self {
        case .new: return "new"
        case .edit(let deck): return deck.id.uuidString
        }
    }

    var deck: DeckModel? {
        switch self {
        case .new: return nil
        case .edit(let deck): return deck
        }
    }
}

struct DeckListScreen: View {
    @ObservedObject var viewModel: DeckListViewModel
    let makeEditViewModel: (DeckModel?) -> DeckEditViewModel

    @State private var editTarget: DeckEditTarget?

    var body: some View {
        NavigationStack {
            Group {
                if let error = viewModel.uiState.error {
                    Text(error)
                } else if viewModel.uiState.decks.isEmpty {
                    ContentUnavailableView(
                        "デッキがありません",
                        systemImage: "rectangle.stack",
                        description: Text("右上の＋からデッキを作成できます")
                    )
                } else {
                    List {
                        ForEach(viewModel.uiState.decks) { deck in
                            DeckRow(deck: deck)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    editTarget = .edit(deck)
                                }
                        }
                        .onDelete { offsets in
                            viewModel.delete(at: offsets)
                        }
                    }
                }
            }
            .navigationTitle("デッキ")
            .toolbar {
                Button {
                    editTarget = .new
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .fullScreenCover(item: $editTarget, onDismiss: { viewModel.load() }) { target in
            DeckEditScreen(viewModel: makeEditViewModel(target.deck))
        }
        .task { viewModel.load() }
    }
}

private struct DeckRow: View {
    let deck: DeckModel

    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 2) {
                ForEach(deck.cards.prefix(3)) { card in
                    SelectedCardCell(card: card)
                        .frame(width: 40, height: 56)
                        .clipped()
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(deck.name)
                    .font(.headline)
                HStack(spacing: 8) {
                    Text("\(deck.totalCount)/\(DeckValidator.deckSize)枚")
                        .foregroundColor(deck.totalCount == DeckValidator.deckSize ? .secondary : .orange)
                    Text(deck.updatedAt, style: .date)
                        .foregroundColor(.secondary)
                }
                .font(.caption)
            }

            Spacer()
        }
    }
}
