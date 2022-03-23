//
//  DoubleTextFieldCell.swift
//  ARCForm
//
//  Created by DuRand Jones on 8/31/17.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

class DoubleTextFieldCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var inputLabelOne: UILabel!
    @IBOutlet weak var inputLabelTwo: UILabel!
    @IBOutlet weak var inputLabelThree: UILabel!
    @IBOutlet weak var inputLabelFour: UILabel!
    @IBOutlet weak var inputTextFieldOne: UITextField!
    @IBOutlet weak var inputTextFieldTwo: UITextField!
    @IBOutlet weak var inputTextFieldThree: UITextField!
    @IBOutlet weak var inputTextFieldFour: UITextField!
    var dateTo: Date!
    var dateFrom: Date!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
