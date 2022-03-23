//
//  UpdateShiftCVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 11/4/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

class UpdateShiftCVCell: UICollectionViewCell {
    
    //    MARK: -Objects-
    @IBOutlet weak var gradientHeaderIV: UIImageView!
    @IBOutlet weak var shiftIconIV: UIImageView!
    @IBOutlet weak var shiftSubjectL: UILabel!
    @IBOutlet weak var statusSubjectL: UILabel!
    @IBOutlet weak var statusDateL: UILabel!
    @IBOutlet weak var shiftUpdateTimeSubjectL: UILabel!
    @IBOutlet weak var shiftUpdateTimeL: UILabel!
    @IBOutlet weak var platoonSubjectL: UILabel!
    @IBOutlet weak var platoonColorIV: UIImageView!
    @IBOutlet weak var platoonL: UILabel!
    @IBOutlet weak var fireStationSubjectL: UILabel!
    @IBOutlet weak var fireStationL: UILabel!
    @IBOutlet weak var resourcesSubjectL: UILabel!
    @IBOutlet weak var resourcesCollectionV: UICollectionView!
    @IBOutlet weak var crewSubjectL: UILabel!
    
    //    MARK: -Properties
    
    

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

}
