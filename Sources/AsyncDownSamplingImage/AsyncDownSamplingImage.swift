import SwiftUI

public struct AsyncDownSamplingImage<Content: View, Placeholder: View, Fail: View>: View {

    @Binding public var url: URL?

    public let content: (Image) -> Content
    public let placeholder: (() -> Placeholder)?
    public let fail: (Error) -> Fail

    @State private var status: Status = .idle

    public init(
        url: Binding<URL?> = .constant(nil),
        content: @escaping (Image) -> Content,
        placeholder: (() -> Placeholder)? = nil,
        fail: @escaping (Error) -> Fail
    ) {
        self._url = url
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
            if case Status.idle = status {
                status = .loading
            }
        }
    }

    @ViewBuilder
    var imageView: some View {
        switch status {
        case .idle:
            EmptyView()
        case .loading:
            if let placeholder {
                placeholder()
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        case .fail(let error):
            fail(error)
        case .loaded(let data):
            if let image = UIImage(data: data) {
                content(Image(uiImage: image))
            }
        }
        EmptyView()
    }
}

enum Status {
    case idle
    case loading
    case fail(Error)
    case loaded(Data)
}
