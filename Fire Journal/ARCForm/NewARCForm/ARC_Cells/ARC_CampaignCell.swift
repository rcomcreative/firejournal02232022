//
//  ARC_CampaignCell.swift
//  FJ ARC Plus
//
//  Created by DuRand Jones on 9/8/20.
//  Copyright © 2020 com.purecommand.FireJournal. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class ARC_CampaignCell: UITableViewCell {
    
//    MARK: -OBJECTS-
    @IBOutlet weak var iconIV: UIImageView!
    @IBOutlet weak var campaignNameL: UILabel!
    @IBOutlet weak var campaignAddressL: UILabel!
    @IBOutlet weak var campaignStartDateL: UILabel!
    
//    MARK: -PROPERTIES-

    var object: NSManagedObjectID? = nil
    var theObject: NSManagedObjectID? = nil {
        didSet {
            self.object = self.theObject
        }
    }
    
    var masterGuid: String = ""
    var theMasterGuid: String? {
        didSet {
            self.masterGuid = self.theMasterGuid ?? ""
        }
    }
    
   var campaignName: String = ""
    var cName: String? {
        didSet {
            self.campaignName = self.cName ?? ""
            self.campaignNameL.text = self.campaignName
        }
    }
    
    var campaignAddress: String = ""
    var cAddress: String? {
        didSet {
            self.campaignAddress = self.cAddress ?? ""
            self.campaignAddressL.text = self.campaignAddress
        }
    }
    
    var campaignDate: String = ""
    var cDate: String? {
        didSet {
            self.campaignDate = cDate ?? ""
            self.campaignStartDateL.text = self.campaignDate
        }
    }
    
    private var imageName: String = ""
    var iName: String? {
        didSet {
            self.imageName = self.iName ?? ""
            if self.imageName != "" {
                self.iconIV.image = UIImage(named: self.imageName)
            }
        }
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
