//
//  NewICS214DateTimeCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 6/12/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol NewICS214DateTimeCellDelegate: AnyObject {
    func theTimeBTapped(tag: Int)
}

class NewICS214DateTimeCell: UITableViewCell {
    @IBOutlet weak var dateL: UILabel!
    @IBOutlet weak var timeL: UILabel!
    @IBOutlet weak var dateTF: UITextField!
    @IBOutlet weak var timeTF: UITextField!
    @IBOutlet weak var timeB: UIButton!
    
    private var dateName = ""
    var dName: String? {
        didSet {
            self.dateName = self.dName ?? ""
            self.dateL.text = self.dateName
        }
    }
    
    private var timeName = ""
    var tName: String? {
        didSet {
            self.timeName = self.tName ?? ""
            self.timeL.text = self.timeName
        }
    }
    
    private var dateText = ""
    var dateT: String? {
        didSet {
            self.dateText = self.dateT ?? ""
            self.dateTF.text = self.dateText
        }
    }
    
    private var timeText = ""
    var timeT: String? {
        didSet {
            self.timeText = self.timeT ?? ""
            self.timeTF.text = self.timeText
        }
    }
    
    weak var delegate: NewICS214DateTimeCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func timeBTapped(_ sender: Any) {
        delegate?.theTimeBTapped(tag: self.tag )
    }
    
}
