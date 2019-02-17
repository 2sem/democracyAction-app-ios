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
    }
}
