//
//  PoliticianRow.swift
//  democracyaction
//
//  Politician list row component
//

import SwiftUI

struct PoliticianRow: View {
    let person: Person
    
    var body: some View {
        HStack(spacing: 12) {
            // Photo on left
            FileImage(url: person.photo) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(.gray.opacity(0.2))
                    .overlay {
                        Image(systemName: "person.fill")
                            .foregroundStyle(.gray.opacity(0.5))
                    }
            }
            .frame(width: 50, height: 65)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            
            // Name on left
            Text(person.name)
                .font(.headline)
                .fontWeight(.medium)
            
            Spacer()
            
            // Party and Area on right
            VStack(alignment: .trailing, spacing: 2) {
                if let group = person.group {
                    Text(group.name)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                if let area = person.area {
                    Text(area)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let group = Group(no: 1, name: "더불어민주당")
    let person = Person(no: 1, name: "홍길동", nameCharacters: "홍길동", nameFirstCharacter: "홍", nameFirstCharacters: "ㅎㄱㄷ")
    person.area = "서울 강남구 갑"
    person.group = group
    
    return List {
        PoliticianRow(person: person)
        PoliticianRow(person: person)
    }
}
