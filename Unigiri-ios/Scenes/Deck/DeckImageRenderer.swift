import Foundation
import Kingfisher
import UIKit

/// デッキ20枚を5列×4行のグリッドに合成した共有用画像を生成する
struct DeckImageRenderer {
    private static let columns = 5
    private static let rows = 4
    private static let cardWidth: CGFloat = 360
    private static let cardHeight: CGFloat = 503
    private static let gap: CGFloat = 8
    private static let padding: CGFloat = 16
    private static let canvasSize = CGSize(
        width: padding * 2 + CGFloat(columns) * cardWidth + CGFloat(columns - 1) * gap, // 1864
        height: padding * 2 + CGFloat(rows) * cardHeight + CGFloat(rows - 1) * gap // 2068
    )

    enum RenderError: Error {
        case invalidDeckSize
        case invalidImageURL
    }

    func render(deck: DeckModel) async throws -> UIImage {
        // sortOrder順にcount分のスロットへ展開 (同名カードは隣接)
        let slots = deck.cards
            .sorted { $0.sortOrder < $1.sortOrder }
            .flatMap { card in Array(repeating: card, count: card.count) }
        guard slots.count == DeckValidator.deckSize else {
            throw RenderError.invalidDeckSize
        }

        // cardIdでデデュープして並列取得 (一覧サムネイルとKingfisherキャッシュを共有)
        var uniqueImageURLs: [String: String] = [:]
        for card in slots where uniqueImageURLs[card.cardId] == nil {
            uniqueImageURLs[card.cardId] = card.img
        }

        let images = try await withThrowingTaskGroup(of: (String, UIImage).self) { group in
            for (cardId, img) in uniqueImageURLs {
                group.addTask {
                    (cardId, try await Self.downloadImage(urlString: img))
                }
            }
            var result: [String: UIImage] = [:]
            for try await (cardId, image) in group {
                result[cardId] = image
            }
            return result
        }

        return Self.compose(slots: slots, images: images)
    }

    // MARK: - Private

    private static func downloadImage(urlString: String) async throws -> UIImage {
        guard let url = URL(string: urlString) else {
            throw RenderError.invalidImageURL
        }

        let modifier = AnyModifier { request in
            var r = request
            r.setValue("https://zutomayocard.net/", forHTTPHeaderField: "Referer")
            return r
        }

        return try await withCheckedThrowingContinuation { continuation in
            KingfisherManager.shared.retrieveImage(
                with: url,
                options: [.requestModifier(modifier)]
            ) { result in
                switch result {
                case .success(let value):
                    continuation.resume(returning: value.image)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private static func compose(slots: [DeckCardModel], images: [String: UIImage]) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        // デフォルトは画面スケールでピクセル数が倍増するため1固定
        format.scale = 1
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: canvasSize, format: format)

        return renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: canvasSize))

            for (index, card) in slots.enumerated() {
                guard let image = images[card.cardId] else { continue }

                let col = CGFloat(index % columns)
                let row = CGFloat(index / columns)
                let slotRect = CGRect(
                    x: padding + col * (cardWidth + gap),
                    y: padding + row * (cardHeight + gap),
                    width: cardWidth,
                    height: cardHeight
                )

                let cgContext = context.cgContext
                cgContext.saveGState()
                cgContext.clip(to: slotRect)
                image.draw(in: aspectFillRect(for: image.size, in: slotRect))
                cgContext.restoreGState()
            }
        }
    }

    private static func aspectFillRect(for imageSize: CGSize, in slotRect: CGRect) -> CGRect {
        let scale = max(slotRect.width / imageSize.width, slotRect.height / imageSize.height)
        let size = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
        return CGRect(
            x: slotRect.midX - size.width / 2,
            y: slotRect.midY - size.height / 2,
            width: size.width,
            height: size.height
        )
    }
}
