//
//  TextViewCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/8/18.
//  Copyright © 2018 PureCommandLLC. All rights reserved.
//

import UIKit

protocol ARCTextViewCellDelegate:class {
    func theTextInTextViewChanged(text:String,section: Sections)
    func theTextViewCompleted(complete: Bool)
}

class ARCTextViewCell: UITableViewCell,UITextViewDelegate {

    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var notesTV: UITextView!
    var section: Sections!
    var completed: Bool!
    
    weak var delegate:ARCTextViewCellDelegate? = nil
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if completed {} else {
            delegate?.theTextViewCompleted(complete: completed)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("here we are")
        delegate?.theTextInTextViewChanged(text: notesTV.text,section: section)
    }
    
}
