//
//  PersonDetailScreen.swift
//  democracyaction
//
//  Person detail screen showing profile, contact info, social media, and websites
//

import SwiftUI
import SwiftData
import UIKit

struct PersonDetailScreen: View {
    let person: Person
    @Environment(\.modelContext) private var modelContext
    @State private var safariURL: URL?

    private var hasMessages: Bool {
        person.email != nil || person.personSms != nil
    }

    private var hasMessageTools: Bool {
        person.messages?.isEmpty == false
    }

    private var hasWebs: Bool {
        person.webs?.isEmpty == false
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    // Profile section
                    PersonProfileView(person: person)

                // Contact sections
                if !person.personPhones.isEmpty {
                    ContactSection(title: "전화", icon: "phone.fill") {
                        ForEach(person.personPhones) { phone in
                            PhoneContactRow(phone: phone)
                        }
                    }
                }

                if hasMessages {
                    ContactSection(title: "메세지", icon: "envelope.fill") {
                        if let email = person.email {
                            MessageContactRow(
                                type: .email,
                                label: email,
                                action: { sendEmail(to: email) }
                            )
                        }

                        if let sms = person.personSms {
                            MessageContactRow(
                                type: .sms,
                                label: sms.name ?? "문자메세지",
                                action: { sendSMS(to: sms) }
                            )
                        }
                    }
                }

                if hasMessageTools {
                    ContactSection(title: "소셜네트워크", icon: "at") {
                        if let twitter = person.findMessageTool(MessageTool.EntityNames.twitter) {
                            SocialMediaContactRow(
                                platform: .twitter,
                                account: twitter.account ?? "",
                                action: { openTwitter(account: twitter.account ?? "") }
                            )
                        }

                        if let facebook = person.findMessageTool(MessageTool.EntityNames.facebook) {
                            SocialMediaContactRow(
                                platform: .facebook,
                                account: facebook.account ?? "",
                                action: { openFacebook(account: facebook.account ?? "") }
                            )
                        }

                        if let kakao = person.findMessageTool(MessageTool.EntityNames.kakao) {
                            SocialMediaContactRow(
                                platform: .kakao,
                                account: kakao.account ?? "",
                                action: { openKakao(account: kakao.account ?? "") }
                            )
                        }

                        if let instagram = person.findMessageTool(MessageTool.EntityNames.instagram) {
                            SocialMediaContactRow(
                                platform: .instagram,
                                account: instagram.account ?? "",
                                action: { openInstagram(account: instagram.account ?? "") }
                            )
                        }
                    }
                }

                if hasWebs {
                    ContactSection(title: "사이트", icon: "globe") {
                        if let youtube = person.findWebUrl(Web.EntityNames.youtube) {
                            WebContactRow(
                                type: .youtube,
                                url: youtube.url ?? "",
                                action: { openURL(youtube.url ?? "") }
                            )
                        }

                        if let homepage = person.findWebUrl(Web.EntityNames.homepage) {
                            WebContactRow(
                                type: .homepage,
                                url: homepage.url ?? "",
                                action: { openURL(homepage.url ?? "") }
                            )
                        }

                        if let blog = person.findWebUrl(Web.EntityNames.blog) {
                            WebContactRow(
                                type: .blog,
                                url: blog.url ?? "",
                                action: { openURL(blog.url ?? "") }
                            )
                        }

                        if let cafe = person.findWebUrl(Web.EntityNames.cafe) {
                            WebContactRow(
                                type: .cafe,
                                url: cafe.url ?? "",
                                action: { openURL(cafe.url ?? "") }
                            )
                        }
                    }
                }
            }

        }
            .contentMargins(.bottom, 8)
        }
        .navigationTitle("\(person.name) 의원")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    sharePerson()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(item: $safariURL) { url in
            SafariView(url: url)
                .ignoresSafeArea()
        }
    }

    // MARK: - Actions

    private func sendEmail(to email: String) {
        guard let url = URL(string: "mailto:\(email)") else { return }
        UIApplication.shared.open(url)
    }

    private func sendSMS(to phone: Phone) {
        guard let number = phone.number else { return }
        let cleanNumber = number.replacingOccurrences(of: "-", with: "")
        guard let url = URL(string: "sms:\(cleanNumber)") else { return }
        UIApplication.shared.open(url)
    }

    private func openTwitter(account: String) {
        guard !account.isEmpty,
              let appURL = URL(string: "twitter://user?screen_name=\(account)"),
              let webURL = URL(string: "https://twitter.com/\(account)") else { return }
        openWithAppFallback(appURL: appURL, webURL: webURL)
    }

    private func openFacebook(account: String) {
        guard !account.isEmpty,
              let appURL = URL(string: "fb://profile/\(account)"),
              let webURL = URL(string: "https://www.facebook.com/\(account)") else { return }
        openWithAppFallback(appURL: appURL, webURL: webURL)
    }

    private func openKakao(account: String) {
        guard !account.isEmpty,
              let appURL = URL(string: "storylink://profile/\(account)"),
              let webURL = URL(string: "https://story.kakao.com/\(account)") else { return }
        openWithAppFallback(appURL: appURL, webURL: webURL)
    }

    private func openInstagram(account: String) {
        guard !account.isEmpty else { return }
        let username = account.hasPrefix("@") ? String(account.dropFirst()) : account
        guard let appURL = URL(string: "instagram://user?username=\(username)"),
              let webURL = URL(string: "https://instagram.com/_u/\(username)") else { return }
        openWithAppFallback(appURL: appURL, webURL: webURL)
    }

    private func openURL(_ urlString: String) {
        guard !urlString.isEmpty, let url = URL(string: urlString) else { return }
        safariURL = url
    }
    
    private func openWithAppFallback(appURL: URL, webURL: URL) {
        UIApplication.shared.open(appURL) { success in
            if !success {
                self.safariURL = webURL
            }
        }
    }

    private func sharePerson() {
        // Build share text
        var text = "\(person.name)"

        if let group = person.group {
            text += " (\(group.name))"
        }

        if let area = person.area {
            text += "\n\(area)"
        }

        if let job = person.job, !job.isEmpty {
            text += " - \(job)"
        }

        // Add contact info
        if let email = person.email {
            text += "\n이메일: \(email)"
        }

        if let phone = person.personPhones.first {
            text += "\n전화: \(phone.number ?? "")"
        }

        // Present share sheet
        let activityVC = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}
