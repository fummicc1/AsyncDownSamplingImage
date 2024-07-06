//
//  Util.swift
//  Example
//
//  Created by Fumiya Tanaka on 2024/07/06.
//

import Foundation

enum Util {
    enum Grid {
        static let url = URL(string: "https://picsum.photos/1000/1000")
        static let bufferedImageSize = CGSize(width: 160, height: 160)
    }
    enum VStack {
        static let url = URL(string: "https://picsum.photos/800/600")
        static let bufferedImageHeight = 320.0
    }
}
