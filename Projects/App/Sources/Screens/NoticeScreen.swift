//
//  NoticeScreen.swift
//  democracyaction
//
//  Created by SwiftUI Migration
//  Migrated from: DANoticeViewController
//

import SwiftUI

struct NoticeScreen: View {
    let text: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Text(text)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationTitle("Notice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NoticeScreen(text: "This is a sample notice text.\n\nIt can have multiple lines and paragraphs.\n\nThis replaces the UIKit DANoticeViewController.")
}
