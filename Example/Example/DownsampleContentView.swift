import SwiftUI
import AsyncDownSamplingImage

struct DownsampleContentView: View {

    @State private var url = URL(string: "https://via.placeholder.com/1000")
    @State private var size: CGSize = .init(width: 160, height: 160)

    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: [.init(), .init()]) {
                    ForEach(0..<1000, id: \.self) { _ in
                        AsyncDownSamplingImage(
                            url: url,
                            downsampleSize: size
                        ) { image in
                            image.resizable()
                                .frame(width: size.width, height: size.height)
                        } fail: { error in
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
        DownsampleContentView()
    }
}
