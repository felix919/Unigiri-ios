import Kingfisher
import SwiftUI

struct SelectedCardCell: View {
    let card: DeckCardModel
    var showsCountBadge = true

    var body: some View {
        let url = URL(string: card.img)
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
            .overlay(alignment: .topTrailing) {
                if showsCountBadge && card.count > 1 {
                    CountBadge(count: card.count)
                }
            }
    }
}

struct CountBadge: View {
    let count: Int

    var body: some View {
        Text("×\(count)")
            .font(.caption2.bold())
            .foregroundColor(.white)
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(Color.accentColor)
            .clipShape(Capsule())
            .padding(3)
    }
}
