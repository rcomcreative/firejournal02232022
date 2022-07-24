//
//  ARC_ChooseACampaignCell.swift
//  FJ ARC Plus
//
//  Created by DuRand Jones on 9/8/20.
//  Copyright © 2020 com.purecommand.FireJournal. All rights reserved.
//

import UIKit

class ARC_ChooseACampaignCell: UITableViewCell {
    
//    MARK: -OBJECTS-
    @IBOutlet weak var chooseACampaignB: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        chooseACampaignB.layer.cornerRadius = 8
        chooseACampaignB.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
