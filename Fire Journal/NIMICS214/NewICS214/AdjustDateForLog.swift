//
//  AdjustDateForLog.swift
//  Fire Journal
//
//  Created by DuRand Jones on 1/29/21.
//  Copyright © 2021 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation

protocol AdjustDateForLogDelegate: AnyObject {
    func theAdjustDateCancelBTapped()
    func theAdjustDateSaveBTapped(activityLog: ICS214ActivityLog, position: Int, path: IndexPath, activityDate: Date, activityDateString: String)
}

class AdjustDateForLog: UIViewController {
    
//    MARK: -PROPERTIES-
    weak var delegate: AdjustDateForLogDelegate? = nil
    let dateFormatter = DateFormatter()
    
    private var logDate: Date = Date()
    private var logDateString: String = ""
    var dateLog: Date = Date() {
        didSet {
            self.logDate = self.dateLog
            dateFormatter.dateFormat = "MM/dd/YYYY HH:mm"
            self.logDateString =  dateFormatter.string(from: self.logDate )
        }
    }
    
    private var log = ICS214ActivityLog()
    var aLog: ICS214ActivityLog? {
        didSet {
            self.log = self.aLog ?? ICS214ActivityLog()
            self.dateLog = self.aLog?.ics214ActivityDate ?? Date()
        }
    }
    
    private var arrayPosition: Int = 0
    var position: Int? {
        didSet {
            self.arrayPosition = self.position ?? 0
        }
    }
    
    private var indexPath: IndexPath = IndexPath(row: 0, section: 0)
    var path: IndexPath? {
        didSet {
            self.indexPath = self.path ?? IndexPath(row: 0, section: 0)
        }
    }
    
//    MARK: -OUTLETS-
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var cancelB: UIButton!
    @IBOutlet weak var saveB: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func datePickerTapped(_ sender: Any) {
        dateLog = datePicker.date
        print(dateLog)
    }
    
    @IBAction func cancelBTapped(_ sender: Any) {
        delegate?.theAdjustDateCancelBTapped()
    }
    
    @IBAction func saveBTapped(_ sender: Any) {
        dateLog = datePicker.date
        log.ics214ActivityDate = logDate
        log.ics214ActivityStringDate = logDateString
        delegate?.theAdjustDateSaveBTapped(activityLog: log, position: arrayPosition, path: indexPath, activityDate: dateLog, activityDateString: logDateString)
    }
    
}
