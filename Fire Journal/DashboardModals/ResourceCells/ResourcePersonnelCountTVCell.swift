//
//  ResourcePersonnelCountTVCell.swift
//  DashboardTest
//
//  Created by DuRand Jones on 2/4/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol ResourcePersonnelCountTVCellDelegate: AnyObject {
    func resourcePersonnelStartedEditing(text: String, row: Int)
    func resourcePersonnelEndedEditing(text: String, row: Int)
}

class ResourcePersonnelCountTVCell: UITableViewCell {

//    MARK: -OBJECTS-
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var personnelNumberTF: UITextField!
    @IBOutlet weak var personnelCountB: UIButton!
    weak var delegate: ResourcePersonnelCountTVCellDelegate? = nil
    var row: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension ResourcePersonnelCountTVCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let count = textField.text {
            if count.isDigits {
                delegate?.resourcePersonnelEndedEditing(text: count, row: row)
            } else {
                textField.text = ""
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let count = textField.text {
            if count.isDigits {
                delegate?.resourcePersonnelStartedEditing(text: count, row: row)
            } else {
                textField.text = ""
            }
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if let count = textField.text {
                   if count.isDigits {
                       delegate?.resourcePersonnelEndedEditing(text: count, row: row)
                   } else {
                       textField.text = ""
                   }
               }
        return true
    }
}
