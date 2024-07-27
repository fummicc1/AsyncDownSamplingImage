//
//  StandardView+VStack.swift
//  Example
//
//  Created by Fumiya Tanaka on 2024/07/06.
//

import SwiftUI

struct StandardView_VStack: View {

    @State private var url = Util.VStack.url
    @State private var height: Double = 240

    var body: some View {
        VStack {
            Text("Default AsyncImage")
            ScrollView {
                LazyVStack() {
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
                                    .frame(height: height)
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
    StandardView_VStack()
}
