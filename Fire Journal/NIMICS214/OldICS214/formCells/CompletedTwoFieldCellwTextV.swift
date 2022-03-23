//
//  CompletedTwoFieldCell.swift
//  ARCForm
//
//  Created by DuRand Jones on 9/1/17.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

class CompletedTwoFieldCellwTextV: UITableViewCell, UITextFieldDelegate {
    @IBOutlet weak var inputTextFieldOne: UITextField!
    @IBOutlet weak var inputTextFieldTwo: UITextField!
    
    @IBOutlet weak var inputTwoTV: UITextView!
    
    var inputDate: Date!
    var inputAction: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        inputTwoTV.layer.borderColor = UIColor.lightGray.cgColor
        inputTwoTV.layer.borderWidth = 0.5
        inputTwoTV.layer.cornerRadius = 8.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
