//
//  WeatherCVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 11/6/19.
//  Copyright © 2019 PureCommand, LLC. All rights reserved.
//

import UIKit

class WeatherCVCell: UICollectionViewCell {
    
//    MARK: -OBJECTS-
    @IBOutlet weak var headerGradientIV: UIImageView!
    @IBOutlet weak var weatherIconIV: UIImageView!
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var dualWeatherL: UIImageView!
    @IBOutlet weak var temperatureSubjectL: UILabel!
    @IBOutlet weak var temperatureL: UILabel!
    @IBOutlet weak var humiditySubjectL: UILabel!
    @IBOutlet weak var humidityL: UILabel!
    @IBOutlet weak var windSubjectL: UILabel!
    @IBOutlet weak var windL: UILabel!
    @IBOutlet weak var burnIndexSubjectL: UILabel!
    @IBOutlet weak var burnIndexL: UILabel!
    @IBOutlet weak var redFlagSubjectL: UILabel!
    @IBOutlet weak var redFlagL: UILabel!
    @IBOutlet weak var ratingSubjectL: UILabel!
    @IBOutlet weak var ratingL: UILabel!
    @IBOutlet weak var flameLengthSubjectL: UILabel!
    @IBOutlet weak var flameLengthL: UILabel!
    @IBOutlet weak var frontLIneIntenitySubjectL: UILabel!
    @IBOutlet weak var frontLineIntensityL: UILabel!
    @IBOutlet weak var ignitionComponentSubjectL: UILabel!
    @IBOutlet weak var ignitionComponentL: UILabel!
    @IBOutlet weak var fuelLineMoistureSubjectL: UILabel!
    @IBOutlet weak var fuelLineMoistureL: UILabel!
    

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
