import SwiftUI
import UIKit

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
    @State private var handCheckDeck: DeckModel?

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
                            DeckRow(
                                deck: deck,
                                onDelete: { viewModel.delete(deck: deck) },
                                onShare: { viewModel.shareDeckImage(deck) },
                                onHandCheck: { handCheckDeck = deck }
                            )
                            .contentShape(Rectangle())
                            .onTapGesture {
                                editTarget = .edit(deck)
                            }
                            .listRowBackground(Color.clear)
                        }
                        .onDelete { offsets in
                            viewModel.delete(at: offsets)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.mainPurple.ignoresSafeArea())
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
        .sheet(item: $viewModel.uiState.shareItem) { item in
            ShareSheet(items: [item.image])
        }
        .sheet(item: $handCheckDeck) { deck in
            HandSimulatorSheet(deck: deck)
        }
        .overlay {
            if viewModel.uiState.isGeneratingShareImage {
                ProgressView()
            }
        }
        .alert(
            "共有に失敗しました",
            isPresented: Binding(
                get: { viewModel.uiState.shareError != nil },
                set: { if !$0 { viewModel.uiState.shareError = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.uiState.shareError ?? "")
        }
        .task { viewModel.load() }
    }
}

private struct DeckRow: View {
    let deck: DeckModel
    let onDelete: () -> Void
    let onShare: () -> Void
    let onHandCheck: () -> Void

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

            Button {
                onDelete()
            } label: {
                Image(systemName: "trash")
            }
            .buttonStyle(.borderless)

            Menu {
                Button("デッキ画像を共有") {
                    onShare()
                }
                .disabled(deck.totalCount != DeckValidator.deckSize)

                Button("初期手札チェック") {
                    onHandCheck()
                }
                .disabled(deck.totalCount != DeckValidator.deckSize)
            } label: {
                Image(systemName: "ellipsis")
                    .frame(width: 32, height: 32)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.borderless)
        }
    }
}

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
