//
//  FormQuestionTFCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/12/18.
//  Copyright © 2018 PureCommandLLC. All rights reserved.
//

import UIKit

protocol FormQuestionTFCellDelegate:class {
    func singleTextFieldInput(type: ValueType, input: String )
    func singleTextFieldInputWithForm(type: CellType, input: String, section:Sections )
    func singleTextFieldCompleted(complete: Bool)
}

class FormQuestionTFCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var answerTF: UITextField!
    @IBOutlet weak var questionL: UILabel!
    var formField: String!
    var value: ValueType!
    var aForm: String = ""
    var cellType: CellType!
    var section: Sections!
    var completed: Bool!
    
    weak var delegate:FormQuestionTFCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func becomeFirstResponder() -> Bool {
        if completed {
            self.answerTF.layer.borderWidth = 2
            self.answerTF.layer.borderColor = UIColor.fjColor.fireOrange.cgColor
            super.becomeFirstResponder()
        }
        return true
    }
    
    override func resignFirstResponder() -> Bool {
        self.answerTF.layer.borderWidth = 1
        self.answerTF.layer.borderColor = UIColor.clear.cgColor
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if completed {
            switch section {
            case .NumNewSA?:
                self.answerTF.keyboardType = .numbersAndPunctuation
            case .NumBellShaker?:
                self.answerTF.keyboardType = .numbersAndPunctuation
            case .NumBatteriesReplaced?:
                self.answerTF.keyboardType = .numbersAndPunctuation
            case .DescHazard?:
                self.answerTF.keyboardType = .default
            case .IANumPeople?:
                self.answerTF.keyboardType = .numbersAndPunctuation
            case .IA17Under?:
                self.answerTF.keyboardType = .numbersAndPunctuation
            case .IA65Over?:
                self.answerTF.keyboardType = .numbersAndPunctuation
            case .IADisability?:
                self.answerTF.keyboardType = .numbersAndPunctuation
            case .IAVets?:
                self.answerTF.keyboardType = .numbersAndPunctuation
            case .IAPrexistingSA?:
                self.answerTF.keyboardType = .numbersAndPunctuation
            case .IAWorkingSA?:
                self.answerTF.keyboardType = .numbersAndPunctuation
            case .NationalPartner?:
                self.answerTF.keyboardType = .default
            case .LocalPartner?:
                self.answerTF.keyboardType = .default
            case .Option1?:
                self.answerTF.keyboardType = .default
            case .Option2?:
                self.answerTF.keyboardType = .default
            case .ResidentCellNum?:
                self.answerTF.keyboardType = .numbersAndPunctuation
            case .ResidentEmail?:
                self.answerTF.keyboardType = .emailAddress
            case .ResidentOtherPhone?:
                self.answerTF.keyboardType = .numbersAndPunctuation
            case .AdminName?:
                self.answerTF.keyboardType = .default
            default:
                self.answerTF.keyboardType = .default
            }
        } else {
            delegate?.singleTextFieldCompleted(complete: completed)
        }
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if let input:String = answerTF.text {
            if aForm == "" {
                delegate?.singleTextFieldInput(type: value, input: input )
            } else {
                delegate?.singleTextFieldInputWithForm(type: cellType, input: input, section:section )
            }
        }
        return true
    }
    
}
