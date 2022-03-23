//
//  TodaysShiftCVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 11/4/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

class TodaysShiftCVCell: UICollectionViewCell {
    
    
    //    MARK: -Objects-
    @IBOutlet weak var gradientHeaderIV: UIImageView!
    @IBOutlet weak var iconIV: UIImageView!
    @IBOutlet weak var shiftSubjectL: UILabel!
    @IBOutlet weak var statusSubjectL: UILabel!
    @IBOutlet weak var statusL: UILabel!
    @IBOutlet weak var shiftStartTimeSubjectL: UILabel!
    @IBOutlet weak var shiftStartTimeL: UILabel!
    @IBOutlet weak var platoonSubjectL: UILabel!
    @IBOutlet weak var platoonColorIV: UIImageView!
    @IBOutlet weak var platoonL: UILabel!
    @IBOutlet weak var fireStationSubjectL: UILabel!
    @IBOutlet weak var fireStationNumL: UILabel!
    @IBOutlet weak var assignmentSubjectL: UILabel!
    @IBOutlet weak var assignmentL: UILabel!
    @IBOutlet weak var assignedApparatusSubjectL: UILabel!
    @IBOutlet weak var assignedApparatusL: UILabel!
    @IBOutlet weak var resourceSubjectL: UILabel!
    @IBOutlet weak var resourcesCV: UICollectionView!
    @IBOutlet weak var supervisorSubjectL: UILabel!
    @IBOutlet weak var supervisorL: UILabel!
    @IBOutlet weak var weatherSubjectL: UILabel!
    @IBOutlet weak var weatherL: UILabel!
    @IBOutlet weak var burnSubjectL: UILabel!
    @IBOutlet weak var burnL: UILabel!
    @IBOutlet weak var windSubjectL: UILabel!
    @IBOutlet weak var windL: UILabel!
    
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
