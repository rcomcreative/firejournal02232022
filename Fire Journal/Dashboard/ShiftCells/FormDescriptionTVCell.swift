//
//  FormDescriptionTVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/18/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData

protocol FormDescriptionTVCellDelegate: AnyObject {
    func theFormChosen(type: IncidentTypes, index: IndexPath)
}

class FormDescriptionTVCell: UITableViewCell {
    
    weak var delegate: FormDescriptionTVCellDelegate? = nil
    
    var theType: IncidentTypes!
    var userID: NSManagedObjectID!
    var index: IndexPath!
    
    let iconIV = UIImageView()
    let theBackgroundView = UIView()
    let titleL = UILabel()
    let descriptionL = UILabel()
    let formsB = UIButton(primaryAction: nil)

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
     
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

extension FormDescriptionTVCell {
    
    func configure() {
        
        iconIV.translatesAutoresizingMaskIntoConstraints = false
        theBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        titleL.translatesAutoresizingMaskIntoConstraints = false
        descriptionL.translatesAutoresizingMaskIntoConstraints = false
        formsB.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(iconIV)
        contentView.addSubview(theBackgroundView)
        contentView.addSubview(titleL)
        contentView.addSubview(descriptionL)
        contentView.addSubview(formsB)
        
        buildTheObjects()
        buildTheNSLayouts()
    }
    
    func buildTheObjects() {
        
        
        
        var iconImage: UIImage!
        switch theType {
        case .ics214Form:
            iconImage = UIImage(named: "100515IconSet_092016_ICS 214 Form")
        case .arcForm:
            iconImage = UIImage(named: "100515IconSet_092016_redCross")
        default: iconImage = UIImage(named: "100515IconSet_092016_NFIRSBasic1")
        }
        if iconImage != nil {
            iconIV.image = iconImage
        }
        
        let formsBImage = UIImage(named: "Add")
        if formsBImage != nil {
            formsB.setImage(formsBImage, for: .normal)
            formsB.tintColor = UIColor(named: "FJRedColor")
        }
        formsB.addTarget(self, action: #selector(formsBTapped(_:)), for: .touchUpInside)
        
        titleL.textAlignment = .left
        titleL.font = .systemFont(ofSize: 21, weight: UIFont.Weight(rawValue: 300))
        titleL.textColor = .label
        titleL.adjustsFontForContentSizeCategory = false
        titleL.lineBreakMode = NSLineBreakMode.byWordWrapping
        titleL.numberOfLines = 0
        switch theType {
        case .ics214Form:
            titleL.text = InfoBodyText.ics214Subject.rawValue
        case .arcForm:
            titleL.text = InfoBodyText.arcFormSubject.rawValue
        default: break
        }
        
        
        descriptionL.textAlignment = .left
        descriptionL.font = .systemFont(ofSize: 16)
        descriptionL.textColor = .label
        descriptionL.adjustsFontForContentSizeCategory = false
        descriptionL.lineBreakMode = NSLineBreakMode.byWordWrapping
        descriptionL.numberOfLines = 0
        switch theType {
        case .ics214Form:
            descriptionL.text = InfoBodyText.ics214Description.rawValue
        case .arcForm:
            descriptionL.text = InfoBodyText.arcFormDescription.rawValue
        default: break
        }
        
    }
    
    func buildTheNSLayouts() {
        NSLayoutConstraint.activate([
            
            
            theBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            theBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            theBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
            theBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            iconIV.leadingAnchor.constraint(equalTo: theBackgroundView.leadingAnchor, constant: 20),
            iconIV.topAnchor.constraint(equalTo: theBackgroundView.topAnchor, constant: 20),
            iconIV.heightAnchor.constraint(equalToConstant: 65),
            iconIV.widthAnchor.constraint(equalToConstant: 65),
            
            formsB.topAnchor.constraint(equalTo: iconIV.topAnchor),
            formsB.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -20),
            formsB.heightAnchor.constraint(equalToConstant: 65),
            formsB.widthAnchor.constraint(equalToConstant: 65),
            
            titleL.centerYAnchor.constraint(equalTo: iconIV.centerYAnchor),
            titleL.heightAnchor.constraint(equalToConstant: 65),
            titleL.leadingAnchor.constraint(equalTo: iconIV.trailingAnchor, constant: 7),
            titleL.trailingAnchor.constraint(equalTo: formsB.leadingAnchor, constant: -5),
            
            descriptionL.leadingAnchor.constraint(equalTo: iconIV.leadingAnchor),
            descriptionL.topAnchor.constraint(equalTo: iconIV.bottomAnchor, constant: 7),
            descriptionL.trailingAnchor.constraint(equalTo: formsB.leadingAnchor, constant: -5),
            descriptionL.bottomAnchor.constraint(equalTo: theBackgroundView.bottomAnchor, constant: -15),
            
            ])
    }
    
    @objc func formsBTapped(_ sender: UIButton) {
        delegate?.theFormChosen(type: theType, index: index )
    }
    
}


