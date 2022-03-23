//
//  EndShiftCVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 11/5/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

class EndShiftCVCell: UICollectionViewCell {
    
    //    MARK: -Objects-
    @IBOutlet weak var dashboardLastShiftGradient: UIImageView!
    @IBOutlet weak var lastShiftIconIV: UIImageView!
    @IBOutlet weak var lastShiftSubjectL: UILabel!
    @IBOutlet weak var endShiftDateSubjectL: UILabel!
    @IBOutlet weak var endShiftDateL: UILabel!
    @IBOutlet weak var endShiftTimeSubjectL: UILabel!
    @IBOutlet weak var endShiftTimeL: UILabel!
    @IBOutlet weak var endShiftIncidentSubjectL: UILabel!
    @IBOutlet weak var endShiftIncidentCountL: UILabel!
    
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
