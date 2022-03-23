//
//  NewICS214ActivityLogCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 6/25/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol NewICS214ActivityLogCellDelegate: AnyObject {
    func timeButtonTapped(path: IndexPath)
    func addButtonTapped(path: IndexPath)
    func textForActivityLogIsDone(text: String, path: IndexPath)
    func textHasBeenAddedToActivityLog(text: String, path: IndexPath)
}

class NewICS214ActivityLogCell: UITableViewCell {
    @IBOutlet weak var timeB: UIButton!
    @IBOutlet weak var timeTF: UITextField!
    @IBOutlet weak var notableTV: UITextView!
    @IBOutlet weak var addB: UIButton!
    
    private var indexPath = IndexPath(item: 0, section: 0)
    var path: IndexPath? {
        didSet {
            self.indexPath = self.path ?? IndexPath(item: 0, section: 0)
        }
    }
    
    private var theDateTime = ""
    var dateTime: String? {
        didSet {
            self.theDateTime = self.dateTime ?? ""
            self.timeTF.text = theDateTime
            if self.theDateTime != "" {
                UIView.animate(withDuration: 0.5, animations: {
                    self.addB.isHidden = false
                    self.addB.isEnabled = true
                    self.addB.alpha = 1.0
                })
            }
        }
    }
    
    weak var delegate: NewICS214ActivityLogCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        notableTV.layer.borderColor = UIColor.lightGray.cgColor
        notableTV.layer.borderWidth = 0.5
        notableTV.layer.cornerRadius = 8.0
        addB.layer.cornerRadius = 8.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func timeBTapped(_ sender: Any) {
        delegate?.timeButtonTapped(path: indexPath)
    }
    
    @IBAction func addBTapped(_ sender: Any) {
        delegate?.addButtonTapped(path: indexPath)
    }
    
}

extension NewICS214ActivityLogCell: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.5, animations: {
            self.addB.isHidden = false
            self.addB.isEnabled = true
            self.addB.alpha = 100.0
        })
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if let text = textView.text {
            delegate?.textHasBeenAddedToActivityLog(text: text, path: indexPath)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if let text = textView.text {
            delegate?.textForActivityLogIsDone(text: text, path: indexPath)
        }
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if let text = textView.text {
            delegate?.textForActivityLogIsDone(text: text, path: indexPath)
        }
        return true
    }
    
}
