//
//  ResourceLabelTextViewTVCell.swift
//  DashboardTest
//
//  Created by DuRand Jones on 2/5/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol ResourceLabelTextViewTVCellDelegate: AnyObject {
    func ResourceTextViewEditing(text: String)
    func ResourceTextViewEnded(text: String)
}

class ResourceLabelTextViewTVCell: UITableViewCell {

//    MARK: -OBJECTS-
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var subjectTV: UITextView!
    
//    MARK: -PROPERTIES-
    weak var delegate: ResourceLabelTextViewTVCellDelegate? = nil
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        subjectTV.layer.borderColor = UIColor.lightGray.cgColor
        subjectTV.layer.borderWidth = 0.5
        subjectTV.layer.cornerRadius = 8.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension ResourceLabelTextViewTVCell: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if let description = textView.text {
            delegate?.ResourceTextViewEditing(text: description)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if let description = textView.text {
            delegate?.ResourceTextViewEnded(text: description)
        }
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if let description = textView.text {
            delegate?.ResourceTextViewEnded(text: description)
        }
        return true
    }
}
