//
//  DataUpdateIndicator.swift
//  democracyaction
//
//  Displays the last data update date to build trust
//

import SwiftUI

struct DataUpdateIndicator: View {
    private var updateDate: Date {
        DADefaults.DataUpdateDate
    }

    /// Check if the date is unset (Unix epoch = 1970-01-01)
    /// This happens for existing users who already have data before this feature was added
    private var isDateUnset: Bool {
        // Unix epoch is 1970-01-01 00:00:00 UTC
        // Check if date is within 1 day of epoch to be safe
        updateDate.timeIntervalSince1970 < 86400 // 86400 seconds = 1 day
    }

    private var daysSinceUpdate: Int {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day], from: updateDate, to: now)
        return components.day ?? 0
    }

    private var isStale: Bool {
        daysSinceUpdate > 180
    }

    private var dateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        let formattedDate = formatter.string(from: updateDate)

        if isStale {
            return "마지막 업데이트: \(formattedDate) (갱신 지연 중)"
        } else {
            return "마지막 업데이트: \(formattedDate)"
        }
    }

    var body: some View {
        // Hide indicator if date is unset (for existing users before this feature)
        // It will appear after the next data update
        if !isDateUnset {
            Text(dateText)
                .font(.caption)
                .foregroundStyle(isStale ? .orange : .secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 4)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        // Recent update (normal)
        DataUpdateIndicator()

        // Simulated stale date (180+ days old)
        // Note: This preview shows what it would look like
        Text("마지막 업데이트: 2024.07.01 (갱신 지연 중)")
            .font(.caption)
            .foregroundStyle(.orange)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 4)
    }
    .padding()
}
