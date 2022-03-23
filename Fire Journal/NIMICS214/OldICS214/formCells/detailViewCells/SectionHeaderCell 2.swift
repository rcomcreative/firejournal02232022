//
//  SectionHeaderCell.swift
//  ARCForm
//
//  Created by DuRand Jones on 8/30/17.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

@objc protocol SectionHeaderCellDelgate: AnyObject {
    @objc optional func  effortHasChangedToComplete(complete: Bool, completed:String )
}

class SectionHeaderCell: UITableViewCell {

    @IBOutlet weak var sectionL: UILabel!
    @IBOutlet weak var completeL: UILabel!
    @IBOutlet weak var completeSwitch: UISwitch!
    var complete:String = "Incomplete"
    var completeB:Bool = false
    
    @IBOutlet weak var sectionIV: UIImageView!
    @IBOutlet weak var sectionAddressL: UILabel!
    @IBOutlet weak var sectionDateL: UILabel!
    
    @IBOutlet weak var formNameL: UILabel!
    
    weak var delegate: SectionHeaderCellDelgate? = nil
    
    @IBAction func completeTapped(_ sender: Any) {
        if completeSwitch.isOn {
            complete = "Incomplete"
            completeB = false
        } else {
            complete = "Complete"
            completeB = true
        }
        delegate?.effortHasChangedToComplete!(complete: completeB, completed: complete)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        formNameL.text = "ACTIVITY LOG (ICS 214)"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
