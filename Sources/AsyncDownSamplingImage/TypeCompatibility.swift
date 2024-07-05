#if os(iOS)
import UIKit
typealias ImageType = UIImage
#elseif os(macOS)
import AppKit
typealias ImageType = NSImage
#endif

import SwiftUI

extension Image {
    init(imageType: ImageType) {
        #if os(iOS)
        self = Image(uiImage: imageType)
        #elseif os(macOS)
        self = Image(nsImage: imageType)
        #endif
    }
}
