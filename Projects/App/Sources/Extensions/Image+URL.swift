//
//  Image+URL.swift
//  democracyaction
//
//  SwiftUI view for loading images from file URLs
//

import SwiftUI

/// A view that synchronously loads and displays an image from a file URL
///
/// Similar to AsyncImage but optimized for local file URLs with synchronous loading.
/// This avoids task cancellation issues when views are destroyed/recreated.
struct FileImage<Content: View, Placeholder: View>: View {
    let url: URL?
    let content: (Image) -> Content
    let placeholder: () -> Placeholder

    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }

    var body: some View {
        if let url = url,
           let uiImage = UIImage(contentsOfFile: url.path) {
            content(Image(uiImage: uiImage))
        } else {
            placeholder()
        }
    }
}
