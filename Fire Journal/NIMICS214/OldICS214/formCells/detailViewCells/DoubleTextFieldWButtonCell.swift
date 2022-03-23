//
//  DoubleTextFieldCell.swift
//  ARCForm
//
//  Created by DuRand Jones on 8/31/17.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit


@objc protocol OneButtonCellDelegate: AnyObject {

    func bOneTapped(date: Date )
    func fourTextFieldsTF1(string: String)
    func fourTextFieldsTF2(string: String)
    func fourTextFieldsTF3(string: String)
    func fourTextFieldsTF4(string: String)
    @objc optional func signatureButtonTapped()
}

class DoubleTextFieldWButtonCell: UITableViewCell, UITextFieldDelegate {

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
    @IBOutlet weak var signatureIV: UIImageView!
    
    @IBOutlet weak var timeButton: UIButton!
    weak var delegate: OneButtonCellDelegate? = nil
    @IBOutlet weak var signatureB: UIButton!
    @IBAction func signatureBTapped(_ sender: Any) {
        delegate?.signatureButtonTapped!()
    }
    
    
    @IBAction func timeButtonTapped(_ sender: Any) {
        let date = Date()
        delegate?.bOneTapped(date: date)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField == inputTextFieldOne {
            if let input:String = inputTextFieldOne.text {
                delegate?.fourTextFieldsTF1(string: input)
            }
        } else if textField == inputTextFieldTwo {
            if let input:String = inputTextFieldTwo.text {
                delegate?.fourTextFieldsTF2(string: input)
            }
        } else if textField == inputTextFieldThree {
            if let input:String = inputTextFieldThree.text {
                delegate?.fourTextFieldsTF3(string: input)
            }
        } else if textField == inputTextFieldFour {
            if let input:String = inputTextFieldFour.text {
                delegate?.fourTextFieldsTF4(string: input)
            }
        }
        return true
    }
    
}
