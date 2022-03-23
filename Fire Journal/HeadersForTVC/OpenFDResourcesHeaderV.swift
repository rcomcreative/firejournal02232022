//
//  OpenFDResourcesHeaderV.swift
//  Fire Journal
//
//  Created by DuRand Jones on 5/1/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol OpenFDResourcesHeaderVDelegate: AnyObject {
    func addNewItemTapped(new: String)
    func saveButtonTapped()
    func theCancelBTapped()
    func openFDInfoBTapped()
}

class OpenFDResourcesHeaderV: UIView,UITextFieldDelegate {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var colorV: UIView!
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var descriptionTV: UITextView!
    @IBOutlet weak var newTypeTF: UITextField!
    @IBOutlet weak var addToListB: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelB: UIButton!
    @IBOutlet weak var infoB: UIButton!
    
    weak var delegate: OpenFDResourcesHeaderVDelegate? = nil
    var newItem:String = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func addToListBTapped(_ sender: Any) {
        _ = textFieldShouldEndEditing(newTypeTF)
        if newItem != "" {
            delegate?.addNewItemTapped(new: newItem)
        }
        newTypeTF.text = ""
    }
    
    @IBAction func saveBTapped(_ sender: Any) {
        delegate?.saveButtonTapped()
    }
    
    @IBAction func cancelBWasTapped(_ sender: Any) {
        delegate?.theCancelBTapped()
    }
    
    @IBAction func infoBTapped(_ sender: Any) {
        delegate?.openFDInfoBTapped()
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        newItem = textField.text ?? ""
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        newItem = textField.text ?? ""
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        newItem = textField.text ?? ""
        return true
    }

}
