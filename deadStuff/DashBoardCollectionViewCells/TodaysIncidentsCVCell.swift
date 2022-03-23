//
//  TodaysIncidentsCVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 11/6/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import CoreLocation

class TodaysIncidentsCVCell: UICollectionViewCell {
    
//    MARK: -OBJECTS-
    @IBOutlet weak var headerGradientIV: UIImageView!
    @IBOutlet weak var incidentIconIV: UIImageView!
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var lastIncidentSubjectL: UILabel!
    @IBOutlet weak var lastIncidentB: UIButton!
    @IBOutlet weak var incidentNumberL: UILabel!
    @IBOutlet weak var lastIncidentIconIV: UIImageView!
    @IBOutlet weak var lastIncidentStreetAddressL: UILabel!
    @IBOutlet weak var lastIncidentCityStateL: UILabel!
    @IBOutlet weak var lastIncidentAlarmL: UILabel!
    @IBOutlet weak var lastIncidentAlertL: UILabel!
    @IBOutlet weak var lastIncidentControlledL: UILabel!
    @IBOutlet weak var lastIncidentLastUnitL: UILabel!
    @IBOutlet weak var lastIncidentResourcesL: UILabel!
    @IBOutlet weak var todaysIncidentL: UILabel!
    @IBOutlet weak var todaysFireL: UILabel!
    @IBOutlet weak var todaysEMSL: UILabel!
    @IBOutlet weak var todaysRescueL: UILabel!
    @IBOutlet weak var todaysFireIconIV: UIImageView!
    @IBOutlet weak var todaysEMSIconIV: UIImageView!
    @IBOutlet weak var todaysRescueIconIV: UIImageView!
    @IBOutlet weak var todayFireIncidentTotalL: UILabel!
    @IBOutlet weak var todaysEMSIncidentTotalL: UILabel!
    @IBOutlet weak var todaysRescueIncidentTotalL: UILabel!
    @IBOutlet weak var todaysIncidentMap: MKMapView!
    @IBOutlet weak var pastMonthArrowB: UIButton!
    @IBOutlet weak var forwardMonthArrowB: UIButton!
    @IBOutlet weak var monthTotalsSubjectL: UILabel!
    @IBOutlet weak var monthFireL: UILabel!
    @IBOutlet weak var monthEMSL: UILabel!
    @IBOutlet weak var monthRescueL: UILabel!
    @IBOutlet weak var monthFireIconIV: UIImageView!
    @IBOutlet weak var monthEMSIconIV: UIImageView!
    @IBOutlet weak var monthRescueIconIV: UIImageView!
    @IBOutlet weak var monthFireTotalL: UILabel!
    @IBOutlet weak var monthEMSTotalL: UILabel!
    @IBOutlet weak var monthRescueTotalL: UILabel!
    
//    MARK: -PROPERTIES-

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
//    MARK: -BUTTON ACTIONS-
    @IBAction func lastIncidentBTapped(_ sender: UIButton) {
    }
    @IBAction func pastMonthArrowBTapped(_ sender: UIButton) {
    }
    @IBAction func forwardMonthArrowBTapped(_ sender: UIButton) {
    }
    

}
