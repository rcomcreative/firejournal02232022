//
//  CompletedTwoFieldCell.swift
//  ARCForm
//
//  Created by DuRand Jones on 9/1/17.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

class CompletedTwoFieldCell: UITableViewCell, UITextFieldDelegate {
    @IBOutlet weak var inputTextFieldOne: UITextField!
    @IBOutlet weak var inputTextFieldTwo: UITextField!
    var inputDate: Date!
    var inputAction: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
