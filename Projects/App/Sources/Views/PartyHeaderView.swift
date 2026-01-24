//
//  PartyHeaderView.swift
//  democracyaction
//
//  Party/Group header view with call/SNS/search buttons
//

import SwiftUI
import UIKit

struct PartyHeaderView: View {
    let group: Group
    @State private var safariURL: URL?

    private var hasMessageTools: Bool {
        group.messages?.isEmpty == false
    }

    var body: some View {
        HStack(spacing: 12) {
            // Party name
            Text(group.name)
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 8) {
                // Call button
                if let phones = group.phones, !phones.isEmpty {
                    Button {
                        handleCall(phones: phones)
                    } label: {
                        Image(systemName: "phone.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                }

                // Social media menu
                if hasMessageTools {
                    Menu {
                        if let twitter = group.findMessageTool(MessageTool.EntityNames.twitter) {
                            Button {
                                openTwitter(account: twitter.account ?? "")
                            } label: {
                                Label("트위터", systemImage: "bird")
                            }
                        }

                        if let facebook = group.findMessageTool(MessageTool.EntityNames.facebook) {
                            Button {
                                openFacebook(account: facebook.account ?? "")
                            } label: {
                                Label("페이스북", systemImage: "person.2")
                            }
                        }

                        if let kakao = group.findMessageTool(MessageTool.EntityNames.kakao) {
                            Button {
                                openKakao(account: kakao.account ?? "")
                            } label: {
                                Label("카카오스토리", systemImage: "message")
                            }
                        }

                        if let instagram = group.findMessageTool(MessageTool.EntityNames.instagram) {
                            Button {
                                openInstagram(account: instagram.account ?? "")
                            } label: {
                                Label("인스타그램", systemImage: "camera")
                            }
                        }
                    } label: {
                        Image(systemName: "at")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Color(red: 0.30, green: 0.69, blue: 0.31)) // Green
                            .clipShape(Circle())
                    }
                }

                // Web/search menu
                Menu {
                    if let homepage = group.findWebUrl(Web.EntityNames.homepage), let url = homepage.url {
                        Button {
                            openURL(url)
                        } label: {
                            Label("홈페이지", systemImage: "house")
                        }
                    }

                    if let blog = group.findWebUrl(Web.EntityNames.blog), let url = blog.url {
                        Button {
                            openURL(url)
                        } label: {
                            Label("블로그", systemImage: "text.alignleft")
                        }
                    }

                    if let youtube = group.findWebUrl(Web.EntityNames.youtube), let url = youtube.url {
                        Button {
                            openURL(url)
                        } label: {
                            Label("유튜브", systemImage: "play.rectangle")
                        }
                    }

                    Divider()

                    Button {
                        showSearchOptions()
                    } label: {
                        Label("검색", systemImage: "magnifyingglass")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(Color(red: 0.47, green: 0.56, blue: 0.61))
                        .clipShape(Circle())
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(UIColor.systemGray6))
        .sheet(item: $safariURL) { url in
            SafariView(url: url)
                .ignoresSafeArea()
        }
    }
    
    // MARK: - Actions
    
    private func handleCall(phones: [Phone]) {
        let sortedPhones = phones.sorted { ($0.name ?? "") < ($1.name ?? "") }
        
        guard let firstPhone = sortedPhones.first else { return }
        
        if sortedPhones.count == 1 {
            // Direct call
            if let number = firstPhone.number, let url = URL(string: "tel:\(number.replacingOccurrences(of: "-", with: ""))") {
                UIApplication.shared.open(url)
            }
        } else {
            // Show action sheet
            let alert = UIAlertController(title: "\(group.name)에 전화", message: "통화할 연락처를 선택하세요", preferredStyle: .alert)
            
            for phone in sortedPhones {
                alert.addAction(UIAlertAction(title: phone.name, style: .default) { _ in
                    if let number = phone.number, let url = URL(string: "tel:\(number.replacingOccurrences(of: "-", with: ""))") {
                        UIApplication.shared.open(url)
                    }
                })
            }
            
            alert.addAction(UIAlertAction(title: "취소", style: .cancel))
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(alert, animated: true)
            }
        }
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
    
    private func showSearchOptions() {
        let alert = UIAlertController(title: "\(group.name) 검색", message: "검색할 포털사이트를 선택하세요", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "다음에서 검색", style: .default) { _ in
            searchWith(engine: "daum")
        })
        
        alert.addAction(UIAlertAction(title: "구글에서 검색", style: .default) { _ in
            searchWith(engine: "google")
        })
        
        alert.addAction(UIAlertAction(title: "네이버에서 검색", style: .default) { _ in
            searchWith(engine: "naver")
        })
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(alert, animated: true)
        }
    }
    
    private func searchWith(engine: String) {
        let keyword = group.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? group.name

        let urlString: String
        switch engine {
        case "daum":
            urlString = "https://search.daum.net/search?q=\(keyword)"
        case "google":
            urlString = "https://www.google.com/search?q=\(keyword)"
        case "naver":
            urlString = "https://search.naver.com/search.naver?query=\(keyword)"
        default:
            return
        }

        if let url = URL(string: urlString) {
            safariURL = url
        }
    }
}

// MARK: - Group Extensions

extension Group {
    func findMessageTool(_ name: String) -> MessageTool? {
        messages?.first(where: { $0.name == name })
    }
    
    func findWebUrl(_ name: String) -> Web? {
        webs?.first(where: { $0.name == name })
    }
}
