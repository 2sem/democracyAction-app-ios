//
//  DAPersonInfo+KLKTalkLinkCenter.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 7. 4..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation
import KakaoLink

extension DAPersonInfo{
    func shareByKakao(){
        var kakaoLink = KLKLinkObject();
        kakaoLink.webURL = URL(string: self.personHomepage?.url ?? "");
        kakaoLink.iosExecutionParams = "id=\(self.no)&name=\(self.name?.trim() ?? "")&area=\(self.area?.trim() ?? "")";
        if self.personSms?.number?.any ?? false{
            kakaoLink.iosExecutionParams = kakaoLink.iosExecutionParams! + "&mobile=\(self.personSms?.number?.trim() ?? "")";
        }
        kakaoLink.iosExecutionParams = kakaoLink.iosExecutionParams!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed);
        kakaoLink.androidExecutionParams = kakaoLink.iosExecutionParams;
        
        var kakaoContent = KLKContentObject(title: "\(self.job ?? "") \(self.name ?? "")", imageURL: URL.init(string: "http://www.assembly.go.kr/photo/\(self.assembly).jpg")!, link: kakaoLink);
        kakaoContent.imageWidth = 120;
        kakaoContent.imageHeight = 160;
        kakaoContent.desc = self.area;
        
        var kakaoTemplate = KLKFeedTemplate.init(builderBlock: { (kakaoBuilder) in
            kakaoBuilder.content = kakaoContent;
            //kakaoBuilder.buttons?.add(kakaoWebButton);
            //link can't have more than two buttons
            // - content's url, button1 url, button2 url
            kakaoBuilder.addButton(KLKButtonObject(builderBlock: { (buttonBuilder) in
                buttonBuilder.link = KLKLinkObject(builderBlock: { (linkBuilder) in
                    if let webUrl = self.personHomepage?.url, !webUrl.isEmpty{
                        var searchUrl = URLComponents(string: "http://search.daum.net/search");
                        searchUrl?.queryItems = [URLQueryItem(name: "q", value: "\(self.job ?? "") \(self.name ?? "")")];
                        linkBuilder.webURL = searchUrl?.url;
                        //kakaoLink.webURL = URL(string:"http://www.assembly.go.kr/assm/memPop/memPopup.do?dept_cd=9770941")!;
                        linkBuilder.mobileWebURL = searchUrl?.url;
                        //kakaoLink.mobileWebURL = URL(string:"http://www.assembly.go.kr/assm/memPop/memPopup.do?dept_cd=9770941")!;
                    }
                })
                buttonBuilder.title = "검색";
            }));
            
            /*kakaoBuilder.addButton(KLKButtonObject(builderBlock: { (buttonBuilder) in
                buttonBuilder.link = KLKLinkObject(builderBlock: { (linkBuilder) in
                    if let webUrl = self.personHomepage?.url, !webUrl.isEmpty{
                        linkBuilder.webURL = URL(string: self.personHomepage?.url ?? "");
                        //kakaoLink.webURL = URL(string:"http://www.assembly.go.kr/assm/memPop/memPopup.do?dept_cd=9770941")!;
                        linkBuilder.mobileWebURL = URL(string: self.personHomepage?.url ?? "");
                        //kakaoLink.mobileWebURL = URL(string:"http://www.assembly.go.kr/assm/memPop/memPopup.do?dept_cd=9770941")!;
                    }
                })
                buttonBuilder.title = "홈페이지";
            }));*/
            
            kakaoBuilder.addButton(KLKButtonObject(builderBlock: { (buttonBuilder) in
                buttonBuilder.link = KLKLinkObject(builderBlock: { (linkBuilder) in
                    linkBuilder.webURL = kakaoLink.webURL;
                    linkBuilder.iosExecutionParams = kakaoLink.iosExecutionParams;
                    linkBuilder.androidExecutionParams = kakaoLink.androidExecutionParams;
                })
                buttonBuilder.title = "앱으로 열기";
            }));
            /*kakaoBuilder.addButton(KLKButtonObject(builderBlock: { (buttonBuilder) in
             buttonBuilder.link = KLKLinkObject(builderBlock: { (linkBuilder) in
             if let webUrl = cell.info.personHomepage?.url, !webUrl.isEmpty{
             linkBuilder.webURL = URL(string: cell.info.personHomepage?.url ?? "");
             //kakaoLink.webURL = URL(string:"http://www.assembly.go.kr/assm/memPop/memPopup.do?dept_cd=9770941")!;
             linkBuilder.mobileWebURL = URL(string: cell.info.personHomepage?.url ?? "");
             //kakaoLink.mobileWebURL = URL(string:"http://www.assembly.go.kr/assm/memPop/memPopup.do?dept_cd=9770941")!;
             }
             })
             buttonBuilder.title = "앱에서 보기";
             }));*/
        })
        
        KLKTalkLinkCenter.shared().sendDefault(with: kakaoTemplate, success: { (warn, args) in
            
        }, failure: { (error) in
            
        })
    }
}
