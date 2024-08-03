import Foundation
import ImageIO

public struct Incremental {
    public static func perform(
        at url: URL?,
        bufferSize: Int = 32 * 1024, // 32KB
        onUpdate: @escaping @MainActor (CGImage) -> Void
    ) async throws {
        try await Task.detached(priority: .low) {
            let imageSourceOption = [
                kCGImageSourceShouldCache: true
            ] as CFDictionary
            let imageSource = CGImageSourceCreateIncremental(
                imageSourceOption
            )

            guard let url else {
                return
            }
            let (remoteData, _) = try await URLSession.shared.data(from: url)
            let inputStream = InputStream(data: remoteData)
            inputStream.open()

            var data = Data()

            var buffer = [UInt8](
                repeating: 0,
                count: bufferSize
            )
            while inputStream.hasBytesAvailable {
                try Task.checkCancellation()
                let readBytes = inputStream.read(
                    &buffer,
                    maxLength: bufferSize
                )
                if readBytes > 0 {
                    data.append(buffer, count: readBytes)
                    CGImageSourceUpdateData(
                        imageSource,
                        data as CFData,
                        false
                    )
                    if let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) {
                        await onUpdate(image)
                    }
                } else {
                    break
                }
            }
            CGImageSourceUpdateData(imageSource, data as CFData, true)
            if let image = CGImageSourceCreateImageAtIndex(imageSource, 0, imageSourceOption) {
                await onUpdate(image)
            }
            inputStream.close()
        }.value
    }
}
