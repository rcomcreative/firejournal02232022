//
//  TextViewCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/8/18.
//  Copyright © 2018 PureCommandLLC. All rights reserved.
//

import UIKit

protocol ARC_TextViewCellDelegate: AnyObject {
    func theTextInTextViewChanged(text: String,index: IndexPath, tag: Int)
    func theTextViewEditing(text: String, index: IndexPath, tag: Int)
}

class ARC_TextViewCell: UITableViewCell, UITextViewDelegate {

//    MARK: -OBJECTS-
    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var notesTV: UITextView!
    
//    MARK: -PROPERTIES-
    var completed: Bool!
    
    weak var delegate:ARC_TextViewCellDelegate? = nil
    
    private var indexPath = IndexPath(item: 0, section: 0)
    var path: IndexPath? {
        didSet {
            self.indexPath = self.path ?? IndexPath(item: 0, section: 0)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        notesTV.layer.borderColor = UIColor.lightGray.cgColor
        notesTV.layer.borderWidth = 0.5
        notesTV.layer.cornerRadius = 8.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if let text = textView.text {
            delegate?.theTextViewEditing(text: text, index: indexPath, tag: self.tag)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if let text = textView.text {
            delegate?.theTextInTextViewChanged(text: text, index: indexPath, tag: self.tag)
        }
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if let text = textView.text {
            delegate?.theTextInTextViewChanged(text: text, index: indexPath, tag: self.tag)
        }
        return true
    }
    
    
}
