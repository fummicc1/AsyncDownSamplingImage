//
//  ExampleApp.swift
//  Example
//
//  Created by Fumiya Tanaka on 2023/02/03.
//

import SwiftUI

@main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                VStack {
                    StandardView_Grid()
                    DownsampleGridView()
                }
                .tabItem {
                    Image(systemName: "1.circle")
                    Text("DownsamplingGrid")
                }
                .tag("DownsamplingGrid")
                VStack {
                    StandardView_VStack()
                    DownSamplingVStackView()
                }
                .tabItem {
                    Image(systemName: "2.circle")
                    Text("VStack")
                }
                .tag("VStack")
                VStack {
                    DownsampleGridView()
                    IncrementalGridView()
                }
                .tabItem {
                    Image(systemName: "3.circle")
                    Text("IncrementalGrid")
                }
                .tag("IncrementalGrid")
            }
        }
    }
}
