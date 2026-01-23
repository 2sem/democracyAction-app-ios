//
//  PersonProfileView.swift
//  democracyaction
//
//  Profile view for a person showing photo, name, party, area, job, and actions
//

import SwiftUI
import SwiftData

struct PersonProfileView: View {
    let person: Person
    @Environment(\.modelContext) private var modelContext

    private var isFavorite: Bool {
        person.favorite != nil
    }

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            // Photo with favorite button overlay
            ZStack(alignment: .bottomTrailing) {
                AsyncImage(url: person.photo) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .empty, .failure:
                        Image(systemName: "person.crop.rectangle")
                            .resizable()
                            .foregroundColor(.gray)
                            .padding(20)
                    @unknown default:
                        ProgressView()
                    }
                }
                .frame(width: 112, height: 150)
                .background(Color(UIColor.systemGray5))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Favorite button
                Button {
                    toggleFavorite()
                } label: {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .font(.system(size: 16))
                        .foregroundColor(isFavorite ? .yellow : .black)
                        .padding(8)
                        .background(.white)
                        .clipShape(Circle())
                }
                .offset(x: 16, y: 16)
            }

            VStack(alignment: .center, spacing: 8) {
                // Party/Group
                if let group = person.group {
                    Text(group.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                // Name
                Text(person.name)
                    .font(.headline)
                    .multilineTextAlignment(.center)

                // Area
                if let area = person.area {
                    Text(area)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.systemBackground))
    }

    // MARK: - Actions

    private func toggleFavorite() {
        if let favorite = person.favorite {
            // Remove favorite
            modelContext.delete(favorite)
            person.favorite = nil
        } else {
            // Add favorite
            let favorite = Favorite(isAlarmOn: false)
            favorite.person = person
            modelContext.insert(favorite)
        }

        try? modelContext.save()
    }
}
