import Kingfisher
import SwiftUI

struct CardView: View {
    let item: ZutocaModel

    var body: some View {
        let url = URL(string: item.img)
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
    }
}
