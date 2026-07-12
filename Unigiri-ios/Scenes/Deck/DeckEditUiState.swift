import Foundation

struct DeckEditUiState {
    var deckName = ""
    var saveError: String?
    var selectedEntries: [DeckCardModel] = []
    var validation = DeckValidationState()
}
