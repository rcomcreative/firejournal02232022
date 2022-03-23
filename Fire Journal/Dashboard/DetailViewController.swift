    //
    //  DetailViewController.swift
    //  Fire Journal
    //
    //  Created by DuRand Jones on 2/21/22.
    //  Copyright © 2022 PureCommand, LLC. All rights reserved.
    //

import UIKit
import AVFoundation
import Foundation
import CoreData
import CoreLocation
import StoreKit

class DetailViewController: UIViewController {
    
    let vcLaunch = VCLaunch()
    var launchNC: LaunchNotifications!
    var startEndGuid = ""
    var child: SpinnerViewController!
    
    var dashboardCollectionView: UICollectionView! = nil
    
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let device = (UIApplication.shared.delegate as? AppDelegate)?.device
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var theFireJournalUser: FireJournalUser!
    var fireJournalUser:FireJournalUserOnboard!
    var entity:String = ""
    var attribute:String = ""
    var sortAttribute:String = ""
    
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    
    var shiftStatus: Int = 0
    var childAdded: Bool = false
    var agreementAccepted:Bool = false
    var shiftAvailable: Bool = false
    var incidentsAvailable: Bool = false
    var incidentTotalsAvailable: Bool = false
    var weatherAvailable: Bool = false
    var alertUp: Bool = false
    var startEndShift: Bool = false
    var firstRun: Bool = true
    var personalModalCalled: Bool = false
    var versionControlled: Bool = false
    var menuCall: Bool = false
    var formModalCalled: Bool = false
    var incidentModalCalled: Bool = false
    
    let nc = NotificationCenter.default
    let userDefaults = UserDefaults.standard
    
    var theTodayIncidents = [Incident]()
    var theNewestIncident: Incident!
    var fireCount: Int!
    var emsCount: Int!
    var rescueCount: Int!
    var incidentCount: Int!
    var theIncident: Incident!
    var theUserTime: UserTime!
    var myShift: MenuItems = .journal
    var yearCounts = [ Int : [(Int,[Int])] ]()
    var weatherTemperature: String = ""
    var weatherHumidity: String = ""
    var weatherWindSpeed: String = ""
    var cellCount: Int = 7
    var compact: SizeTrait = .regular
    
    let configureShiftStartCVCellRegistration =  UICollectionView.CellRegistration<ShiftStartCVCell, UserTime> { (cell, indexPath, userTime) in
        cell.tag = 0
        cell.configure()
    }
    
    let configureShiftEndCVCellRegistration =  UICollectionView.CellRegistration<ShiftEndCVCell, UserTime> { (cell, indexPath, userTime) in
        cell.tag = 1
        cell.configure()
    }
    
    let configureShiftFormCVCellRegistration =  UICollectionView.CellRegistration<ShiftFormCVCell, UserTime> { (cell, indexPath, userTime) in
        cell.tag = 2
        cell.configure()
    }
    
    let configureShiftStartStatusCVCellRegistration =  UICollectionView.CellRegistration<ShiftStartStatusCVCell, UserTime> { (cell, indexPath, userTime) in
        cell.tag = 3
        cell.configure(userTime)
    }
    
    let configureShiftEndStatusCVCellRegistration =  UICollectionView.CellRegistration<ShiftEndStatusCVCell, UserTime> { (cell, indexPath, userTime) in
        cell.tag = 4
        cell.configure(userTime)
    }
    
    let configureShiftIncidentsCVCellRegistration =  UICollectionView.CellRegistration<ShiftIncidentsCVCell, UserTime> { (cell, indexPath, userTime) in
        cell.tag = 5
        cell.configure(userTime)
    }
    
    let  configureStationIncidentCVCellRegistration =  UICollectionView.CellRegistration<StationIncidentCVCell, UserTime> { (cell, indexPath, userTime) in
        cell.tag = 6
        cell.configure()
    }
    
    let configureShiftWeatherCVCellRegistration =  UICollectionView.CellRegistration<ShiftWeatherCVCell, UserTime> { (cell, indexPath, userTime) in
        cell.tag = 7
        cell.configure()
    }
    
    lazy var incidentProvider: IncidentProvider = {
        let provider = IncidentProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var taskContext: NSManagedObjectContext!
    
    lazy var userTimeProvider: UserTimeProvider = {
        let provider = UserTimeProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var userTimeContext: NSManagedObjectContext!
    
    lazy var incidentMonthTotalsProvider: IncidentMonthTotalsProvider = {
        let provider = IncidentMonthTotalsProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var incidentMonthTotalsContext: NSManagedObjectContext!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vcLaunch.splitVC = self.splitViewController
        launchNC = LaunchNotifications.init(launchVC: vcLaunch)
        launchNC.callNotifications()
        registerNotifications()
        
        agreementAccepted = userDefaults.bool(forKey: FJkUserAgreementAgreed)
        
        if agreementAccepted {
            guard let guid = userDefaults.string(forKey: FJkUSERTIMEGUID) else {
                let errorMessage = "Start shift needs to be started."
                errorAlert(errorMessage: errorMessage)
                return
            }
            if guid == "" {
                startEndShift = true
                userDefaults.set(startEndShift, forKey: FJkSTARTSHIFTENDSHIFTBOOL)
                getTheLastUserTime()
                if theUserTime != nil {
                    DispatchQueue.main.async {
                        self.nc.post(name:Notification.Name(rawValue:FJkOPENWEATHER_UPDATENow),object: nil)
                    }
                    getThisShiftsIncidents(theUserTime)
                    getThisShiftsIncidents(theUserTime)
                    getIncidentMonthTotals()
                } else {
                    let guidDate = GuidFormatter.init(date: Date())
                    let guid = guidDate.formatGuid()
                    let theUserGuid = "78."+guid
                    theUserTime = UserTime.init(context: context)
                    theUserTime.userTimeGuid = theUserGuid
                    theUserTime.userStartShiftTime = Date()
                    self.userDefaults.set(theUserGuid, forKey: FJkUSERTIMEGUID)
                    let objectID = theUserTime.objectID
                    DispatchQueue.main.async {
                        self.nc.post(name:Notification.Name(rawValue: FJkCKNewStartEndCreated),
                                object: nil,
                                userInfo: ["objectID": objectID as NSManagedObjectID])
                    }
                    do {
                        try context.save()
                        DispatchQueue.main.async {
                            self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"EndShiftModal TVC merge that"])
                        }
                    } catch let error as NSError {
                        let theError: String = error.localizedDescription
                        let error = "There was an error in saving " + theError
                        errorAlert(errorMessage: error)
                    }
                }
            } else {
                getTheCompletedShift(guid: guid)
                if theUserTime != nil {
                    startEndShift = false
                    userDefaults.set(startEndShift, forKey: FJkSTARTSHIFTENDSHIFTBOOL)
                } else {
                    getTheLastUserTime()
                    startEndShift = true
                    userDefaults.set(startEndShift, forKey: FJkSTARTSHIFTENDSHIFTBOOL)
                }
                if theUserTime != nil {
                    DispatchQueue.main.async {
                        self.nc.post(name:Notification.Name(rawValue:FJkOPENWEATHER_UPDATENow),object: nil)
                    }
                    getThisShiftsIncidents(theUserTime)
                    getThisShiftsIncidents(theUserTime)
                    getIncidentMonthTotals()
                } else {
                    let guidDate = GuidFormatter.init(date: Date())
                    let guid = guidDate.formatGuid()
                    let theUserGuid = "78."+guid
                    theUserTime = UserTime.init(context: context)
                    theUserTime.userTimeGuid = theUserGuid
                    theUserTime.userStartShiftTime = Date()
                    self.userDefaults.set(theUserGuid, forKey: FJkUSERTIMEGUID)
                    let objectID = theUserTime.objectID
                    DispatchQueue.main.async {
                        self.nc.post(name:Notification.Name(rawValue: FJkCKNewStartEndCreated),
                                object: nil,
                                userInfo: ["objectID": objectID as NSManagedObjectID])
                    }
                    do {
                        try context.save()
                        DispatchQueue.main.async {
                            self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"EndShiftModal TVC merge that"])
                        }
                    } catch let error as NSError {
                        let theError: String = error.localizedDescription
                        let error = "There was an error in saving " + theError
                        errorAlert(errorMessage: error)
                    }
                
                }
            }
            configuredashboardCollectionView()
            
        } else {
            presentAgreement()
            userDefaults.set(false, forKey: FJkDONTSHOWSTARTSHIFTALERTAGAIN)
        }
        
        
    }
    
    
    
//    MARK: -ALERTS-
    
    func errorAlert(errorMessage: String) {
        let alert = UIAlertController.init(title: "Error", message: errorMessage, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(okAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
