import SwiftUI

struct BattleScreen: View {

    @State private var topValue = 100
    @State private var bottomValue = 100
    @State private var selectedIndex = 4

    @State private var showResetDialog = false

    var body: some View {

        GeometryReader { geo in

            let circleSize = geo.size.width * 0.8

            ZStack {

                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.15),
                        Color.blue.opacity(0.15),
                        Color.yellow.opacity(0.2),
                        Color.yellow.opacity(0.2)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {

                    HPView(
                        value: $topValue,
                        isUpsideDown: true
                    )

                    CronusView(
                        selectedIndex: $selectedIndex,
                        onCenterTap: {
                            showResetDialog = true
                        }
                    )
                        .frame(width: circleSize, height: circleSize)

                    HPView(
                        value: $bottomValue,
                        isUpsideDown: false
                    )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .alert("リセットしますか？", isPresented: $showResetDialog) {

            Button("Yes") {

                topValue = 100
                bottomValue = 100
                selectedIndex = 4
            }

            Button("No", role: .cancel) { }

        } message: {
            Text("HPとクロノスを対戦前に戻します")
        }
    }
}

#Preview {
    BattleScreen()
}
