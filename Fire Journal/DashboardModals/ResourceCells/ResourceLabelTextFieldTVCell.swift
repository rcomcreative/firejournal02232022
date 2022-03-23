//
//  ResourceManufacturerTVCell.swift
//  DashboardTest
//
//  Created by DuRand Jones on 2/5/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol ResourceLabelTextFieldTVCellDelegate: AnyObject {
    func resourceTFStartedEditing(text: String, row: Int)
    func resourceTFEndedEditing(text: String, row: Int)
}

class ResourceLabelTextFieldTVCell: UITableViewCell {

//    MARK: -PROPERTIES-
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var subjectTF: UITextField!
    
//    MARK: -OBJECTS-
    var row: Int = 0
    weak var delegate: ResourceLabelTextFieldTVCellDelegate? = nil
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension ResourceLabelTextFieldTVCell: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let count = textField.text {
            delegate?.resourceTFEndedEditing(text: count, row: row)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let count = textField.text {
                delegate?.resourceTFStartedEditing(text: count, row: row)
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if let count = textField.text {
            delegate?.resourceTFEndedEditing(text: count, row: row)
        }
        return true
    }
}
