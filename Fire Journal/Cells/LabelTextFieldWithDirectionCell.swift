//
//  LabelTextFieldWithDirectionCell.swift
//  dashboard
//
//  Created by DuRand Jones on 8/18/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit

protocol LabelTextFieldWithDirectionCellDelegate: AnyObject {
    func directionalBTapped(type: IncidentTypes)
    func directionalBJWasTapped(type: UserInfo)
    func theTextFieldHasBeenEdited(text: String, type:UserInfo)
    func theTextFieldHasBeenEdited2(text: String)
}

class LabelTextFieldWithDirectionCell: UITableViewCell,UITextFieldDelegate {
    
    //    MARK: -objects
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var descriptionTF: UITextField!
    @IBOutlet weak var moreB: UIButton!
    
    //    MARK: -PROPERTIES
    var myShift: MenuItems = .journal
    weak var delegate:LabelTextFieldWithDirectionCellDelegate? = nil
    var incidenttype:IncidentTypes!
    var userInfo: UserInfo!
    

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
    
    //    MARK: -BUTTON FUNC
    @IBAction func moreButtonTapped(_ sender: Any) {
        switch myShift {
        case .incidents:
            delegate?.directionalBTapped(type: incidenttype)
        case .journal:
            delegate?.directionalBJWasTapped(type: userInfo)
        default:
            print("no shift")
        }
    }
    
    //    MARK: -textFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let text = textField.text ?? ""
        switch myShift {
        case .incidents:
            delegate?.theTextFieldHasBeenEdited2(text: text)
        case .journal:
            delegate?.theTextFieldHasBeenEdited(text: text, type: userInfo)
        default:
            print("nothing here")
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let text = textField.text ?? ""
        switch myShift {
        case .incidents:
            delegate?.theTextFieldHasBeenEdited2(text: text)
        case .journal:
            delegate?.theTextFieldHasBeenEdited(text: text, type: userInfo)
        default:
            print("nothing here")
        }
    }

    
}
