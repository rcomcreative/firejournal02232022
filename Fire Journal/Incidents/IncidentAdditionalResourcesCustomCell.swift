//
//  IncidentAdditionalResourcesCustomCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 6/1/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

class IncidentAdditionalResourcesCustomCell: UITableViewCell {

    @IBOutlet weak var customIncidentAdditionalIV: UIImageView!
    @IBOutlet weak var customIncidentAdditionalL: UILabel!
    @IBOutlet weak var customIncidentAdditionalL2: UITextField!
    
    var fdResource: UserFDResources? {
        didSet {
                var labelName = ""
                if let name: String = self.fdResource!.fdResource {
                    if name.count > 6 {
                        labelName = name.replacingOccurrences(of: " ", with: "\n")
                        self.customIncidentAdditionalL.font = customIncidentAdditionalL.font.withSize(10)
                        self.customIncidentAdditionalL.adjustsFontSizeToFitWidth = true
                        self.customIncidentAdditionalL.lineBreakMode = NSLineBreakMode.byWordWrapping
                        self.customIncidentAdditionalL.numberOfLines = 0
                        self.customIncidentAdditionalL.setNeedsDisplay()
                        self.customIncidentAdditionalL.text = labelName
                    } else {
                        labelName = name
                    }
                    self.customIncidentAdditionalL.text = labelName
                    self.customIncidentAdditionalL2.text = labelName
                }
            }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // update UI
        accessoryType = selected ? .checkmark : .none
    }
    
}
