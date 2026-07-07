import Foundation
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    @Published var uiState = SearchUiState()
    @Published var condition = SearchCondition()

    private let interactor: SearchInteractor
    private var rawResult = SearchResultModel.empty
    private var cancellables = Set<AnyCancellable>()

    init() {
        let api = APIService()
        let repository = SearchRepositoryImpl(api: api)
        let useCase = GetSearchResultUseCase(repository: repository)
        self.interactor = SearchInteractor(useCase: useCase)

        // conditionの変更を監視してフィルタリング
        $condition
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] condition in
                guard let self else { return }
                self.uiState.result = self.filterResult(raw: self.rawResult, condition: condition)
            }
            .store(in: &cancellables)

        Task { await fetch() }
    }

    // MARK: - Rare

    func updateRare(_ rare: String) {
        condition.rare.insert(rare)
    }

    func removeRare(_ rare: String) {
        condition.rare.remove(rare)
    }

    // MARK: - CardType

    func updateCardType(_ cardType: String) {
        condition.cardType.insert(cardType)
    }

    func removeCardType(_ cardType: String) {
        condition.cardType.remove(cardType)
    }

    // MARK: - Type

    func updateType(_ type: String) {
        condition.type.insert(type)
    }

    func removeType(_ type: String) {
        condition.type.remove(type)
    }

    // MARK: - Power

    func updatePower(_ power: Int) {
        condition.power.insert(power)
    }

    func removePower(_ power: Int) {
        condition.power.remove(power)
    }

    // MARK: - Pack / Song

    func updatePack(_ pack: String?) {
        condition.pack = pack
    }

    func updateSong(_ song: String?) {
        condition.song = song
    }

    // MARK: - Attack

    func togglePowerEnabled() {
        if condition.attackEnabled {
            condition.attackEnabled = false
            condition.attackType = []
        } else {
            condition.attackEnabled = true
        }
    }

    func updateAttackType(_ type: AttackType) {
        condition.attackType.insert(type)
    }

    func removeAttackType(_ type: AttackType) {
        condition.attackType.remove(type)
    }

    func updateAttackRange(_ range: ClosedRange<Int>) {
        condition.attackRange = range
    }

    // MARK: - Private

    private func fetch() async {
        uiState.isLoading = true
        uiState.error = nil

        do {
            let result = try await interactor.fetchSamples()
            rawResult = result
            // uiState.packList = Array(Set(result.hits.compactMap { $0.pack.first }))
            uiState.packList = result.hits
                .compactMap { $0.pack.first }
                .unique()
            // uiState.songList = Array(Set(result.hits.map { $0.songs }))
            uiState.songList = result.hits
                .compactMap { $0.songs }
                .unique()
                .filter { !$0.isEmpty }
            uiState.result = filterResult(raw: result, condition: condition)
            uiState.isLoading = false
        } catch {
            uiState.isLoading = false
            uiState.error = error.localizedDescription
        }
    }

    private func filterResult(raw: SearchResultModel, condition: SearchCondition) -> [ZutocaModel] {
        raw.hits.filter { zutoca in
            (condition.rare.isEmpty || condition.rare.contains(zutoca.rare)) &&
            (condition.type.isEmpty || condition.type.contains(zutoca.type)) &&
            (condition.cardType.isEmpty || condition.cardType.contains(zutoca.cardType)) &&
            (condition.power.isEmpty || condition.power.contains(zutoca.power)) &&
            (!condition.attackEnabled || {
                let targets: [Int?]
                if condition.attackType.isEmpty {
                    targets = [zutoca.noonAttack, zutoca.nightAttack]
                } else {
                    targets = condition.attackType.map {
                        switch $0 {
                        case .day: return zutoca.noonAttack
                        case .night: return zutoca.nightAttack
                        }
                    }
                }
                return targets.contains { attack in
                    guard let attack else { return false }
                    return condition.attackRange.contains(attack)
                }
            }()) &&
            (condition.pack == nil || condition.pack!.isEmpty || zutoca.pack.contains(condition.pack!)) &&
            (condition.song == nil || condition.song!.isEmpty || zutoca.songs.contains(condition.song!))
        }
    }
}

extension Array where Element: Hashable {
    func unique() -> [Element] {
        var seen = Set<Element>()
        return self.filter { seen.insert($0).inserted }
    }
}
