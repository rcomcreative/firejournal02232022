//
//  LabelDateTimeButtonCell.swift
//  dashboard
//
//  Created by DuRand Jones on 8/18/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit

protocol LabelDateTimeButtonCellDelegate: AnyObject {
    func dateTimeButtonTapped(type: IncidentTypes)
}

class LabelDateTimeButtonCell: UITableViewCell, UITextFieldDelegate {
    
    //    MARK: -Objects
    @IBOutlet weak var dateTimeTV: UITextField!
    @IBOutlet weak var dateTimeL: UILabel!
    @IBOutlet weak var dateTimeB: UIButton!
    //    MARK: -Properties
    var dateBTappedB:Bool = false
    weak var delegate: LabelDateTimeButtonCellDelegate? = nil
    var myShift: MenuItems! = nil
    var type: IncidentTypes!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func dateTimeButtonTapped(_ sender: Any) {
        delegate?.dateTimeButtonTapped(type: type)
    }
    
    //    MARK: -textFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print(textField.text ?? "nothing to see here")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print(textField.text ?? "nothing to see here")
    }
    
    
}
