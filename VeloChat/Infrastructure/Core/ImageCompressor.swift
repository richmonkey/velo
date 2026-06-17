import UIKit

enum ImageCompressor {
    static let defaultMaxBytes = 320_000

    static func compressedJPEGData(from image: UIImage, maxBytes: Int = defaultMaxBytes) -> Data? {
        let quality: CGFloat = 0.8
        if let data = image.jpegData(compressionQuality: quality), data.count <= maxBytes {
            return data
        }

        var dimension = max(image.size.width, image.size.height)
        let minDimension: CGFloat = 320
        while dimension > minDimension {
            dimension *= 0.75
            let resized = resize(image, maxDimension: dimension)
            if let data = resized.jpegData(compressionQuality: quality), data.count <= maxBytes {
                return data
            }
        }

        let smallest = resize(image, maxDimension: minDimension)
        guard let data = smallest.jpegData(compressionQuality: 0.5), data.count <= maxBytes else {
            return nil
        }
        return data
    }

    private static func resize(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let longest = max(image.size.width, image.size.height)
        guard longest > maxDimension else { return image }
        let scale = maxDimension / longest
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        return UIGraphicsImageRenderer(size: newSize).image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
