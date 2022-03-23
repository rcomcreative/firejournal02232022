    //
    //  LabelSingleDateFieldCell.swift
    //  StationCommand
    //
    //  Created by DuRand Jones on 5/5/21.
    //

import UIKit

protocol LabelSingleDateFieldCellDelegate: AnyObject {
    func singleDatePickerTapped(index: IndexPath, tag: Int, date: Date)
}

class LabelSingleDateFieldCell: UITableViewCell {
    
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateHolderV: UIView!
    
    weak var delegate: LabelSingleDateFieldCellDelegate? = nil
    var chosenDate: Date!
    var index: IndexPath!
    
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
        if chosenDate != nil {
            datePicker.date = chosenDate
        } else {
            datePicker.date = Date()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
            // Configure the view for the selected state
    }
    
    @IBAction func datePickerTapped(_ sender: UIDatePicker, forEvent event: UIEvent) {
        theFirstDose = sender.date
        delegate?.singleDatePickerTapped(index: index, tag: self.tag, date: theFirstDose )
    }
    
    func configureDatePickersHoldingV() {
        let frame = self.dateHolderV.frame
        let width = frame.width + 100
        let height = frame.height
        let theX = frame.origin.x - 200
        self.dateHolderV.frame = CGRect(x: theX, y: frame.origin.y, width: width, height: height)
        self.dateHolderV.setNeedsDisplay()
    }
    
    func configureTheLabel(width: CGFloat) {
        let frame = self.subjectL.frame
        let width = frame.width + width
        let height = frame.height
        self.subjectL.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: width, height: height)
        self.subjectL.setNeedsDisplay()
    }
    
    
}
