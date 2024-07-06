import SwiftUI

struct StandardView_Grid: View {

    @State private var url = Util.Grid.url
    @State private var size: CGSize = .init(width: 160, height: 160)

    var body: some View {
        VStack {
            Text("Default AsyncImage")
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
                                    .aspectRatio(contentMode: .fit)
                                    .frame(
                                        width: size.width,
                                        height: size.height
                                    )
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

#Preview {
    StandardView_Grid()
}
