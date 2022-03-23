//
//  ARC_LabelTextViewCell.swift
//  dashboard
//
//  Created by DuRand Jones on 8/18/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit
import Foundation

protocol ARC_LabelTextViewCellDelegate: AnyObject {
    func textViewEditing(text: String, indexPath: IndexPath)
    func textViewDoneEditing(text: String, indexPath: IndexPath)
}

class ARC_LabelTextViewCell: UITableViewCell, UITextViewDelegate {

    //    MARK: -objects
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var descriptionTV: UITextView!
    //    MARK: -properties
    weak var delegate:ARC_LabelTextViewCellDelegate? = nil
    
    private var indexPath = IndexPath(item: 0, section: 0)
    var path: IndexPath? {
        didSet {
            self.indexPath = self.path ?? IndexPath(item: 0, section: 0)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        descriptionTV.layer.borderColor = UIColor.lightGray.cgColor
//        descriptionTV.layer.borderWidth = 0.5
//        descriptionTV.layer.cornerRadius = 8.0
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
            delegate?.textViewEditing(text: text, indexPath: indexPath)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let text = textView.text ?? ""
        delegate?.textViewDoneEditing(text: text, indexPath: indexPath)
    }
    
}
