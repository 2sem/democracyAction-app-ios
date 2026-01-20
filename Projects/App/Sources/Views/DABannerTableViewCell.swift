//
//  DABannerTableViewCell.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 7. 6..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit
import GoogleMobileAds

class DABannerTableViewCell: UITableViewCell {

    
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var detailView: UILabel!
    
    @IBOutlet weak var bannerView: BannerView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.bannerView.loadUnitId("TableBanner");
        self.bannerView.rootViewController = UIApplication.shared.keyWindow?.rootViewController;
        let req = Request();
        #if DEBUG
            //req.testDevices = ["5fb1f297b8eafe217348a756bdb2de56"];
        #endif
        self.bannerView.load(req);
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onShare(_ sender: UIButton) {
        ReviewManager.shared?.show(true);
    }

    /*private func showBanner(visible: Bool){
        self.toggleContraint(value: visible, constraintOn: constraint_bottomBanner_Bottom, constarintOff: constraint_bottomBanner_Top);
        
        if visible{
            print("show banner");
        }else{
            print("hide banner");
        }
        self.bannerView.isHidden = !visible;
    }*/
}

extension DABannerTableViewCell: BannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        //self.showBanner(visible: true);
        self.bannerView.isHidden = false;
        self.titleView.isHidden = !self.bannerView.isHidden;
        self.detailView.isHidden = !self.bannerView.isHidden;
    }
    
    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
        print("banner error -  \(error)");
        self.bannerView.isHidden = true;
        self.titleView.isHidden = !self.bannerView.isHidden;
        self.detailView.isHidden = !self.bannerView.isHidden;
        //self.showBanner(visible: false);
    }
}
