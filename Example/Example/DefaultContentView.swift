import SwiftUI

struct DefaultContentView: View {

    @State private var url = URL(string: "https://via.placeholder.com/1000")
    @State private var size: CGSize = .init(width: 160, height: 160)

    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: [.init(), .init()]) {
                    ForEach(0..<1000, id: \.self) { _ in
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView().progressViewStyle(.circular)
                            case .failure(let error):
                                Text("Error: \(error.localizedDescription)")
                            case .success(let image):
                                image.resizable()
                                    .frame(width: size.width, height: size.height)
                            @unknown default:
                                fatalError()
                            }
                        }
                    }
                }
            }
        }
        .padding()
    }
}

struct DefaultContentView_Previews: PreviewProvider {
    static var previews: some View {
        DefaultContentView()
    }
}
