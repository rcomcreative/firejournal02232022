//
//  ARC_DatePickerCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 7/7/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol ARC_DatePickerCellDelegate: AnyObject {
    func theDatePickerChangedDate(_ date:Date, at indexPath: IndexPath, tag: Int)
}

class ARC_DatePickerCell: UITableViewCell {

//    MARK: -PROPERTIES-
    @IBOutlet weak var datePickerV: UIView!
    @IBOutlet weak var theDatePicker: UIDatePicker!
    
//    MARK: -PROPERTIES-
    private var pickerDate:Date!
    
    weak var delegate: ARC_DatePickerCellDelegate? = nil
    
    private var indexPath = IndexPath(item: 0, section: 0)
    var path: IndexPath? {
        didSet {
            self.indexPath = self.path ?? IndexPath(item: 0, section: 0)
        }
    }
    
    var pDate: Date? {
        didSet {
            self.pickerDate = self.pDate ?? Date()
        }
    }
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func theDatePickerTapped(_ sender: Any) {
        pDate = theDatePicker.date
        delegate?.theDatePickerChangedDate(pickerDate, at: indexPath, tag: self.tag )
    }
    
    
}
