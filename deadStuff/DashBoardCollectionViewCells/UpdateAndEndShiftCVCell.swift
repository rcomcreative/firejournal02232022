//
//  UpdateAndEndShiftCVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 11/5/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

class UpdateAndEndShiftCVCell: UICollectionViewCell {
    
//    MARK: -OBJECTS-
    @IBOutlet weak var updateIconIV: UIImageView!
    @IBOutlet weak var updateShiftSubjectL: UILabel!
    @IBOutlet weak var updateB: UIButton!
    @IBOutlet weak var endIconIV: UIImageView!
    @IBOutlet weak var endShiftSubjectL: UILabel!
    @IBOutlet weak var endShiftB: UIButton!
    

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
    @IBAction func updateBTapped(_ sender: Any) {
    //        MARK: -TODO-
    }
    @IBAction func endShiftBTapped(_ sender: Any) {
        //        MARK: -TODO-
    }
    

}
