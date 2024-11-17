//
//  UIApplication+KakaoLink.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 7. 7..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit
import KakaoSDKShare
import KakaoSDKTemplate

extension UIApplication{
    func _shareByKakao(){
        let kakaoLink = Link();
        let kakaoContent = Content.init(title: "문자행동",
                                        imageUrl: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Newsstand127/v4/d9/d4/9d/d9d49d1d-e062-4aa1-ca16-30c6a8023cf1/Icon-76@2x.png.png/0x0ss.png")!,
                                        imageWidth: 120,
                                        imageHeight: 120,
                                        description: "내 손안의 민주주의",
                                        link: kakaoLink)
        
        let kakaoTemplate = FeedTemplate.init(content: kakaoContent,
                                              buttons: [.init(title: "언론보도",
                                                              link: .init(webUrl: URL(string: "https://youtu.be/0n0oQkLX_4s"))),
                                                        .init(title: "다운로드",
                                                              link: .init())
                                              ])
        
        ShareApi.shared.shareDefault(templatable: kakaoTemplate) { result, error in
            guard let result = result else {
                print("kakao error[\(error.debugDescription )]")
                return
            }
            
            UIApplication.shared.open(result.url)
            print("kakao warn[\(result.warningMsg?.debugDescription ?? "")] args[\(result.argumentMsg?.debugDescription ?? "")]")
        }
    }
    
    func shareByKakao(){
        let kakaoLink = Link();
        let kakaoContent = Content.init(title: UIApplication.shared.displayName ?? "",
                                        imageUrl: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Purple128/v4/8d/f9/04/8df90400-4feb-c7ec-bb2e-b52261a7d5f1/mzl.hyjsxhof.png/150x150bb.jpg")!,
                                        imageWidth: 120,
                                        imageHeight: 120,
                                        description: "해외, 국내 여행시 외국인을 만나면 당황하셨나요?",
                                        link: kakaoLink)
        
        let khanURL = URL(string: "http://news.khan.co.kr/kh_news/khan_art_view.html?artid=201706231651011&code=940100")!
        let haniUrl = URL(string: "http://www.hani.co.kr/arti/society/society_general/799996.html")!
        let sbsUrl = URL(string: "https://www.youtube.com/watch?v=0n0oQkLX_4s")!
        let reviewUrl = URL(string: "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=\(UIApplication.shared.appId)&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8")
        
        let kakaoTemplate = ListTemplate.init(headerTitle: "문자행동 - 내 손안의 민주주의",
                                              headerLink: .init(webUrl: khanURL),
                                              contents: [.init(title: "‘문자행동’ 어플 개발자 인터뷰···“민주주의 발전에 한손 보탤 수 있길”",
                                                               imageUrl: URL(string: "http://img.khan.co.kr/news/2017/06/23/l_2017062301003119000246131.jpg")!,
                                                               description: "경향신문",
                                                               link: .init(webUrl: khanURL,
                                                                           mobileWebUrl: khanURL)),
                                                         .init(title: "국회의원 연락처 한 곳에…‘문자행동’ 어플까지 나왔네",
                                                                          imageUrl: URL(string: "http://img.hani.co.kr/imgdb/resize/2017/0623/00501745_20170623.JPG")!,
                                                                          description: "한겨례",
                                                                          link: .init(webUrl: haniUrl,
                                                                                      mobileWebUrl: haniUrl)),
                                                         .init(title: "\"문자 폭탄\" VS \"문자 행동\" 논란 속에…'의견 앱' 등장",
                                                                          imageUrl: URL(string: "https://www.youtube.com/watch?v=0n0oQkLX_4s")!,
                                                                          description: "한겨례",
                                                                          link: .init(webUrl: sbsUrl,
                                                                                      mobileWebUrl: sbsUrl))],
                                              buttons: [.init(title: "응원하기", link: .init(webUrl: reviewUrl, mobileWebUrl: reviewUrl)),
                                                        .init(title: "앱 다운로드", link: .init())])
        
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
