//
//  NewCampaignCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/23/18.
//  Copyright © 2018 PureCommandLLC. All rights reserved.
//

import UIKit


protocol NewCampaignCellDelegate:class {
    func newCampaignCreated(campaign: String)
}

class NewCampaignCell: UITableViewCell {
    
    @IBOutlet weak var campaignTitleL: UILabel!
    @IBOutlet weak var campaignNameTF: UITextField!
    @IBOutlet weak var newCampaignB: UIButton!
    
    weak var delegate:NewCampaignCellDelegate? = nil
    
    @IBAction func newCampaignBTapped(_ sender: Any) {
        var campaignName = ""
        if let test2:String = campaignNameTF.text {
            campaignName = test2
        }
        delegate?.newCampaignCreated(campaign: campaignName)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
