import Foundation
import UIKit

struct DeckListUiState {
    var decks: [DeckModel] = []
    var error: String?
    var isGeneratingShareImage = false
    var shareItem: ShareImageItem?
    var shareError: String?
}

struct ShareImageItem: Identifiable {
    let id = UUID()
    let image: UIImage
}
