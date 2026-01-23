//
//  ContactSection.swift
//  democracyaction
//
//  Reusable section container for grouping contact information
//

import SwiftUI

struct ContactSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section header
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(.primary)
                Text(title)
                    .font(.headline)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(UIColor.systemGray6))

            // Content
            content()
        }
    }
}
