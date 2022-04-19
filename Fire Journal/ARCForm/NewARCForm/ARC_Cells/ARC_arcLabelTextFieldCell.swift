//
//  ARC_arcLabelTextFieldCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 7/7/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol ARC_arcLabelTextFieldCellDelegate: AnyObject {
    func theTextFieldHasChanged(text: String, indexPath: IndexPath, tag: Int)
    func theTextFieldTextIsChanging(text: String, indexPath: IndexPath, tag: Int)
    func theTextFieldHitReturnKey(text: String, indexPath: IndexPath, tag: Int)
}

class ARC_arcLabelTextFieldCell: UITableViewCell {
    
    //    MARK: -OBJECTS-
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var descriptionTF: UITextField!
    
    //    MARK: -PROPERTIES-
    private var indexPath = IndexPath(item: 0, section: 0)
    var path: IndexPath? {
        didSet {
            self.indexPath = self.path ?? IndexPath(item: 0, section: 0)
            switch self.tag {
            case 45, 46:
                self.descriptionTF.keyboardType = .numbersAndPunctuation
            default: break
            }
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
    
    weak var delegate: ARC_arcLabelTextFieldCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

extension ARC_arcLabelTextFieldCell: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let text = textField.text {
            delegate?.theTextFieldTextIsChanging(text: text, indexPath: indexPath, tag: self.tag)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text {
            delegate?.theTextFieldHasChanged(text: text, indexPath: indexPath, tag: self.tag)
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        //        if let text = textField.text {
        ////            delegate?.theTextFieldHitReturnKey(text: text, indexPath: indexPath, tag: self.tag)
        //        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            delegate?.theTextFieldHitReturnKey(text: text, indexPath: indexPath, tag: self.tag)
        }
        textField.resignFirstResponder()
        return true
    }
    
}
