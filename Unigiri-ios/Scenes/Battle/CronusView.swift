import SwiftUI

struct CronusView: View {

    @Binding var selectedIndex: Int
    private let divisions = 18
    
    var onCenterTap: () -> Void

    @State private var dragAngle: Double = 0

    var body: some View {

        GeometryReader { geo in

            let size = min(geo.size.width, geo.size.height)

            ZStack {
                let size = min(geo.size.width, geo.size.height)
                let radius = size / 2

                ForEach(0..<divisions, id: \.self) { index in

                    SectorShape(
                        startAngle: angle(for: index),
                        endAngle: angle(for: index + 1)
                    )
                    .fill(color(for: index))
                    .overlay(
                        SectorShape(
                            startAngle: angle(for: index),
                            endAngle: angle(for: index + 1)
                        )
                        .stroke(Color.black, lineWidth: 1)
                    )
                    .scaleEffect(index == selectedIndex ? 1.08 : 1.0)
                    .animation(.easeInOut(duration: 0.15), value: selectedIndex)
                    .onTapGesture {
                        selectedIndex = index
                    }
                }
                
                // 区画番号（円の外側）
                ForEach(0..<divisions, id: \.self) { index in
                    numberLabel(index: index, radius: radius)
                }

                // 真ん中の昼夜アイコン
                centerIcon(size: size)
                    .onTapGesture {
                        onCenterTap()
                    }
            }
            .frame(width: size, height: size)
            .position(x: geo.size.width/2, y: geo.size.height/2)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        updateSelection(from: value.location, in: geo.size)
                    }
            )
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    // MARK: - 区画番号
    private func numberLabel(index: Int, radius: CGFloat) -> some View {

        let step = 360.0 / Double(divisions)
        let angle = step * (Double(index) + 0.5) + 180
        let rad = angle * .pi / 180

        // let distance = radius * 1.15
        let distance = radius * 0.9

        let x = cos(rad) * distance
        let y = sin(rad) * distance
        
        // 選択区画から時計回り距離
        let distanceFromSelected = (index - selectedIndex + divisions) % divisions

        return Group {
            if distanceFromSelected != 0 {
                // 距離に応じた透明度
                let opacity = 1.0 - (Double(distanceFromSelected) / Double(divisions))

                Text("+\(distanceFromSelected)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
                    .opacity(opacity)
                    .position(
                        x: radius + x,
                        y: radius + y
                    )
            }
        }
    }

    private func updateSelection(from point: CGPoint, in size: CGSize) {

        let center = CGPoint(x: size.width/2, y: size.height/2)

        let dx = point.x - center.x
        let dy = point.y - center.y

        let angle = atan2(dy, dx) * 180 / .pi

        var adjusted = angle + 180
        if adjusted < 0 { adjusted += 360 }

        let step = 360.0 / Double(divisions)

        let index = Int(adjusted / step)

        selectedIndex = min(max(index,0), divisions-1)
    }

    private func color(for index: Int) -> Color {

        if index == selectedIndex {
            return .orange
        }

        // Android版と同じ不透明色 (半透明だと紫背景が透けて濁るため)
        if index > 8 {
            return Color(red: 0xFF / 255, green: 0xF5 / 255, blue: 0x9D / 255) // #FFF59D
        } else {
            return Color(red: 0x90 / 255, green: 0xCA / 255, blue: 0xF9 / 255) // #90CAF9
        }
    }

    private func centerIcon(size: CGFloat) -> some View {

        let isDay = selectedIndex > 8
        let iconSize = size * 0.12
        let circleSize = size * 0.22

        return ZStack {

            Circle()
                .fill(Color.white)

            Image(systemName: isDay ? "sun.max.fill" : "moon.stars.fill")
                .font(.system(size: iconSize))
                .foregroundStyle(isDay ? Color.orange : Color.indigo)
        }
        .frame(width: circleSize, height: circleSize)
        .shadow(radius: 6)
        .animation(.easeInOut, value: selectedIndex)
    }

    private func angle(for index: Int) -> Angle {
        Angle(degrees: Double(index) * 360.0 / Double(divisions) + 180)
    }
}

struct SectorShape: Shape {

    var startAngle: Angle
    var endAngle: Angle

    func path(in rect: CGRect) -> Path {

        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = rect.width / 2

        var path = Path()

        path.move(to: center)

        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )

        path.closeSubpath()

        return path
    }
}
