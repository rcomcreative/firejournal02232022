//
//  NewICS214DatePickerCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 7/7/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol NewICS214DatePickerCellDelegate: AnyObject {
    func theDatePickerChangedDate(_ date:Date, at indexPath: IndexPath)
}

class NewICS214DatePickerCell: UITableViewCell {

    @IBOutlet weak var datePickerV: UIView!
    @IBOutlet weak var theDatePicker: UIDatePicker!
    
    var pickerDate:Date!
    
    weak var delegate: NewICS214DatePickerCellDelegate? = nil
    
    private var indexPath = IndexPath(item: 0, section: 0)
    var path: IndexPath? {
        didSet {
            self.indexPath = self.path ?? IndexPath(item: 0, section: 0)
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
        pickerDate = theDatePicker.date
        delegate?.theDatePickerChangedDate(pickerDate, at: indexPath)
    }
    
    
}
