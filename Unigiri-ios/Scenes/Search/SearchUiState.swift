import Foundation

struct SearchUiState {
    var isLoading = false
    var result: [ZutocaModel] = []
    var packList: [String] = []
    var songList: [String] = []
    var illustratorList: [String] = []
    var error: String?
}
