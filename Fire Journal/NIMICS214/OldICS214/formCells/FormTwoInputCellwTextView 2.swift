//
//  FormTwoInputCell.swift
//  ARCForm
//
//  Created by DuRand Jones on 8/31/17.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol TwoInputCellwTextViewDelegate: AnyObject {
    func twoAnswersChosenWTV(array: Array<Any>)
    func timeButtonTappedWTV()
    func timeButtonTapped()
    func oneAnswerChosen()
    func twoAnswersAndDateChosen(dateString:String,logActivity:String,activityDate:Date)
    func textViewHasBegunChanging()
}

class FormTwoInputCellwTextView: UITableViewCell, UITextFieldDelegate,UITextViewDelegate {

    @IBOutlet weak var cellL: UILabel!
    @IBOutlet weak var inputLabelOne: UILabel!
    @IBOutlet weak var inputLabelTwo: UILabel!
    @IBOutlet weak var inputTextFieldOne: UITextField!
    @IBOutlet weak var inputTextFieldTwo: UITextField!
    
    @IBOutlet weak var inputTwoTV: UITextView!
    @IBOutlet weak var inputButton: UIButton!
    
    @IBOutlet weak var timeButton: UIButton!
    
    var fieldOne: String!
    var fieldTwo: String!
    var inputDate: Date!
    
    weak var delegate: TwoInputCellwTextViewDelegate? = nil
    
    @IBAction func inputButtonTapped(_ sender: Any) {
        fieldOne = inputTextFieldOne.text
        fieldTwo = inputTwoTV.text
//        let a: [String?] = [fieldOne,fieldTwo]
//        let b = a.flatMap{ $0 }
        if fieldTwo.isEmpty {
            delegate?.oneAnswerChosen()
        } else {
            delegate?.twoAnswersAndDateChosen(dateString:fieldOne,logActivity:fieldTwo,activityDate:inputDate)
        }
    }
    
    @IBAction func timeBTapped(_ sender: Any) {
        delegate?.timeButtonTapped()
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        inputTwoTV.layer.borderColor = UIColor.lightGray.cgColor
        inputTwoTV.layer.borderWidth = 0.5
        inputTwoTV.layer.cornerRadius = 8.0
        inputButton.isEnabled = false
        inputButton.alpha = 0.0
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView == inputTwoTV {
            inputButton.isEnabled = true
            inputButton.alpha = 1.0
        }
        return true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
