//
//  NewICS214LabelTextFieldCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 7/7/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol NewICS214LabelTextFieldCellDelegate: AnyObject {
    func theTextFieldHasChanged(text: String, indexPath: IndexPath, tag: Int)
}

class NewICS214LabelTextFieldCell: UITableViewCell {

    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var descriptionTF: UITextField!
    
    private var indexPath = IndexPath(item: 0, section: 0)
    var path: IndexPath? {
        didSet {
            self.indexPath = self.path ?? IndexPath(item: 0, section: 0)
        }
    }
    
    private var theDescription = ""
    var described: String? {
        didSet {
            self.theDescription = self.described ?? ""
            self.descriptionTF.text = self.theDescription
        }
    }
    
    private var theSubject = ""
    var label: String? {
        didSet {
            self.theSubject = self.label ?? ""
            self.subjectL.text = self.theSubject
        }
    }
    
    weak var delegate: NewICS214LabelTextFieldCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

extension NewICS214LabelTextFieldCell: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let text = textField.text {
            print ("text has changed \(text)")
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text {
            delegate?.theTextFieldHasChanged(text: text, indexPath: indexPath, tag: self.tag)
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            delegate?.theTextFieldHasChanged(text: text, indexPath: indexPath, tag: self.tag)
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
