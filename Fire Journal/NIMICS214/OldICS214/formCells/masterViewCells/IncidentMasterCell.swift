//
//  IncidentMasterCell.swift
//  ARCForm
//
//  Created by DuRand Jones on 10/25/17.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import CoreData

class IncidentMasterCell: UITableViewCell {

    @IBOutlet weak var incidentIV: UIImageView!
    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var incidentAddressL: UILabel!
    @IBOutlet weak var incidentTimeL: UILabel!
    var incidentGuid: String?
    var masterGuid: String?
    var type:TypeOfForm!
    var incidentNumber: String?
    var incidentName:String?
    var teamName:String?
    var obID:NSManagedObjectID?
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
