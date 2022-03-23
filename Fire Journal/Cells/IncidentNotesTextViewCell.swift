//
//  IncidentNotesTextViewCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 12/11/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol IncidentNotesTextViewCellDelegate: AnyObject {
    func incidentTextViewEditing(text: String, myShift: MenuItems, incidentType: IncidentTypes)
    func incidentTextViewDoneEditing(text: String, myShift: MenuItems, incidentType: IncidentTypes)
    func supportNotesBTapped()
    func incidentAndSupportNotesInfoBTapped()
}

class IncidentNotesTextViewCell: UITableViewCell, UITextViewDelegate {
    //    MARK: -properties
    weak var delegate:IncidentNotesTextViewCellDelegate? = nil
    var myShift: MenuItems = .journal
    var journalType: JournalTypes!
    var incidentType: IncidentTypes!
    

    //    MARK: -objects
    @IBOutlet weak var supportNotesL: UILabel!
    @IBOutlet weak var supportNotesDirectionB: UIButton!
    @IBOutlet weak var infoB: UIButton!
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var descriptionTV: UITextView!
    @IBOutlet weak var notesAvailableB: UIButton!
    
    //    MARK: -ACTION BUTTONS
    @IBAction func infoBTapped(_ sender: Any) {
        delegate?.incidentAndSupportNotesInfoBTapped()
    }
    
    @IBAction func directionalBTapped(_ sender: Any) {
        delegate?.supportNotesBTapped()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        descriptionTV.layer.borderColor = UIColor.lightGray.cgColor
        descriptionTV.layer.borderWidth = 0.5
        descriptionTV.layer.cornerRadius = 8.0
        // Initialization code
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
            delegate?.incidentTextViewEditing(text: text, myShift: myShift,incidentType:incidentType)
        default:
            print("no go")
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        let text = textView.text ?? ""
        switch myShift {
        case .incidents:
            delegate?.incidentTextViewDoneEditing(text: text, myShift: myShift,incidentType:incidentType)
        default:
            print("no go")
        }
    }
    
}
