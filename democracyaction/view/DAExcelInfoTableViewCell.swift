//
//  DAExcelTableViewCell.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 6. 8..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit
import Material

class DAExcelTableViewCell: UITableViewCell, FABMenuDelegate {

    var info : DAExcelPersonInfo!{
        didSet{
            self.updateInfo();
        }
    };
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var areaLabel: UILabel!
    @IBOutlet weak var callButton: FABButton!
    //@IBOutlet weak
    var msgMenu: FABMenu!
    var msgButton : FABButton!;
    //@IBOutlet weak
    var searchMenu: FABMenu!
    var searchButton : FABButton!;
    @IBOutlet weak var buttonsStack: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        if !selected{
            //self.msgMenu?.close();
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        guard self.msgMenu?.fabMenuItems.count ?? 0 > 1 || self.searchMenu?.fabMenuItems.count ?? 0 > 1 else{
            return super.hitTest(point, with: event);
        }
        
        var value : UIView?;
        var targetPoint = point;
        
        if self.msgMenu != nil && self.msgMenu.fabMenuItems.count > 1 && self.msgMenu.isOpened{
            value = self.msgMenu.hitTestItems(self.convert(point, to: self.msgMenu), with: event);
        }else if self.searchMenu != nil && self.searchMenu.fabMenuItems.count > 1 && self.searchMenu.isOpened{
            value = self.searchMenu.hitTestItems(self.convert(point, to: self.searchMenu), with: event);
        }
        
        if value == nil{
            value = super.hitTest(point, with: event);
        }
        
        return value;
    }
    
    enum menuType : Int{
        case email = 0
        case sms
        case twitter
        case facebook
        case web
        case blog
        case youtube
    }
    
    var preparedMenuItems : [menuType : FABMenuItem] = [:];
    func updateInfo(){
        self.nameLabel.text = self.info.name;
        self.areaLabel.text = !self.info.area.isEmpty ? self.info.area : self.info.title;
        var msgMenuItems : [FABMenuItem] = [];
        
        if !self.info.email.isEmpty {
            var menuItem : FABMenuItem! = self.preparedMenuItems[menuType.email];
            if menuItem == nil{
                menuItem = FABMenuItem();
                //menuItem.title = "email";
                menuItem.fabButton.image = UIImage(named: "icon_email.png")?.withRenderingMode(.alwaysTemplate);
                menuItem.fabButton.tintColor = .white;
                menuItem.fabButton.pulseColor = .white;
                menuItem.fabButton.backgroundColor = DATheme.fabButtonBackgroundColor;
                menuItem.fabButton.addTarget(self, action: #selector(self.onEmail(_:)), for: .touchUpInside);
                self.preparedMenuItems[menuType.email] = menuItem;
            }
            msgMenuItems.append(menuItem);
        }
        
        if !self.info.sms.isEmpty {
            var menuItem : FABMenuItem! = preparedMenuItems[menuType.sms];
            if menuItem == nil{
                menuItem = FABMenuItem();
                //menuItem.title = "sms";
                menuItem.fabButton.image = UIImage(named: "icon_sms.png")?.withRenderingMode(.alwaysTemplate);
                menuItem.fabButton.tintColor = .white;
                menuItem.fabButton.pulseColor = .white;
                menuItem.fabButton.backgroundColor = DATheme.fabButtonBackgroundColor;
                menuItem.fabButton.addTarget(self, action: #selector(self.onSms(_:)), for: .touchUpInside);
                preparedMenuItems[menuType.sms] = menuItem;
            }
            msgMenuItems.append(menuItem);
        }
        
        if !self.info.twitter.isEmpty {
            var menuItem : FABMenuItem! = preparedMenuItems[menuType.twitter];
            if menuItem == nil{
                menuItem = FABMenuItem();
                //menuItem.title = "twitter";
                
                menuItem.fabButton.image = UIImage(named: "icon_twitter.png")?.withRenderingMode(.alwaysTemplate);
                menuItem.fabButton.tintColor = DATheme.twitterButtonTintColor;
                menuItem.fabButton.pulseColor = DATheme.twitterButtonTintColor;
                menuItem.fabButton.backgroundColor = DATheme.twitterButtonBackgroundColor;
                menuItem.fabButton.addTarget(self, action: #selector(self.onTwitter(_:)), for: .touchUpInside);
                preparedMenuItems[menuType.twitter] = menuItem;
            }
            msgMenuItems.append(menuItem);
        }
        
        if !self.info.facebook.isEmpty {
            var menuItem : FABMenuItem! = preparedMenuItems[menuType.facebook];
            if menuItem == nil{
                menuItem = FABMenuItem();
                //menuItem.title = "facebook";
                
                menuItem.fabButton.image = UIImage(named: "icon_facebook.png")?.withRenderingMode(.alwaysTemplate);
                menuItem.fabButton.tintColor = DATheme.facebookButtonTintColor;
                menuItem.fabButton.pulseColor = DATheme.facebookButtonTintColor;
                menuItem.fabButton.backgroundColor = DATheme.facebookButtonBackgroundColor;
                menuItem.fabButton.addTarget(self, action: #selector(self.onFacebook(_:)), for: .touchUpInside);
                preparedMenuItems[menuType.facebook] = menuItem;
            }
            msgMenuItems.append(menuItem);
        }
        
        //self.msgMenu.open();
        //print("check msgMenu. subViews[\(self.buttonsStack.subviews)]");
        /*if self.msgMenu != nil && !self.buttonsStack.subviews.contains(self.msgMenu){
            //self.buttonsStack.removeArrangedSubview(self.msgMenu);
            //self.msgMenu.removeFromSuperview();
            self.msgMenu = nil;
        }else{
            //self.msgMenu = nil;
        }*/
        
        if self.msgMenu == nil{
            self.msgMenu = FABMenu();
            self.msgMenu.fabMenuDirection = .left;
            self.msgMenu.fabMenuItemSize = self.callButton.frame.size;
            
            self.msgMenu.clipsToBounds = false;
            self.msgMenu.delegate = self;
        }
        
        if msgMenuItems.count > 1{
            msgMenuItems.insert(self.callButton.cloneAsMenu(), at: 0);
        }
        
        self.msgMenu.fabMenuItems = msgMenuItems;
        
        if self.msgButton != nil{
            self.buttonsStack.removeArrangedSubview(self.msgButton);
            self.msgButton.removeFromSuperview();
            self.msgButton = nil;
        }
        
        if msgMenuItems.count <= 1{
            //self.msgMenu.removeConstraints(self.msgMenu.constraints);
            self.msgMenu.fabButton = nil;
            self.buttonsStack.removeArrangedSubview(self.msgMenu);
            self.msgMenu.removeFromSuperview();
            //self.msgMenu = nil;
            //print("remove msg menu. cell[\(self)]");
            if msgMenuItems.count == 1{
                self.msgButton = msgMenuItems[0].fabButton.clone();
                self.buttonsStack.insertArrangedSubview(self.msgButton, at: 1);
                self.msgButton.heightAnchor.constraint(equalTo: self.callButton.heightAnchor).isActive = true;
                self.msgButton.widthAnchor.constraint(equalTo: self.callButton.widthAnchor).isActive = true;
            }
        }else{
            self.msgMenu.fabButton = FABButton();
            self.msgMenu.fabButton?.image = UIImage(named: "icon_msg.png")?.withRenderingMode(.alwaysTemplate);
            self.msgMenu.fabButton?.tintColor = .white;
            self.msgMenu.fabButton?.backgroundColor = DATheme.fabMenuBackgroundColor;
            self.msgMenu.fabButton?.pulseColor = .white;
            
            self.buttonsStack.insertArrangedSubview(self.msgMenu, at: 1);
            //print("add msg menu. cell[\(self)]");
            //self.addSubview(self.msgMenu);
            self.msgMenu.heightAnchor.constraint(equalTo: self.callButton.heightAnchor).isActive = true;
            self.msgMenu.widthAnchor.constraint(equalTo: self.callButton.widthAnchor).isActive = true;
            self.msgMenu.prepare();
            self.msgMenu.interimSpace.add(-6);

            //self.msgMenu.closeWithAnimation();
        }
                
        var searchMenuItems : [FABMenuItem] = [];
        
        if !self.info.web.isEmpty {
            var menuItem : FABMenuItem! = preparedMenuItems[menuType.web];
            if menuItem == nil{
                menuItem = FABMenuItem();
                //menuItem.title = "web";
                
                menuItem.fabButton.image = UIImage(named: "icon_homepage.png")?.withRenderingMode(.alwaysTemplate);
                menuItem.fabButton.tintColor = .white;
                menuItem.fabButton.pulseColor = .white;
                menuItem.fabButton.backgroundColor = DATheme.fabButtonBackgroundColor;
                menuItem.fabButton.addTarget(self, action: #selector(self.onWeb(_:)), for: .touchUpInside);
                preparedMenuItems[menuType.web] = menuItem;
            }
            searchMenuItems.append(menuItem);
        }
        
        if !self.info.blog.isEmpty {
            var menuItem : FABMenuItem! = preparedMenuItems[menuType.blog];
            if menuItem == nil{
                menuItem = FABMenuItem();
                //menuItem.title = "blog";
                
                menuItem.fabButton.image = UIImage(named: "icon_blog.png")?.withRenderingMode(.alwaysTemplate);
                menuItem.fabButton.tintColor = .white;
                menuItem.fabButton.pulseColor = .white;
                menuItem.fabButton.backgroundColor = DATheme.fabButtonBackgroundColor;
                menuItem.fabButton.addTarget(self, action: #selector(self.onBlog(_:)), for: .touchUpInside);
                preparedMenuItems[menuType.blog] = menuItem;
            }
            
            searchMenuItems.append(menuItem);
        }
        
        if !self.info.youtube.isEmpty {
            var menuItem : FABMenuItem! = preparedMenuItems[menuType.youtube];
            if menuItem == nil{
                menuItem = FABMenuItem();
                //menuItem.title = "youTube";
                
                menuItem.fabButton.image = UIImage(named: "icon_youtube.png")?.withRenderingMode(.alwaysTemplate);
                menuItem.fabButton.tintColor = DATheme.youtubeButtonTintColor;
                menuItem.fabButton.pulseColor = DATheme.youtubeButtonTintColor;
                menuItem.fabButton.backgroundColor = DATheme.youtubeButtonBackgroundColor;
                menuItem.fabButton.addTarget(self, action: #selector(self.onYoutube(_:)), for: .touchUpInside);
                preparedMenuItems[menuType.youtube] = menuItem;
            }
            searchMenuItems.append(menuItem);
        }
        
        /*if self.searchMenu != nil {
            //!self.buttonsStack.subviews.contains(self.searchMenu)
            self.buttonsStack.removeArrangedSubview(self.searchMenu);
            self.searchMenu.removeFromSuperview();
            self.searchMenu = nil;
        }*/
        
        if self.searchMenu == nil{
            self.searchMenu = FABMenu();
            self.searchMenu.fabMenuDirection = .left;
            self.searchMenu.fabMenuItemSize = self.callButton.frame.size;
            
            self.searchMenu.clipsToBounds = false;
            self.searchMenu.delegate = self;
        }
        
        if searchMenuItems.count > 1{
            searchMenuItems.insert(self.callButton.cloneAsMenu(), at: 0);
            var msgMenu : FABMenuItem! = self.msgMenu?.fabButton != nil
                ? self.msgMenu.fabButton?.cloneAsMenu() : self.msgButton?.cloneAsMenu();
            if msgMenu != nil{
                searchMenuItems.insert(msgMenu, at: 0);
                msgMenu.fabButton.addTarget(self, action: #selector(self.onOpenMsgMenu(_:)), for: .touchUpInside);
            }
        }
        self.searchMenu.fabMenuItems = searchMenuItems;
        
        if self.searchButton != nil{
            self.buttonsStack.removeArrangedSubview(self.searchButton);
            self.searchButton.removeFromSuperview();
            self.searchButton = nil;
        }
        
        if searchMenuItems.count <= 1{
            //self.msgMenu.removeConstraints(self.msgMenu.constraints);
            self.searchMenu.fabButton = nil;
            self.buttonsStack.removeArrangedSubview(self.searchMenu);
            self.searchMenu.removeFromSuperview();
            self.searchMenu = nil;
            if searchMenuItems.count == 1{
                self.searchButton = searchMenuItems[0].fabButton.clone();
                self.buttonsStack.insertArrangedSubview(self.searchButton, at: 2)
                self.searchButton.heightAnchor.constraint(equalTo: self.callButton.heightAnchor).isActive = true;
                self.searchButton.widthAnchor.constraint(equalTo: self.callButton.widthAnchor).isActive = true;
            }
        }else{
            self.searchMenu.fabButton = FABButton();
            self.searchMenu.fabButton?.image = UIImage(named: "icon_web.png")?.withRenderingMode(.alwaysTemplate);
            self.searchMenu.fabButton?.tintColor = .white;
            self.searchMenu.fabButton?.backgroundColor = DATheme.fabMenuBackgroundColor;
            self.searchMenu.fabButton?.pulseColor = .white;

            self.buttonsStack.insertArrangedSubview(self.searchMenu, at: 2)
            //self.addSubview(self.msgMenu);
            self.searchMenu.heightAnchor.constraint(equalTo: self.callButton.heightAnchor).isActive = true;
            self.searchMenu.widthAnchor.constraint(equalTo: self.callButton.widthAnchor).isActive = true;
            self.searchMenu.prepare();
            self.searchMenu.interimSpace.add(-6);
            
            //self.searchMenu.closeWithAnimation();
        }
        
        //self.layoutSubviews();
    }
    
    func closeMenus(){
        if self.msgMenu?.isOpened ?? false{
            self.msgMenu.closeWithAnimation();
        }
        
        if self.searchMenu?.isOpened ?? false{
            self.searchMenu.closeWithAnimation();
        }
    }
    
    func onOpenMsgMenu(_ button : UIButton){
        print("open msg menu \(self.info.phones)");
        self.msgMenu.open();
        self.searchMenu.close();
    }
    
    @IBAction func onCall(_ button : UIButton){
        print("call \(self.info.phones)");
        self.closeMenus();
        
        if self.info.phones.count == 1{
            UIApplication.shared.openTel(self.info.phones.first?.number ?? "");
        }else{
            var actions : [UIAlertAction] = [];
            for phone in self.info.phones{
                actions.append(UIAlertAction(title: phone.title, style: .default, handler: { (act) in
                    UIApplication.shared.openTel(phone.number);
                }));
            }
            actions.append(UIAlertAction(title: "취소", style: .cancel, handler: { (act) in
                
            }));
            
            UIApplication.shared.keyWindow?.rootViewController?.showAlert(title: "통화할 연락처를 선택하세요", msg: "", actions: actions, style: .alert);
        }
    }
    
    func onSms(_ button : UIButton){
        print("send sms \(self.info.sms)");
        self.closeMenus();
        UIApplication.shared.openSms(self.info.sms);
    }
    
    func onEmail(_ button : UIButton){
        print("send email \(self.info.email)");
        self.closeMenus();
        UIApplication.shared.openEmail(self.info.email);
    }
    
    func onTwitter(_ button : UIButton){
        print("send twitter \(self.info.twitter)");
        self.closeMenus();
        UIApplication.shared.openTwitter(self.info.twitter);
    }

    func onFacebook(_ button : UIButton){
        print("send facebook \(self.info.facebook)");
        self.closeMenus();
        UIApplication.shared.openFacebook(self.info.facebook);
    }
    
    func onKakao(_ button : UIButton){
        print("send kakao \(self.info.kakao)");
        self.closeMenus();
    }
    
    func onYoutube(_ button : UIButton){
        print("go youtube \(self.info.youtube)");
        self.closeMenus();
        UIApplication.shared.openWeb(self.info.youtube);
    }
    
    func onWeb(_ button : UIButton){
        print("go web \(self.info.web)");
        UIApplication.shared.openWeb(self.info.web);
        self.closeMenus();
    }
    
    func onBlog(_ button : UIButton){
        print("go blog \(self.info.blog)");
        UIApplication.shared.openWeb(self.info.blog);
        self.closeMenus();
    }
    
    // MARK: FABMenuDelegate
    func fabMenuWillOpen(fabMenu: FABMenu) {
        fabMenu.fabButton?.animate(Motion.rotation(angle: -45));
        if self.msgMenu == fabMenu{
            self.searchMenu?.closeWithAnimation();
        }else{
            self.msgMenu?.closeWithAnimation();
        }
    }
    
    func fabMenuWillClose(fabMenu: FABMenu) {
        fabMenu.fabButton?.animate(Motion.rotation(angle: 0));
    }
}

/*extension FABMenu{
    func closeWithAnimation(){
        self.close();
        self.fabButton?.animate(Motion.rotation(angle: 0));
    }
}*/
