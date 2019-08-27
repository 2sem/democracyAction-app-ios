//
//  DAAssemblyViewController.swift
//  democracyaction
//
//  Created by 영준 이 on 2019. 2. 13..
//  Copyright © 2019년 leesam. All rights reserved.
//

import UIKit
import Material
import GADManager
import GoogleMobileAds

class DAPersonViewController: UIViewController {

    static let storyboardName = "Assembly";
    static let storyboardId = "person";
    
    class Cell_Ids{
        static let profile = "profile";
        static let contact = "contact";
    }
    
    class Sections{
        static let profile = 0;
        static let contacts = 1;
    }
    
    var info : DAPersonInfo!;
    var contactGroups : [DAContactGroup] = [];
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var banner: GADBannerView!
    
    static func instantiate() -> DAPersonViewController?{
        return UIStoryboard.init(name: storyboardName, bundle: Bundle.main).instantiateViewController(withIdentifier: storyboardId) as? DAPersonViewController;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "\(self.info?.name ?? "") 의원";
        self.tableView?.contentInset.top = 16;
        self.tableView?.contentInset.bottom = 16;
        
        /*switch UIDevice.current.userInterfaceIdiom{
            //case .pad:
                //self.banner = GADBannerView.init(adSize: kGADAdSizeful)
                //break;
            default:
                self.banner = GADBannerView.init(adSize: kGADAdSizeBanner)
                break;
        }*/
        
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            self.banner = AppDelegate.sharedGADManager?.prepare(bannerUnit: .info, size: kGADAdSizeFullBanner);
            break;
        default:
            self.banner = AppDelegate.sharedGADManager?.prepare(bannerUnit: .info);
            break;
        }

        if let tableView = self.tableView, let banner = self.banner{
            self.view?.addSubview(banner);
            banner.translatesAutoresizingMaskIntoConstraints = false;
            banner.heightAnchor.constraint(equalToConstant: 50).isActive = true;
            banner.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true;
            banner.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true;
            banner.bottomAnchor.constraint(equalTo: tableView.bottomAnchor).isActive = true;
            
            banner.delegate = self;
            banner.rootViewController = self;
            self.banner?.isHidden = true;
            banner.load(GADRequest());
        }
        self.loadContacts();
    }
    
    func loadContacts(){
        guard info === self.info else{
            return;
        }
        
        self.contactGroups = [];
        
        self.loadPhones();
        self.loadMessages();
        self.loadSocialNetworks();
        self.loadSites();
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
            group.append(DAContact.init(type: .sms, name: "문자", value: phone));
        }
        
        guard group.contacts.any else{
            return;
        }
        
        self.contactGroups.append(group);
    }
    
    func loadSocialNetworks(){
        let group = DAContactGroup("소셜네트워크");
        
        if let value = info.personTwitter?.account, value.any{
            group.append(DAContact.init(type: .twitter, name: "트위터", value: value));
        }
        
        if let value = info.personFacebook?.account, value.any {
            group.append(DAContact.init(type: .facebook, name: "페이스북", value: value));
        }
        
        if let value = info.personKakao?.account, value.any {
            //group.append(DAContact.init(type: .kakao, name: "카카오스토리", value: value));
        }
        
        if let value = info.personInstagram?.account, value.any {
            //group.append(DAContact.init(type: .instagram, name: "인스타그램", value: value));
        }
        
        guard group.contacts.any else{
            return;
        }
        
        self.contactGroups.append(group);
    }
    
    func loadSites(){
        let group = DAContactGroup("사이트");

        if let value = info.personYoutube?.url, value.any{
            group.append(DAContact.init(type: .youtube, name: "유튜브", value: value));
        }
        
        if let value = info.personHomepage?.url, value.any{
            group.append(DAContact.init(type: .web, name: "홈페이지", value: value));
        }
        
        if let value = info.personBlog?.url, value.any{
            group.append(DAContact.init(type: .blog, name: "블로그", value: value));
        }
        
        if let value = info.personCafe?.url, value.any{
            group.append(DAContact.init(type: .cafe, name: "카페", value: value));
        }
        
        self.contactGroups.append(group);
    }

    @IBAction func onShare(_ button: UIBarButtonItem) {
        self.info?.shareByKakao();
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.contactGroups.count + 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : self.contactGroups[section - 1].contacts.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell!;
        
        if indexPath.section == Sections.profile{
            if let profileCell = tableView.dequeueReusableCell(withIdentifier: Cell_Ids.profile, for: indexPath) as? DAPersonProfileCell{
                profileCell.info = self.info;
                cell = profileCell;
            }
        }else{
            if let contactCell = tableView.dequeueReusableCell(withIdentifier: Cell_Ids.contact, for: indexPath) as? DAContactTableViewCell{
                cell = contactCell;
                if indexPath.section <= self.contactGroups.count{
                    let group = self.contactGroups[indexPath.section - 1];
                    if indexPath.row < group.contacts.count{
                        contactCell.info = group.contacts[indexPath.row];
                    }
                }
            }
        }
        
        
        return cell!;
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == Sections.profile ? "" : self.contactGroups[section - 1].name;
    }
}

extension DAPersonViewController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //(UIScreen.main.bounds.width > UIScreen.Size._5s.width ? UITableViewAutomaticDimension : 120)
        return indexPath.section == Sections.profile ? UITableViewAutomaticDimension : 52;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section > Sections.profile else{
            return;
        }
        
        guard let info = self.info else{
            return;
        }
        
        guard let cell = tableView.cellForRow(at: indexPath) as? DAContactTableViewCell, let contact = cell.info else{
            return;
        }
        
        self.share(["#문자행동 [\(info.name ?? "") 의원] \(contact.name ?? "") - \(contact.value)"]);
    }
}

extension DAPersonViewController : GADBannerViewDelegate{
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("receive info banner");
        self.banner?.isHidden = false;
        self.tableView?.contentInset.bottom = bannerView.frame.height + 16;
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("receive info banner failed. error[\(error.localizedDescription)]");
    }
}
