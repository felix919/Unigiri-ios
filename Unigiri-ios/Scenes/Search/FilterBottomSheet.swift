import SwiftUI

struct FilterBottomSheet: View {
    @ObservedObject var viewModel: SearchViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                // 属性
                Section("属性") {
                    filterTypeSection
                }

                // 種類
                Section("種類") {
                    filterCardTypeSection
                }

                // レアリティ
                Section("レアリティ") {
                    filterRareSection
                }

                // パック名
                Section("パック名") {
                    filterPackSection
                }

                // 楽曲名
                Section("楽曲名") {
                    filterSongSection
                }

                // Send To Power
                Section("SEND TO POWER") {
                    filterPowerSection
                }

                // 攻撃力
                Section("攻撃力") {
                    filterAttackRangeSection
                }
            }
            .listRowBackground(Color.surfacePurpleHigh)
            .scrollContentBackground(.hidden)
            .background(Color.surfacePurpleContainer.ignoresSafeArea())
            .navigationTitle("検索条件")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
        .presentationBackground(Color.surfacePurpleContainer)
    }

    // MARK: - 属性

    private var filterTypeSection: some View {
        let types = ["炎", "電気", "闇", "風", "カオス"]
        return FlowLayout(spacing: 8) {
            ForEach(types, id: \.self) { type in
                FilterToggleChip(
                    title: type,
                    isSelected: viewModel.condition.type.contains(type)
                ) { selected in
                    if selected {
                        viewModel.updateType(type)
                    } else {
                        viewModel.removeType(type)
                    }
                }
            }
        }
    }

    // MARK: - 種類

    private var filterCardTypeSection: some View {
        let cardTypes = ["Character", "Enchant", "Area Enchant"]
        return FlowLayout(spacing: 8) {
            ForEach(cardTypes, id: \.self) { cardType in
                FilterToggleChip(
                    title: cardType,
                    isSelected: viewModel.condition.cardType.contains(cardType)
                ) { selected in
                    if selected {
                        viewModel.updateCardType(cardType)
                    } else {
                        viewModel.removeCardType(cardType)
                    }
                }
            }
        }
    }

    // MARK: - レアリティ

    private var filterRareSection: some View {
        let rares = ["UR", "SR", "R", "N", "SE"]
        return FlowLayout(spacing: 8) {
            ForEach(rares, id: \.self) { rare in
                FilterToggleChip(
                    title: rare,
                    isSelected: viewModel.condition.rare.contains(rare)
                ) { selected in
                    if selected {
                        viewModel.updateRare(rare)
                    } else {
                        viewModel.removeRare(rare)
                    }
                }
            }
        }
    }

    // MARK: - パック名

    private var filterPackSection: some View {
        let packList = ["すべて"] + viewModel.uiState.packList
        return Picker("パック名", selection: Binding(
            get: { viewModel.condition.pack ?? "すべて" },
            set: { viewModel.updatePack($0 == "すべて" ? nil : $0) }
        )) {
            ForEach(packList, id: \.self) { pack in
                Text(pack).tag(pack)
            }
        }
    }

    // MARK: - 楽曲名

    private var filterSongSection: some View {
        let songList = ["すべて"] + viewModel.uiState.songList.sorted()
        return Picker("楽曲名", selection: Binding(
            get: { viewModel.condition.song ?? "すべて" },
            set: { viewModel.updateSong($0 == "すべて" ? nil : $0) }
        )) {
            ForEach(songList, id: \.self) { song in
                Text(song).tag(song)
            }
        }
    }

    // MARK: - Send To Power

    private var filterPowerSection: some View {
        let powers = [0, 1, 2]
        return FlowLayout(spacing: 8) {
            ForEach(powers, id: \.self) { power in
                FilterToggleChip(
                    title: "\(power)",
                    isSelected: viewModel.condition.power.contains(power)
                ) { selected in
                    if selected {
                        viewModel.updatePower(power)
                    } else {
                        viewModel.removePower(power)
                    }
                }
            }
        }
    }

    // MARK: - 攻撃力

    private var filterAttackRangeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle("攻撃力フィルター", isOn: Binding(
                get: { viewModel.condition.attackEnabled },
                set: { _ in viewModel.togglePowerEnabled() }
            ))

            HStack(spacing: 8) {
                FilterToggleChip(
                    title: "昼",
                    isSelected: viewModel.condition.attackType.contains(.day)
                ) { selected in
                    if selected {
                        viewModel.updateAttackType(.day)
                    } else {
                        viewModel.removeAttackType(.day)
                    }
                }
                .disabled(!viewModel.condition.attackEnabled)

                FilterToggleChip(
                    title: "夜",
                    isSelected: viewModel.condition.attackType.contains(.night)
                ) { selected in
                    if selected {
                        viewModel.updateAttackType(.night)
                    } else {
                        viewModel.removeAttackType(.night)
                    }
                }
                .disabled(!viewModel.condition.attackEnabled)
            }

            let lowerBound = Binding(
                get: { Double(viewModel.condition.attackRange.lowerBound) },
                set: { newVal in
                    let lower = Int(newVal / 10) * 10
                    let upper = viewModel.condition.attackRange.upperBound
                    viewModel.updateAttackRange(min(lower, upper)...upper)
                }
            )
            let upperBound = Binding(
                get: { Double(viewModel.condition.attackRange.upperBound) },
                set: { newVal in
                    let upper = Int(newVal / 10) * 10
                    let lower = viewModel.condition.attackRange.lowerBound
                    viewModel.updateAttackRange(lower...max(upper, lower))
                }
            )

            VStack {
                HStack {
                    Text("\(viewModel.condition.attackRange.lowerBound)")
                    Spacer()
                    Text("\(viewModel.condition.attackRange.upperBound)")
                }

                Slider(value: lowerBound, in: 0...250, step: 10) {
                    Text("最小")
                }
                .disabled(!viewModel.condition.attackEnabled)

                Slider(value: upperBound, in: 0...250, step: 10) {
                    Text("最大")
                }
                .disabled(!viewModel.condition.attackEnabled)

                HStack {
                    Text("0")
                    Spacer()
                    Text("250")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - FilterToggleChip

struct FilterToggleChip: View {
    let title: String
    let isSelected: Bool
    let onToggle: (Bool) -> Void

    var body: some View {
        Button {
            onToggle(!isSelected)
        } label: {
            HStack(spacing: 4) {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption)
                }
                Text(title)
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.accentColor.opacity(0.2) : Color.gray.opacity(0.15))
            .foregroundColor(isSelected ? .accentColor : .primary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - FlowLayout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x)
        }

        return (CGSize(width: maxX, height: y + rowHeight), positions)
    }
}
