//
//  FormCVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 2/23/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol ShiftFormCVCellDelegate: AnyObject {
    func incidentTapped()
    func journalTapped()
    func formsTapped()
}

class ShiftFormCVCell: UICollectionViewCell {
    
    let theBackgroundView = UIView()
    
    let journalIconIV = UIImageView()
    let journalTitleL = UILabel()
    let journalB = UIButton(primaryAction: nil)
    
    let incidentIconIV = UIImageView()
    let incidentTitleL = UILabel()
    let incidentB = UIButton(primaryAction: nil)
    
    let formsIconIV = UIImageView()
    let formsTitleL = UILabel()
    let formsB = UIButton(primaryAction: nil)
    
    let line1View = UIView()
    let line2View = UIView()

    var theBorderColor: UIColor!
    
    let nc = NotificationCenter.default
    
    weak var delegate: ShiftFormCVCellDelegate? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
}

extension ShiftFormCVCell {
    
    func configure() {
        
        theBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        journalIconIV.translatesAutoresizingMaskIntoConstraints = false
        journalTitleL.translatesAutoresizingMaskIntoConstraints = false
        journalB.translatesAutoresizingMaskIntoConstraints = false
        incidentIconIV.translatesAutoresizingMaskIntoConstraints = false
        incidentTitleL.translatesAutoresizingMaskIntoConstraints = false
        incidentB.translatesAutoresizingMaskIntoConstraints = false
        formsIconIV.translatesAutoresizingMaskIntoConstraints = false
        formsTitleL.translatesAutoresizingMaskIntoConstraints = false
        formsB.translatesAutoresizingMaskIntoConstraints = false
        line1View.translatesAutoresizingMaskIntoConstraints = false
        line2View.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(theBackgroundView)
        contentView.addSubview(journalIconIV)
        contentView.addSubview(journalTitleL)
        contentView.addSubview(journalB)
        contentView.addSubview(incidentIconIV)
        contentView.addSubview(incidentTitleL)
        contentView.addSubview(incidentB)
        contentView.addSubview(formsIconIV)
        contentView.addSubview(formsTitleL)
        contentView.addSubview(formsB)
        contentView.addSubview(line1View)
        contentView.addSubview(line2View)
        
        configureImagesLabels()
        configureNSLayouts()
        
    }
    
    func configureImagesLabels() {
        
        theBorderColor = UIColor(named: "FJBlueColor")
        theBackgroundView.layer.cornerRadius = 8
        theBackgroundView.layer.borderWidth = 1
        theBackgroundView.layer.borderColor = theBorderColor.cgColor
        
        line1View.backgroundColor = UIColor(named: "FJBlueColor")
        line2View.backgroundColor = UIColor(named: "FJBlueColor")
        
        
        let journalImage = UIImage(named: "100515IconSet_092016_Stationboard c0l0r")
        if journalImage != nil {
            journalIconIV.image = journalImage
        }
        
        let incidentImage = UIImage(named: "100515IconSet_092016_fireboard")
        if incidentImage != nil {
            incidentIconIV.image = incidentImage
        }
        
        let formsImage = UIImage(named: "100515IconSet_092016_Forms")
        if formsImage != nil {
            formsIconIV.image = formsImage
        }
        
        journalTitleL.textAlignment = .left
        journalTitleL.font = .systemFont(ofSize: 22, weight: UIFont.Weight(rawValue: 300))
        journalTitleL.textColor = .label
        journalTitleL.adjustsFontForContentSizeCategory = false
        journalTitleL.lineBreakMode = NSLineBreakMode.byWordWrapping
        journalTitleL.numberOfLines = 0
        journalTitleL.text = "Journal"
        
        incidentTitleL.textAlignment = .left
        incidentTitleL.font = .systemFont(ofSize: 22, weight: UIFont.Weight(rawValue: 300))
        incidentTitleL.textColor = .label
        incidentTitleL.adjustsFontForContentSizeCategory = false
        incidentTitleL.lineBreakMode = NSLineBreakMode.byWordWrapping
        incidentTitleL.numberOfLines = 0
        incidentTitleL.text = "Incident"
        
        formsTitleL.textAlignment = .left
        formsTitleL.font = .systemFont(ofSize: 22, weight: UIFont.Weight(rawValue: 300))
        formsTitleL.textColor = .label
        formsTitleL.adjustsFontForContentSizeCategory = false
        formsTitleL.lineBreakMode = NSLineBreakMode.byWordWrapping
        formsTitleL.numberOfLines = 0
        formsTitleL.text = "Forms"
        
        let journalBImage = UIImage(named: "Add")
        if journalBImage != nil {
            journalB.setImage(journalBImage, for: .normal)
            journalB.tintColor = UIColor(named: "FJBlueColor")
        }
        journalB.addTarget(self, action: #selector(journalBTapped(_:)), for: .touchUpInside)
        
        let incidentBImage = UIImage(named: "Add")
        if incidentBImage != nil {
            incidentB.setImage(incidentBImage, for: .normal)
            incidentB.tintColor = UIColor(named: "FJRedColor")
        }
        incidentB.addTarget(self, action: #selector(incidentBTapped(_:)), for: .touchUpInside)
        
        let formsBImage = UIImage(named: "Add")
        if formsBImage != nil {
            formsB.setImage(formsBImage, for: .normal)
            formsB.tintColor = UIColor(named: "FJOrangeColor")
        }
        formsB.addTarget(self, action: #selector(formsBTapped(_:)), for: .touchUpInside)
        
    }
    
    func configureNSLayouts() {
        
        NSLayoutConstraint.activate([
            
            theBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            theBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            theBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
            theBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            journalIconIV.leadingAnchor.constraint(equalTo: theBackgroundView.leadingAnchor, constant: 20),
            journalIconIV.topAnchor.constraint(equalTo: theBackgroundView.topAnchor, constant: 20),
            journalIconIV.heightAnchor.constraint(equalToConstant: 65),
            journalIconIV.widthAnchor.constraint(equalToConstant: 65),
            
            journalB.topAnchor.constraint(equalTo: journalIconIV.topAnchor),
            journalB.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -20),
            journalB.heightAnchor.constraint(equalToConstant: 65),
            journalB.widthAnchor.constraint(equalToConstant: 65),
            
            journalTitleL.centerYAnchor.constraint(equalTo: journalIconIV.centerYAnchor),
            journalTitleL.heightAnchor.constraint(equalToConstant: 30),
            journalTitleL.leadingAnchor.constraint(equalTo: journalIconIV.trailingAnchor, constant: 15),
            journalTitleL.trailingAnchor.constraint(equalTo: journalB.leadingAnchor, constant: -5),
            
            line1View.heightAnchor.constraint(equalToConstant: 1),
            line1View.topAnchor.constraint(equalTo: journalIconIV.bottomAnchor, constant: 20),
            line1View.leadingAnchor.constraint(equalTo: journalIconIV.leadingAnchor),
            line1View.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -20),
            
            incidentIconIV.leadingAnchor.constraint(equalTo: journalIconIV.leadingAnchor),
            incidentIconIV.topAnchor.constraint(equalTo: line1View.bottomAnchor, constant: 20),
            incidentIconIV.heightAnchor.constraint(equalToConstant: 65),
            incidentIconIV.widthAnchor.constraint(equalToConstant: 65),
            
            incidentB.topAnchor.constraint(equalTo: incidentIconIV.topAnchor),
            incidentB.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -20),
            incidentB.heightAnchor.constraint(equalToConstant: 65),
            incidentB.widthAnchor.constraint(equalToConstant: 65),
            
            incidentTitleL.centerYAnchor.constraint(equalTo: incidentIconIV.centerYAnchor),
            incidentTitleL.heightAnchor.constraint(equalToConstant: 30),
            incidentTitleL.leadingAnchor.constraint(equalTo: incidentIconIV.trailingAnchor, constant: 15),
            incidentTitleL.trailingAnchor.constraint(equalTo: incidentB.leadingAnchor, constant: -5),
            
            line2View.heightAnchor.constraint(equalToConstant: 1),
            line2View.topAnchor.constraint(equalTo: incidentIconIV.bottomAnchor, constant: 20),
            line2View.leadingAnchor.constraint(equalTo: incidentIconIV.leadingAnchor),
            line2View.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -20),
            
            formsIconIV.leadingAnchor.constraint(equalTo: journalIconIV.leadingAnchor),
            formsIconIV.topAnchor.constraint(equalTo: line2View.bottomAnchor, constant: 20),
            formsIconIV.heightAnchor.constraint(equalToConstant: 65),
            formsIconIV.widthAnchor.constraint(equalToConstant: 65),
            
            formsB.topAnchor.constraint(equalTo: formsIconIV.topAnchor),
            formsB.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -20),
            formsB.heightAnchor.constraint(equalToConstant: 65),
            formsB.widthAnchor.constraint(equalToConstant: 65),
            
            formsTitleL.centerYAnchor.constraint(equalTo: formsIconIV.centerYAnchor),
            formsTitleL.heightAnchor.constraint(equalToConstant: 30),
            formsTitleL.leadingAnchor.constraint(equalTo: formsIconIV.trailingAnchor, constant: 15),
            formsTitleL.trailingAnchor.constraint(equalTo: incidentB.leadingAnchor, constant: -5),
            
            
            
            ])
    }
    
    @objc func journalBTapped(_ sender: UIButton) {
        delegate?.journalTapped()
        DispatchQueue.main.async {
            self.nc.post(name:Notification.Name(rawValue:FJkJOURNAL_FROM_DETAIL), object: nil, userInfo: nil )
        }
    }
    
    @objc func incidentBTapped(_ sender: UIButton) {
        delegate?.incidentTapped()
        DispatchQueue.main.async {
            self.nc.post(name:Notification.Name(rawValue:FJkINCIDENT_FROM_DETAIL), object: nil, userInfo: nil )
        }
    }
    
    @objc func formsBTapped(_ sender: UIButton) {
        delegate?.formsTapped()
        DispatchQueue.main.async {
            self.nc.post(name:Notification.Name(rawValue:FJkFORMS_FROM_DETAIL), object: nil, userInfo: nil )
        }
    }
    
}
