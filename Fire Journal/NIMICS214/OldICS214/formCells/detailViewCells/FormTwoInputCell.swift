//
//  FormTwoInputCell.swift
//  ARCForm
//
//  Created by DuRand Jones on 8/31/17.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit


protocol TwoFieldDelegate: AnyObject {
    func twoAnswersAndDateChosen(dateString:String,logActivity:String,activityDate:Date)
    func oneAnswerChosen()
    func timeButtonTapped()
}

class FormTwoInputCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var cellL: UILabel!
    @IBOutlet weak var inputLabelOne: UILabel!
    @IBOutlet weak var inputLabelTwo: UILabel!
    @IBOutlet weak var inputTextFieldOne: UITextField!
    @IBOutlet weak var inputTextFieldTwo: UITextField!
    
    @IBOutlet weak var inputButton: UIButton!
    
    @IBOutlet weak var timeButton: UIButton!
    
    var fieldOne: String!
    var fieldTwo: String!
    var inputDate: Date!
    var ics214Guid: String!
    
    weak var delegate: TwoFieldDelegate? = nil
    
    @IBAction func inputButtonTapped(_ sender: Any) {
        fieldOne = inputTextFieldOne.text
        fieldTwo = inputTextFieldTwo.text
        
        if fieldTwo.isEmpty {
            delegate?.oneAnswerChosen();
        } else {
            delegate?.twoAnswersAndDateChosen(dateString: fieldOne, logActivity: fieldTwo, activityDate: inputDate)
        }
    }
    
    @IBAction func timeBTapped(_ sender: Any) {
        delegate?.timeButtonTapped()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
