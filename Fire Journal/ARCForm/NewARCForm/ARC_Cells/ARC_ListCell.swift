//
//  ARC_ListCell.swift
//  FJ ARC Plus
//
//  Created by DuRand Jones on 9/4/20.
//  Copyright © 2020 com.purecommand.FJARCPlus. All rights reserved.
//

import UIKit
import Foundation
import CoreData

protocol ARC_ListCellDelegate: AnyObject {
    func theARC_ListCellTapped(id: NSManagedObjectID)
}

class ARC_ListCell: UITableViewCell {
    
//    MARK: -OBJECTS-
    @IBOutlet weak var iconIV: UIImageView!
    @IBOutlet weak var campaignL: UILabel!
    @IBOutlet weak var addressL: UILabel!
    @IBOutlet weak var aptL: UILabel!
    @IBOutlet weak var dateL: UILabel!
    @IBOutlet weak var campaignActionL: UILabel!
    
    
//    MARK: -PROPERTIES-
    weak var delegate: ARC_ListCellDelegate? = nil
    
    private var campaignName: String = ""
    var theCampaignName: String? {
        didSet {
            self.campaignName = self.theCampaignName ?? ""
            self.campaignL.text = self.campaignName
        }
    }
    
    private var address: String = ""
    var theAddress: String? {
        didSet {
            self.address = self.theAddress ?? ""
            self.addressL.text = "Address: \(self.address)"
        }
    }
    
    private var aptMobile: String = ""
    var theAptMobile: String? {
        didSet {
            self.aptMobile = self.theAptMobile ?? ""
            self.aptL.text = " Apt/Mobile #: \(self.aptMobile)"
        }
    }
    
    private var campaignStartDate: String = ""
    var theStartDate: String? {
        didSet {
            self.campaignStartDate = self.theStartDate ?? ""
            self.dateL.text = self.campaignStartDate
        }
    }
    
    private var campaignStatus: String = ""
    var theStatus: String? {
        didSet {
            self.campaignStatus = self.theStatus ?? ""
            self.campaignActionL.text = self.campaignStatus
        }
    }
    
    var object: NSManagedObjectID? = nil
    var theObject: NSManagedObjectID? = nil {
        didSet {
            self.object = self.theObject
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
