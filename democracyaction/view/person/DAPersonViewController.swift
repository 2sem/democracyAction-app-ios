//
//  DAAssemblyViewController.swift
//  democracyaction
//
//  Created by 영준 이 on 2019. 2. 13..
//  Copyright © 2019년 leesam. All rights reserved.
//

import UIKit
import Material

class DAPersonViewController: UIViewController {

    class Cell_Ids{
        static let contact = "contact";
    }
    
    var info : DAPersonInfo!;
    var contactGroups : [DAContactGroup] = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func loadContacts(){
        guard info === self.info else{
            return;
        }
        
        self.contactGroups = [];
        
        self.loadPhones();
    }
    
    func loadPhones(){
        let group = DAContactGroup("전화");
        let phones = info.personPhones.filter{ $0.number != nil }.sorted(by: { (left, right) -> Bool in
            return left.name! < right.name!;
        });
        phones.forEach{ group.append(DAContact.init(type: .phone, name: $0.name ?? "", value: $0.number ?? "")) }
        
        guard group.contacts.any else{
            return;
        }
        
        self.contactGroups.append(group);
    }
    
    func loadMessages(){
        let group = DAContactGroup("메세지");
        let email = info.personEmail.trim();
        if email.any {
            group.append(DAContact.init(type: .email, name: "이메일", value: email));
        }
        
        if let phone = info.personSms?.number, phone.any{
            group.append(DAContact.init(type: .sms, name: "문자", value: email));
        }
        
        guard group.contacts.any else{
            return;
        }
        
        self.contactGroups.append(group);
    }
    
    func loadSocialNetworks(){
        let group = DAContactGroup("소셜네트워크");
        
        if let value = info.personTwitter?.account, value.any{
            group.append(DAContact.init(type: .email, name: "트위터", value: value));
        }
        
        if let value = info.personFacebook?.account, value.any {
            group.append(DAContact.init(type: .sms, name: "페이스북", value: value));
        }
        
        if let value = info.personKakao?.account, value.any {
            group.append(DAContact.init(type: .sms, name: "카카오스토리", value: value));
        }
        
        if let value = info.personInstagram?.account, value.any {
            group.append(DAContact.init(type: .sms, name: "인스타그램", value: value));
        }
        
        guard group.contacts.any else{
            return;
        }
        
        self.contactGroups.append(group);
    }
    
    func loadSites(){
        let group = DAContactGroup("사이트");

        if let value = info.personYoutube?.url, value.any{
            group.append(DAContact.init(type: .sms, name: "홈페이지", value: value));
        }
        
        if let value = info.personHomepage?.url, value.any{
            group.append(DAContact.init(type: .sms, name: "홈페이지", value: value));
        }
        
        if let value = info.personBlog?.url, value.any{
            group.append(DAContact.init(type: .sms, name: "블로그", value: value));
        }
        
        if let value = info.personCafe?.url, value.any{
            group.append(DAContact.init(type: .sms, name: "카페", value: value));
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension DAPersonViewController : UITableViewDataSource{
    
}
