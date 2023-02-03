import Foundation
import ImageIO

/// reference: https://medium.com/@zippicoder/downsampling-images-for-better-memory-consumption-and-uicollectionview-performance-35e0b4526425
struct DownSampling {
    enum Error: LocalizedError {
        case failedToFetchImage
        case failedToDownsample
    }

    static func perform(at url: URL, size: CGSize, scale: CGFloat = 1) async throws -> CGImage {
        let imageSourceOption = [kCGImageSourceShouldCache: true] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, imageSourceOption) else {
            throw Error.failedToFetchImage
        }

        let maxDimensionsInPixels = max(size.width, size.height) * scale

        let downsampledOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionsInPixels,
        ] as CFDictionary
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(
            imageSource,
            0,
            downsampledOptions
        ) else {
            throw Error.failedToDownsample
        }
        return downsampledImage
    }
}
