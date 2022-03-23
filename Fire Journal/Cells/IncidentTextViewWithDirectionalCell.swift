//
//  IncidentTextViewWithDirectionalCell.swift
//  dashboard
//
//  Created by DuRand Jones on 8/23/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit

protocol IncidentTextViewWithDirectionalCellDelegate: AnyObject {
    func theIncidentDirectionalButtonWasTapped()
    func theIncidentTextViewIsFinishedEditing()
    func nfirsIncidentTypeInfoTapped()
    func nfirstIncidentTyped(code: String)
}

class IncidentTextViewWithDirectionalCell: UITableViewCell, UITextViewDelegate {

    
    //    MARK: -OBJECTS
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var descriptionTV: UITextView!
    @IBOutlet weak var directionalB: UIButton!
    @IBOutlet weak var nfirsInfoB: UIButton!
    
    //    MARK: -properties
    var myShift: MenuItems = .journal
    var editedText: Bool = false
    weak var delegate:IncidentTextViewWithDirectionalCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        descriptionTV.layer.borderColor = UIColor.lightGray.cgColor
        descriptionTV.layer.borderWidth = 0.5
        descriptionTV.layer.cornerRadius = 8.0
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
    
    
    //    MARK: -text view delegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        switch myShift {
        case .incidents:
            if editedText {} else {
                textView.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1.0)
                DispatchQueue.main.async {
                    textView.selectAll(nil)
                }
                editedText = true
            }
        default:break
        }
    }
    func textViewDidChange(_ textView: UITextView) {
        let text = textView.text ?? ""
        if text.count == 3 {
            delegate?.nfirstIncidentTyped(code: text)
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
    }
    
    //    MARK: -BUTTON ACTION
    @IBAction func incidentDirectionalBTapped(_ sender: Any) {
        delegate?.theIncidentDirectionalButtonWasTapped()
    }
    
    @IBAction func nfirsInfoBTapped(_ sender: Any) {
        delegate?.nfirsIncidentTypeInfoTapped()
    }
    
    
    
}
