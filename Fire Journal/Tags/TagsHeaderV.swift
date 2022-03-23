//
//  TagsHeaderV.swift
//  StationCommand
//
//  Created by DuRand Jones on 11/23/21.
//

import UIKit
import CoreData
import CloudKit

protocol TagsHeaderVDelegate: AnyObject {
    func theTagAddBTapped(tag: String)
    func theTagsError(error: String)
}

class TagsHeaderV: UIView {
    
    weak var delegate: TagsHeaderVDelegate? = nil

    @IBOutlet weak var contentView: UIView!
    let addB = UIButton(primaryAction: nil )
    var subjectL = UILabel()
    var descriptionTF = UITextField()
    
    var subject: String = "" {
        didSet {
            self.subjectL.text = self.subject
        }
    }

    var tagName: String = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func addBTapped(_ sender: Any) {
        if tagName == "" {
            _ = textFieldShouldEndEditing(descriptionTF)
        }
        if tagName != "" {
            delegate?.theTagAddBTapped(tag: tagName)
            tagName = ""
            descriptionTF.text = ""
        } else {
            let errorMessage: String = "The following is needed to complete\n\nA tag needs to be added"
            delegate?.theTagsError(error: errorMessage)
        }
    }

}

extension TagsHeaderV {
    
    func configure() {
        
        configureElements()
        configureLabelTextField()
        configureButton()
        configureNSLayouts()
    }
    
    func configureElements() {
        
        subjectL.translatesAutoresizingMaskIntoConstraints = false
        descriptionTF.translatesAutoresizingMaskIntoConstraints = false
        addB.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(subjectL)
        contentView.addSubview(descriptionTF)
        contentView.addSubview(addB)
        
    }
    
    func configureLabelTextField() {
        
        subjectL.textAlignment = .left
        subjectL.font = .systemFont(ofSize: 18, weight: UIFont.Weight(rawValue: 300))
        subjectL.textColor = .label
        
        descriptionTF.textColor = .black
        descriptionTF.font = UIFont.preferredFont(forTextStyle: .subheadline)
        descriptionTF.delegate = self
        descriptionTF.autocapitalizationType = .words
        descriptionTF.borderStyle = .roundedRect
        descriptionTF.backgroundColor = .white
        descriptionTF.placeholder = "Tag"
        descriptionTF.tag = 0
        
    }
    
    func configureButton() {
        
       let image = UIImage(systemName: "plus.circle.fill")
        addB.setImage(image, for: .normal)
        addB.addTarget(self, action: #selector(addBTapped(_:)), for: .touchUpInside)
        
    }
    
    func configureNSLayouts() {
        
        NSLayoutConstraint.activate([
            
            subjectL.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 34),
            subjectL.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 22),
            subjectL.widthAnchor.constraint(equalToConstant: 160),
            subjectL.heightAnchor.constraint(equalToConstant: 20),
            
            descriptionTF.leadingAnchor.constraint(equalTo: subjectL.leadingAnchor),
            descriptionTF.topAnchor.constraint(equalTo: subjectL.bottomAnchor, constant: 11),
            descriptionTF.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant:  -125),
            descriptionTF.heightAnchor.constraint(equalToConstant: 40),
            
            addB.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -25),
            addB.heightAnchor.constraint(equalToConstant: 65),
            addB.widthAnchor.constraint(equalToConstant: 65),
            addB.topAnchor.constraint(equalTo: descriptionTF.bottomAnchor),
            
            ])
        
    }
    
}

extension TagsHeaderV: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let text = textField.text {
            tagName = text
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text {
            tagName = text
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            tagName = text
        }
        return true
    }
}

