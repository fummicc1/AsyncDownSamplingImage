import SwiftUI
import AsyncDownSamplingImage

struct DownsampleGridView: View {

    @State private var url = URL(string: "https://picsum.photos/1000")
    @State private var size: CGSize = .init(width: 160, height: 160)

    var body: some View {
        VStack {
            Text("AsyncDownSamplingImage")
            ScrollView {
                LazyVGrid(columns: [.init(), .init()]) {
                    ForEach(0..<1000, id: \.self) { _ in
                        AsyncDownSamplingImage(
                            url: url,
                            downsampleSize: .size(size)
                        ) { image in
                            image.resizable()
                                .frame(width: size.width, height: size.height)
                        } onFail: { error in
                            Text("Error: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
        .padding()
    }
}

struct DownsampleContentView_Previews: PreviewProvider {
    static var previews: some View {
        DownsampleGridView()
    }
}
