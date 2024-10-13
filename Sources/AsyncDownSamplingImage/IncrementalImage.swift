//
//  IncrementalImage.swift
//
//
//  Created by Fumiya Tanaka on 2024/08/03.
//

import Foundation
import SwiftUI

/// `IncrementalImage` is a SwiftUI view that asynchronously fetches and displays an image from a given URL incrementally.
///
/// This view is particularly useful for displaying large images that need to be loaded in chunks to avoid blocking the main thread.
///
/// - Parameters:
///   - url: A binding to the URL from which the image will be fetched. This URL can be changed dynamically.
///   - bufferSize: The size of the buffer in bytes used for incremental loading. The default value is 1KB.
///
/// The view displays a `EmptyView` while the image is being fetched. Once the image is fully loaded, it is displayed using an `Image` view.
///
/// Example usage:
/// ```
/// @State private var imageURL: URL? = URL(string: "https://via.placeholder.com/1000")
///
/// var body: some View {
///     IncrementalImage(url: $imageURL)
/// }
/// ```
public struct IncrementalImage: View {

    /// resource URL where you would like to fetch an image.
    ///
    /// Example:  https://via.placeholder.com/1000
    @Binding public var url: URL?

    /// unit byte size to perform incremental image
    ///
    /// example: `1 * 1024 ... 1KB`
    public let bufferSize: Int

    public let animation: Animation?

    @MainActor @State private var image: CGImage?

    public var body: some View {
        Group {
            if let image {
                Image(
                    image,
                    scale: 1,
                    label: Text(
                        String(describing: self)
                    )
                )
                .resizable()
                .aspectRatio(contentMode: .fit)
            } else {
                VStack {}
            }
        }
        .task {
            try! await Incremental.perform(
                at: url,
                bufferSize: bufferSize,
                onUpdate: { image in
                    if let animation {
                        withAnimation(animation) {
                            self.image = image
                        }
                    } else {
                        self.image = image
                    }
                }
            )
        }
    }

    public init(url: Binding<URL?>, bufferSize: Int = 1 * 1024, animation: Animation? = nil) {
        self._url = url
        self.bufferSize = bufferSize
        self.animation = animation
    }
}
