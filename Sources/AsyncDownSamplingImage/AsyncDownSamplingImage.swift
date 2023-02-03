import SwiftUI

public struct AsyncDownSamplingImage<Content: View, Placeholder: View, Fail: View>: View {

    @Binding public var url: URL?
    @Binding public var downsampleSize: CGSize

    public let content: (Image) -> Content
    public let placeholder: (() -> Placeholder)?
    public let fail: (Error) -> Fail

    @State private var status: Status = .idle

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
            VStack{}
                .redacted(reason: .placeholder)
        case .loading:
            if let placeholder {
                placeholder()
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        case .fail(let error):
            fail(error)
        case .loaded(let image):
            content(image)
        }
        EmptyView()
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
