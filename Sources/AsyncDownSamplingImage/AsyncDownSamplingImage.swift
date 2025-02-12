import SwiftUI


private enum LoadingOpacityEdge {
    case upperBound
    case lowerBound

    var value: Double {
        switch self {
        case .upperBound:
            return 1
        case .lowerBound:
            return 0.3
        }
    }

    mutating func toggle() {
        switch self {
        case .upperBound:
            self = .lowerBound
        case .lowerBound:
            self = .upperBound
        }
    }
}

public enum DownSamplingSize {
    case size(CGSize, scale: Double = 1)
    case width(Double, scale: Double = 1)
    case height(Double, scale: Double = 1)

    public var width: Double? {
        switch self {
        case .size(let cGSize, _):
            cGSize.width
        case .width(let double, _):
            double
        case .height:
            nil
        }
    }

    public var height: Double? {
        switch self {
        case .size(let cGSize, _):
            cGSize.height
        case .width:
            nil
        case .height(let double, _):
            double
        }
    }

    var size: (width: CGFloat?, height: CGFloat?) {
        let width: CGFloat? = if let width {
            width
        } else {
            nil
        }
        let height: CGFloat? = if let height {
            height
        } else {
            nil
        }
        return (width, height)
    }
}

/// AsyncDownSamplingImage is a ImageView that can perform downsampling and use less memory use than `AsyncImage`.
///
/// Generic Types:
/// - `Content`: The view displayed when the image is successfully loaded.
/// - `Placeholder`: The view displayed while the image is loading.
/// - `Fail`: The view displayed when the image fails to load.
public struct AsyncDownSamplingImage<Content: View, Placeholder: View, Fail: View>: View {

    /// resource URL where you would like to fetch an image.
    ///
    /// Example: https://via.placeholder.com/1000
    @Binding public var url: URL?
    /// image size to perform downsampling.
    @Binding public var downsampleSize: DownSamplingSize

    /// View which appears when `status` is `Status.loaded`.
    public let content: (Image) -> Content
    /// View which appears when `status` is `Status.loading`.
    public let onLoad: (() -> Placeholder)?
    /// View which appears when `status` is `Status.failed`.
    public let onFail: (any Error) -> Fail

    @State private var status: Status = .idle
    @State private var loadingOpacity: LoadingOpacityEdge = .upperBound

    /// A initializer that requires exact downsampling size.
    ///
    /// - Parameters:
    ///     - url: a resource url which should be downsampled.
    ///     - downSamplingSize: final image buffer size after downsampling.
    ///         choose from ``DownSamplingSize.width``, ``DownSamplingSize.height`` or ``DownSamplingSize.size``
    ///     - content: UI builder which takes ``Image`` as an argument after image is fetched and downsampled.
    ///     - onLoad: UI builder used when ``Image`` is loading or in downsampling phase.
    ///     - onFail: UI builder used when something wrong happened in downsampling phase.
    public init(
        url: Binding<URL?>,
        downsampleSize: Binding<DownSamplingSize>,
        content: @escaping (Image) -> Content,
        onLoad: @escaping () -> Placeholder,
        onFail: @escaping (any Error) -> Fail
    ) {
        self._url = url
        self._downsampleSize = downsampleSize
        self.content = content
        self.onLoad = onLoad
        self.onFail = onFail
        self.status = status

        if let url = self.url {
            startLoading(url: url)
        }
    }

    public var body: some View {
        imageView
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
            if let onLoad {
                onLoad()
            } else {
                loadingView
            }
        case .failed(let error):
            onFail(error)
        case .loaded(let image), .reloading(let image):
            content(image)
        }
    }

    var loadingView: some View {
        return Image(systemName: "plus") // any image is okay
            .resizable()
            .cornerRadius(2)
            .opacity(loadingOpacity.value)
            .animation(
                Animation.easeInOut(duration: 0.7).repeatForever(autoreverses: true),
                value: loadingOpacity
            )
            .frame(
                // If both width and height are not provided, treat loading image as square.
                width: downsampleSize.size.width ?? downsampleSize.size.height,
                height: downsampleSize.size.height ?? downsampleSize.size.width
            )
            .redacted(reason: .placeholder)
            .onAppear {
                loadingOpacity.toggle()
            }
    }

    func startLoading(url: URL) {
        if case Status.loaded(let image) = status {
            status = .reloading(image)
        } else {
            status = .loading
        }
        Task.detached {
            do {
                let cgImage = try await DownSampling.perform(
                    at: url,
                    size: downsampleSize
                )
            #if os(macOS)
                let aspectRatio = Double(cgImage.height) / Double(cgImage.width)
                let downsampleSize = await self.downsampleSize
                let width = downsampleSize.width ?? downsampleSize.height! / aspectRatio
                let height = downsampleSize.height ?? downsampleSize.width! * aspectRatio
                let image = ImageType(
                    cgImage: cgImage,
                    size: CGSize(
                        width: width,
                        height: height
                    )
                )
#elseif os(iOS)
                let image = ImageType(
                    cgImage: cgImage
                )
                #endif
                await MainActor.run {
                    status = .loaded(Image(imageType: image))
                }
            } catch {
                await MainActor.run {
                    status = .failed(error)
                }
            }
        }
    }
}

extension AsyncDownSamplingImage {
    enum Status {
        case idle
        case loading
        case reloading(Image)
        case failed(Error)
        case loaded(Image)
    }
}

// MARK: Simple initializer
extension AsyncDownSamplingImage {
    public init(
        url: URL?,
        downsampleSize: Binding<DownSamplingSize>,
        content: @escaping (Image) -> Content,
        onFail: @escaping (any Error) -> Fail
    ) where Placeholder == EmptyView {
        self._url = .constant(url)
        self._downsampleSize = downsampleSize
        self.content = content
        self.onLoad = nil
        self.onFail = onFail
        self.status = status
    }

    public init(
        url: URL?,
        downsampleSize: DownSamplingSize,
        content: @escaping (Image) -> Content,
        onFail: @escaping (any Error) -> Fail
    ) where Placeholder == EmptyView {
        self._url = .constant(url)
        self._downsampleSize = .constant(downsampleSize)
        self.content = content
        self.onLoad = nil
        self.onFail = onFail
        self.status = status
    }

    public init(
        url: URL?,
        downsampleSize: Binding<DownSamplingSize>,
        content: @escaping (Image) -> Content,
        placeholder: @escaping () -> Placeholder,
        onFail: @escaping (any Error) -> Fail
    ) where Placeholder == EmptyView {
        self._url = .constant(url)
        self._downsampleSize = downsampleSize
        self.content = content
        self.onLoad = placeholder
        self.onFail = onFail
        self.status = status
    }

    public init(
        url: URL?,
        downsampleSize: DownSamplingSize,
        content: @escaping (Image) -> Content,
        onLoad: @escaping () -> Placeholder,
        onFail: @escaping (any Error) -> Fail
    ) {
        self._url = .constant(url)
        self._downsampleSize = .constant(downsampleSize)
        self.content = content
        self.onLoad = onLoad
        self.onFail = onFail
        self.status = status
    }
}
