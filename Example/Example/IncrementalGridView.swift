//
//  IncrementalGridView.swift
//  Example
//
//  Created by Fumiya Tanaka on 2024/08/03.
//

import SwiftUI
import AsyncDownSamplingImage

struct IncrementalGridView: View {
    @State private var url = Util.Grid.url
    @State private var showsDetail: Bool = false
    @State private var size: CGSize = .init(width: 160, height: 160)

    var body: some View {
        VStack {
            Text("Image")
            ScrollView {
                LazyVGrid(columns: [.init(), .init()]) {
                    ForEach(0..<1000, id: \.self) { _ in
                        Button {
                            showsDetail.toggle()
                        } label: {
                            IncrementalImage(
                                url: $url,
                                bufferSize: 1024, // 1KB
                                animation: .easeIn
                            )
                                .frame(
                                    width: size.width,
                                    height: size.height
                                )
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

#Preview {
    IncrementalGridView()
}
