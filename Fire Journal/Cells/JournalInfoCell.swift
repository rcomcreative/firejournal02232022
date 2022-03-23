//
//  JournalInfoCell.swift
//  dashboard
//
//  Created by DuRand Jones on 9/10/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit

protocol JournalInfoCellDelegate: AnyObject {
    func theInfoBTapped()
}

class JournalInfoCell: UITableViewCell,UITextFieldDelegate {
    //    MARK: -Objects
    @IBOutlet weak var infoB: UIButton!
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var userTF: UITextField!
    @IBOutlet weak var entryTypeTF: UITextField!
    @IBOutlet weak var fireStationTF: UITextField!
    @IBOutlet weak var platoonTF: UITextField!
    @IBOutlet weak var assignmentTF: UITextField!
    @IBOutlet weak var apparatusTF: UITextField!
    @IBOutlet weak var label1L: UILabel!
    @IBOutlet weak var label2L: UILabel!
    @IBOutlet weak var label3L: UILabel!
    @IBOutlet weak var label4L: UILabel!
    @IBOutlet weak var label5L: UILabel!
    @IBOutlet weak var label6L: UILabel!
    weak var delegate:JournalInfoCellDelegate? = nil
    

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    @IBAction func infoBTapped(_ sender: Any) {
        delegate?.theInfoBTapped()
    }
    
}
