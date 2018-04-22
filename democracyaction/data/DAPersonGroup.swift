//
//  DAPersonGroup.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 6. 26..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation

class DAPersonGroup : NSObject{
    var id : Int = 0;
    var name : String = "";
    var detail : String = "";
    var sponsor : Int = 0;
    var persons : [DAPersonInfo] = [];
    var phones : [DAPhoneInfo] = [];
    var messages : [DAMessageToolInfo] = [];
    var webs : [DAWebInfo] = [];
    
    var groupTwitter : DAMessageToolInfo?{
        get{
            return self.findMessageTool(DAMessageToolInfo.EntityNames.twitter);
        }
    }
    
    var groupFacebook : DAMessageToolInfo?{
        get{
            return self.findMessageTool(DAMessageToolInfo.EntityNames.facebook);
        }
    }
    
    var groupKakao : DAMessageToolInfo?{
        get{
            return self.findMessageTool(DAMessageToolInfo.EntityNames.kakao);
        }
    }
    
    var groupInstagram : DAMessageToolInfo?{
        get{
            return self.findMessageTool(DAMessageToolInfo.EntityNames.instagram);
        }
    }
    
    var groupYoutube : DAWebInfo?{
        get{
            return self.findWebUrl(DAWebInfo.EntityNames.youtube);
        }
    }
    
    var groupBlog : DAWebInfo?{
        get{
            return self.findWebUrl(DAWebInfo.EntityNames.blog);
        }
    }
    
    var groupHomepage : DAWebInfo?{
        get{
            return self.findWebUrl(DAWebInfo.EntityNames.homepage);
        }
    }
    
    var groupCafe : DAWebInfo?{
        get{
            return self.findWebUrl(DAWebInfo.EntityNames.cafe);
        }
    }
    
    var groupCyworld : DAWebInfo?{
        get{
            return self.findWebUrl(DAWebInfo.EntityNames.cyworld);
        }
    }
    
    func findMessageTool(_ name : String) -> DAMessageToolInfo? {
        return self.messages.first(where: { (tool) -> Bool in
            return tool.name == name;
        })
    }
    
    func findWebUrl(_ name : String) -> DAWebInfo? {
        return webs.first(where: { (web) -> Bool in
            return web.name == name;
        })
    }
}
