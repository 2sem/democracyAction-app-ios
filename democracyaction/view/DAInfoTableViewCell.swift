//
//  DAInfoTableViewCell.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 6. 8..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit
import Material
import SwipeCellKit
import ContactsUI
//import JSQWebViewController
import ProgressWebViewController
import LSExtensions
import SDWebImage

class DAInfoTableViewCell:SwipeTableViewCell, FABMenuDelegate, CNContactPickerDelegate {

    var info : DAPersonInfo!{
        didSet{
            self.updateInfo();
        }
    };
    
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var groupLabel: UILabel!
    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var areaLabel: UILabel!
    @IBOutlet weak var callButton: FABButton!
    
    //@IBOutlet weak
    var msgMenu: FABMenu!
    var msgButton : FABButton!;
    //@IBOutlet weak
    var searchMenu: FABMenu!
    var searchButton : FABButton!;
    
    var sponseButton : FABButton!;
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
    
    enum menuType : Int{
        case email = 0
        case sms
        case twitter
        case facebook
        case web
        case blog
        case youtube
        case search
    }
    
    var preparedMenuItems : [menuType : FABMenuItem] = [:];
    
    var overflowedMenus : [FABMenuItem] = [];
    /*var needToShowMenuActions : Bool{
        get{
            var value = false;
            
            guard self.msgMenu != nil || self.searchMenu != nil else{
                return value;
            }
            
            guard self.msgMenu?.isOpened ?? false || self.searchMenu?.isOpened ?? false else{
                return value;
            }
            
            if self.msgMenu != nil{
                var fabButton : FABButton! = self.msgMenu.fabMenuItems.first?.fabButton;
                

            }else if self.searchMenu != nil{
                
            }
            
            return true;
        }
    }*/
    var swipeActions : [SwipeAction]{
        var values = [SwipeAction]();
        
        for menu in self.overflowedMenus{
            let action = SwipeAction(style: .default, title: nil, handler: { (act, indexPath) in
                //UIApplication.shared.sendAction(menu.fabButton.action, to: <#T##Any?#>, from: <#T##Any?#>, for: <#T##UIEvent?#>)
                //UIApplication.shared.sendEvent(UIControlEvents.touchUpInside);
                menu.fabButton.sendActions(for: .touchUpInside);
            })
            action.backgroundColor = menu.fabButton.backgroundColor;
            action.textColor = menu.fabButton.tintColor;
            action.image = menu.fabButton.image;
            
            values.append(action);
        }
        
        return values;
    };
    
    func updateInfo(){
        guard let info = self.info else{
            return;
        }
        
        guard info === self.info else{
            return;
        }
        
        self.nameLabel.text = info.name;
        self.groupLabel?.text = info.group?.name;
        self.groupImageView?.sd_setImage(with: info.group?.logoUrl, placeholderImage: DAGroupInfo.defaultLogo, completed: nil);
        
        self.areaLabel.text = !info.personArea.isEmpty ? info.personArea : info.personName;
        self.photoView.sd_setImage(with: info.photo, placeholderImage: nil, completed: nil);
        
        return;
        var msgMenuItems : [FABMenuItem] = [];
        
        if !info.personEmail.isEmpty {
            var menuItem : FABMenuItem! = self.preparedMenuItems[menuType.email];
            if menuItem == nil{
                menuItem = FABMenuItem();
                //menuItem.title = "email";
                menuItem.titleLabel.isHidden = true;
                menuItem.fabButton.image = UIImage(named: "icon_email.png")?.withRenderingMode(.alwaysTemplate);
                menuItem.fabButton.tintColor = .white;
                menuItem.fabButton.pulseColor = .white;
                menuItem.fabButton.backgroundColor = DATheme.fabButtonBackgroundColor;
                menuItem.fabButton.addTarget(self, action: #selector(self.onEmail(_:)), for: .touchUpInside);
                self.preparedMenuItems[menuType.email] = menuItem;
            }
            msgMenuItems.append(menuItem);
        }
        
        if info.personSms?.number != nil{
            var menuItem : FABMenuItem! = preparedMenuItems[menuType.sms];
            if menuItem == nil{
                menuItem = FABMenuItem();
                //menuItem.title = "sms";
                menuItem.hideTitleLabel();
                menuItem.fabButton.image = UIImage(named: "icon_sms.png")?.withRenderingMode(.alwaysTemplate);
                menuItem.fabButton.tintColor = .white;
                menuItem.fabButton.pulseColor = .white;
                menuItem.fabButton.backgroundColor = DATheme.fabButtonBackgroundColor;
                menuItem.fabButton.addTarget(self, action: #selector(self.onSms(_:)), for: .touchUpInside);
                preparedMenuItems[menuType.sms] = menuItem;
            }
            msgMenuItems.append(menuItem);
        }
        
        if info.personTwitter?.account != nil{
            var menuItem : FABMenuItem! = preparedMenuItems[menuType.twitter];
            if menuItem == nil{
                menuItem = FABMenuItem();
                //menuItem.title = "twitter";
                menuItem.hideTitleLabel();
                menuItem.fabButton.image = UIImage(named: "icon_twitter.png")?.withRenderingMode(.alwaysTemplate);
                menuItem.fabButton.tintColor = DATheme.twitterButtonTintColor;
                menuItem.fabButton.pulseColor = DATheme.twitterButtonTintColor;
                menuItem.fabButton.backgroundColor = DATheme.twitterButtonBackgroundColor;
                menuItem.fabButton.addTarget(self, action: #selector(self.onTwitter(_:)), for: .touchUpInside);
                preparedMenuItems[menuType.twitter] = menuItem;
            }
            msgMenuItems.append(menuItem);
        }
        
        if info.personFacebook?.account != nil {
            var menuItem : FABMenuItem! = preparedMenuItems[menuType.facebook];
            if menuItem == nil{
                menuItem = FABMenuItem();
                //menuItem.title = "facebook";
                menuItem.hideTitleLabel();
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
        return;
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
            self.msgMenu.interimSpace = self.msgMenu.interimSpace - 6;

            //self.msgMenu.closeWithAnimation();
        }
                
        var searchMenuItems : [FABMenuItem] = [];
        
        if info.personHomepage?.url != nil{
            var menuItem : FABMenuItem! = preparedMenuItems[menuType.web];
            if menuItem == nil{
                menuItem = FABMenuItem();
                //menuItem.title = "web";
                menuItem.hideTitleLabel();
                menuItem.fabButton.image = UIImage(named: "icon_homepage.png")?.withRenderingMode(.alwaysTemplate);
                menuItem.fabButton.tintColor = .white;
                menuItem.fabButton.pulseColor = .white;
                menuItem.fabButton.backgroundColor = DATheme.fabButtonBackgroundColor;
                menuItem.fabButton.addTarget(self, action: #selector(self.onWeb(_:)), for: .touchUpInside);
                preparedMenuItems[menuType.web] = menuItem;
            }
            searchMenuItems.append(menuItem);
        }
        
        if info.personBlog?.url != nil{
            var menuItem : FABMenuItem! = preparedMenuItems[menuType.blog];
            if menuItem == nil{
                menuItem = FABMenuItem();
                //menuItem.title = "blog";
                menuItem.hideTitleLabel();
                menuItem.fabButton.image = UIImage(named: "icon_blog.png")?.withRenderingMode(.alwaysTemplate);
                menuItem.fabButton.tintColor = .white;
                menuItem.fabButton.pulseColor = .white;
                menuItem.fabButton.backgroundColor = DATheme.fabButtonBackgroundColor;
                menuItem.fabButton.addTarget(self, action: #selector(self.onBlog(_:)), for: .touchUpInside);
                preparedMenuItems[menuType.blog] = menuItem;
            }
            
            searchMenuItems.append(menuItem);
        }
        
        if info.personYoutube?.url != nil{
            var menuItem : FABMenuItem! = preparedMenuItems[menuType.youtube];
            if menuItem == nil{
                menuItem = FABMenuItem();
                //menuItem.title = "youTube";
                menuItem.hideTitleLabel();
                menuItem.fabButton.image = UIImage(named: "icon_youtube.png")?.withRenderingMode(.alwaysTemplate);
                menuItem.fabButton.tintColor = DATheme.youtubeButtonTintColor;
                menuItem.fabButton.pulseColor = DATheme.youtubeButtonTintColor;
                menuItem.fabButton.backgroundColor = DATheme.youtubeButtonBackgroundColor;
                menuItem.fabButton.addTarget(self, action: #selector(self.onYoutube(_:)), for: .touchUpInside);
                preparedMenuItems[menuType.youtube] = menuItem;
            }
            searchMenuItems.append(menuItem);
        }
        
        if true{
            var menuItem : FABMenuItem! = preparedMenuItems[menuType.search];
            if menuItem == nil{
                menuItem = FABMenuItem();
                //menuItem.title = "search";
                menuItem.hideTitleLabel();
                menuItem.fabButton.image = UIImage(named: "icon_search.png")?.withRenderingMode(.alwaysTemplate);
                menuItem.fabButton.tintColor = DATheme.searchButtonTintColor;
                menuItem.fabButton.pulseColor = DATheme.searchButtonTintColor;
                menuItem.fabButton.backgroundColor = DATheme.searchButtonBackgroundColor;
                menuItem.fabButton.addTarget(self, action: #selector(self.onSearch(_:)), for: .touchUpInside);
                preparedMenuItems[menuType.search] = menuItem;
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
            let msgMenu : FABMenuItem! = self.msgMenu?.fabButton != nil
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
                self.buttonsStack.insertArrangedSubview(self.searchButton, at: self.buttonsStack.arrangedSubviews.count);
                self.searchButton.heightAnchor.constraint(equalTo: self.callButton.heightAnchor).isActive = true;
                self.searchButton.widthAnchor.constraint(equalTo: self.callButton.widthAnchor).isActive = true;
            }
        }else{
            self.searchMenu.fabButton = FABButton();
            self.searchMenu.fabButton?.image = UIImage(named: "icon_web.png")?.withRenderingMode(.alwaysTemplate);
            self.searchMenu.fabButton?.tintColor = .white;
            self.searchMenu.fabButton?.backgroundColor = DATheme.fabMenuBackgroundColor;
            self.searchMenu.fabButton?.pulseColor = .white;

            self.buttonsStack.insertArrangedSubview(self.searchMenu, at: self.buttonsStack.arrangedSubviews.count);
            //self.addSubview(self.msgMenu);
            self.searchMenu.heightAnchor.constraint(equalTo: self.callButton.heightAnchor).isActive = true;
            self.searchMenu.widthAnchor.constraint(equalTo: self.callButton.widthAnchor).isActive = true;
            self.searchMenu.prepare();
            self.searchMenu.interimSpace = self.searchMenu.interimSpace - 6;
            
            //self.searchMenu.closeWithAnimation();
        }
        
        if self.sponseButton != nil{
            self.buttonsStack.removeArrangedSubview(self.sponseButton);
            self.sponseButton.removeFromSuperview();
            self.sponseButton = nil;
        }
        
        if self.sponseButton == nil && info.sponsor > 0{
            self.sponseButton = FABButton();
            self.sponseButton.image = UIImage(named: "icon_money.png")?.withRenderingMode(.alwaysTemplate);
            self.sponseButton.frame.size = self.callButton.frame.size;
            
            self.buttonsStack.insertArrangedSubview(self.sponseButton, at: self.buttonsStack.arrangedSubviews.count);
            
            self.sponseButton.heightAnchor.constraint(equalTo: self.callButton.heightAnchor).isActive = true;
            self.sponseButton.widthAnchor.constraint(equalTo: self.callButton.widthAnchor).isActive = true;
            
            self.sponseButton?.tintColor = DATheme.sponseButtonTintColor;
            self.sponseButton?.backgroundColor = DATheme.sponseButtonBackgroundColor;
            self.sponseButton?.pulseColor = DATheme.sponseButtonTintColor;
            
            self.sponseButton.addTarget(self, action: #selector(self.onPaySponsor(_:)), for: .touchUpInside);
            
        }else if info.sponsor == 0 && self.sponseButton != nil{
            self.buttonsStack.removeArrangedSubview(self.sponseButton);
            self.sponseButton.removeFromSuperview();
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
    
    func openWeb(_ url : URL){
        //var webView = WebViewController(url: url);
        //let webView = ProgressWebViewController(nibName: nil, bundle: Bundle.main);
        //webView.url = url;
        //webView.hidesBottomBarWhenPushed = true;
        //self.viewController?.navigationController?.pushViewController(webView, animated: true);
        UIApplication.shared.openURL(url);
    }
    
    @IBAction func onOpenMsgMenu(_ button : UIButton){
        guard let info = self.info else{
            return;
        }
        
        print("open msg menu phones[\(info.phones.debugDescription)]");
        self.msgMenu.open();
        self.searchMenu.close();
    }
    
    @IBAction func onCall(_ button : UIButton){
        guard let info = self.info else{
            return;
        }
        
        print("call \(info.phones.debugDescription)");
        self.closeMenus();
        
        let phones = info.personPhones.sorted(by: { (left, right) -> Bool in
            return left.name! < right.name!;
        });
        /*.filter { (phone) -> Bool in
            return phone.sms;
        }*/
        
        var actions : [UIAlertAction] = [];
        for phone in phones{
            actions.append(UIAlertAction(title: phone.name, style: .default, handler: { (act) in
                UIApplication.shared.openTel(phone.number ?? "");
            }));
        }
        
        if let mobile = phones.first(where: { (phone) -> Bool in
            return phone.sms;
        }){
            //edit new mobile
            actions.append(UIAlertAction(title: "휴대폰 번호 수정", style: .default, handler: { (act) in
                self.onEditMobile(phone: mobile);
            }));
        }else{
            //register mobile
            actions.append(UIAlertAction(title: "휴대폰 번호 등록", style: .default, handler: { (act) in
                self.onRegisterMobile();
            }));
        }
        
        actions.append(UIAlertAction(title: "취소", style: .cancel, handler: { (act) in
            
        }));
        
        UIApplication.shared.keyWindow?.rootViewController?.showAlert(title: "\(info.job ?? "") \(info.name ?? "")에게 전화", msg: "통화할 연락처를 선택하세요", actions: actions, style: .alert);
    }
    
    @IBAction func onLoadPhoneFromContact(){
        let picker = CNContactPickerViewController();
        //picker.displayedPropertyKeys = [CNContactGivenNameKey, CNContactNameSuffixKey, CNContactNicknameKey, CNContactImageDataKey, CNContactOrganizationNameKey, CNContactDepartmentNameKey, CNContactJobTitleKey, CNContactEmailAddressesKey, CNContactPhoneNumbersKey, CNContactNoteKey];
        picker.displayedPropertyKeys = [CNContactPhoneNumbersKey];
        picker.delegate = self;
        
        UIApplication.shared.keyWindow?.rootViewController?.present(picker, animated: true, completion: nil);
    }
    
    @IBAction func onEditMobile(phone : DAPhoneInfo){
        let alert = UIAlertController(title: "휴대폰 번호 수정", message: nil, preferredStyle: .alert);
        
        alert.addTextField { (textField) in
            textField.placeholder = "휴대폰 번호";
            textField.keyboardType = .phonePad;
            textField.text = phone.number;
        }
        alert.addAction(UIAlertAction(title: "수정", style: .default, handler: { (act) in
            let textField : UITextField! = alert.textFields?.first;
            //info.createPhone(name: "휴대폰", number: textField.text ?? "", canSendSMS: true);
            guard !(textField.text ?? "").isEmpty else{
                return;
            }
            phone.number = textField.text;
            DAModelController.shared.saveChanges();
            //DAModelController.shared.refresh(person: info);
            
            self.updateInfo();
        }));
        alert.addAction(UIAlertAction(title: "연락처에서 가져오기", style: .default, handler: { (act) in
            self.onLoadPhoneFromContact();
        }));
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { (act) in
            
        }));
        
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil);
    }
    
    @IBAction func onRegisterMobile(){
        guard let info = self.info else{
            return;
        }
        
        let alert = UIAlertController(title: "휴대폰 번호 등록", message: nil, preferredStyle: .alert);
        
        alert.addTextField { (textField) in
            textField.placeholder = "휴대폰 번호";
            textField.keyboardType = .phonePad;
        }
        alert.addAction(UIAlertAction(title: "등록", style: .default, handler: { (act) in
            let textField : UITextField! = alert.textFields?.first;
            guard !(textField.text ?? "").isEmpty else{
                return;
            }
            
            info.createPhone(name: "휴대폰", number: textField.text ?? "", canSendSMS: true);
            DAModelController.shared.saveChanges();
            DAModelController.shared.refresh(person: info);
            
            self.updateInfo();
        }));
        alert.addAction(UIAlertAction(title: "연락처에서 가져오기", style: .default, handler: { (act) in
            self.onLoadPhoneFromContact();
        }));
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { (act) in
            
        }));
            
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil);
    }
    
    @IBAction func onSms(_ button : UIButton){
        guard let info = self.info else{
            return;
        }
        
        print("send sms \(info.personSms?.number ?? "")");
        self.closeMenus();
        UIApplication.shared.openSms(info.personSms?.number ?? "");
    }
    
    @IBAction func onEmail(_ button : UIButton){
        guard let info = self.info else{
            return;
        }
        
        print("send email \(info.personEmail)");
        self.closeMenus();
        UIApplication.shared.openEmail(info.personEmail);
    }
    
    @IBAction func onTwitter(_ button : UIButton){
        guard let info = self.info else{
            return;
        }
        
        print("send twitter \(self.info.personTwitter?.account ?? "")");
        self.closeMenus();
        UIApplication.shared.openTwitter(info.personTwitter?.account ?? "", webOpen: { (url) in
            self.openWeb(url);
        });
    }

    @IBAction func onFacebook(_ button : UIButton){
        guard let info = self.info else{
            return;
        }
        
        print("send facebook \(info.personFacebook?.account ?? "")");
        self.closeMenus();
        UIApplication.shared.openFacebook(info.personFacebook?.account ?? "", webOpen: { (url) in
            self.openWeb(url);
        });
    }
    
    @IBAction func onKakao(_ button : UIButton){
        print("send kakao \(self.info.personKakao?.account ?? "")");
        self.closeMenus();
    }
    
    @IBAction func onYoutube(_ button : UIButton){
        print("go youtube \(self.info.personYoutube?.url ?? "")");
        self.closeMenus();
        self.openWeb(URL(string: self.info.personYoutube?.url ?? "")!);
        //UIApplication.shared.openWeb(self.info.personYoutube?.url ?? "");
    }
    
    @IBAction func onWeb(_ button : UIButton){
        print("go web \(self.info.personHomepage?.url ?? "")");
        //UIApplication.shared.openWeb(self.info.personHomepage?.url ?? "");
        self.openWeb(URL(string: self.info.personHomepage?.url ?? "")!);
        self.closeMenus();
    }
    
    @IBAction func onBlog(_ button : UIButton){
        print("go blog \(self.info.personBlog?.url ?? "")");
        //UIApplication.shared.openWeb(self.info.personBlog?.url ?? "");
        self.openWeb(URL(string: self.info.personBlog?.url ?? "")!);
        self.closeMenus();
    }
    
    @IBAction func onSearch(_ button : UIButton){
        print("go search \(self.info.personBlog?.url ?? "")");
        //UIApplication.shared.openWeb(self.info.personBlog?.url ?? "");
        let keyword = "\(self.info.job ?? "") \(self.info.name ?? "")";
        //let viewController = UIApplication.shared.keyWindow?.rootViewController;
        UIApplication.shared.keyWindow?.rootViewController?.showAlert(title: "\(keyword) 검색", msg: "검색할 포털사이트를 선택하세요", actions: [UIAlertAction(title: "다음에서 검색", style: .default, handler: { (act) in
            UIApplication.shared.searchByDaum(keyword, webOpen: { (url) in
                self.openWeb(url);
            });
        }), UIAlertAction(title: "구글에서 검색", style: .default, handler: { (act) in
            UIApplication.shared.searchByGoogle(keyword, webOpen: { (url) in
                self.openWeb(url);
            });
        }), UIAlertAction(title: "네이버에서 검색", style: .default, handler: { (act) in
            UIApplication.shared.searchByNaver(keyword, webOpen: { (url) in
                self.openWeb(url);
            });
        }), UIAlertAction(title: "취소", style: .default, handler: nil)], style: .alert);
        
        self.closeMenus();
    }
    
    @IBAction func onPaySponsor(_ button : UIButton){
        print("go sponsor \(self.info.personHomepage?.url ?? "")");
        //UIApplication.shared.openWeb(self.info.personHomepage?.url ?? "");
        let req = DASponsorPayRequest(party: Int(self.info.group?.sponsor ?? 0), person: Int(self.info.sponsor), source: DASponsor.Sources.leesam).urlRequest;
        //self.openWeb(URL(string: self.info.personHomepage?.url ?? "")!);
        self.openWeb(req.url!);
        self.closeMenus();
    }
    
    // MARK: FABMenuDelegate
    func fabMenuWillOpen(fabMenu: FABMenu) {
        fabMenu.fabButton?.animate(.rotate(-45));
        if self.msgMenu == fabMenu{
            self.searchMenu?.closeWithAnimation();
        }else{
            self.msgMenu?.closeWithAnimation();
        }
    }
    
    func fabMenuDidOpen(fabMenu: FABMenu) {
        let lastfabButton : FABButton! = fabMenu.fabMenuItems.last?.fabButton;
        let left = lastfabButton.convert(lastfabButton.frame.origin, to: self);
        guard left.x < 0 else{
            self.overflowedMenus = [];
            return;
        }
        
        for menu in fabMenu.fabMenuItems{
            let fabButton : FABButton! = menu.fabButton;
            let left = fabButton.convert(fabButton.frame.origin, to: self);
            if left.x < 0 {
                self.overflowedMenus.append(menu);
            }
        }
    
        self.showSwipe(orientation: .left, animated: true, completion: nil);
    }
    
    func fabMenuWillClose(fabMenu: FABMenu) {
        fabMenu.fabButton?.animate(.rotate(0));
    }
    
    //MARK: CNContactPickerDelegate
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
        print("contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty)");
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        print("contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact)");
        let phones = (self.info.phones?.allObjects as? [DAPhoneInfo] ?? []);
        var actions : [UIAlertAction] = [];
        if let mobile = phones.first(where: { (phone) -> Bool in
            return phone.sms;
        }){
            for phone in contact.phoneNumbers{
                actions.append(UIAlertAction(title: phone.value.stringValue, style: .default, handler: { (act) in
                    mobile.number = phone.value.stringValue;
                    DAModelController.shared.saveChanges();
                    self.updateInfo();
                }));
            }
        }else{
            for phone in contact.phoneNumbers{
                actions.append(UIAlertAction(title: phone.value.stringValue, style: .default, handler: { (act) in
                    self.info.createPhone(name: "휴대폰", number: phone.value.stringValue, canSendSMS: true);
                    DAModelController.shared.saveChanges();
                    self.updateInfo();
                }));
            }
        }
        
        /*if actions.count == 1{
            var phone = contact.phoneNumbers.first;
            if let mobile = phones.first(where: { (phone) -> Bool in
                return phone.sms;
            }){
                mobile.number = phone?.value.stringValue;
            }else{
                self.info.createPhone(name: "휴대폰", number: phone?.value.stringValue ?? "", canSendSMS: true);
            }
            DAModelController.shared.saveChanges();
        }*/
        
        guard !actions.isEmpty else{
            return;
        }
        actions.append(UIAlertAction(title: "취소", style: .cancel, handler: nil));
        
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.rootViewController?.showAlert(title: "휴대폰 번호 선택", msg: "", actions: actions, style: .alert);
        }
    }
}

extension FABMenu{
    func closeWithAnimation(){
        self.close();
        self.fabButton?.animate(.rotate(0));
    }
}
