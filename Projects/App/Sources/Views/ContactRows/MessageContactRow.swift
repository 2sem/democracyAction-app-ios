//
//  MessageContactRow.swift
//  democracyaction
//
//  Row component for displaying email and SMS contact information
//

import SwiftUI

enum MessageContactType {
    case email
    case sms

    var icon: String {
        switch self {
        case .email: return "envelope.fill"
        case .sms: return "message.fill"
        }
    }

    var title: String {
        switch self {
        case .email: return "이메일"
        case .sms: return "문자메세지"
        }
    }
}

struct MessageContactRow: View {
    let type: MessageContactType
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: type.icon)
                    .foregroundColor(type == .email ? .blue : .green)
                    .frame(width: 30)

                VStack(alignment: .leading, spacing: 4) {
                    Text(type.title)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text(label)
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
