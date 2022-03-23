//
//  SubjectLabelTextViewTVCell.swift
//  DashboardTest
//
//  Created by DuRand Jones on 1/28/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol SubjectLabelTextViewTVCellDelegate: AnyObject {
    func subjectLabelTextViewEditing(text: String)
    func subjectLabelTextViewDoneEditing(text: String)
}

class SubjectLabelTextViewTVCell: UITableViewCell {
    
//    MARK: -Properties-
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var subjectTV: UITextView!
    weak var delegate: SubjectLabelTextViewTVCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        subjectTV.layer.borderColor = UIColor.lightGray.cgColor
        subjectTV.layer.borderWidth = 0.5
        subjectTV.layer.cornerRadius = 8.0

        subjectTV.delegate = self


    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension SubjectLabelTextViewTVCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if let text = textView.text {
            delegate?.subjectLabelTextViewEditing(text: text)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if let text = textView.text {
            delegate?.subjectLabelTextViewDoneEditing(text: text)
        }
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if let text = textView.text {
            delegate?.subjectLabelTextViewDoneEditing(text: text)
        }
        return true
    }
}
