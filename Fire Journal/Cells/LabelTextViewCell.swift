//
//  LabelTextViewCell.swift
//  dashboard
//
//  Created by DuRand Jones on 8/18/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit
import Foundation

protocol LabelTextViewCellDelegate: AnyObject {
    func textViewEditing(text: String, myShift: MenuItems, journalType: JournalTypes)
    func textViewDoneEditing(text: String, myShift: MenuItems, journalType: JournalTypes)
    func textViewEditing(text: String, myShift: MenuItems, incidentType: IncidentTypes)
    func textViewDoneEditing(text: String, myShift: MenuItems, incidentType: IncidentTypes)
}

class LabelTextViewCell: UITableViewCell, UITextViewDelegate {

    //    MARK: -objects
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var descriptionTV: UITextView!
    //    MARK: -properties
    weak var delegate:LabelTextViewCellDelegate? = nil
    var myShift: MenuItems = .journal
    var journalType: JournalTypes!
    var incidentType: IncidentTypes!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        descriptionTV.layer.borderColor = UIColor.lightGray.cgColor
        descriptionTV.layer.borderWidth = 0.5
        descriptionTV.layer.cornerRadius = 8.0
//        descriptionTV.backgroundColor = UIColor.blue as? CGColor
    }

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let text = textView.text ?? ""
        switch myShift {
        case .incidents:
            delegate?.textViewEditing(text: text, myShift: myShift,incidentType:incidentType)
        case .journal:
            delegate?.textViewEditing(text: text, myShift: myShift,journalType:journalType)
        case .personal:
            delegate?.textViewEditing(text: text, myShift: myShift,journalType:journalType)
        case .startShift:
            delegate?.textViewEditing(text: text, myShift: myShift,journalType:journalType)
        case .endShift:
            delegate?.textViewEditing(text: text, myShift: myShift,journalType:journalType)
        case .updateShift:
            delegate?.textViewEditing(text: text, myShift: myShift,journalType:journalType)
        default:
            print("no go")
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let text = textView.text ?? ""
        switch myShift {
        case .incidents:
            delegate?.textViewDoneEditing(text: text, myShift: myShift,incidentType:incidentType)
        case .journal:
            delegate?.textViewDoneEditing(text: text, myShift: myShift,journalType:journalType)
        case .personal:
            delegate?.textViewDoneEditing(text: text, myShift: myShift,journalType:journalType)
        case .startShift:
            delegate?.textViewDoneEditing(text: text, myShift: myShift,journalType:journalType)
        case .updateShift:
            delegate?.textViewDoneEditing(text: text, myShift: myShift,journalType:journalType)
        case .endShift:
            delegate?.textViewDoneEditing(text: text, myShift: myShift,journalType:journalType)
        default:
            print("no go")
        }
    }
    
}
