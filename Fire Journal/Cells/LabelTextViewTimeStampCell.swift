//
//  LabelTextViewTimeStampCell.swift
//  dashboard
//
//  Created by DuRand Jones on 9/11/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit

protocol LabelTextViewTimeStampCellDelegate: AnyObject {
    func timeStampTapped(type:JournalTypes)
    func tsTextViewEdited(text: String, journalType: JournalTypes, myShift: MenuItems)
    func tsTextViewEndedEditing(text: String, journalType: JournalTypes, myShift: MenuItems)
}

class LabelTextViewTimeStampCell: UITableViewCell,UITextViewDelegate {
    //    MARK: -objects
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var descriptionTV: UITextView!
    @IBOutlet weak var timeB: UIButton!
    //    MARK: -Properties
    var myShift: MenuItems!
    var switchTypes: SwitchTypes!
    var journalType: JournalTypes!
    var buttonTapped: Bool = false
    
    weak var delegate:LabelTextViewTimeStampCellDelegate? = nil
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        descriptionTV.layer.borderColor = UIColor.lightGray.cgColor
        descriptionTV.layer.borderWidth = 0.5
        descriptionTV.layer.cornerRadius = 8.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

    @IBAction func timeBTapped(_ sender: Any) {
        buttonTapped = true
        delegate?.timeStampTapped(type:journalType)
    }
    
    //    MARK: -text view delegate
    func textViewDidChange(_ textView: UITextView) {
        let text = textView.text ?? ""
        delegate?.tsTextViewEdited(text: text, journalType: journalType, myShift: myShift)
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        let text = textView.text ?? ""
        
        if buttonTapped {} else {
        delegate?.tsTextViewEndedEditing(text: text, journalType: journalType, myShift: myShift)
        }
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        let text = textView.text ?? ""
        if buttonTapped {} else {
            delegate?.tsTextViewEndedEditing(text: text, journalType: journalType, myShift: myShift)
        }
        return true
    }
}
