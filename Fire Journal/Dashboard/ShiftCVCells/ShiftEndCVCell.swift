//
//  ShiftEndCVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 2/23/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol ShiftEndCVCellDelegate: AnyObject {
    func shiftEndBTapped()
}

class ShiftEndCVCell: UICollectionViewCell {
    
    let nc = NotificationCenter.default
    
    let theBackgroundView = UIView()
    let iconIV = UIImageView()
    let titleL = UILabel()
    let shiftB = UIButton(primaryAction: nil)
    
    var theBorderColor: UIColor!
    
    weak var delegate: ShiftEndCVCellDelegate? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
}

extension ShiftEndCVCell {
    
    func configure() {
        
        theBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        iconIV.translatesAutoresizingMaskIntoConstraints = false
        titleL.translatesAutoresizingMaskIntoConstraints = false
        shiftB.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(theBackgroundView)
        contentView.addSubview(iconIV)
        contentView.addSubview(titleL)
        contentView.addSubview(shiftB)
        configureStructure()
        configureNSLayout()
        
    }
    
    func configureStructure() {
        
        theBorderColor = UIColor(named: "FJBlueColor")
        theBackgroundView.layer.cornerRadius = 8
        theBackgroundView.layer.borderWidth = 1
        theBackgroundView.layer.borderColor = theBorderColor.cgColor
        
        let image = UIImage(named: "ICONS_endShift")
        if image != nil {
            iconIV.image = image
        }
        
        titleL.textAlignment = .left
        titleL.font = .systemFont(ofSize: 22, weight: UIFont.Weight(rawValue: 300))
        titleL.textColor = .label
        titleL.adjustsFontForContentSizeCategory = false
        titleL.lineBreakMode = NSLineBreakMode.byWordWrapping
        titleL.numberOfLines = 0
        titleL.text = """
End
Shift
"""
        let shiftImage = UIImage(named: "Add")
        if shiftImage != nil {
            shiftB.setImage(shiftImage, for: .normal)
            shiftB.tintColor = UIColor.systemGray
        }
        shiftB.addTarget(self, action: #selector(theButtonTapped(_:)), for: .touchUpInside)
        
    }
    
    func configureNSLayout() {
        
        NSLayoutConstraint.activate([
            
            theBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            theBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            theBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
            theBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            iconIV.leadingAnchor.constraint(equalTo: theBackgroundView.leadingAnchor, constant: 20),
            iconIV.topAnchor.constraint(equalTo: theBackgroundView.topAnchor, constant: 20),
            iconIV.heightAnchor.constraint(equalToConstant: 65),
            iconIV.widthAnchor.constraint(equalToConstant: 65),
            
            shiftB.topAnchor.constraint(equalTo: iconIV.topAnchor),
            shiftB.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -20),
            shiftB.heightAnchor.constraint(equalToConstant: 65),
            shiftB.widthAnchor.constraint(equalToConstant: 65),
            
            titleL.topAnchor.constraint(equalTo: iconIV.topAnchor),
            titleL.centerYAnchor.constraint(equalTo: iconIV.centerYAnchor),
            titleL.leadingAnchor.constraint(equalTo: iconIV.trailingAnchor, constant: 15),
            titleL.trailingAnchor.constraint(equalTo: shiftB.leadingAnchor, constant: -5),
            
            ])
            
        
    }
    
    @objc func theButtonTapped(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.nc.post(name:Notification.Name(rawValue: FJkENDSHIFT_FROM_DETAIL), object: nil, userInfo: nil )
        }
    }
    
}
