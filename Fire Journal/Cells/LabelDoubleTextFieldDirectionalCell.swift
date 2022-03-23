//
//  LabelDoubleTextFieldDirectionalCell.swift
//  dashboard
//
//  Created by DuRand Jones on 9/13/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit

protocol LabelDoubleTextFieldDirectionalCellDelegate: AnyObject {
    func twoTFDirectionalBTapped(type:IncidentTypes)
    func twoTFBeganEditing(text:String,myShift:MenuItems,incidentType:IncidentTypes)
    func twoTFDidFinishEditing(text:String,myShift:MenuItems,incidentType:IncidentTypes)
}

class LabelDoubleTextFieldDirectionalCell: UITableViewCell,UITextFieldDelegate {
    
    //    MARK: -OBJECTS
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var directionalB: UIButton!
    @IBOutlet weak var firstDescriptionTF: UITextField!
    @IBOutlet weak var secondDescriptionTF: UITextField!
    //    MARK: -PROPERTIES
    var myShift: MenuItems!
    weak var delegate: LabelDoubleTextFieldDirectionalCellDelegate? = nil
    var incidentType: IncidentTypes!
    

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
    
    //    MARK: -BUTTON ACTION
    @IBAction func directionalBTapped(_ sender: Any) {
        delegate?.twoTFDirectionalBTapped(type: incidentType)
    }
    
    //    MARK: -textFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let text = textField.text ?? ""
        delegate?.twoTFBeganEditing(text: text, myShift: myShift,incidentType: incidentType)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let text = textField.text ?? ""
        delegate?.twoTFDidFinishEditing(text:text,myShift:myShift,incidentType:incidentType)
    }
    
}
