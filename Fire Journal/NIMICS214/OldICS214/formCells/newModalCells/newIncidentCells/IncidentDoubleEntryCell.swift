//
//  IncidentDoubleEntryCell.swift
//  ARCForm
//
//  Created by DuRand Jones on 10/30/17.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

class IncidentDoubleEntryCell: UITableViewCell {

    var type:ValueType!
    @IBOutlet weak var incidentInput1TF: UITextField!
    @IBOutlet weak var incidentInput2TF: UITextField!
    @IBOutlet weak var incidentOneL: UILabel!
    @IBOutlet weak var incidentTwoL: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
