//
//  LabelDateiPhoneTVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/28/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol LabelDateiPhoneTVCellDelegate: AnyObject {
    func theDatePickerTapped(_ theDate: Date, index: IndexPath)
}

class LabelDateiPhoneTVCell: UITableViewCell {

    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    weak var delegate: LabelDateiPhoneTVCellDelegate? = nil
    var index: IndexPath!
    
    var chosenDate: Date!
    
    private var subject1: String = ""
    var theSubject: String = "" {
        didSet {
            self.subject1 = self.theSubject
            self.subjectL.text = self.subject1
        }
    }
    
    private var date1: Date!
    var theFirstDose = Date() {
        didSet {
            self.date1 = self.theFirstDose
            datePicker.date = date1
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func datePickerTapped(_ sender: UIDatePicker) {
        let theDate = sender.date
        delegate?.theDatePickerTapped(theDate, index: index)
    }
    
    
}
