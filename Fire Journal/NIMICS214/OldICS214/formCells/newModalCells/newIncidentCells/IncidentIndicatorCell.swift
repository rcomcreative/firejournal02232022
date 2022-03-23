//
//  IncidentIndicatorCell.swift
//  ARCForm
//
//  Created by DuRand Jones on 10/30/17.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit


protocol IncidentIndicatorCellDelegate: AnyObject {

 func indicatorTextFieldFilled(type:ValueType,input:String)

}

class IncidentIndicatorCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var incidentTitleL: UILabel!
    @IBOutlet weak var incidentInputTF: UITextField!
    var type: ValueType?
    
    weak var delegate: IncidentIndicatorCellDelegate? = nil
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
