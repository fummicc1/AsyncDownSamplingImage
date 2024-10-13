//
//  ImageDetailView.swift
//  Example
//
//  Created by Fumiya Tanaka on 2024/08/03.
//

import Foundation
import AsyncDownSamplingImage
import SwiftUI

public struct ImageDetailView: View {

    @MainActor @Binding private var url: URL?

    public var body: some View {
        IncrementalImage(
            url: $url
        )
    }

    init(url: Binding<URL?>) {
        self._url = url
    }
}
