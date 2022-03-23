//
//  LabelTextViewDirectionalCell.swift
//  dashboard
//
//  Created by DuRand Jones on 8/18/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit

protocol LabelTextViewDirectionalCellDelegate: AnyObject {
    func theDirectionalButtonWasTapped(type:JournalTypes)
    func theTextViewIsFinishedEditing(type:JournalTypes,text:String)
}

class LabelTextViewDirectionalCell: UITableViewCell, UITextViewDelegate {
    
    //    MARK: -OBJECTS
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var descriptionTV: UITextView!
    @IBOutlet weak var directionalB: UIButton!
    //    MARK: -properties
    var myShift: MenuItems = .journal
    var journalType: JournalTypes!
    weak var delegate:LabelTextViewDirectionalCellDelegate? = nil
    

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
    
    //    MARK: -button action
    
    @IBAction func directionalBTapped(_ sender: Any) {
        delegate?.theDirectionalButtonWasTapped(type: journalType)
    }
    
    
    
    //    MARK: -text view delegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        switch myShift {
        case .nfirsBasic1Search:
            if textView.textColor == UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.45) {
                textView.text = nil
                textView.textColor = UIColor.black
            }
        default: break
        }
    }
    func textViewDidChange(_ textView: UITextView) {
//        print(textView.text)
    }
    func textViewDidEndEditing(_ textView: UITextView) {
//        print(textView.text)
    }
    
}
