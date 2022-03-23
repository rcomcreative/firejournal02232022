//
//  ChooseCampaignCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/24/18.
//  Copyright © 2018 PureCommandLLC. All rights reserved.
//

import UIKit
import CoreData

class ChooseCampaignCell: UITableViewCell {

    @IBOutlet weak var campaignNameL: UILabel!
    var objectID: NSManagedObjectID? = nil
    @IBOutlet weak var formIconIV: UIImageView!
    var guid:String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
