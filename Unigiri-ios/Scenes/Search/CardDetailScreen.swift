import Kingfisher
import SwiftUI

struct CardDetailScreen: View {
    let card: ZutocaModel

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.mainPurple
                    .ignoresSafeArea()

                cardImage
                    .padding(16)
            }
            .navigationTitle("カード詳細")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }

    private var cardImage: some View {
        let url = URL(string: card.img)
        let modifier = AnyModifier { request in
            var r = request
            r.setValue("https://zutomayocard.net/", forHTTPHeaderField: "Referer")
            return r
        }

        return KFImage.url(url)
            .requestModifier(modifier)
            .placeholder {
                ProgressView()
            }
            .resizable()
            .aspectRatio(0.715, contentMode: .fit)
            .frame(maxWidth: .infinity)
    }
}
