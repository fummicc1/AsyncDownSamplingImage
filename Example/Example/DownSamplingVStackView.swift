//
//  DownSamplingVStackView.swift
//  Example
//
//  Created by Fumiya Tanaka on 2024/07/06.
//

import SwiftUI
import AsyncDownSamplingImage

struct DownSamplingVStackView: View {
    
    @State private var url = Util.VStack.url
    @State private var height: Double = 240

    var body: some View {
        VStack {
            Text("AsyncDownSamplingImage")
            ScrollView {
                LazyVStack() {
                    ForEach(0..<1000, id: \.self) { _ in
                        AsyncDownSamplingImage(
                            url: url,
                            downsampleSize: .height(
                                Util.VStack.bufferedImageHeight
                            )
                        ) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: height)
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

#Preview {
    DownSamplingVStackView()
}
