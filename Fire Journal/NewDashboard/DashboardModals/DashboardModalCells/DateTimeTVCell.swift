//
//  DateTimeTVCell.swift
//  DashboardTest
//
//  Created by DuRand Jones on 1/28/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol DateTimeTVCellDelegate: AnyObject {
    func dateTimeBTapped()
}

class DateTimeTVCell: UITableViewCell {

//    MARK: -OBJECTS-
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var dateTimeTF: UITextField!
    @IBOutlet weak var dateTimeB: UIButton!
    
    weak var delegate: DateTimeTVCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//    MARK: -Actions-
    
    @IBAction func dateTimeBTapped(_ sender: Any) {
        delegate?.dateTimeBTapped()
    }
    
}
