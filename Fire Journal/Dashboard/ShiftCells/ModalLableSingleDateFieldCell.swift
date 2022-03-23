//
//  ModalLableSingleDateFieldCell.swift
//  StationCommand
//
//  Created by DuRand Jones on 12/28/21.
//

import UIKit

protocol ModalLableSingleDateFieldCellDelegate: AnyObject {
    func modalSingleDatePickerTapped(index: IndexPath, tag: Int, date: Date)
}

class ModalLableSingleDateFieldCell: UITableViewCell {
    
    weak var delegate: ModalLableSingleDateFieldCellDelegate? = nil
    
    @IBOutlet weak var dateHolderVleading1: NSLayoutConstraint!
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateHolderV: UIView!

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
        delegate?.modalSingleDatePickerTapped(index: index, tag: self.tag, date: theFirstDose )
    }
    
    func configureDatePickersHoldingV() {
        let frame = self.dateHolderV.frame
        let width = frame.width + 100
        let height = frame.height
        let theX = frame.origin.x - 100
        self.dateHolderV.frame = CGRect(x: theX, y: frame.origin.y, width: width, height: height)
        self.dateHolderV.setNeedsDisplay()
    }
    
}
