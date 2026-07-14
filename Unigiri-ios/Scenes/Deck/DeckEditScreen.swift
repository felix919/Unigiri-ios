import SwiftUI

struct DeckEditScreen: View {
    @StateObject private var viewModel: DeckEditViewModel
    @StateObject private var searchViewModel = SearchViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showFilterSheet = false

    // 基本6列、6列で4行目に折り返す(19種類以上)場合は7列に切り替える
    private var selectedColumns: [GridItem] {
        let columnCount = viewModel.uiState.selectedEntries.count >= 19 ? 7 : 6
        return Array(repeating: GridItem(.flexible(), spacing: 4), count: columnCount)
    }

    private let resultColumns = [
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4)
    ]

    init(viewModel: @autoclosure @escaping () -> DeckEditViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    selectedSection
                        .frame(height: geometry.size.height * 0.45)

                    Divider()

                    resultSection
                }
            }
            .background(Color.mainPurple.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        if viewModel.save() {
                            dismiss()
                        }
                    }
                    .disabled(viewModel.uiState.selectedEntries.isEmpty)
                }
            }
            .alert(
                "保存に失敗しました",
                isPresented: Binding(
                    get: { viewModel.uiState.saveError != nil },
                    set: { if !$0 { viewModel.uiState.saveError = nil } }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.uiState.saveError ?? "")
            }
            .sheet(isPresented: $showFilterSheet) {
                FilterBottomSheet(viewModel: searchViewModel)
            }
        }
    }

    // MARK: - 上側: 選択したカードリスト

    private var selectedSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                TextField("デッキ名", text: $viewModel.uiState.deckName)
                    .textFieldStyle(.roundedBorder)

                Text("\(viewModel.uiState.validation.totalCount)/\(DeckValidator.deckSize)")
                    .font(.headline)
                    .foregroundColor(viewModel.uiState.validation.isComplete ? .brandGreen : .orange)
            }

            if viewModel.uiState.validation.showsCharacterWarning {
                Label("キャラクターカードは50%以上を推奨", systemImage: "exclamationmark.triangle")
                    .font(.caption)
                    .foregroundColor(.orange)
            }

            if viewModel.uiState.selectedEntries.isEmpty {
                Text("下のカードをタップして追加")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVGrid(columns: selectedColumns, spacing: 4) {
                        ForEach(viewModel.uiState.selectedEntries) { entry in
                            SelectedCardCell(card: entry)
                                .onTapGesture {
                                    viewModel.removeCard(entry.cardId)
                                }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
    }

    // MARK: - 下側: 検索結果 (SearchScreenと同一ビジュアル)

    private var resultSection: some View {
        ZStack(alignment: .bottomTrailing) {
            ZStack {
                if searchViewModel.uiState.isLoading {
                    ProgressView()
                } else if let error = searchViewModel.uiState.error {
                    Text(error)
                } else {
                    ScrollView {
                        LazyVGrid(columns: resultColumns, spacing: 4) {
                            ForEach(searchViewModel.uiState.result) { item in
                                let count = viewModel.copyCount(of: item.id)
                                CardView(item: item)
                                    .overlay(alignment: .topTrailing) {
                                        if count > 0 {
                                            CountBadge(count: count)
                                        }
                                    }
                                    .opacity(viewModel.uiState.validation.canAdd(item.id) ? 1 : 0.35)
                                    .onTapGesture {
                                        viewModel.addCard(item)
                                    }
                            }
                        }
                        .padding(4)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Button {
                showFilterSheet = true
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.accentColor)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            .padding(.trailing, 24)
            .padding(.bottom, 24)
        }
    }
}
