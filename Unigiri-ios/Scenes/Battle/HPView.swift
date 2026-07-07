import SwiftUI

struct HPView: View {

    @Binding var value: Int
    var isUpsideDown: Bool

    var body: some View {

        GeometryReader { geo in

            HStack(spacing: 0) {
                
                Button {
                    value += isUpsideDown ? 10 : -10
                } label: {
                    Text(isUpsideDown ? "＋" : "ー")
                        .font(.title3)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

//                Color.clear
//                    .contentShape(Rectangle())
//                    .onTapGesture {
//                        if isUpsideDown {
//                            value += 10
//                        } else {
//                            value -= 10
//                        }
//                    }

                Text("\(value)")
                    .font(.largeTitle)
                    .frame(width: geo.size.width / 3)
                    .rotationEffect(isUpsideDown ? .degrees(180) : .degrees(0))
                
                Button {
                    value += isUpsideDown ? -10 : 10
                } label: {
                    Text(isUpsideDown ? "ー" : "＋")
                        .font(.title3)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .frame(height: 120)
    }
}
