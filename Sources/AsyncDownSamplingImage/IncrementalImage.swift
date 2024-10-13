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

    @State private var lastUpdateTime: Date = Date()
    @State private var pendingUpdate: CGImage?
    @State private var isUpdating: Bool = false

    // 20ms
    let timing = 0.02

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
                onUpdate: { newImage in
                    throttledUpdate(newImage)
                }
            )
        }
    }

    private func throttledUpdate(_ newImage: CGImage) {
        let currentTime = Date()
        if currentTime.timeIntervalSince(lastUpdateTime) >= timing {
            performUpdate(newImage)
            lastUpdateTime = currentTime
        } else {
            pendingUpdate = newImage
            if !isUpdating {
                isUpdating = true
                DispatchQueue.main.asyncAfter(deadline: .now() + timing) {
                    if let pendingImage = self.pendingUpdate {
                        self.performUpdate(pendingImage)
                    }
                    self.isUpdating = false
                    self.pendingUpdate = nil
                }
            }
        }
    }

    private func performUpdate(_ newImage: CGImage) {
        if let animation {
            withAnimation(animation) {
                self.image = newImage
            }
        } else {
            self.image = newImage
        }
    }

    private func throttle(_ block: @escaping () -> Void) {
        let currentTime = Date()
        if currentTime.timeIntervalSince(lastUpdateTime) >= timing {
            block()
            lastUpdateTime = currentTime
        }
    }

    public init(url: Binding<URL?>, bufferSize: Int = 1 * 1024, animation: Animation? = nil) {
        self._url = url
        self.bufferSize = bufferSize
        self.animation = animation
    }
}
