import SwiftUI

public struct AsyncDownSamplingImage<Content: View, Placeholder: View, Fail: View>: View {

    @Binding public var url: URL?
    @Binding public var downsampleSize: CGSize
    @Environment(\.redactionReasons) var reasons

    public let content: (Image) -> Content
    public let placeholder: (() -> Placeholder)?
    public let fail: (Error) -> Fail

    @State private var status: Status = .idle
    @State private var loadingOpacity: CGFloat = 1.0

    public init(
        url: Binding<URL?>,
        downsampleSize: Binding<CGSize>,
        content: @escaping (Image) -> Content,
        placeholder: (() -> Placeholder)?,
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
        case .fail(let error):
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
                status = .fail(error)
            }
        }
    }
}

extension AsyncDownSamplingImage {
    enum Status {
        case idle
        case loading
        case fail(Error)
        case loaded(Image)
    }
}

extension AsyncDownSamplingImage where Placeholder == EmptyView {
    public init(
        url: Binding<URL?>,
        downsampleSize: Binding<CGSize>,
        content: @escaping (Image) -> Content,
        fail: @escaping (Error) -> Fail
    ) {
        self._url = url
        self._downsampleSize = downsampleSize
        self.content = content
        self.placeholder = nil
        self.fail = fail
        self.status = status
    }

    public init(
        url: Binding<URL?>,
        downsampleSize: CGSize,
        content: @escaping (Image) -> Content,
        fail: @escaping (Error) -> Fail
    ) {
        self._url = url
        self._downsampleSize = .constant(downsampleSize)
        self.content = content
        self.placeholder = nil
        self.fail = fail
        self.status = status
    }
}
