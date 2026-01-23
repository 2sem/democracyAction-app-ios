//
//  SocialMediaContactRow.swift
//  democracyaction
//
//  Row component for displaying social media contact information
//

import SwiftUI

enum SocialMediaPlatform {
    case twitter
    case facebook
    case kakao
    case instagram

    var icon: String {
        switch self {
        case .twitter: return "bird"
        case .facebook: return "person.2"
        case .kakao: return "message"
        case .instagram: return "camera"
        }
    }

    var title: String {
        switch self {
        case .twitter: return "트위터"
        case .facebook: return "페이스북"
        case .kakao: return "카카오스토리"
        case .instagram: return "인스타그램"
        }
    }

    var color: Color {
        switch self {
        case .twitter: return .blue
        case .facebook: return Color(red: 0.23, green: 0.35, blue: 0.60)
        case .kakao: return Color(red: 0.98, green: 0.85, blue: 0.20)
        case .instagram: return Color(red: 0.83, green: 0.31, blue: 0.55)
        }
    }
}

struct SocialMediaContactRow: View {
    let platform: SocialMediaPlatform
    let account: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: platform.icon)
                    .foregroundColor(platform.color)
                    .frame(width: 30)

                VStack(alignment: .leading, spacing: 4) {
                    Text(platform.title)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text(account)
                        .font(.body)
                        .foregroundColor(.primary)
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
