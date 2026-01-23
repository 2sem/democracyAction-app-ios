//
//  PhoneContactRow.swift
//  democracyaction
//
//  Row component for displaying phone contact information
//

import SwiftUI

struct PhoneContactRow: View {
    let phone: Phone

    var body: some View {
        Button {
            callPhone()
        } label: {
            HStack {
                Image(systemName: "phone.fill")
                    .foregroundColor(.blue)
                    .frame(width: 30)

                VStack(alignment: .leading, spacing: 4) {
                    if let name = phone.name, !name.isEmpty {
                        Text(name)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    if let number = phone.number {
                        Text(number)
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                }

                Spacer()

                // Show SMS indicator if available
                if phone.sms {
                    Image(systemName: "message.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                }

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

    private func callPhone() {
        guard let number = phone.number else { return }
        let cleanNumber = number.replacingOccurrences(of: "-", with: "")
        guard let url = URL(string: "tel:\(cleanNumber)") else { return }
        UIApplication.shared.open(url)
    }
}
