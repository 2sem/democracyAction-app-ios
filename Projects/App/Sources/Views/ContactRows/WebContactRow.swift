//
//  WebContactRow.swift
//  democracyaction
//
//  Row component for displaying website contact information
//

import SwiftUI

enum WebType {
    case youtube
    case homepage
    case blog
    case cafe

    var icon: String {
        switch self {
        case .youtube: return "play.rectangle"
        case .homepage: return "house"
        case .blog: return "text.alignleft"
        case .cafe: return "cup.and.saucer"
        }
    }

    var title: String {
        switch self {
        case .youtube: return "유튜브"
        case .homepage: return "홈페이지"
        case .blog: return "블로그"
        case .cafe: return "카페"
        }
    }

    var color: Color {
        switch self {
        case .youtube: return .red
        case .homepage: return .blue
        case .blog: return .green
        case .cafe: return .orange
        }
    }
}

struct WebContactRow: View {
    let type: WebType
    let url: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: type.icon)
                    .foregroundColor(type.color)
                    .frame(width: 30)

                VStack(alignment: .leading, spacing: 4) {
                    Text(type.title)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text(url)
                        .font(.caption)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(UIColor.systemBackground))
        }
        .buttonStyle(PlainButtonStyle())

        Divider()
            .padding(.leading, 56)
    }
}
