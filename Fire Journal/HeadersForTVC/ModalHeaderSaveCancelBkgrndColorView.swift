//
//  ModalHeaderSaveCancelBkgrndColorView.swift
//  Fire Journal
//
//  Created by DuRand Jones on 6/6/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation

protocol ModalHeaderSaveCancelDelegate: AnyObject {
    func modalHeaderSaveBTapped()
    func modalHeaderCancelBTapped()
    func modalHeaderAddNewTag(tag:String)
}

class ModalHeaderSaveCancelBkgrndColorView: UIView, UITextFieldDelegate {

    @IBOutlet weak var cancelB: UIButton!
    @IBOutlet weak var saveB: UIButton!
    
    @IBOutlet weak var modalHTitle: UILabel!
    @IBOutlet weak var tagTF: UITextField!
    @IBOutlet weak var addTagB: UIButton!
    @IBOutlet weak var backgroundV: UIView!
    var newTag:String?
    
    weak var delegate:ModalHeaderSaveCancelDelegate? = nil
    
    @IBAction func modalHcancelBTapped(_ sender: UIButton) {
        delegate?.modalHeaderCancelBTapped()
    }
    
    @IBAction func modalHSaveBTapped(_ sender: UIButton) {
        delegate?.modalHeaderSaveBTapped()
    }
    @IBAction func modalHNewTapped(_ sender: Any) {
        _ = textFieldShouldEndEditing(tagTF)
        if newTag != nil {
            delegate?.modalHeaderAddNewTag(tag: newTag!)
        }
        tagTF.text = ""
        tagTF.placeholder = "New Tag"
        newTag = ""
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        newTag = textField.text
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        newTag = textField.text
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        newTag = textField.text
        return true
    }
}
