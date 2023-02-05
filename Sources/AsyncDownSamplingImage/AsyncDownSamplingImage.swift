import SwiftUI

/// AsyncDownSamplingImage is a Image View that can perform downsampling and use less memory use than `AsyncImage`.
///
/// About generics type:
///
///     - Content: View which appears when state is Successful.
///     - Placeholder: View which appears when state is Loading.
///     - Fail: View which appears when state is Failed.
public struct AsyncDownSamplingImage<Content: View, Placeholder: View, Fail: View>: View {

    /// resource URL where you would like to fetch an image.
    ///
    /// Example: https://via.placeholder.com/1000
    @Binding public var url: URL?
    /// image size to perform downsampling.
    @Binding public var downsampleSize: CGSize

    /// View which appears when `status` is `Status.loaded`.
    public let content: (Image) -> Content
    /// View which appears when `status` is `Status.loading`.
    public let placeholder: (() -> Placeholder)?
    /// View which appears when `status` is `Status.failed`.
    public let fail: (Error) -> Fail

    @State private var status: Status = .idle
    @State private var loadingOpacity: CGFloat = 1.0

    /// Standard initializer
    ///
    /// - Note: You can also use simpler initializer.
    public init(
        url: Binding<URL?>,
        downsampleSize: Binding<CGSize>,
        content: @escaping (Image) -> Content,
        placeholder: @escaping () -> Placeholder,
        fail: @escaping (Error) -> Fail
    ) {
        self._url = url
        self._downsampleSize = downsampleSize
        self.content = content
        self.placeholder = placeholder
        self.fail = fail
        self.status = status

        if let url = self.url {
            startLoading(url: url)
        }
    }

    public var body: some View {
        Group {
            imageView
        }
        .onAppear {
            if case Status.idle = status, let url {
                startLoading(url: url)
            }
        }
        .onChange(of: url) { url in
            guard let url else {
                status = .idle
                return
            }
            startLoading(url: url)
        }
    }

    @ViewBuilder
    var imageView: some View {
        switch status {
        case .idle:
            loadingView
        case .loading:
            if let placeholder {
                placeholder()
            } else {
                loadingView
            }
        case .failed(let error):
            fail(error)
        case .loaded(let image):
            content(image)
        }
        EmptyView()
    }

    var loadingView: some View {
        Image(systemName: "plus") // any image is okay
            .resizable()
            .cornerRadius(2)
            .opacity(loadingOpacity)
            .animation(
                Animation.easeIn(duration: 0.5).repeatForever(autoreverses: true),
                value: loadingOpacity
            )
            .frame(
                width: downsampleSize.width,
                height: downsampleSize.height
            )
            .redacted(reason: .placeholder)
            .onAppear {
                loadingOpacity = abs(1.0 - loadingOpacity)
            }
    }

    func startLoading(url: URL) {
        status = .loading
        Task {
            do {
                let cgImage = try await DownSampling.perform(
                    at: url,
                    size: downsampleSize
                )
                let image = ImageType(cgImage: cgImage, size: downsampleSize)
                status = .loaded(Image(imageType: image))
            } catch {
                status = .failed(error)
            }
        }
    }
}

extension AsyncDownSamplingImage {
    enum Status {
        case idle
        case loading
        case failed(Error)
        case loaded(Image)
    }
}

// MARK: Simple initializer
extension AsyncDownSamplingImage {
    public init(
        url: URL?,
        downsampleSize: Binding<CGSize>,
        content: @escaping (Image) -> Content,
        fail: @escaping (Error) -> Fail
    ) where Placeholder == EmptyView {
        self._url = .constant(url)
        self._downsampleSize = downsampleSize
        self.content = content
        self.placeholder = nil
        self.fail = fail
        self.status = status
    }

    public init(
        url: URL?,
        downsampleSize: CGSize,
        content: @escaping (Image) -> Content,
        fail: @escaping (Error) -> Fail
    ) where Placeholder == EmptyView {
        self._url = .constant(url)
        self._downsampleSize = .constant(downsampleSize)
        self.content = content
        self.placeholder = nil
        self.fail = fail
        self.status = status
    }

    public init(
        url: URL?,
        downsampleSize: Binding<CGSize>,
        content: @escaping (Image) -> Content,
        placeholder: @escaping () -> Placeholder,
        fail: @escaping (Error) -> Fail
    ) where Placeholder == EmptyView {
        self._url = .constant(url)
        self._downsampleSize = downsampleSize
        self.content = content
        self.placeholder = placeholder
        self.fail = fail
        self.status = status
    }

    public init(
        url: URL?,
        downsampleSize: CGSize,
        content: @escaping (Image) -> Content,
        placeholder: @escaping () -> Placeholder,
        fail: @escaping (Error) -> Fail
    ) {
        self._url = .constant(url)
        self._downsampleSize = .constant(downsampleSize)
        self.content = content
        self.placeholder = placeholder
        self.fail = fail
        self.status = status
    }
}
