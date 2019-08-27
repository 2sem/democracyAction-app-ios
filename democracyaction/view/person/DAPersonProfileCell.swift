//
//  DAPersonProfileCell.swift
//  democracyaction
//
//  Created by 영준 이 on 2019. 2. 16..
//  Copyright © 2019년 leesam. All rights reserved.
//

import UIKit

class DAPersonProfileCell: UITableViewCell {

    var info : DAPersonInfo!{
        didSet{
            self.updateInfo();
        }
    }
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var areaLabel: UILabel!
    @IBOutlet weak var favButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func updateInfo(){
        guard let info = self.info else{
            return;
        }
        
        self.nameLabel.text = info.name;
        self.groupNameLabel?.text = info.group?.name;
        self.groupImageView?.sd_setImage(with: info.group?.logoUrl, placeholderImage: DAGroupInfo.defaultLogo, completed: nil);
        
        self.areaLabel.text = !info.personArea.isEmpty ? info.personArea : info.personName;
        self.photoImageView?.sd_setImage(with: info.photo, placeholderImage: nil, completed: nil);
        self.favButton.isHidden = DAModelController.shared.findFavorite(info) != nil;
    }
    
    @IBAction func onFavorite(_ button: UIButton) {
        guard let info = self.info else{
            return;
        }
        
        if let _ = DAModelController.shared.findFavorite(info){
            //self.modelController.removeFavorite(favor);
            //act.image = self.favOffImage;
            button.isHidden = true;
        }
        else{
            DAModelController.shared.createFavorite(person: info);
            DAModelController.shared.saveChanges();
            button.isHidden = true;
        }
        
        
    }
}
