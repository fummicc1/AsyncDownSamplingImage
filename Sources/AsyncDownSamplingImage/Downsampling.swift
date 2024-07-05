import Foundation
import ImageIO

struct DownSampling {
    enum Error: LocalizedError {
        case failedToFetchImage
        case failedToDownsample
    }

    static func perform(
        at url: URL,
        size: DownSamplingSize,
        scale: CGFloat = 1
    ) async throws -> CGImage {
        let imageSourceOption = [kCGImageSourceShouldCache: true] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, imageSourceOption) else {
            throw Error.failedToFetchImage
        }

        let maxDimensionsInPixels = size.maxDimensionsInPixels

        let downsampledOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCache: true,
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

fileprivate extension DownSamplingSize {
    var maxDimensionsInPixels: Double {
        switch self {
        case .size(let cGSize, let scale):
            max(cGSize.width, cGSize.height) * scale
        case .width(let double, let scale):
            double * scale
        case .height(let double, let scale):
            double * scale
        }
    }
}
