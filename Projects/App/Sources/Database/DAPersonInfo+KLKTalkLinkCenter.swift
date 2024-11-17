//
//  DAPersonInfo+KLKTalkLinkCenter.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 7. 4..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit
import KakaoSDKShare
import KakaoSDKTemplate

extension DAPersonInfo{
    func shareByKakao(){
        let kakaoLink = Link(webUrl: URL(string: self.personHomepage?.url ?? ""),
                             iosExecutionParams: ["id": "\(self.no)",
                                                  "name": self.name?.trim() ?? "",
                                                  "area": self.area?.trim() ?? "",
                                                  "mobile": (self.personSms?.number?.any ?? false) ? self.personSms?.number?.trim() ?? "" : ""]);
        
        let kakaoContent = Content.init(title: "\(self.job ?? "") \(self.name ?? "")",
                                        imageUrl: URL.init(string: "http://www.assembly.go.kr/photo/\(self.assembly).jpg")!,
                                        imageWidth: 120,
                                        imageHeight: 160,
                                        description: self.area,
                                        link: kakaoLink)
        
        var searchUrl = URLComponents(string: "http://search.daum.net/search");
        searchUrl?.queryItems = [URLQueryItem(name: "q", value: "\(self.job ?? "") \(self.name ?? "")")];
        
        let kakaoTemplate = FeedTemplate.init(content: kakaoContent,
                                              buttons: [.init(title: "검색",
                                                              link: .init(webUrl: searchUrl?.url)),
                                                        .init(title: "앱으로 열기", link: kakaoLink)])
        
        ShareApi.shared.shareDefault(templatable: kakaoTemplate) { result, error in
            guard let result = result else {
                print("kakao error[\(error.debugDescription )]")
                return
            }
            
            UIApplication.shared.open(result.url)
            print("kakao warn[\(result.warningMsg?.debugDescription ?? "")] args[\(result.argumentMsg?.debugDescription ?? "")]")
        }
    }
}
