//
//  DAContactTableViewCell.swift
//  democracyaction
//
//  Created by 영준 이 on 2019. 2. 12..
//  Copyright © 2019년 leesam. All rights reserved.
//

import UIKit
import Material
import ContactsUI

class DAContactTableViewCell: UITableViewCell {

    var info : DAContact!{
        didSet{
            self.updateInfo();
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var contactButton: FABButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func updateInfo(){
        guard info === self.info else{
            return;
        }
        
        self.nameLabel?.text = info.name;
        self.valueLabel?.text = info.value;
        
        switch info.contactType{
        case .phone:
            self.contactButton.image = UIImage(named: "icon_call")?.withRenderingMode(.alwaysTemplate);
            self.contactButton.tintColor = .white;
            self.contactButton.pulseColor = .white;
            self.contactButton.backgroundColor = DATheme.fabButtonBackgroundColor;
            break;
        case .sms:
            self.contactButton.image = UIImage(named: "icon_sms")?.withRenderingMode(.alwaysTemplate);
            self.contactButton.tintColor = .white;
            self.contactButton.pulseColor = .white;
            self.contactButton.backgroundColor = DATheme.fabButtonBackgroundColor;
            break;
        case .email:
            self.contactButton.image = UIImage(named: "icon_email");
            self.contactButton.tintColor = .white;
            self.contactButton.pulseColor = .white;
            self.contactButton.backgroundColor = DATheme.fabButtonBackgroundColor;
            break;
        case .twitter:
            self.contactButton.image = UIImage(named: "icon_twitter")?.withRenderingMode(.alwaysTemplate);
            self.contactButton.tintColor = DATheme.twitterButtonTintColor;
            self.contactButton.pulseColor = DATheme.twitterButtonTintColor;
            self.contactButton.backgroundColor = DATheme.twitterButtonBackgroundColor;
            break;
        case .facebook:
            self.contactButton.image = UIImage(named: "icon_facebook")?.withRenderingMode(.alwaysTemplate);
            self.contactButton.tintColor = DATheme.facebookButtonTintColor;
            self.contactButton.pulseColor = DATheme.facebookButtonTintColor;
            self.contactButton.backgroundColor = DATheme.facebookButtonBackgroundColor;
            break;
        case .web:
            self.contactButton.image = UIImage(named: "icon_homepage")?.withRenderingMode(.alwaysTemplate);
            self.contactButton.tintColor = DATheme.webButtonTintColor;
            self.contactButton.pulseColor = DATheme.webButtonTintColor;
            self.contactButton.backgroundColor = DATheme.fabButtonBackgroundColor;
            break;
        case .blog:
            self.contactButton.image = UIImage(named: "icon_blog")?.withRenderingMode(.alwaysTemplate);
            self.contactButton.tintColor = DATheme.webButtonTintColor;
            self.contactButton.pulseColor = DATheme.webButtonTintColor;
            self.contactButton.backgroundColor = DATheme.fabButtonBackgroundColor;
            break;
        case .youtube:
            self.contactButton.image = UIImage(named: "icon_youtube")?.withRenderingMode(.alwaysTemplate);
            self.contactButton.tintColor = DATheme.youtubeButtonTintColor;
            self.contactButton.pulseColor = DATheme.youtubeButtonTintColor;
            self.contactButton.backgroundColor = DATheme.youtubeButtonBackgroundColor;
            break;
        case .cafe:
            self.contactButton.image = UIImage(named: "icon_cafe")?.withRenderingMode(.alwaysTemplate);
            self.contactButton.tintColor = DATheme.webButtonTintColor;
            self.contactButton.pulseColor = DATheme.webButtonTintColor;
            self.contactButton.backgroundColor = DATheme.webButtonBackgroundColor;
            break;
        default:
            break
        }
        
        /*if true{
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
        }*/
        
        /*if self.searchMenu != nil {
         //!self.buttonsStack.subviews.contains(self.searchMenu)
         self.buttonsStack.removeArrangedSubview(self.searchMenu);
         self.searchMenu.removeFromSuperview();
         self.searchMenu = nil;
         }*/
        
        //self.layoutSubviews();
    }
    
    func openWeb(_ url : URL){
        //var webView = WebViewController(url: url);
        //let webView = ProgressWebViewController(nibName: nil, bundle: Bundle.main);
        //webView.url = url;
        //webView.hidesBottomBarWhenPushed = true;
        //self.viewController?.navigationController?.pushViewController(webView, animated: true);
        UIApplication.shared.openURL(url);
    }
    
    /*@IBAction func onCall(_ button : UIButton){
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
    }*/
    
    @IBAction func onContact(_ button : UIButton){
        guard let info = self.info else{
            return;
        }
        
        switch info.contactType{
        case .phone:
            print("prepare sms \(info.value)");
            UIApplication.shared.openTel(info.value);
            break;
        case .sms:
            print("prepare sms \(info.value)");
            UIApplication.shared.openSms(info.value);
            break;
        case .email:
            print("send email \(info.value)");
            UIApplication.shared.openEmail(info.value);
            break;
        case .twitter:
            print("send twitter \(self.info.value)");
            UIApplication.shared.openTwitter(info.value, webOpen: { (url) in
                self.openWeb(url);
            });
            break;
        case .facebook:
            print("send facebook \(info.value)");
            UIApplication.shared.openFacebook(info.value, webOpen: { (url) in
                self.openWeb(url);
            });
            break;
        case .kakao:
            print("send kakao \(info.value)");
            UIApplication.shared.openFacebook(info.value, webOpen: { (url) in
                self.openWeb(url);
            });
            break;
        case .youtube:
            print("go youtube \(info.value)");
            self.openWeb(URL(string: info.value)!);
            break;
        case .web:
            print("go web \(info.value)");
            self.openWeb(URL(string: info.value)!);
            break;
        case .blog:
            print("go blog \(info.value)");
            self.openWeb(URL(string: info.value)!);
            break;
        default:
            break;
        }
    }
    
    @IBAction func onKakao(_ button : UIButton){
        //print("send kakao \(self.info.personKakao?.account ?? "")");
        //self.closeMenus();
    }
    
    @IBAction func onSearch(_ button : UIButton){
        /*print("go search \(self.info.personBlog?.url ?? "")");
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
        
        self.closeMenus();*/
    }
    
    @IBAction func onPaySponsor(_ button : UIButton){
        /*print("go sponsor \(self.info.personHomepage?.url ?? "")");
        //UIApplication.shared.openWeb(self.info.personHomepage?.url ?? "");
        let req = DASponsorPayRequest(party: Int(self.info.group?.sponsor ?? 0), person: Int(self.info.sponsor), source: DASponsor.Sources.leesam).urlRequest;
        //self.openWeb(URL(string: self.info.personHomepage?.url ?? "")!);
        self.openWeb(req.url!);
        self.closeMenus();*/
    }
}

#if false
//MARK: CNContactPickerDelegate
extension DAContactTableViewCell : CNContactPickerDelegate{
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
#endif
