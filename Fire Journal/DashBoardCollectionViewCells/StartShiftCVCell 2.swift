//
//  StartShiftCVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 11/5/19.
//  Copyright © 2019 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol StartShiftCVCellDelegate: AnyObject {
    func startShiftBTapped()
}

class StartShiftCVCell: UICollectionViewCell {
    
    //    MARK: -OBJECTS-
    @IBOutlet weak var backgroundGradientIV: UIImageView!
    @IBOutlet weak var iconIV: UIImageView!
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var startShiftB: UIButton!
    
    //    MARK: -PROPERTIES-
    weak var delegate: StartShiftCVCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        roundViews()
        }
        
        func roundViews() {
            self.contentView.layer.cornerRadius = 6
            self.contentView.clipsToBounds = true
            self.contentView.layer.borderColor = UIColor.systemRed.cgColor
            self.contentView.layer.borderWidth = 2
        }
    
    //    MARK: -BUTTON ACTIONS-
    @IBAction func startShiftBTapped(_ sender: UIButton) {
        delegate?.startShiftBTapped()
    }
    
}
