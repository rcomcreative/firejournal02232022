//
//  NewICS214ActivityLogCompleteCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 6/25/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol NewICS214ActivityLogCompleteCellDelegate: AnyObject {
    func activityLogCompleteAddBTapped(activityLog:  ICS214ActivityLog, position: Int)
    func activityLogHasChanged(activityLog: ICS214ActivityLog, position: Int, path: IndexPath)
    func activityLogDateBTapped(activityLog: ICS214ActivityLog, position: Int, path: IndexPath)
}

class NewICS214ActivityLogCompleteCell: UITableViewCell {
    
    @IBOutlet weak var timeDateTF: UITextField!
    @IBOutlet weak var logTV: UITextView!
    @IBOutlet weak var addB: UIButton!
    @IBOutlet weak var changeDateB: UIButton!
    
    private var theActivityLog: String = ""
    var activityLog: String? {
        didSet {
            self.theActivityLog = activityLog ?? ""
            self.logTV.text = self.activityLog
        }
    }
    
    private var dateTimeText: String = ""
    var dateTime: String? {
        didSet {
            self.dateTimeText = dateTime ?? ""
            self.timeDateTF.text = self.dateTimeText
        }
    }
    
    private var log = ICS214ActivityLog()
    var aLog: ICS214ActivityLog? {
        didSet {
            self.log = self.aLog ?? ICS214ActivityLog()
            self.dateTime = self.log.ics214ActivityStringDate
            self.activityLog = self.log.ics214ActivityLog
            self.addB.isHidden = true
            self.addB.isEnabled = false
            self.addB.alpha = 0.0
        }
    }
    
    private var arrayPosition: Int = 0
    var position: Int? {
        didSet {
            self.arrayPosition = self.position ?? 0
        }
    }
    
    private var indexPath: IndexPath = IndexPath(row: 0, section: 0)
    var path: IndexPath? {
        didSet {
            self.indexPath = self.path ?? IndexPath(row: 0, section: 0)
        }
    }
    
    
    
    weak var delegate: NewICS214ActivityLogCompleteCellDelegate? = nil
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        logTV.layer.borderColor = UIColor.lightGray.cgColor
        logTV.layer.borderWidth = 0.5
        logTV.layer.cornerRadius = 8.0
        addB.layer.cornerRadius = 8.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func addBTapped(_ sender: Any) {
        _ = textViewShouldEndEditing(logTV)
        delegate?.activityLogCompleteAddBTapped(activityLog: log, position: arrayPosition )
        UIView.animate(withDuration: 0.5, animations: {
            self.addB.isHidden = true
            self.addB.isEnabled = false
            self.addB.alpha = 0.0
        })
    }
    
    @IBAction func changeDateBTapped(_ sender: Any) {
        delegate?.activityLogDateBTapped(activityLog: self.log, position: arrayPosition, path: indexPath)
    }
    
    
}

extension NewICS214ActivityLogCompleteCell: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if let log = textView.text {
            theActivityLog = log
            UIView.animate(withDuration: 0.5, animations: {
                self.addB.isHidden = false
                self.addB.isEnabled = true
                self.addB.alpha = 100.0
            })
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        UIView.animate(withDuration: 0.5, animations: {
            self.addB.isHidden = false
            self.addB.isEnabled = true
            self.addB.alpha = 100.0
        })
        if let log = textView.text {
            theActivityLog = log
            self.log.ics214ActivityLog = theActivityLog
            delegate?.activityLogHasChanged(activityLog: self.log, position: arrayPosition, path: indexPath)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if let log = textView.text {
            theActivityLog = log
            self.log.ics214ActivityLog = theActivityLog
        }
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if let log = textView.text {
            theActivityLog = log
            self.log.ics214ActivityLog = theActivityLog
        }
        return true
    }
    
}
