import SwiftUI
import AsyncDownSamplingImage

struct DownsampleGridView: View {

    @State private var url = Util.Grid.url
    @State private var showsDetail: Bool = false
    @State private var height: Double = 160

    var body: some View {
        VStack {
            Text("AsyncDownSamplingImage")
            ScrollView {
                LazyVGrid(columns: [.init(), .init()]) {
                    ForEach(0..<1000, id: \.self) { _ in
                        Button {
                            showsDetail.toggle()
                        } label: {
                            AsyncDownSamplingImage(
                                url: url,
                                downsampleSize: .height(height)
                            ) { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(
                                        height: height
                                    )
                            } onFail: { error in
                                Text("Error: \(error.localizedDescription)")
                            }
                        }

                    }
                }
            }
        }
        .padding()
        .sheet(isPresented: $showsDetail) {
            ImageDetailView(url: $url)
        }
    }
}

struct DownsampleContentView_Previews: PreviewProvider {
    static var previews: some View {
        DownsampleGridView()
    }
}
