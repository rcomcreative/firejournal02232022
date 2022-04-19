//
//  ARC_LabelExtendedTextFieldCell.swift
//  FJ ARC Plus
//
//  Created by DuRand Jones on 8/27/20.
//  Copyright © 2020 com.purecommand.FJARCPlus. All rights reserved.
//

import UIKit
import Foundation

protocol LabelExtendedTextFieldDelegate: AnyObject {
    func labelExtendedTFEdited(text: String, tag: Int, index: IndexPath)
    func labelTextBeingEdited(text:String,tag: Int, index: IndexPath)
}

class ARC_LabelExtendedTextFieldCell: UITableViewCell, UITextFieldDelegate {
    
//    MARK: -objects-
    @IBOutlet weak var answerTF: UITextField!
    @IBOutlet weak var subjectL: UILabel!
    
//    MARK: -PROPERTIES-
    weak var delegate: LabelExtendedTextFieldDelegate? = nil
    
    private var theSubject = ""
    var label: String? {
        didSet {
            self.theSubject = self.label ?? ""
            self.subjectL.text = self.theSubject
        }
    }
    
    private var theAnswer = ""
    var answer: String? {
        didSet {
            self.theAnswer = self.answer ?? ""
            self.answerTF.text = self.theAnswer
        }
    }
    
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let text = textField.text {
            delegate?.labelTextBeingEdited(text: text, tag: self.tag, index: indexPath)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text {
            delegate?.labelExtendedTFEdited(text: text, tag: self.tag, index: indexPath)
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            delegate?.labelExtendedTFEdited(text: text, tag: self.tag, index: indexPath)
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
