//
//  IncidentDateTimeV.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/18/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation

protocol IncidentDateTimeVDelegate: AnyObject {
    func timeAndDateChosen(_ theDate: Date)
}


class IncidentDateTimeV: UIView {
    
    weak var delegate: IncidentDateTimeVDelegate? = nil
    let dateTimePicker = UIDatePicker()
    let subjectL = UILabel()
    let theBackgroundView = UIView()
    
    private var theAlarmDate: Date = Date()
    var alarmDate: Date = Date() {
        didSet {
            self.theAlarmDate = self.alarmDate
            self.dateTimePicker.date = self.theAlarmDate
        }
    }
    
    private var theSubject: String = ""
    var subject: String = "" {
        didSet {
            self.theSubject = self.subject
            self.subjectL.text = self.theSubject
        }
    }
    
    
    private var theColor: UIColor = .label
    private var aColor: String = "FJIconRed"
    var color: String = "FJIconRed" {
        didSet {
            self.aColor = self.color
            self.theColor = UIColor(named: self.aColor)!
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}

extension IncidentDateTimeV {
    
    func configure() {
        
    }
    
}


