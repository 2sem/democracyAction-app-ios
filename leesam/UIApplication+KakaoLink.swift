//
//  UIApplication+KakaoLink.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 7. 7..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation
import KakaoLink

extension UIApplication{
    func shareByKakao(){
        var kakaoLink = KLKLinkObject();
        var kakaoContent = KLKContentObject(title: "문자행동", imageURL: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Newsstand127/v4/d9/d4/9d/d9d49d1d-e062-4aa1-ca16-30c6a8023cf1/Icon-76@2x.png.png/0x0ss.png")!, link: kakaoLink);
        kakaoContent.imageWidth = 120;
        kakaoContent.imageHeight = 120; //160
        kakaoContent.desc = "내 손안의 민주주의";
        
        var kakaoTemplate = KLKFeedTemplate.init(builderBlock: { (kakaoBuilder) in
            kakaoBuilder.content = kakaoContent;
            //kakaoBuilder.buttons?.add(kakaoWebButton);
            //link can't have more than two buttons
            // - content's url, button1 url, button2 url
            /*kakaoBuilder.addButton(KLKButtonObject(builderBlock: { (buttonBuilder) in
                buttonBuilder.link = KLKLinkObject(builderBlock: { (linkBuilder) in
                    linkBuilder.webURL = URL(string: "https://itunes.apple.com/us/app/id1243863489?mt=8");
                    linkBuilder.mobileWebURL = URL(string: "https://itunes.apple.com/us/app/id1243863489?mt=8");
                })
                buttonBuilder.title = "애플 앱스토어";
            }));*/
            
            /*kakaoBuilder.addButton(KLKButtonObject(builderBlock: { (buttonBuilder) in
                buttonBuilder.link = KLKLinkObject(builderBlock: { (linkBuilder) in
                    linkBuilder.webURL = URL(string: "https://play.google.com/store/apps/details?id=kr.co.ncredif.directdemocracy");
                    linkBuilder.mobileWebURL = URL(string: "https://play.google.com/store/apps/details?id=kr.co.ncredif.directdemocracy");
                    //linkBuilder.mobileWebURL = URL(string: "www.daum.net");
                })
                buttonBuilder.title = "구글플레이";
            }));*/
            kakaoBuilder.addButton(KLKButtonObject(builderBlock: { (buttonBuilder) in
                buttonBuilder.link = KLKLinkObject(builderBlock: { (linkBuilder) in
                    linkBuilder.webURL = URL(string: "https://youtu.be/0n0oQkLX_4s");
                    //linkBuilder.webURL = URL(string: "https://www.youtube.com/watch?v=0n0oQkLX_4s");

                    linkBuilder.mobileWebURL = linkBuilder.webURL;
                })
                buttonBuilder.title = "언론보도";
            }));
            
            kakaoBuilder.addButton(KLKButtonObject(builderBlock: { (buttonBuilder) in
                buttonBuilder.link = KLKLinkObject(builderBlock: { (linkBuilder) in
                    //linkBuilder.webURL = URL(string: "https://itunes.apple.com/us/app/id1243863489?mt=8");
                    //linkBuilder.mobileWebURL = URL(string: "https://itunes.apple.com/us/app/id1243863489?mt=8");
                })
                buttonBuilder.title = "다운로드";
            }));
            
            //https://youtu.be/0n0oQkLX_4s
        })
        
        KLKTalkLinkCenter.shared().sendDefault(with: kakaoTemplate, success: { (warn, args) in
            print("kakao warn[\(warn)] args[\(args)]")
        }, failure: { (error) in
            print("kakao error[\(error)]")
        })
    }
}
