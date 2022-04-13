//
//  ProfileLabelTextFieldTVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/13/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation

protocol ProfileLabelTextFieldTVCellDelegate: AnyObject {
    func profileDescriptionChanged(text: String, tag: Int)
}

class ProfileLabelTextFieldTVCell: UITableViewCell {
    
    let subjectL = UILabel()
    let descriptionTF = UITextField()
    
    var index: IndexPath!
    
    var delegate: ProfileLabelTextFieldTVCellDelegate? = nil
    
    private var theSubject: String = ""
    var subject: String = "" {
        didSet {
            self.theSubject = self.subject
            self.subjectL.text = self.theSubject
        }
    }
    
    private var theDescription: String = ""
    var aDescription: String = "" {
        didSet {
            self.theDescription = self.aDescription
            self.descriptionTF.text = theDescription
        }
    }
    
    private var thePlaceHolder: String = ""
    var placeHolder: String = "" {
        didSet {
            self.thePlaceHolder = self.placeHolder
        }
    }
    
    var textFieldValue: String = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension ProfileLabelTextFieldTVCell {
    
    func configure() {
        
        self.selectionStyle = .none
        
        subjectL.translatesAutoresizingMaskIntoConstraints = false
        descriptionTF.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(subjectL)
        contentView.addSubview(descriptionTF)
        
        subjectL.textAlignment = .left
        subjectL.font = .systemFont(ofSize: 22, weight: UIFont.Weight(rawValue: 300))
        subjectL.textColor = .label
        
        descriptionTF.textColor = .black
        descriptionTF.font = .systemFont(ofSize: 22)
        descriptionTF.delegate = self
        descriptionTF.autocapitalizationType = .words
        descriptionTF.borderStyle = .roundedRect
        descriptionTF.backgroundColor = .white
        descriptionTF.placeholder = thePlaceHolder
        
        if Device.IS_IPHONE {
        NSLayoutConstraint.activate([
            
            subjectL.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 26),
            subjectL.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 7),
            subjectL.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant:  -35),
            subjectL.heightAnchor.constraint(equalToConstant: 40),
            
            descriptionTF.leadingAnchor.constraint(equalTo: subjectL.leadingAnchor),
            descriptionTF.topAnchor.constraint(equalTo: subjectL.bottomAnchor, constant: 5),
            descriptionTF.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant:  -35),
            descriptionTF.heightAnchor.constraint(equalToConstant: 40),
            
            ])
        } else {
            
            NSLayoutConstraint.activate([
                subjectL.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 34),
                subjectL.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 7),
                subjectL.widthAnchor.constraint(equalToConstant: 200),
                subjectL.heightAnchor.constraint(equalToConstant: 40),
                
                descriptionTF.leadingAnchor.constraint(equalTo: subjectL.trailingAnchor, constant:  20),
                descriptionTF.topAnchor.constraint(equalTo: subjectL.topAnchor),
                descriptionTF.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant:  -35),
                descriptionTF.heightAnchor.constraint(equalToConstant: 40),
            ])
        }
    }
    
}

extension ProfileLabelTextFieldTVCell: UITextFieldDelegate {
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let text = textField.text {
            textFieldValue = text
            delegate?.profileDescriptionChanged(text: textFieldValue, tag: self.tag)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text {
            textFieldValue = text
            delegate?.profileDescriptionChanged(text: textFieldValue, tag: self.tag)
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            textFieldValue = text
            delegate?.profileDescriptionChanged(text: textFieldValue, tag: self.tag)
        }
        return true
    }
    
}
