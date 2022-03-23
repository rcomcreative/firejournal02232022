//
//  IncidentDateInputCell.swift
//  ARCForm
//
//  Created by DuRand Jones on 10/31/17.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

class IncidentDateInputCell: UITableViewCell {

    @IBOutlet weak var monthInputL: UILabel!
    @IBOutlet weak var dayInputL: UILabel!
    @IBOutlet weak var yearInputL: UILabel!
    @IBOutlet weak var hourInputL: UILabel!
    @IBOutlet weak var minuteInputL: UILabel!
    var type:ValueType!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
