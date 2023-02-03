//
//  ContentView.swift
//  Example
//
//  Created by Fumiya Tanaka on 2023/02/03.
//

import SwiftUI
import AsyncDownSamplingImage

struct ContentView: View {

    @State private var url = URL(string: "https://via.placeholder.com/1000")
    @State private var size: CGSize = .init(width: 160, height: 160)

    var body: some View {
        TabView {
            Group {
                firstTab
//                secondTab
            }
            .padding()
        }
    }

    var firstTab: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: [.init(), .init()]) {
                    ForEach(0..<1000, id: \.self) { _ in
                        AsyncDownSamplingImage(
                            url: $url,
                            downsampleSize: size
                        ) { image in
                            image
                                .resizable()
                                .frame(width: size.width, height: size.height)
                        } fail: { error in
                            Text("Error: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
        .tabItem {
            Text("AsyncDownSamplingImage")
        }
    }

    var secondTab: some View {
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
                                image
                                    .resizable()
                                    .frame(width: size.width, height: size.height)
                            @unknown default:
                                fatalError()
                            }
                        }
                    }
                }
            }
        }
        .tabItem {
            Text("AsyncImage")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
