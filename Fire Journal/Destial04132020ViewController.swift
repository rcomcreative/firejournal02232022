//
//  Destial04132020ViewController
//  dashboard
//
//  Created by DuRand Jones on 7/12/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData


class Destial04132020ViewController: UIViewController, UIScrollViewDelegate, ModalTVCDelegate,JournalTVCDelegate,IncidentTVCDelegate,NFIRSBasic1FormTVCDelegate,ICS214FormTVCDelegate,ARCFormTVCDelegate,MapTVCDelegate,SettingsTVCDelegate,StoreTVCDelegate,MapVCDelegate,ARCFormDetailTVCDelegate,OpenModalScrollVCDelegate,NSFetchedResultsControllerDelegate,NewICS214ModalTVCDelegate,NewARCFormDelegate,PersonalJournalDelegate  {
    
    //    MARK: -PersonalJournalDelegate
    func thePersonalJournalEntrySaved(){}
    func thePersonalJournalCancel(){
        self.dismiss(animated: true, completion: nil)
    }
    
    //    MARK: -NewARCFormDelegate
    func newARCFormCreated(date:Date, objectID: NSManagedObjectID) {}
    func theARCFormCancelled() {
        self.dismiss(animated: true, completion: nil)
    }
    
    //    MARK: -NewICS214ModalTVCDelegate
    func theCancelCalledOnNewICS214Modal() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func settingsLoadPage(settings: FJSettings) {
        //        TODO:
    }
    
    
    
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    //    MARK: Dashboards
    @IBOutlet weak var dashboardOne: UIView!
    @IBOutlet weak var dashboardTwo: UIView!
    @IBOutlet weak var dashboardThree: UIView!
    @IBOutlet weak var dashboardFour: UIView!
    @IBOutlet weak var dashboardFive: UIView!
    @IBOutlet weak var dashboardSix: UIView!
    @IBOutlet weak var dashboardSeven: UIView!
    
    @IBOutlet weak var dashboard: UIView!
    @IBOutlet weak var timeL: UILabel!
    //    MARK: -scrollView
    @IBOutlet weak var dashboardSV: UIScrollView!
    //    MARK: - STACK VIEWS
    @IBOutlet weak var startShiftStackView: UIStackView!
    @IBOutlet weak var endShiftStackView: UIStackView!
    
    //    MARK: image Views
    var backgroundImage: UIImageView!
    var stationLogoIV: UIImageView!
    var fireLogoIV: UIImageView!
    var formLogoIV: UIImageView!
    var cameraLogoIV: UIImageView!
    var emsLogoIV: UIImageView!
    var rescueLogoIV: UIImageView!
    var nfirsLogoIV: UIImageView!
    var ics214LogoIV: UIImageView!
    var arcFormLogoIV: UIImageView!
    var startEndShift: Bool = false
    
    var timer: Timer!
    //    MARK: -incident labels
    @IBOutlet weak var incidentFireCountL: UILabel!
    @IBOutlet weak var incidentEMSCountL: UILabel!
    @IBOutlet weak var incidentRescueCountL: UILabel!
    @IBOutlet weak var shiftDateL: UILabel!
    //    MARK: -BUTTONS
    @IBOutlet weak var theJournalButton: UIButton!
    @IBOutlet weak var addIncidentB: UIButton!
    @IBOutlet weak var addFormB: UIButton!
    @IBOutlet weak var addCameraB: UIButton!
    @IBOutlet weak var startShiftL: UILabel!
    @IBOutlet weak var updateShiftL: UILabel!
    @IBOutlet weak var endShiftL: UILabel!
    @IBOutlet weak var addStartShiftB: UIButton!
    @IBOutlet weak var updateShiftB: UIButton!
    @IBOutlet weak var addEndShiftB: UIButton!
    @IBOutlet weak var shiftCalendarB: UIButton!
    //    MARK: -Start/End Shift Labels
    @IBOutlet weak var startEndL: UILabel!
    @IBOutlet weak var statusL: UILabel!
    @IBOutlet weak var platoonL: UILabel!
    @IBOutlet weak var fireStationL: UILabel!
    @IBOutlet weak var assignmentL: UILabel!
    @IBOutlet weak var apparatusL: UILabel!
    @IBOutlet weak var resourceaL: UILabel!
    @IBOutlet weak var crewTV: UITextView!
    //    MARK: -NFIRS labels
    @IBOutlet weak var nfirsIncompleteL: UILabel!
    @IBOutlet weak var nfirsCompleteL: UILabel!
    @IBOutlet weak var nfirsSubmittedL: UILabel!
    //    MARK: -Alarm labels
    @IBOutlet weak var alarmCampaignL: UILabel!
    @IBOutlet weak var alarmTotalCampaignL: UILabel!
    @IBOutlet weak var alarmSmokeInstallL: UILabel!
    @IBOutlet weak var alarmC02AlarmInstalledL: UILabel!
    @IBOutlet weak var alarmTotalSmokeAlarmsL: UILabel!
    @IBOutlet weak var alarmTotalC02AlarmsL: UILabel!
    //    MARK: -ics214 labels
    @IBOutlet weak var ics214CampaignL: UILabel!
    @IBOutlet weak var ics214LastEffortL: UILabel!
    @IBOutlet weak var ics214TotalCampaignsL: UILabel!
    @IBOutlet weak var ics214IncompleteCountL: UILabel!
    @IBOutlet weak var ics214CompletedCountL: UILabel!
    //    MARK: -new dashboard labels
    @IBOutlet weak var journalTitleL: UILabel!
    @IBOutlet weak var journalCountL: UILabel!
    @IBOutlet weak var incidentTitleL: UILabel!
    @IBOutlet weak var incidentCountL: UILabel!
    @IBOutlet weak var formsTitleL: UILabel!
    @IBOutlet weak var formsCountL: UILabel!
    @IBOutlet weak var cameraTitleL: UILabel!
    @IBOutlet weak var cameraCountL: UILabel!
    @IBOutlet weak var endShiftB: UIButton!
    @IBOutlet weak var userNameL: UILabel!
    
    
    //    MARK: - presentation Delegate
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    var myShift: MenuItems = .journal
    var theCompactShift: MenuItems = .journal
    //    MARK: - Date stuctures
    var incidentStructure: IncidentData!
    var journalStructure: JournalData!
    var startShiftStructure: StartShiftData!
    var updateShiftStructure: UpdateShiftData!
    var endShiftStructure: EndShiftData!
    var shift: Shift!
    var formModalCalled: Bool = false
    var incidentModalCalled: Bool = false
    var personalModalCalled: Bool = false
    
    private let vcLaunch = VCLaunch()
    private var launchNC: LaunchNotifications!
    
    let nc = NotificationCenter.default
    var compact:SizeTrait! = nil
    var compactCalled:Bool = false
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fetched:Array<Any>!
    var agreementAccepted:Bool = false
    var userResourcesUpdated:Bool = false
    let userDefaults = UserDefaults.standard
    var fireJournalUser:FireJournalUserOnboard!
    var userStartEndShift:StartEnd!
    var fju:FireJournalUser!
    var fjUserTimeCD:UserTime!
    var startEnd:StartEnd!
    var sendAlert:Bool = false
    var entity:String = ""
    var attribute:String = ""
    var sortAttribute:String = ""
    var journalCount: Int = 0
    var incidentCount: Int = 0
    var fireCount: Int = 0
    var emsCount: Int = 0
    var rescueCount: Int = 0
    var nfirsCompleteCount: Int = 0
    var nfirsIncompleteCount: Int = 0
    var nfirsSubmittedCount: Int = 0
    var icsCounts: ICS214DashboardData!
    var arcFormCounts: ARCFormDashboardData!
    var alertUp:Bool = false
    var timeCount: Int = 0
    @IBOutlet weak var shiftStatusIV: UIImageView!
    var startEndGuid = ""
    var shiftExists: Bool = false
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    
    var months: YearOfMonths!
    
    //    MARK: -OpenModalScrollVCDelegate
    func allCompleted(yesNo: Bool) {
        dismiss(animated: true, completion: {
            self.theAgreementsAccepted()
            self.freshDeskRequest()
            self.appDelegate.fetchAnyChangesWeMissed(firstRun: true)
        })
    }
    
    func errorOnFormLoad(errorInCD: String) {
        dismiss(animated: true, completion: {
            let title:String = "Error in Core Data"
            let message:String = errorInCD
            let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
                self.alertUp = false
            })
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            self.alertUp = true
        })
    }
    
    func freshDeskRequest() {
        let fresh = self.userDefaults.bool(forKey: FJkFRESHDESK_UPDATED)
        DispatchQueue.main.async {
            if !fresh {
                let title:String = "Sync with CRM"
                let message:String = "We would like add your info to our CRM for customer service"
                let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
                let okAction = UIAlertAction.init(title: "Yes Thank you", style: .default, handler: {_ in
                    self.alertUp = false
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: FJkFRESHDESK_UPDATENow), object: nil, userInfo: nil)
                    }
                })
                alert.addAction(okAction)
                let noAction = UIAlertAction.init(title: "No Thanks", style: .default, handler: {_ in
                    self.alertUp = false
                    let fresh = false
                    DispatchQueue.main.async {
                        self.userDefaults.set(fresh, forKey: FJkFRESHDESK_UPDATED)
                        self.userDefaults.synchronize()
                    }
                })
                alert.addAction(noAction)
                self.present(alert, animated: true, completion: nil)
                self.alertUp = true
            }
        }
    }
    //    MARK: -ARCFormDetailTVCDelegate
    func arcFormCancelled(){
        //
    }
    //    MARK: -MapVC
    func mapTapped() {
        //        <#code#>
    }
    
    func journalSaveTapped() {
        //        <#code#>
    }
    
    
    func journalBackToList(){}
    
    //    MARK: -SettingsTVCDelegate
    func settingsTapped() {
        print("TODO")
    }
    func profileCalled() {
        print("nothing")
    }
    //    MARK: -StoreDelegate
    func storeTapped() {
        print("TODO")
    }
    //    MARK: -MapTVCDelegate
    func maptapped() {
        print("TODO")
    }
    //    MARK: -ICS214FormTVCDelegate
    func ics214Tapped() {
        print("TODO")
    }
    //    MARK: -ArcFormTVCDelegate
    func arcFormTapped() {
        print("TODO")
    }
    
    //    MARK: -NFIRSdelegate
    func nfirsTapped() {
        print("TODO")
    }
    //    MARK: -IncidentTVCDelegate
    func incidentTapped() {
        print("TODO")
    }
    //    MARK: -journalTVCDelegates
    func goBack() {
        print("TODO")
    }
    
    
    
    func configureView() {
    }
    
    private func updateUserTime() {
        do {
            try context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"DetailVC merge that"])
            }
        } catch let error as NSError {
            let nserror = error
            print("Unresolved error \(nserror), \(nserror.userInfo)")
            let error = "\(nserror):\(nserror.localizedDescription)\(nserror.userInfo)"
            print("DetailViewController: \(error)")
        }
    }
    
    override func viewWillLayoutSubviews() {
        getTheDetailData()
        //        theUserTimeCount
        var count = 0
        if let guid = userDefaults.string(forKey: FJkUSERTIMEGUID) {
            if guid != "" {
                _ = theUserTimeCount(entity: "UserTime", guid: guid)
                count = timeCount
            } else {
                _ = theUserTimeLast(entity: "UserTime")
                count = timeCount
            }
        }
        print(count)
        
        dashboardOne.layer.cornerRadius = 20.0
        
        dashboardOne.layer.borderColor = UIColor(red:0.25, green:0.5, blue:0.79, alpha:1).cgColor
        dashboardOne.layer.borderWidth = 0.5
        
        
        let frame = CGRect(x: 0.0, y: 0.0, width: dashboardOne.frame.width, height: dashboardOne.frame.height)
        print(frame)
        let backgroundImage = UIImageView(frame: frame)
        backgroundImage.image = UIImage(named: "graidentBackgroundGreen")
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        backgroundImage.layer.cornerRadius = 20
        backgroundImage.clipsToBounds = true
        //        let frame = CGRect(x: 0.0, y: 0.0, width: dashboardOne.frame.width, height: 182.0)
        //        let gradientV = UIView(frame: frame)
        //        let gradientLayer = CAGradientLayer()
        //        gradientLayer.frame = frame
        //        let color1 = UIColor(named: "GreenGradientOne")
        //        let color2 = UIColor(named: "GreenGradientTwo")
        //        gradientLayer.colors = [color2!.cgColor, color1!.withAlphaComponent(0.3).cgColor]
        //        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        //        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        //        gradientLayer.name = "gradientLayer"
        //        gradientV.layer.addSublayer(gradientLayer)
        //        gradientV.layer.cornerRadius = 20
        //        gradientV.clipsToBounds = true
        //
        //        if #available(iOS 11, *) {
        //            gradientV.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMinYCorner]
        //        }
        
        dashboardOne.insertSubview(backgroundImage, at: 0)
        //        dashboardOne.clipsToBounds = true
        //        dashboardOne.insertSubview(backgroundImage, at: 0)
        
        let theShift = userDefaults.integer(forKey: FJkSTARTUPDATEENDSHIFT)
        if timeCount != 0 {
            
            switch theShift {
            case 0:
                updateShiftB.isHidden = false
                updateShiftB.alpha = 1.0
                addEndShiftB.isHidden = false
                addEndShiftB.alpha = 1.0
                addStartShiftB.isHidden = false
                addStartShiftB.alpha = 0.0
                shift = .start
            case 1:
                updateShiftB.isHidden = false
                updateShiftB.alpha = 1.0
                addEndShiftB.isHidden = false
                addEndShiftB.alpha = 1.0
                addStartShiftB.isHidden = false
                addStartShiftB.alpha = 0.0
                shift = .update
            case 2:
                updateShiftB.isHidden = false
                updateShiftB.alpha = 0.0
                addEndShiftB.isHidden = false
                addEndShiftB.alpha = 0.0
                addStartShiftB.isHidden = false
                addStartShiftB.alpha = 1.0
                shift = .end
            default:
                updateShiftB.isHidden = false
                updateShiftB.alpha = 0.0
                addEndShiftB.isHidden = false
                addEndShiftB.alpha = 0.0
                addStartShiftB.isHidden = false
                addStartShiftB.alpha = 1.0
                shift = .start
            }
        } else {
            updateShiftB.isHidden = false
            updateShiftB.alpha = 0.0
            addEndShiftB.isHidden = false
            addEndShiftB.alpha = 0.0
            addStartShiftB.isHidden = false
            addStartShiftB.alpha = 1.0
        }
        
        var floatPercent = 1.00
        // MARK: -COMPACT/REGULAR TRAIT
        if (self.view.traitCollection.horizontalSizeClass == .compact) {
            floatPercent = 0.1028
            //
            print(".compact")
            compact = .compact
            nc.post(name:Notification.Name(rawValue:FJkCOMPACTORREGULAR),
                    object: nil,
                    userInfo: ["compact":compact!])
        } else {
            floatPercent = 0.1338
            print(".regular")
            compact = .regular
            nc.post(name:Notification.Name(rawValue:FJkCOMPACTORREGULAR),
                    object: nil,
                    userInfo: ["compact":compact!])
        }
        print(floatPercent)
        let constraints = [
            NSLayoutConstraint(item: backgroundImage, attribute: .width, relatedBy: .equal, toItem: self.dashboardOne, attribute: .width, multiplier: 1.00, constant: 0) ,
            NSLayoutConstraint(item: backgroundImage, attribute: .height, relatedBy: .equal, toItem: self.dashboardOne, attribute: .height, multiplier: 1.00, constant: 0) ,
            NSLayoutConstraint(item: backgroundImage, attribute: .leading, relatedBy: .equal, toItem: self.dashboardOne, attribute: .leading, multiplier: 1.00, constant: 0) ,
            NSLayoutConstraint(item: backgroundImage, attribute: .top, relatedBy: .equal, toItem: self.dashboardOne, attribute: .top, multiplier: 1.0, constant: 0),
            //            NSLayoutConstraint(item: gradientV, attribute: .width, relatedBy: .equal, toItem: self.dashboardOne, attribute: .width, multiplier: 1.00, constant: 0) ,
            //            NSLayoutConstraint(item: gradientV, attribute: .height, relatedBy: .equal, toItem: self.dashboardOne, attribute: .height, multiplier: 1.00, constant: 0) ,
            //            NSLayoutConstraint(item: gradientV, attribute: .leading, relatedBy: .equal, toItem: self.dashboardOne, attribute: .leading, multiplier: 1.00, constant: 0) ,
            //            NSLayoutConstraint(item: gradientV, attribute: .top, relatedBy: .equal, toItem: self.dashboardOne, attribute: .top, multiplier: 1.0, constant: 0),
        ]
        
        dashboardOne.addConstraints(constraints)
        
        dashboardSeven.layer.cornerRadius = 20.0
        dashboardSeven.layer.borderColor  = UIColor(red:0.25, green:0.5, blue:0.79, alpha:1).cgColor
        dashboardSeven.layer.borderWidth = 0.5
        
        let frame7 = CGRect(x: 0.0, y: 0.0, width: dashboardSeven.frame.width, height: dashboardSeven.frame.height)
        let backgroundImage7 = UIImageView(frame: frame7)
        backgroundImage7.image = UIImage(named: "graidentbackground2")
        backgroundImage7.translatesAutoresizingMaskIntoConstraints = false
        backgroundImage7.layer.cornerRadius = 20
        backgroundImage7.clipsToBounds = true
        dashboardSeven.insertSubview(backgroundImage7, at: 0)
        
        let constraints7 = [
            NSLayoutConstraint(item: backgroundImage7, attribute: .width, relatedBy: .equal, toItem: self.dashboardSeven, attribute: .width, multiplier: 1.00, constant: 0) ,
            NSLayoutConstraint(item: backgroundImage7, attribute: .height, relatedBy: .equal, toItem: self.dashboardSeven, attribute: .height, multiplier: 1.00, constant: 0) ,
            NSLayoutConstraint(item: backgroundImage7, attribute: .leading, relatedBy: .equal, toItem: self.dashboardSeven, attribute: .leading, multiplier: 1.00, constant: 0) ,
            NSLayoutConstraint(item: backgroundImage7, attribute: .top, relatedBy: .equal, toItem: self.dashboardSeven, attribute: .top, multiplier: 1.0, constant: 0),
        ]
        
        dashboardSeven.addConstraints(constraints7)
        
        dashboardTwo.layer.cornerRadius = 20.0
        
        dashboardTwo.layer.borderColor = UIColor(red:0.25, green:0.5, blue:0.79, alpha:1).cgColor
        dashboardTwo.layer.borderWidth = 0.5
        
        let frame2 = CGRect(x: 0.0, y: 0.0, width: dashboardTwo.frame.width, height: dashboardTwo.frame.height)
        
        let backgroundImageG = UIImageView(frame: frame2)
        if timeCount != 0 {
            switch shift {
            case .update?:
                backgroundImageG.image = UIImage(named: "backgroundO1")
                backgroundImageG.translatesAutoresizingMaskIntoConstraints = false
                backgroundImageG.layer.cornerRadius = 20
                backgroundImageG.clipsToBounds = true
                backgroundImageG.tag = 100
                if let view = dashboardTwo.viewWithTag(100) {
                    view.removeFromSuperview()
                }
                dashboardTwo.insertSubview(backgroundImageG, at: 0)
                startEndL.text = "Shift\nUpdated"
                let image = UIImage.init(named: "ICONS_updateShift")
                shiftStatusIV.image = image
                let shiftDate = fjUserTimeCD.userUpdateShiftTime ?? Date()
                let formattedDate = vcLaunch.incidentFullDate(date: shiftDate)
                shiftDateL.text = formattedDate
                fireStationL.text = fjUserTimeCD.updateShiftFireStation ?? ""
                platoonL.text = fjUserTimeCD.updateShiftPlatoon ?? ""
            case .end?:
                backgroundImageG.image = UIImage(named: "backgroundRed1")
                backgroundImageG.translatesAutoresizingMaskIntoConstraints = false
                backgroundImageG.layer.cornerRadius = 20
                backgroundImageG.clipsToBounds = true
                backgroundImageG.tag = 100
                if let view = dashboardTwo.viewWithTag(100) {
                    view.removeFromSuperview()
                }
                dashboardTwo.insertSubview(backgroundImageG, at: 0)
                startEndL.text = "Last\nShift"
                let image = UIImage.init(named: "ICONS_endShift")
                shiftStatusIV.image = image
                let shiftDate = fjUserTimeCD.userEndShiftTime ?? Date()
                let formattedDate = vcLaunch.incidentFullDate(date: shiftDate)
                shiftDateL.text = formattedDate
            case .start?:
                backgroundImageG.image = UIImage(named: "backgroundG1")
                backgroundImageG.translatesAutoresizingMaskIntoConstraints = false
                backgroundImageG.layer.cornerRadius = 20
                backgroundImageG.clipsToBounds = true
                backgroundImageG.tag = 100
                if let view = dashboardTwo.viewWithTag(100) {
                    view.removeFromSuperview()
                }
                startEndL.text = "Shift\nStarted"
                let image = UIImage.init(named: "ICONS_startShift")
                shiftStatusIV.image = image
                if agreementAccepted {
                    if timeCount != 0 {
                        let shiftDate = fjUserTimeCD.userStartShiftTime ?? Date()
                        let formattedDate = vcLaunch.incidentFullDate(date: shiftDate)
                        shiftDateL.text = formattedDate
                    }
                }
                dashboardTwo.insertSubview(backgroundImageG, at: 0)
            default: break
            }
        } else {
            backgroundImageG.image = UIImage(named: "backgroundG1")
            backgroundImageG.translatesAutoresizingMaskIntoConstraints = false
            backgroundImageG.layer.cornerRadius = 20
            backgroundImageG.clipsToBounds = true
            backgroundImageG.tag = 100
            if let view = dashboardTwo.viewWithTag(100) {
                view.removeFromSuperview()
            }
            startEndL.text = "Shift\nStarted"
            let image = UIImage.init(named: "ICONS_startShift")
            shiftStatusIV.image = image
            if agreementAccepted {
                if timeCount != 0 {
                    let shiftDate = fjUserTimeCD.userStartShiftTime ?? Date()
                    let formattedDate = vcLaunch.incidentFullDate(date: shiftDate)
                    shiftDateL.text = formattedDate
                } else {
                    let shiftDate = Date()
                    let formattedDate = vcLaunch.incidentFullDate(date: shiftDate)
                    shiftDateL.text = formattedDate
                }
            }
            dashboardTwo.insertSubview(backgroundImageG, at: 0)
        }
        startEndL.setNeedsDisplay()
        dashboardTwo.setNeedsDisplay()
        addStartShiftB.setNeedsDisplay()
        
        dashboardTwo.addConstraints([
            NSLayoutConstraint(item: backgroundImageG, attribute: .width, relatedBy: .equal, toItem: self.dashboardTwo, attribute: .width, multiplier: 1.00, constant: 0),
            NSLayoutConstraint(item: backgroundImageG, attribute: .height, relatedBy: .equal, toItem: self.dashboardTwo, attribute: .height, multiplier: 1.00, constant: 0),
            NSLayoutConstraint(item: backgroundImageG, attribute: .leading, relatedBy: .equal, toItem: self.dashboardTwo, attribute: .leading, multiplier: 1.00, constant: 0),
            NSLayoutConstraint(item: backgroundImageG, attribute: .top, relatedBy: .equal, toItem: self.dashboardTwo, attribute: .top, multiplier: 1.0, constant: 0),
        ])
        if agreementAccepted {
            
            var overtimeAm:String = ""
            if fireJournalUser.statusAMorOvertime {
                overtimeAm = "AM Relief"
            } else {
                overtimeAm = "Overtime"
            }
            
            switch theShift {
            case 0:
                if !shiftExists {
                    startShiftStructure = StartShiftData.init()
                }
                if startShiftStructure == nil {
                    startShiftStructure = StartShiftData.init()
                }
                if let guid = userDefaults.string(forKey: FJkUSERTIMEGUID) {
                    if guid != "" {
                        _ = theUserTimeCount(entity: "UserTime", guid: guid)
                    } else {
                        _ = theUserTimeLast(entity: "UserTime")
                    }
                }
                if timeCount != 0 {
                    startShiftStructure.ssPlatoonTF = fjUserTimeCD.startShiftPlatoon ?? ""
                    startShiftStructure.ssFireStationTF = fjUserTimeCD.startShiftFireStation ?? ""
                    startShiftStructure.ssApparatusTF = fjUserTimeCD.startShiftApparatus ?? ""
                    startShiftStructure.ssAssignmentTF = fjUserTimeCD.startShiftAssignment ?? ""
                    startShiftStructure.ssResourcesTF = fjUserTimeCD.startShiftResources ?? fju.tempResources ?? ""
                    startShiftStructure.ssResourcesCombine = fjUserTimeCD.startShiftResources ?? fju.tempResources ?? ""
                    if startShiftStructure.ssResourcesTF == "" {
                        if fju.defaultResources != "" {
                            startShiftStructure.ssResourcesTF = fju.defaultResources ?? ""
                            fjUserTimeCD.startShiftResources = fju.defaultResources ?? ""
                            fjUserTimeCD.startShiftMyFDResources = fju.defaultResources ?? ""
                        }
                    }
                    if startShiftStructure.ssResourcesCombine == "" {
                        if fju.defaultResources != "" {
                            startShiftStructure.ssResourcesCombine = fju.defaultResources ?? ""
                        }
                    }
                    updateUserTime()
                    startShiftStructure.ssCrewsTF = fjUserTimeCD.startShiftCrew ?? ""
                    startShiftStructure.ssAMReliefDefault = fjUserTimeCD.startShiftStatus
                    if startShiftStructure.ssAMReliefDefault {
                        statusL.text = "AM Relief"
                    } else {
                        statusL.text = "Overtime"
                    }
                    
                    platoonL.text = startShiftStructure.ssPlatoonTF
                    fireStationL.text = startShiftStructure.ssFireStationTF
                    assignmentL.text = startShiftStructure.ssAssignmentTF
                    apparatusL.text = startShiftStructure.ssApparatusTF
                    resourceaL.text = startShiftStructure.ssResourcesTF
                    crewTV.text = startShiftStructure.ssCrewsTF
                }
                journalCountL.text = "\(journalCount) Journal"
                incidentCountL.text = "\(incidentCount) Incidents"
                platoonL.setNeedsLayout()
            case 1:
                if !shiftExists {
                    updateShiftStructure = UpdateShiftData.init()
                }
                if let guid = userDefaults.string(forKey: FJkUSERTIMEGUID) {
                    if guid != "" {
                        _ = theUserTimeCount(entity: "UserTime", guid: guid)
                    } else {
                        _ = theUserTimeLast(entity: "UserTime")
                    }
                }
                if timeCount != 0 {
                    updateShiftStructure.upsPlatoonTF = fjUserTimeCD.updateShiftPlatoon ?? ""
                    updateShiftStructure.upsFireStationTF = fjUserTimeCD.updateShiftFireStation ?? ""
                    updateShiftStructure.upsAssignmentTF = fjUserTimeCD.startShiftAssignment ?? ""
                    updateShiftStructure.upsApparatusTF = fjUserTimeCD.startShiftApparatus ?? ""
                    updateShiftStructure.upsResourcesTF = fjUserTimeCD.startShiftResources ?? fju.tempResources ?? ""
                    if updateShiftStructure.upsResourcesTF == "" {
                        if fju.defaultResources != "" {
                            updateShiftStructure.upsResourcesTF = fju.defaultResources ?? ""
                        }
                    }
                    updateShiftStructure.upsCrewCombine = fjUserTimeCD.startShiftCrew ?? ""
                    updateShiftStructure.upsAMReliefDefaultT = fjUserTimeCD.updateShiftStatus
                    if updateShiftStructure.upsAMReliefDefaultT {
                        statusL.text = "AM Relief"
                    } else {
                        statusL.text = "Overtime"
                    }
                    platoonL.text = updateShiftStructure.upsPlatoonTF
                    fireStationL.text = updateShiftStructure.upsFireStationTF
                    assignmentL.text = updateShiftStructure.upsAssignmentTF
                    apparatusL.text = updateShiftStructure.upsApparatusTF
                    resourceaL.text = updateShiftStructure.upsResourcesTF
                    crewTV.text = updateShiftStructure.upsCrewCombine
                }
                journalCountL.text = "\(journalCount) Journal"
                incidentCountL.text = "\(incidentCount) Incidents"
                platoonL.setNeedsLayout()
                
            case 2:
                if !shiftExists {
                    endShiftStructure = EndShiftData.init()
                }
                if let guid = userDefaults.string(forKey: FJkUSERTIMEGUID) {
                    if guid != "" {
                        _ = theUserTimeCount(entity: "UserTime", guid: guid)
                    } else {
                        _ = theUserTimeLast(entity: "UserTime")
                    }
                }
                if timeCount != 0 {
                    endShiftStructure.esPlatoonTF = fjUserTimeCD.updateShiftPlatoon ?? fjUserTimeCD.startShiftPlatoon ?? ""
                    if endShiftStructure.esPlatoonTF == "" {
                        endShiftStructure.esPlatoonTF = fju.tempPlatoon ?? ""
                        fjUserTimeCD.startShiftPlatoon = fju.tempPlatoon ?? ""
                    }
                    endShiftStructure.esFireStationTF = fjUserTimeCD.updateShiftFireStation ?? fjUserTimeCD.startShiftFireStation ?? ""
                    if endShiftStructure.esFireStationTF == "" {
                        endShiftStructure.esFireStationTF = fju.fireStation ?? ""
                        fjUserTimeCD.startShiftFireStation = fju.fireStation ?? ""
                        fjUserTimeCD.updateShiftFireStation = fju.fireStation ?? ""
                    }
                    endShiftStructure.esApparatusTF = fjUserTimeCD.startShiftApparatus ?? ""
                    if endShiftStructure.esApparatusTF == "" {
                        endShiftStructure.esApparatusTF = fju.tempApparatus ?? ""
                        fjUserTimeCD.startShiftApparatus = fju.tempApparatus ?? ""
                    }
                    endShiftStructure.esAssignmentTF = fjUserTimeCD.startShiftAssignment ?? ""
                    if endShiftStructure.esAssignmentTF == "" {
                        endShiftStructure.esAssignmentTF = fju.tempAssignment ?? ""
                        fjUserTimeCD.startShiftAssignment = fju.tempAssignment ?? ""
                    }
                    endShiftStructure.esResourcesTF = fjUserTimeCD.startShiftResources ?? fju.tempResources ?? ""
                    if endShiftStructure.esResourcesTF == "" {
                        if fju.defaultResources != "" {
                            endShiftStructure.esResourcesTF = fju.defaultResources ?? ""
                            fjUserTimeCD.startShiftResources = fju.defaultResources ?? ""
                            fjUserTimeCD.updateShiftResources = fju.defaultResources ?? ""
                        }
                    }
                    endShiftStructure.esCrewCombine = fjUserTimeCD.startShiftCrew ?? ""
                    if endShiftStructure.esCrewCombine == "" {
                        endShiftStructure.esCrewCombine = fju.defaultCrew ?? ""
                        fjUserTimeCD.startShiftCrew = fju.defaultCrew ?? ""
                    }
                    endShiftStructure.esAMReliefDefaultT = fjUserTimeCD.endShiftStatus
                    if endShiftStructure.esAMReliefDefaultT {
                        statusL.text = "AM Relief"
                    } else {
                        statusL.text = "Overtime"
                    }
                    updateUserTime()
                    platoonL.text = endShiftStructure.esPlatoonTF
                    fireStationL.text = endShiftStructure.esFireStationTF
                    assignmentL.text = endShiftStructure.esAssignmentTF
                    apparatusL.text = endShiftStructure.esApparatusTF
                    resourceaL.text = endShiftStructure.esResourcesTF
                    crewTV.text = endShiftStructure.esCrewCombine
                }
                journalCountL.text = "\(journalCount) Journal"
                incidentCountL.text = "\(incidentCount) Incidents"
                platoonL.setNeedsLayout()
            default:
                statusL.text = overtimeAm
                platoonL.text = fireJournalUser.fjuPlatoonTemp
                fireStationL.text = fireJournalUser.fjuFireStation
                assignmentL.text = fireJournalUser.fjuAssignmentTemp
                apparatusL.text = fireJournalUser.fjuApparatusTemp
                resourceaL.text = fireJournalUser.fjuResources
                crewTV.text = fireJournalUser.fjuCrew
                journalCountL.text = "\(journalCount) Journal"
                incidentCountL.text = "\(incidentCount) Incidents"
                platoonL.setNeedsLayout()
            }
        }
        
        dashboardThree.layer.cornerRadius = 20.0
        dashboardThree.layer.borderColor = UIColor(red:0.25, green:0.5, blue:0.79, alpha:1).cgColor
        dashboardThree.layer.borderWidth = 0.5
        let frame3 = CGRect(x: 0.0, y: 0.0, width: dashboardThree.frame.width, height: dashboardThree.frame.height)
        
        let backgroundImageR1 = UIImageView(frame: frame3)
        backgroundImageR1.image = UIImage(named: "backgroundR1")
        backgroundImageR1.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageR1.layer.cornerRadius = 20
        backgroundImageR1.clipsToBounds = true
        dashboardThree.insertSubview(backgroundImageR1, at: 0)
        
        dashboardThree.addConstraints([
            NSLayoutConstraint(item: backgroundImageR1, attribute: .width, relatedBy: .equal, toItem: self.dashboardThree, attribute: .width, multiplier: 1.00, constant: 0),
            NSLayoutConstraint(item: backgroundImageR1, attribute: .height, relatedBy: .equal, toItem: self.dashboardThree, attribute: .height, multiplier: 1.00, constant: 0),
            NSLayoutConstraint(item: backgroundImageR1, attribute: .leading, relatedBy: .equal, toItem: self.dashboardThree, attribute: .leading, multiplier: 1.00, constant: 0),
            NSLayoutConstraint(item: backgroundImageR1, attribute: .top, relatedBy: .equal, toItem: self.dashboardThree, attribute: .top, multiplier: 1.0, constant: 0),
        ])
        incidentFireCountL.text = "\(fireCount)"
        incidentEMSCountL.text = "\(emsCount)"
        incidentRescueCountL.text = "\(rescueCount)"
        incidentFireCountL.setNeedsLayout()
        
        //        dashboardFour.layer.cornerRadius = 20.0
        //        dashboardFour.layer.borderColor = UIColor(red:0.25, green:0.5, blue:0.79, alpha:1).cgColor
        //        dashboardFour.layer.borderWidth = 0.5
        //        let frame4 = CGRect(x: 0.0, y: 0.0, width: dashboardFour.frame.width, height: dashboardFour.frame.height)
        //
        //        let backgroundImageB1 = UIImageView(frame: frame4)
        //        backgroundImageB1.image = UIImage(named: "backgroundB1")
        //        backgroundImageB1.translatesAutoresizingMaskIntoConstraints = false
        //        backgroundImageB1.layer.cornerRadius = 20
        //        backgroundImageB1.clipsToBounds = true
        //        dashboardFour.insertSubview(backgroundImageB1, at: 0)
        //
        //        dashboardFour.addConstraints([
        //            NSLayoutConstraint(item: backgroundImageB1, attribute: .width, relatedBy: .equal, toItem: self.dashboardFour, attribute: .width, multiplier: 1.00, constant: 0),
        //            NSLayoutConstraint(item: backgroundImageB1, attribute: .height, relatedBy: .equal, toItem: self.dashboardFour, attribute: .height, multiplier: 1.00, constant: 0),
        //            NSLayoutConstraint(item: backgroundImageB1, attribute: .leading, relatedBy: .equal, toItem: self.dashboardFour, attribute: .leading, multiplier: 1.00, constant: 0),
        //            NSLayoutConstraint(item: backgroundImageB1, attribute: .top, relatedBy: .equal, toItem: self.dashboardFour, attribute: .top, multiplier: 1.0, constant: 0),
        //            ])
        //
        //        nfirsIncompleteL.text = "\(nfirsIncompleteCount)"
        //        nfirsCompleteL.text = "\(nfirsCompleteCount)"
        //        nfirsSubmittedL.text = "\(nfirsSubmittedCount)"
        
        
        
        dashboardFive.layer.cornerRadius = 20.0
        dashboardFive.layer.borderColor = UIColor(red:0.25, green:0.5, blue:0.79, alpha:1).cgColor
        dashboardFive.layer.borderWidth = 0.5
        let frame5 = CGRect(x: 0.0, y: 0.0, width: dashboardFive.frame.width, height: dashboardFive.frame.height)
        
        let backgroundImageB2 = UIImageView(frame: frame5)
        backgroundImageB2.image = UIImage(named: "backgroundB2")
        backgroundImageB2.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageB2.layer.cornerRadius = 20
        backgroundImageB2.clipsToBounds = true
        dashboardFive.insertSubview(backgroundImageB2, at: 0)
        
        dashboardFive.addConstraints([
            NSLayoutConstraint(item: backgroundImageB2, attribute: .width, relatedBy: .equal, toItem: self.dashboardFive, attribute: .width, multiplier: 1.00, constant: 0),
            NSLayoutConstraint(item: backgroundImageB2, attribute: .height, relatedBy: .equal, toItem: self.dashboardFive, attribute: .height, multiplier: 1.00, constant: 0),
            NSLayoutConstraint(item: backgroundImageB2, attribute: .leading, relatedBy: .equal, toItem: self.dashboardFive, attribute: .leading, multiplier: 1.00, constant: 0),
            NSLayoutConstraint(item: backgroundImageB2, attribute: .top, relatedBy: .equal, toItem: self.dashboardFive, attribute: .top, multiplier: 1.0, constant: 0),
        ])
        
        dashboardSix.layer.cornerRadius = 20.0
        dashboardSix.layer.borderColor = UIColor(red:0.25, green:0.5, blue:0.79, alpha:1).cgColor
        dashboardSix.layer.borderWidth = 0.5
        let frame6 = CGRect(x: 0.0, y: 0.0, width: dashboardSix.frame.width, height: dashboardSix.frame.height)
        
        let backgroundImageR2 = UIImageView(frame: frame6)
        backgroundImageR2.image = UIImage(named: "backgroundRed2DeeperR")
        backgroundImageR2.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageR2.layer.cornerRadius = 20
        backgroundImageR2.clipsToBounds = true
        dashboardSix.insertSubview(backgroundImageR2, at: 0)
        
        dashboardSix.addConstraints([
            NSLayoutConstraint(item: backgroundImageR2, attribute: .width, relatedBy: .equal, toItem: self.dashboardSix, attribute: .width, multiplier: 1.00, constant: 0),
            NSLayoutConstraint(item: backgroundImageR2, attribute: .height, relatedBy: .equal, toItem: self.dashboardSix, attribute: .height, multiplier: 1.00, constant: 0),
            NSLayoutConstraint(item: backgroundImageR2, attribute: .leading, relatedBy: .equal, toItem: self.dashboardSix, attribute: .leading, multiplier: 1.00, constant: 0),
            NSLayoutConstraint(item: backgroundImageR2, attribute: .top, relatedBy: .equal, toItem: self.dashboardSix, attribute: .top, multiplier: 1.0, constant: 0),
        ])
        
        
        dashboardOne.setNeedsDisplay()
        dashboardTwo.setNeedsDisplay()
        dashboardThree.setNeedsDisplay()
        //        dashboardFour.setNeedsDisplay()
        dashboardFive.setNeedsDisplay()
        dashboardSix.setNeedsDisplay()
        
        if formModalCalled {
            myShift = .forms
            presentModal(menuType: myShift, title: "Choose a Form Type")
            formModalCalled = false
        }
        
        if incidentModalCalled {
            myShift = .incidents
            presentNewerIncidentModal()
            incidentModalCalled = false
        }
        
        if personalModalCalled {
            myShift = .personal
            presentModal(menuType: myShift, title: "New Personal Journal")
        }
        
        _ = self.splitViewController?.isCollapsed
        
        if compactCalled {
            switch myShift {
            case .journal:
                nc.post(name:Notification.Name(rawValue:FJkJOURNAL_FROM_MASTER),
                        object: nil,
                        userInfo: ["objectID":"searchARCForm.objectID", "date":"searchARCForm.cStartDate","arcFormGuid":"searchARCForm.arcFormGuid"])
            case .incidents:
                nc.post(name:Notification.Name(rawValue:FJkINCIDENT_FROM_MASTER),
                        object: nil,
                        userInfo: ["objectID":"searchARCForm.objectID", "date":"searchARCForm.cStartDate","arcFormGuid":"searchARCForm.arcFormGuid"])
            default:
                print("nothing")
            }
            print("here are the products \(SubscriptionsService.shared.fjProducts)")
        }
        
        agreementAccepted = userDefaults.bool(forKey: FJkUserAgreementAgreed)
        startEndShift = userDefaults.bool(forKey: FJkSTARTSHIFTENDSHIFTBOOL)
        if !agreementAccepted {
            presentAgreement()
            userDefaults.set(false, forKey: FJkDONTSHOWSTARTSHIFTALERTAGAIN)
            userDefaults.synchronize()
        } else {
            if let guid = userDefaults.string(forKey: FJkUSERTIMEGUID) {
                startEndGuid = guid
            }
        }
        
    }
    
    private func theAgreementsAccepted() {
        if let guid = userDefaults.string(forKey: FJkUSERTIMEGUID) {
            startEndGuid = guid
        }
    }
    
    private func startEndAlertCall(title: String, message: String) {
        //        self.dismiss(animated: false, completion: nil)
        //        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        //        let okAction = UIAlertAction.init(title: "Start Shift", style: .default, handler: {_ in
        //            self.shouldStartShift(self)
        //        })
        //        alert.addAction(okAction)
        //        let notOkAction = UIAlertAction.init(title: "Don't Start Shift", style: .cancel, handler: {_ in
        //            print("I disagree")
        //            self.dismiss(animated: true, completion: nil)
        //        })
        //        let dontShowAgainAction = UIAlertAction.init(title: "Don't Show This Alert Again", style: .default, handler: {_ in
        //            self.dontShowAlertAgain(self)
        //        })
        //        alert.addAction(notOkAction)
        //        alert.addAction(dontShowAgainAction)
        //        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func dontShowAlertAgain(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        userDefaults.set(true, forKey: FJkDONTSHOWSTARTSHIFTALERTAGAIN)
        userDefaults.synchronize()
    }
    
    @IBAction func shouldStartShift(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        startShiftTapped(self)
        let theStartDate = Date()
        startEnd = StartEnd.init(date: theStartDate)
        let fjuUserTime = UserTime.init(entity: NSEntityDescription.entity(forEntityName: "UserTime", in: context)!, insertInto: context)
        fjuUserTime.userTimeGuid = startEnd.sTuserTimeGuid
        fjuUserTime.userStartShiftTime = theStartDate
        let cal = NSCalendar.current
        let dayOfYear = cal.ordinality(of: .day, in: .year, for: theStartDate)
        fjuUserTime.userTimeDayOfYear = "\(dayOfYear ?? 0)"
        userDefaults.set(startEnd.sTuserTimeGuid, forKey: FJkUSERTIMEGUID)
        fjUserTimeCD = fjuUserTime
        userDefaults.synchronize()
        saveToCD()
    }
    
    private func saveToCD() {
        do {
            try context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"DetailVC merge that"])
            }
            DispatchQueue.main.async {
                if let guid = self.userDefaults.string(forKey: FJkUSERTIMEGUID) {
                    self.startEndGuid = guid
                }
                if self.startEndGuid != "" {
                    _ = self.theUserTimeCount(entity: "UserTime", guid: self.startEndGuid)
                    let id = self.fjUserTimeCD.objectID
                    self.nc.post(name:Notification.Name(rawValue:FJkCKNewStartEndCreated),
                                 object: nil,
                                 userInfo: ["objectID":id])
                    
                }
            }
        } catch let error as NSError {
            let nserror = error
            print("Unresolved error \(nserror), \(nserror.userInfo)")
            let error = "\(nserror):\(nserror.localizedDescription)\(nserror.userInfo)"
            print("DetailViewController: \(error)")
        }
    }
    
    @objc func journalBtnTapped() {
        print("journal")
    }
    
    @objc func incidentBtnTapped() {
        print("incident")
    }
    
    @objc func formBtnTapped() {
        print("forms")
    }
    
    @objc func cameraBtnTapped() {
        print("camera")
    }
    
    func labels() {
        statusL.text = ""
        platoonL.text = ""
        fireStationL.text = ""
        assignmentL.text = ""
        apparatusL.text = ""
        resourceaL.text = ""
        crewTV.text = ""
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        if launchNC != nil {
            launchNC.removeNC()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Home"
        labels()
        fireJournalUser = FireJournalUserOnboard()
        agreementAccepted = userDefaults.bool(forKey: FJkUserAgreementAgreed)
        if agreementAccepted {
            agreementYes()
        }
        vcLaunch.splitVC = self.splitViewController
        launchNC = LaunchNotifications.init(launchVC: vcLaunch)
        launchNC.callNotifications()
        dateString()
        registerNotifications()
        
        navigationItem.leftItemsSupplementBackButton = true
        self.splitViewController?.displayModeButtonItem.possibleTitles = [""]
        let button3 = self.splitViewController?.displayModeButtonItem
        navigationItem.setLeftBarButtonItems([button3!], animated: true)
        
        DispatchQueue.main.async {
            print("run sync")
            self.nc.post(name:Notification.Name(rawValue:(FJkFJSHOULDRunSYNC)),
                         object: nil,
                         userInfo: nil)
        }
        
        allOfTheIncidents()
    }
    
    func allOfTheIncidents() {
//        let theIncidents = GetTheIncidents.init(theYear: 2020, context: context)
//        months = theIncidents.getTheIncidents()
//        print("here are the numbers January \(months.janCounts) February \(months.febCounts)")
    }
    
    func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector:#selector(formsWasTapped(notification:)), name:NSNotification.Name(rawValue: FJkFORMS_FROM_MASTER), object: nil)
        NotificationCenter.default.addObserver(self,selector:#selector(newUserCreated(notification:)), name:NSNotification.Name(rawValue:FJkFireJournalUserSaved),object:nil)
        
        NotificationCenter.default.addObserver(self, selector:#selector(noConnectionCalled(ns:)),name:NSNotification.Name(rawValue: kHAVENO_CONNECTIONALERT), object: nil)
        
        NotificationCenter.default.addObserver(self, selector:#selector(startShiftForDash(ns:)),name:NSNotification.Name(rawValue: FJkSTARTSHIFTFORDASH), object: nil)
        
        NotificationCenter.default.addObserver(self, selector:#selector(newContentForDashboard(ns:)),name:NSNotification.Name(rawValue: FJkRELOADTHEDASHBOARD), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
    }
    
    func agreementYes() {
        let userFDResourcesUpdated = userDefaults.bool(forKey: FJkUserFDResourcesPointOfTruthOperationHasRun)
        icsCounts = ICS214DashboardData.init()
        arcFormCounts = ARCFormDashboardData.init()
        entity = "FireJournalUser"
        attribute = "userGuid"
        sortAttribute = "lastName"
        getTheDetailData()
        attribute = "journalDateSearch"
        journalCount = theJournalCount(entity: "Journal")
        attribute = "incidentDateSearch"
        incidentCount = theJournalCount(entity: "Incident")
        attribute = "Fire"
        fireCount = theFireCount(entity:"Incident",attribute:attribute)
        attribute = "EMS"
        emsCount = theFireCount(entity:"Incident",attribute:attribute)
        attribute = "Rescue"
        rescueCount =  theFireCount(entity:"Incident",attribute:attribute)
        attribute = "incidentNFIRSCompleted"
        nfirsCompleteCount = theNIRSCount(entity: "Incident", attribute: attribute, yesNo: true)
        nfirsIncompleteCount = theNIRSCount(entity: "Incident", attribute: attribute, yesNo: false)
        attribute = "incidentNFIRSSubmitted"
        nfirsSubmittedCount = theNIRSCount(entity: "Incident", attribute: attribute, yesNo: true)
        startEndShift = userDefaults.bool(forKey: FJkSTARTSHIFTENDSHIFTBOOL)
        theICSCounts()
        theARCFormCounts()
        let count = icsCounts.ics214Complete + icsCounts.ics214Incomplete + arcFormCounts.alarmTotalCampaigns
        formsCountL.text = "\(count) Forms"
        formsCountL.setNeedsDisplay()
        userResourcesUpdated = false
        DispatchQueue.main.async {
            print("run sync")
            self.nc.post(name:Notification.Name(rawValue:(FJkSETTINGSUSERRESOURCESCUSTOMRUN)),
                         object: nil,
                         userInfo: ["customOrNot": self.userResourcesUpdated])
        }
        
        
        if !userFDResourcesUpdated {
            DispatchQueue.main.async {
                print("run sync")
                self.nc.post(name:Notification.Name(rawValue:(FJkUSERFDRESOURCESPOINTOFTRUTH)),
                             object: nil,
                             userInfo: ["runOnce": false])
            }
            userDefaults.set(true, forKey: FJkUserFDResourcesPointOfTruthOperationHasRun)
            userDefaults.synchronize()
        }
    }
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    @objc func noConnectionCalled(ns: Notification) {
        if vcLaunch.alertI == 0 {
            let alert = vcLaunch.networkUnavailable()
            self.present(alert,animated: true)
        }
    }
    
    private func getTheDetailData() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FireJournalUser" )
        fetchRequest.fetchBatchSize = 1
        
        do {
            fetched = try context.fetch(fetchRequest) as! [FireJournalUser]
            if fetched.isEmpty {
                print("no user available")
            } else {
                fju = fetched.last as? FireJournalUser
                assignToUser(fju: fju)
            }
        } catch let error as NSError {
            // failure
            print("DetailViewController line 881 Fetch failed: \(error.localizedDescription)")
        }
    }
    
    private func theARCFormCounts()->Void {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ARCrossForm" )
        let sectionSortDescriptor = NSSortDescriptor(key: "arcCreationDate", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.fetchBatchSize = 20
        do {
            let fetchedForm = try context.fetch(fetchRequest) as! [ARCrossForm]
            if !fetchedForm.isEmpty {
                let arcFormLast:ARCrossForm = fetchedForm.last!
                arcFormCounts = arcFormLast.arcGetTheDashboardData(forms: fetchedForm)
                
                alarmCampaignL.text = arcFormCounts.alarmLatestCampaign
                alarmTotalCampaignL.text = "\(arcFormCounts.alarmTotalCampaigns)"
                alarmSmokeInstallL.text = "\(arcFormCounts.alarmCampaignSmokeInstalled)"
                alarmTotalSmokeAlarmsL.text = "\(arcFormCounts.alarmTotalSmokeAlarmsInstalled)"
                alarmC02AlarmInstalledL.text = "\(arcFormCounts.alarmCampaignC02Installed)"
                alarmTotalC02AlarmsL.text = "\(arcFormCounts.alarmTotalC02AlarmsInstalled)"
                alarmTotalC02AlarmsL.setNeedsDisplay()
            }
        } catch let error as NSError {
            print("DetailViewController line 906 Error: \(error.localizedDescription)")
        }
    }
    
    private func theICSCounts()->Void {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ICS214Form" )
        let sectionSortDescriptor = NSSortDescriptor(key: "ics214FromTime", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.fetchBatchSize = 20
        do {
            let fetchedForm = try context.fetch(fetchRequest) as! [ICS214Form]
            if !fetchedForm.isEmpty {
                let ics214Last:ICS214Form = fetchedForm.last!
                icsCounts = ics214Last.getTheDashboardCounts(forms: fetchedForm)
                //                print(icsCounts)
                ics214CampaignL.text = icsCounts.ics214LastCampaign
                ics214LastEffortL.text = icsCounts.ics214LastEffort
                ics214TotalCampaignsL.text = "\(icsCounts.ics214TotalCampaigns)"
                ics214IncompleteCountL.text = "\(icsCounts.ics214Incomplete)"
                ics214CompletedCountL.text = "\(icsCounts.ics214Complete)"
                ics214CompletedCountL.setNeedsDisplay()
            }
        } catch let error as NSError {
            print("DetailViewController line 930 Error: \(error.localizedDescription)")
        }
    }
    
    private func theJournalCount(entity: String)->Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        if entity == "Journal" {
            let predicate = NSPredicate(format: "%K != %@", attribute, "")
            let predicate2 = NSPredicate(format: "%K == %@","journalPrivate", NSNumber(value: true))
            let predicate3 = NSPredicate(format: "%K == %@ || %K == %@ || %K == %@","journalEntryType","Station","journalEntryType","Community","journalEntryType","Members")
            let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate, predicate2, predicate3])
            fetchRequest.predicate = predicateCan
        }
        do {
            let count = try context.count(for:fetchRequest)
            return count
        } catch let error as NSError {
            print("DetailViewController line 947 Error: \(error.localizedDescription)")
            return 0
        }
    }
    
    private func theUserTimeCount(entity: String, guid: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        let predicate = NSPredicate(format: "%K == %@", "userTimeGuid", guid)
        fetchRequest.predicate = predicate
        do {
            let userFetched = try context.fetch(fetchRequest) as! [UserTime]
            if !userFetched.isEmpty {
                timeCount = userFetched.count
                fjUserTimeCD = userFetched.last!
            } else {
                _ = theUserTimeLast(entity: "UserTime")
            }
        } catch let error as NSError {
            print("DetailViewController line 959 Error: \(error.localizedDescription)")
        }
    }
    
    private func theUserTimeLast(entity: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        let predicate = NSPredicate(format: "%K != %@", "userTimeGuid", "")
        fetchRequest.predicate = predicate
        do {
            let userFetched = try context.fetch(fetchRequest) as! [UserTime]
            timeCount = userFetched.count
            if !userFetched.isEmpty {
                fjUserTimeCD = userFetched.last!
            }
        } catch let error as NSError {
            print("DetailViewController line 1073 Error: \(error.localizedDescription)")
        }
    }
    
    private func theFireCount(entity: String, attribute: String)->Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        let predicate = NSPredicate(format: "%K == %@", "situationIncidentImage", attribute)
        fetchRequest.predicate = predicate
        do {
            let count = try context.count(for:fetchRequest)
            return count
        } catch let error as NSError {
            print("DetailViewController line 970 Error: \(error.localizedDescription)")
            return 0
        }
    }
    
    private func theNIRSCount(entity: String, attribute: String, yesNo: Bool)->Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>( entityName: entity )
        let predicate = NSPredicate(format: "%K == %@",attribute, NSNumber( value: yesNo ))
        fetchRequest.predicate = predicate
        do {
            let count = try context.count(for:fetchRequest)
            return count
        } catch let error as NSError {
            print("DetailViewController line 985 Error: \(error.localizedDescription)")
            return 0
        }
    }
    
    private func assignToUser(fju:FireJournalUser) {
        fireJournalUser.fjuUserName = fju.userName ?? ""
        fireJournalUser.fjuFirstName = fju.firstName ?? ""
        fireJournalUser.fjuLastName = fju.lastName ?? ""
        fireJournalUser.fjuApparatusTemp = fju.tempApparatus ?? ""
        fireJournalUser.fjuAssignmentTemp = fju.tempAssignment ?? ""
        fireJournalUser.fjuFireStation = fju.fireStation ?? ""
        fireJournalUser.fjuPlatoonTemp = fju.tempPlatoon ?? ""
        fireJournalUser.fjuResources = fju.tempResources ?? ""
        fireJournalUser.fjuCrew = fju.defaultCrew ?? ""
        fireJournalUser.statusAMorOvertime = fju.shiftStatusAMorOver
    }
    
    @objc func newUserCreated(notification:Notification)-> Void {
        if let userInfo = notification.userInfo as! [String: Any]?
        {
            self.fireJournalUser = userInfo["user"] as? FireJournalUserOnboard
            self.platoonL.text = self.fireJournalUser.fjuPlatoon
            self.fireStationL.text = self.fireJournalUser.fjuFireStation
            self.assignmentL.text = self.fireJournalUser.fjuAssignment
            self.apparatusL.text = self.fireJournalUser.fjuApparatus
            self.journalCountL.text = "\(self.journalCount) Journal"
            self.incidentCountL.text = "\(self.incidentCount) Incidents"
            self.incidentCountL.setNeedsLayout()
        }
    }
    
    @objc func formsWasTapped(notification:Notification)-> Void {
        myShift = .forms
        presentModal(menuType: myShift, title: "Choose a Form Type")
    }
    
    
    func timerForDashboard() {
        print("time for a change")
        timer = Timer(timeInterval: 1, target: self,
                      selector: #selector(dateString),
                      userInfo: nil, repeats: true)
    }
    
    @objc func dateString() {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, MM/dd/YYYY HH:mm"
        _ = dateFormatter.string(from: date)
    }
    
    
    
    func addConstraintFromView(subview: UIImageView?,
                               attribute: NSLayoutConstraint.Attribute,
                               multiplier: CGFloat,
                               identifier: String,
                               superV: UIView? ) {
        if let subview = subview {
            let constraint = NSLayoutConstraint(item: subview,
                                                attribute: attribute,
                                                relatedBy: .equal,
                                                toItem: superV,
                                                attribute: attribute,
                                                multiplier: multiplier,
                                                constant: 0)
            constraint.identifier = identifier
            constraint.isActive = true
            superV?.addConstraint(constraint)
            print(constraint)
        }
        
    }
    
    fileprivate func presentAgreement() {
        //        switch compact {
        //        case .regular?:
        //        userDefaults.set(nil, forKey: FJkCKServerChangeToken)
        //        userDefaults.synchronize()
        //        if !Device.IS_IPHONE {
        let userItemsLoad = LoadUserItems.init(context)
        userItemsLoad.runTheOperations()
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let openingScrollVC = storyBoard.instantiateViewController(withIdentifier: "OpenModalScrollVC") as! OpenModalScrollVC
        openingScrollVC.delegate = self
        openingScrollVC.fromMaster = false
        openingScrollVC.transitioningDelegate = slideInTransitioningDelgate
        openingScrollVC.modalPresentationStyle = .custom
        self.present(openingScrollVC, animated: true, completion: nil)
        //        } else {
        //
        //        }
        //        case .compact?:
        //            print("nothing to see here")
        //        default:
        //            print("doing nothing")
        //        }
        
    }
    
    
    
    //    MAIN: -STARTSHIFT MODAL CALLED
    func startShiftModalCalled(menuType: MenuItems, title: String) {
        setUpDataStructur(myShift: menuType)
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyboard = UIStoryboard(name: "StartShiftDashboardModal", bundle: nil)
        let startShiftModalTVC  = storyboard.instantiateViewController(identifier: "StartShiftDashbaordModalTVC") as! StartShiftDashbaordModalTVC
        startShiftModalTVC.delegate = self
        startShiftModalTVC.transitioningDelegate = slideInTransitioningDelgate
        startShiftModalTVC.modalPresentationStyle = .custom
        startShiftModalTVC.context = context
        self.present(startShiftModalTVC, animated: true, completion: nil)
        //        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        //        let startShiftModalTVC = storyBoard.instantiateViewController(withIdentifier: "StartShiftModalTVC") as! StartShiftModalTVC
        //        startShiftModalTVC.transitioningDelegate = slideInTransitioningDelgate
        //        startShiftModalTVC.modalPresentationStyle = .custom
        //        startShiftModalTVC.context = context
        //        startShiftModalTVC.delegate = self
        //        self.present(startShiftModalTVC, animated: true, completion: nil)
    }
    
    func updateShiftModalCalled(menuType: MenuItems, title: String) {
        setUpDataStructur(myShift: menuType)
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyboard = UIStoryboard(name: "UpdateShiftDashboardModal", bundle: nil)
        let updateShiftModalTVC  = storyboard.instantiateViewController(identifier: "UpdateShiftDashboardModalTVC") as! UpdateShiftDashboardModalTVC
        updateShiftModalTVC.delegate = self
        updateShiftModalTVC.transitioningDelegate = slideInTransitioningDelgate
        updateShiftModalTVC.modalPresentationStyle = .custom
        updateShiftModalTVC.context = context
        self.present(updateShiftModalTVC, animated: true, completion: nil)
        //        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        //        let updateShiftModalTVC = storyBoard.instantiateViewController(withIdentifier: "UpdateShiftModalTVC") as! UpdateShiftModalTVC
        //        updateShiftModalTVC.transitioningDelegate = slideInTransitioningDelgate
        //        updateShiftModalTVC.modalPresentationStyle = .custom
        //        updateShiftModalTVC.context = context
        //        updateShiftModalTVC.delegate = self
        //        self.present(updateShiftModalTVC, animated: true, completion: nil)
    }
    
    func endShiftModalCalled(menuType: MenuItems, title: String) {
        setUpDataStructur(myShift: menuType)
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyboard = UIStoryboard(name: "EndShiftDashboardModal", bundle: nil)
        let endShiftModalTVC  = storyboard.instantiateViewController(identifier: "EndShiftBashboardModalTVC") as! EndShiftBashboardModalTVC
        endShiftModalTVC.delegate = self
        endShiftModalTVC.transitioningDelegate = slideInTransitioningDelgate
        endShiftModalTVC.modalPresentationStyle = .custom
        endShiftModalTVC.context = context
        self.present(endShiftModalTVC, animated: true, completion: nil)
        //        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        //        let endShiftModaleTVC = storyBoard.instantiateViewController(withIdentifier: "EndShiftModalTVC") as! EndShiftModalTVC
        //        endShiftModaleTVC.transitioningDelegate = slideInTransitioningDelgate
        //        endShiftModaleTVC.modalPresentationStyle = .custom
        //        endShiftModaleTVC.context = context
        //        endShiftModaleTVC.delegate = self
        //        self.present(endShiftModaleTVC, animated: true, completion: nil)
    }
    
    func newJournalModalCalled() {
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyBoard : UIStoryboard = UIStoryboard(name: "JournalSB", bundle:nil)
        let newJournalModalTVC = storyBoard.instantiateInitialViewController() as? JournalModalTVC
        newJournalModalTVC?.transitioningDelegate = slideInTransitioningDelgate
        newJournalModalTVC?.modalPresentationStyle = .custom
        newJournalModalTVC?.context = context
        newJournalModalTVC?.delegate = self
        self.present(newJournalModalTVC!,animated: true)
    }
    
    fileprivate func presentModal(menuType: MenuItems, title: String) {
        setUpDataStructur(myShift: menuType)
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let modalTVC = storyBoard.instantiateViewController(withIdentifier: "ModalTVC") as! ModalTVC
        modalTVC.delegate = self
        modalTVC.transitioningDelegate = slideInTransitioningDelgate
        modalTVC.title = title
        modalTVC.myShift = menuType
        if personalModalCalled {
            modalTVC.personalJournalEntry = true
        }
        modalTVC.modalPresentationStyle = .custom
        modalTVC.context = context
        self.present(modalTVC, animated: true, completion: nil)
    }
    
    private func presentNewerIncidentModal() {
        setUpDataStructur(myShift: MenuItems.incidents)
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let modalTVC = storyBoard.instantiateViewController(withIdentifier: "NewerIncidentModalTVC") as! NewerIncidentModalTVC
        modalTVC.delegate = self
        modalTVC.context = context
        modalTVC.transitioningDelegate = slideInTransitioningDelgate
        modalTVC.modalPresentationStyle = .custom
        self.present(modalTVC, animated: true, completion: nil)
    }
    
    fileprivate func setUpDataStructur(myShift: MenuItems) {
        switch myShift {
        case .incidents:
            incidentStructure = IncidentData.init()
        case .journal:
            journalStructure = JournalData.init()
        case .nfirsBasic1Search:
            incidentStructure = IncidentData.init()
        case .startShift:
            startShiftStructure = StartShiftData.init()
            if let guid = userDefaults.string(forKey: FJkUSERTIMEGUID) {
                if guid != "" {
                    _ = theUserTimeCount(entity: "UserTime", guid: guid)
                } else {
                    _ = theUserTimeLast(entity: "UserTime")
                }
            }
            startShiftStructure.ssPlatoon = fjUserTimeCD.startShiftPlatoon ?? ""
            startShiftStructure.ssFireStationTF = fjUserTimeCD.startShiftFireStation ?? ""
            startShiftStructure.ssApparatusTF = fjUserTimeCD.startShiftApparatus ?? ""
            startShiftStructure.ssAssignmentTF = fjUserTimeCD.startShiftAssignment ?? ""
            startShiftStructure.ssResourcesTF = fjUserTimeCD.startShiftResources ?? ""
            startShiftStructure.ssCrewsTF = fjUserTimeCD.startShiftCrew ?? ""
            startShiftStructure.ssAMReliefDefault = fjUserTimeCD.startShiftStatus
            if startShiftStructure.ssAMReliefDefault {
                startShiftStructure.ssAMReliefDefaultT = "AM Relief"
            } else {
                startShiftStructure.ssAMReliefDefaultT = "Overtime"
            }
        case .updateShift:
            updateShiftStructure = UpdateShiftData.init()
            if let guid = userDefaults.string(forKey: FJkUSERTIMEGUID) {
                if guid != "" {
                    _ = theUserTimeCount(entity: "UserTime", guid: guid)
                } else {
                    _ = theUserTimeLast(entity: "UserTime")
                }
            }
            updateShiftStructure.upsPlatoon = fjUserTimeCD.updateShiftPlatoon ?? ""
            updateShiftStructure.upsFireStationTF = fjUserTimeCD.updateShiftFireStation ?? ""
            updateShiftStructure.upsAssignmentTF = fjUserTimeCD.startShiftAssignment ?? ""
            updateShiftStructure.upsApparatusTF = fjUserTimeCD.startShiftApparatus ?? ""
            updateShiftStructure.upsResourcesTF = fjUserTimeCD.startShiftResources ?? ""
            updateShiftStructure.upsCrewCombine = fjUserTimeCD.startShiftCrew ?? ""
            updateShiftStructure.upsAMReliefDefaultT = fjUserTimeCD.updateShiftStatus
            if updateShiftStructure.upsAMReliefDefaultT {
                statusL.text = "AM Relief"
            } else {
                statusL.text = "Overtime"
            }
        case .endShift:
            endShiftStructure = EndShiftData.init()
            if let guid = userDefaults.string(forKey: FJkUSERTIMEGUID) {
                if guid != "" {
                    _ = theUserTimeCount(entity: "UserTime", guid: guid)
                } else {
                    _ = theUserTimeLast(entity: "UserTime")
                }
            }
            endShiftStructure.esPlatoon = fjUserTimeCD.updateShiftPlatoon ?? ""
            endShiftStructure.esFireStationTF = fjUserTimeCD.updateShiftFireStation ?? ""
            endShiftStructure.esApparatusTF = fjUserTimeCD.startShiftApparatus ?? ""
            endShiftStructure.esAssignmentTF = fjUserTimeCD.startShiftAssignment ?? ""
            endShiftStructure.esResourcesTF = fjUserTimeCD.startShiftResources ?? ""
            endShiftStructure.esCrewCombine = fjUserTimeCD.startShiftCrew ?? ""
            endShiftStructure.esAMReliefDefaultT = fjUserTimeCD.endShiftStatus
            if endShiftStructure.esAMReliefDefaultT {
                statusL.text = "AM Relief"
            } else {
                statusL.text = "Overtime"
            }
        default:
            print("none")
        }
    }
    
    //    MARK: -Reload the dashboarde
    @objc func newContentForDashboard(ns: Notification)->Void {
        if agreementAccepted {
            icsCounts = ICS214DashboardData.init()
            arcFormCounts = ARCFormDashboardData.init()
            entity = "FireJournalUser"
            attribute = "userGuid"
            sortAttribute = "lastName"
            getTheDetailData()
            attribute = "journalDateSearch"
            journalCount = theJournalCount(entity: "Journal")
            attribute = "incidentDateSearch"
            incidentCount = theJournalCount(entity: "Incident")
            attribute = "Fire"
            fireCount = theFireCount(entity:"Incident",attribute:attribute)
            attribute = "EMS"
            emsCount = theFireCount(entity:"Incident",attribute:attribute)
            attribute = "Rescue"
            rescueCount =  theFireCount(entity:"Incident",attribute:attribute)
            attribute = "incidentNFIRSCompleted"
            nfirsCompleteCount = theNIRSCount(entity: "Incident", attribute: attribute, yesNo: true)
            nfirsIncompleteCount = theNIRSCount(entity: "Incident", attribute: attribute, yesNo: false)
            attribute = "incidentNFIRSSubmitted"
            nfirsSubmittedCount = theNIRSCount(entity: "Incident", attribute: attribute, yesNo: true)
            startEndShift = userDefaults.bool(forKey: FJkSTARTSHIFTENDSHIFTBOOL)
            theICSCounts()
            theARCFormCounts()
            let count = icsCounts.ics214Complete + icsCounts.ics214Incomplete + arcFormCounts.alarmTotalCampaigns
            formsCountL.text = "\(count) Forms"
            //            formsCountL.setNeedsDisplay()
        }
        
        if !alertUp {
            
            var count:Int = self.userDefaults.integer(forKey: FJkALERTBACKUPCOMPLETED)
            if count == 0 {
                let alert = UIAlertController.init(title: "Cloud Data", message: "Your data has been backed up. Access to backed up data requires a subscription", preferredStyle: .alert)
                let learnMore = UIAlertAction.init(title: "Learn More", style: .default, handler: {_ in
                    self.alertUp = false
                    count = count + 1
                    if count > 20 {
                        count = 0
                    }
                    self.userDefaults.set(count, forKey: FJkALERTBACKUPCOMPLETED)
                    self.userDefaults.synchronize()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.nc.post(name:Notification.Name(rawValue:FJkSTOREINALERTTAPPED),
                                     object: nil,
                                     userInfo: nil)
                    }
                })
                alert.addAction(learnMore)
                let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
                    self.alertUp = false
                    count = count + 1
                    if count > 20 {
                        count = 0
                    }
                    self.userDefaults.set(count, forKey: FJkALERTBACKUPCOMPLETED)
                    self.userDefaults.synchronize()
                })
                alert.addAction(okAction)
                alertUp = true
                self.present(alert, animated: true, completion: nil)
                
            }
            
            
            //            self.cleanUpTheAttendees()
        }
        
        
    }
    
    private func cleanUpTheAttendees() {
        var attendeeCount = self.userDefaults.integer(forKey: FJkCLEANUSERATTENDEES)
        if attendeeCount == 0 {
            DispatchQueue.main.async {
                self.nc.post(name:Notification.Name(rawValue:FJkCLEANUSERATTENDEES),
                             object: nil,
                             userInfo: nil)
            }
            attendeeCount = attendeeCount + 1
            self.userDefaults.set(attendeeCount, forKey: FJkCLEANUSERATTENDEES)
            self.userDefaults.synchronize()
        }
    }
    //    MARK: -DETAIL PROTOCOLS
    @objc func startShiftForDash(ns: Notification)-> Void {
        if let userInfo = ns.userInfo as! [String: Any]?
        {
            startShiftStructure = userInfo["startShift"] as? StartShiftData
            if startShiftStructure.ssPlatoonTF != "" {
                platoonL.text = startShiftStructure.ssPlatoonTF
                fireJournalUser.fjuPlatoonTemp = startShiftStructure.ssPlatoonTF
            }
            if startShiftStructure.ssFireStationTF != "" {
                fireStationL.text = startShiftStructure.ssFireStationTF
                fireJournalUser.fjuFireStation = startShiftStructure.ssFireStationTF
            }
            if startShiftStructure.ssAssignmentTF != "" {
                assignmentL.text = startShiftStructure.ssAssignmentTF
                fireJournalUser.fjuAssignmentTemp = startShiftStructure.ssAssignmentTF
            }
            if startShiftStructure.ssApparatusTF != "" {
                apparatusL.text = startShiftStructure.ssApparatusTF
                fireJournalUser.fjuApparatusTemp = startShiftStructure.ssApparatusTF
            }
            if startShiftStructure.ssResourcesTF != "" {
                resourceaL.text = startShiftStructure.ssResourcesCombine
                fireJournalUser.fjuResources = startShiftStructure.ssResourcesCombine
            }
            if startShiftStructure.ssCrewsTF != "" {
                crewTV.text = startShiftStructure.ssCrewsTF
                fireJournalUser.fjuCrew = startShiftStructure.ssCrewsTF
            }
            if startShiftStructure.ssAMReliefDefault {
                statusL.text = "AM Relief"
            } else {
                statusL.text = "Overtime"
            }
            
            attribute = "journalDateSearch"
            journalCount = theJournalCount(entity: "Journal")
            journalCountL.text = "\(journalCount) Journal"
            journalCountL.setNeedsDisplay()
            
            self.userDefaults.set(0, forKey: FJkSTARTUPDATEENDSHIFT)
            self.userDefaults.set(true, forKey: FJkSTARTSHIFTENDSHIFTBOOL)
            self.userDefaults.synchronize()
            startEndShift = true
            
            resourceaL.setNeedsDisplay()
            self.dismiss(animated: true, completion: nil)
            viewWillLayoutSubviews()
        }
    }
    
    func startSaveBTapped(shift: MenuItems, startShift: StartShiftData) {
        startShiftStructure = startShift
        if startShiftStructure.ssPlatoonTF != "" {
            platoonL.text = startShiftStructure.ssPlatoonTF
        }
        if startShiftStructure.ssFireStationTF != "" {
            fireStationL.text = startShiftStructure.ssFireStationTF
        }
        if startShiftStructure.ssAssignmentTF != "" {
            assignmentL.text = startShiftStructure.ssAssignmentTF
        }
        if startShiftStructure.ssApparatusTF != "" {
            apparatusL.text = startShiftStructure.ssApparatusTF
        }
        if startShiftStructure.ssResourcesTF != "" {
            resourceaL.text = startShiftStructure.ssResourcesCombine
        }
        if startShiftStructure.ssCrewsTF != "" {
            crewTV.text = startShiftStructure.ssCrewsTF
        }
        if startShiftStructure.ssAMReliefDefault {
            statusL.text = "AM Relief"
        } else {
            statusL.text = "Overtime"
        }
        print("here is startshift \(startShift)")
        attribute = "journalDateSearch"
        journalCount = theJournalCount(entity: "Journal")
        journalCountL.text = "\(journalCount) Journal"
        journalCountL.setNeedsDisplay()
        
        self.userDefaults.set(0, forKey: FJkSTARTUPDATEENDSHIFT)
        self.userDefaults.set(true, forKey: FJkSTARTSHIFTENDSHIFTBOOL)
        self.userDefaults.synchronize()
        startEndShift = true
        viewWillLayoutSubviews()
        self.dismiss(animated: true, completion: nil)
    }
    
    func endSaveBTapped(shift: MenuItems, endShift: EndShiftData) {
        endShiftStructure = endShift
        shiftExists = true
        if endShiftStructure.esPlatoonTF != "" {
            platoonL.text = endShiftStructure.esPlatoonTF
        }
        if endShiftStructure.esFireStationTF != "" {
            fireStationL.text = endShiftStructure.esFireStationTF
        }
        if endShiftStructure.esAMReliefDefaultT {
            statusL.text = "AM Relief"
        } else {
            statusL.text = "Overtime"
        }
        attribute = "journalDateSearch"
        journalCount = theJournalCount(entity: "Journal")
        journalCountL.text = "\(journalCount) Journal"
        journalCountL.setNeedsDisplay()
        
        self.userDefaults.set(2, forKey: FJkSTARTUPDATEENDSHIFT)
        self.userDefaults.set(false, forKey: FJkSTARTSHIFTENDSHIFTBOOL)
        
        self.userDefaults.synchronize()
        startEndShift = false
        viewWillLayoutSubviews()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func updateBTapped(shift: MenuItems, updateShift: UpdateShiftData) {
        updateShiftStructure = updateShift
        shiftExists = true
        print(updateShift)
        if updateShiftStructure.upsPlatoonTF != "" {
            platoonL.text = updateShiftStructure.upsPlatoonTF
        }
        if updateShiftStructure.upsFireStationTF != "" {
            fireStationL.text = updateShiftStructure.upsFireStationTF
        }
        if updateShiftStructure.upsAMReliefDefaultT {
            statusL.text = "AM Relief"
        } else {
            statusL.text = "Overtime"
        }
        attribute = "journalDateSearch"
        journalCount = theJournalCount(entity: "Journal")
        journalCountL.text = "\(journalCount) Journal"
        journalCountL.setNeedsDisplay()
        
        self.userDefaults.set(1, forKey: FJkSTARTUPDATEENDSHIFT)
        self.userDefaults.set(true, forKey: FJkSTARTSHIFTENDSHIFTBOOL)
        self.userDefaults.synchronize()
        startEndShift = true
        viewWillLayoutSubviews()
        self.dismiss(animated: true, completion: nil)
    }
    
    func endUpdateBTapped(shift: MenuItems, endShift: EndShiftData) {
        endShiftStructure = endShift
        print(endShift)
        if endShiftStructure.esPlatoonTF != "" {
            platoonL.text = endShiftStructure.esPlatoonTF
        }
        if endShiftStructure.esFireStationTF != "" {
            fireStationL.text = endShiftStructure.esFireStationTF
        }
        if endShiftStructure.esAMReliefDefaultT {
            statusL.text = "AM Relief"
        } else {
            statusL.text = "Overtime"
        }
        attribute = "journalDateSearch"
        journalCount = theJournalCount(entity: "Journal")
        journalCountL.text = "\(journalCount) Journal"
        journalCountL.setNeedsDisplay()
        
        self.userDefaults.set(1, forKey: FJkSTARTUPDATEENDSHIFT)
        self.userDefaults.set(true, forKey: FJkSTARTSHIFTENDSHIFTBOOL)
        self.userDefaults.synchronize()
        startEndShift = true
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func journalNewTapped(_ sender: Any) {
        myShift = .journal
        //        presentModal(menuType: myShift, title: "New Journal")
        newJournalModalCalled()
    }
    
    @IBAction func newIncidentTapped(_ sender: Any) {
        myShift = .incidents
        
        presentNewerIncidentModal()
    }
    
    @IBAction func formsTapped(_ sender: Any) {
        myShift = .forms
        presentModal(menuType: myShift, title: "")
    }
    @IBAction func cameraTapped(_ sender: Any) {
        myShift = .camera
        presentModal(menuType: myShift, title: "Camera")
    }
    
    
    @IBAction func startShiftTapped(_ sender: Any) {
        //        if !startEndShift {
        dismiss(animated: true, completion:nil)
        startEndShift = true
        shift = .start
        viewWillLayoutSubviews()
        myShift = .startShift
        let theStartDate = Date()
        startEnd = StartEnd.init(date: theStartDate)
        let fjuUserTime = UserTime.init(entity: NSEntityDescription.entity(forEntityName: "UserTime", in: context)!, insertInto: context)
        fjuUserTime.userTimeGuid = startEnd.sTuserTimeGuid
        fjuUserTime.userStartShiftTime = theStartDate
        let cal = NSCalendar.current
        let dayOfYear = cal.ordinality(of: .day, in: .year, for: theStartDate)
        fjuUserTime.userTimeDayOfYear = "\(dayOfYear ?? 0)"
        userDefaults.set(startEnd.sTuserTimeGuid, forKey: FJkUSERTIMEGUID)
        fjUserTimeCD = fjuUserTime
        userDefaults.synchronize()
        saveToCD()
        startShiftModalCalled(menuType: myShift, title: "Start Shift")
    }
    
    @IBAction func updateShiftBTapped(_ sender: Any) {
        dismiss(animated: true, completion:nil)
        startEndShift = true
        shift = .update
        myShift = .updateShift
        shiftExists = false
        //        presentModal(menuType: myShift, title: "Update Shift")
        updateShiftModalCalled(menuType: myShift, title: "Update Shift")
    }
    @IBAction func endShiftTapped(_ sender: Any) {
        startEndShift = false
        viewWillLayoutSubviews()
        myShift = .endShift
        shift = .end
        shiftExists = false
        //        presentModal(menuType: myShift, title: "End Shift")
        endShiftModalCalled(menuType: myShift, title: "End Shift")
    }
    @IBAction func nfirsSearchTapped(_ sender: Any) {
        myShift = .nfirsBasic1Search
        presentModal(menuType: myShift, title: "NFIRS Basic 1 Search")
    }
    @IBAction func alarmSearchTsapped(_ sender: Any) {
        myShift = .alarmSearch
        presentModal(menuType: myShift, title: "Alarm Search")
    }
    @IBAction func incidentSearchTapped(_ sender: Any) {
        myShift = .incidentSearch
        presentModal(menuType: myShift, title: "Incident Search")
    }
    @IBAction func ics214SearchTapped(_ sender: Any) {
        myShift = .ics214Search
        presentModal(menuType: myShift, title: "ICS 214 Search")
    }
    @IBAction func shiftCalendarTapped(_ sender: Any) {
        myShift = .shiftCalendar
        presentModal(menuType: myShift, title: "Shift Calendar")
    }
    
    //    MARK: -modal delegate
    func newModalTVCTapped(date:Date, objectID: NSManagedObjectID) {
        
    }
    func theModalTVCCancelled() {
        
    }
    
    private func theCount(entity: String)->Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        do {
            let count = try context.count(for:fetchRequest)
            return count
        } catch let error as NSError {
            print("DetailViewController line 1391 Error: \(error.localizedDescription)")
            return 0
        }
    }
    
    func formTypedTapped(shift: MenuItems) {
        self.dismiss(animated: true, completion: nil)
        let nc = NotificationCenter.default
        switch shift {
        case .nfirs:
            nc.post(name:Notification.Name(rawValue:FJkNFIRSBASIC1_FROM_MASTER),
                    object: nil,
                    userInfo: ["objectID":"", "date":"","arcFormGuid":""])
        case .ics214:
            let int = theCount(entity: "ICS214Form")
            if int != 0 {
                let objectID = fetchTheLatest(shift: shift)
                nc.post(name:Notification.Name(rawValue:FJkICS214_FROM_MASTER),
                        object: nil,
                        userInfo: ["objectID": objectID, "shift": shift])
            } else {
                slideInTransitioningDelgate.direction = .bottom
                slideInTransitioningDelgate.disableCompactHeight = true
                let vc:NewICS214ModalTVC = vcLaunch.modalICS214NewCalled()
                vc.title = "New ICS 214"
                //        let navigator = UINavigationController.init(rootViewController: vc)
                vc.delegate = self
                vc.transitioningDelegate = slideInTransitioningDelgate
                vc.modalPresentationStyle = .custom
                self.present(vc, animated: true, completion: nil)
            }
        case .arcForm:
            let int = theCount(entity: "ARCrossForm")
            if int != 0 {
                let objectID = fetchTheLatest(shift: shift)
                nc.post(name:Notification.Name(rawValue:FJkARCFORM_FROM_MASTER),
                        object: nil,
                        userInfo: ["objectID": objectID, "shift": shift])
            } else {
                slideInTransitioningDelgate.direction = .bottom
                slideInTransitioningDelgate.disableCompactHeight = true
                let vc:NewARCFormModalTVC = vcLaunch.modalARCFormNewCalled()
                vc.title = "New ARC Form"
                vc.delegate = self
                vc.transitioningDelegate = slideInTransitioningDelgate
                vc.modalPresentationStyle = .custom
                self.present(vc, animated: true, completion: nil)
            }
        default:
            print("no forms")
        }
    }
    
    func fetchTheLatest(shift: MenuItems)->NSManagedObjectID {
        var objectID:NSManagedObjectID!
        switch shift {
        case .ics214:
            var ics214 = [ICS214Form]()
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ICS214Form")
            let sort = NSSortDescriptor(key: "ics214FromTime", ascending: true)
            request.sortDescriptors = [sort]
            do {
                ics214 = try context.fetch(request) as! [ICS214Form]
                let form = ics214.last
                objectID = form?.objectID
            }  catch let error as NSError {
                let nserror = error
                let errorMessage = "\(nserror):\(nserror.localizedDescription)\(nserror.userInfo)"
                print("there were zero ICS214 Forms available \(errorMessage)")
            }
        case .arcForm:
            var arcForm = [ARCrossForm]()
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ARCrossForm")
            let sort = NSSortDescriptor(key: "arcCreationDate", ascending: true)
            request.sortDescriptors = [sort]
            do {
                arcForm = try context.fetch(request) as! [ARCrossForm]
                if !arcForm.isEmpty {
                    let form = arcForm.last
                    objectID = form?.objectID
                } else {
                    
                }
            } catch let error as NSError {
                print("DetailViewController line 1475 Error: \(error.localizedDescription)")
            }
        default: break
        }
        return objectID
    }
    
    func journalSaved(id:NSManagedObjectID,shift:MenuItems) {
        self.dismiss(animated: true, completion: nil)
        switch shift {
        case .journal:
            nc.post(name:Notification.Name(rawValue:FJkJOURNAL_FROM_MASTER),
                    object: nil,
                    userInfo: ["sizeTrait":compact!,"objectID":id])
        case .personal:
            nc.post(name:Notification.Name(rawValue:FJkPERSONAL_FROM_MASTER),
                    object: nil,
                    userInfo: ["sizeTrait":compact!,"objectID":id])
        default:
            print("not here")
        }
    }
    
    
    func incidentSave(id: NSManagedObjectID, shift: MenuItems) {
        self.dismiss(animated: true, completion: nil)
        nc.post(name:Notification.Name(rawValue:FJkINCIDENT_FROM_MASTER), object: nil, userInfo:["sizeTrait":compact!,"objectID":id])
    }
    
    func saveBTapped(shift: MenuItems) {
        myShift = shift
        switch myShift{
        case .endShift:
            startEndShift = false
            viewWillLayoutSubviews()
            self.dismiss(animated: true, completion: nil)
        case .startShift:
            startEndShift = true
            viewWillLayoutSubviews()
            self.dismiss(animated: true, completion: nil)
        default:
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func dismissTapped(shift: MenuItems) {
        myShift = shift
        switch myShift{
        case .endShift:
            startEndShift = true
            self.userDefaults.set(true, forKey: FJkSTARTSHIFTENDSHIFTBOOL)
            self.userDefaults.synchronize()
            viewWillLayoutSubviews()
            self.dismiss(animated: true, completion: nil)
        case .startShift:
            startEndShift = false
            self.userDefaults.set(false, forKey: FJkSTARTSHIFTENDSHIFTBOOL)
            self.userDefaults.synchronize()
            viewWillLayoutSubviews()
            self.dismiss(animated: true, completion: nil)
        default:
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func updateBTapped(shift: MenuItems) {
        startEndShift = true
        viewWillLayoutSubviews()
        myShift = .updateShift
        //        shift = .update
        //        presentModal(menuType: myShift, title: "Update Shift")
        updateShiftModalCalled(menuType: myShift, title: "Update Shift")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showJournalNewDetail" {
            let modalTVC = segue.destination as! ModalTVC
            modalTVC.delegate = self
        }
    }
    
}

extension Destial04132020ViewController: JournalModalTVCDelegate {
    func dismissJModalTapped(shift: MenuItems) {
        self.dismiss(animated: true, completion: nil)
    }
    func journalModalSaved(id:NSManagedObjectID,shift:MenuItems) {
        self.dismiss(animated: true, completion: nil)
        nc.post(name:Notification.Name(rawValue:FJkJOURNAL_FROM_MASTER),object: nil, userInfo: ["sizeTrait":compact!,"objectID":id])
    }
}

extension Destial04132020ViewController: NewerIncidentModalTVCDelegate {
    func theNewIncidentCancelled() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func theNewIncidentModalSaved(ojectID: NSManagedObjectID, shift: MenuItems) {
        self.dismiss(animated: true, completion: nil)
        nc.post(name:Notification.Name(rawValue:FJkINCIDENT_FROM_MASTER), object: nil, userInfo:["sizeTrait":compact!,"objectID":ojectID])
    }
}

extension Destial04132020ViewController: StartShiftModalTVCDelegate {
    
    //    MARK: -StartShiftModalTVCDelegate
    func cancelStartShiftCalled() {
        self.dismiss(animated: true, completion: nil)
        shift = .end
        viewWillLayoutSubviews()
    }
    
    func startShiftSaved(shift: MenuItems, startShift: StartShiftData) {
        startShiftStructure = startShift
        shiftExists = true
        if startShiftStructure.ssPlatoonTF != "" {
            platoonL.text = startShiftStructure.ssPlatoonTF
        }
        if startShiftStructure.ssFireStationTF != "" {
            fireStationL.text = startShiftStructure.ssFireStationTF
        }
        if startShiftStructure.ssAssignmentTF != "" {
            assignmentL.text = startShiftStructure.ssAssignmentTF
        }
        if startShiftStructure.ssApparatusTF != "" {
            apparatusL.text = startShiftStructure.ssApparatusTF
        }
        if startShiftStructure.ssResourcesCombine != "" {
            resourceaL.text = startShiftStructure.ssResourcesCombine
        }
        if startShiftStructure.ssCrewsTF != "" {
            crewTV.text = startShiftStructure.ssCrewsTF
        }
        if startShiftStructure.ssAMReliefDefault {
            statusL.text = "AM Relief"
        } else {
            statusL.text = "Overtime"
        }
        print("here is startshift \(startShift)")
        attribute = "journalDateSearch"
        journalCount = theJournalCount(entity: "Journal")
        journalCountL.text = "\(journalCount) Journal"
        journalCountL.setNeedsDisplay()
        
        self.userDefaults.set(0, forKey: FJkSTARTUPDATEENDSHIFT)
        self.userDefaults.set(true, forKey: FJkSTARTSHIFTENDSHIFTBOOL)
        self.userDefaults.synchronize()
        startEndShift = true
        viewWillLayoutSubviews()
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension Destial04132020ViewController: EndShiftModalTVCDelegate {
    func endShiftCancelTapped() {
        self.dismiss(animated: true, completion: nil)
        shift = .start
        viewWillLayoutSubviews()
    }
    
    func endShiftUpdated(shift: MenuItems, EndShift: EndShiftData) {
        endShiftStructure = EndShift
        shiftExists = true
        if endShiftStructure.esPlatoonTF != "" {
            platoonL.text = endShiftStructure.esPlatoonTF
        }
        if endShiftStructure.esFireStationTF != "" {
            fireStationL.text = endShiftStructure.esFireStationTF
        }
        if endShiftStructure.esAMReliefDefaultT {
            statusL.text = "AM Relief"
        } else {
            statusL.text = "Overtime"
        }
        attribute = "journalDateSearch"
        journalCount = theJournalCount(entity: "Journal")
        journalCountL.text = "\(journalCount) Journal"
        journalCountL.setNeedsDisplay()
        
        self.userDefaults.set(2, forKey: FJkSTARTUPDATEENDSHIFT)
        self.userDefaults.set(false, forKey: FJkSTARTSHIFTENDSHIFTBOOL)
        
        self.userDefaults.synchronize()
        startEndShift = false
        viewWillLayoutSubviews()
        self.dismiss(animated: true, completion: nil)
        //        endShiftStructure = EndShift
        //        shiftExists = true
        //        if endShiftStructure.esPlatoonTF != "" {
        //            platoonL.text = endShiftStructure.esPlatoonTF
        //        }
        //        if endShiftStructure.esFireStationTF != "" {
        //            fireStationL.text = endShiftStructure.esFireStationTF
        //        }
        //        if endShiftStructure.esAMReliefDefaultT {
        //            statusL.text = "AM Relief"
        //        } else {
        //            statusL.text = "Overtime"
        //        }
        //        if endShiftStructure.esResourcesCombine != "" {
        //            resourceaL.text = endShiftStructure.esResourcesCombine
        //        }
        //        attribute = "journalDateSearch"
        //        journalCount = theJournalCount(entity: "Journal")
        //        journalCountL.text = "\(journalCount) Journal"
        //        journalCountL.setNeedsDisplay()
        //
        //        self.userDefaults.set(2, forKey: FJkSTARTUPDATEENDSHIFT)
        //        self.userDefaults.set(true, forKey: FJkSTARTSHIFTENDSHIFTBOOL)
        //        self.userDefaults.synchronize()
        //        startEndShift = true
        //        viewWillLayoutSubviews()
        //        self.dismiss(animated: true, completion: nil)
    }
    
    
}

extension Destial04132020ViewController: UpdateShiftModalTVCDelegate {
    func cancelUpdateShiftCalled() {
        self.dismiss(animated: true, completion: nil)
        shift = .start
        viewWillLayoutSubviews()
    }
    
    func updateShiftSaved(shift: MenuItems, UpdateShift: UpdateShiftData) {
        updateShiftStructure = UpdateShift
        shiftExists = true
        if updateShiftStructure.upsPlatoonTF != "" {
            platoonL.text = updateShiftStructure.upsPlatoonTF
        }
        if updateShiftStructure.upsFireStationTF != "" {
            fireStationL.text = updateShiftStructure.upsFireStationTF
        }
        if updateShiftStructure.upsAMReliefDefaultT {
            statusL.text = "AM Relief"
        } else {
            statusL.text = "Overtime"
        }
        if updateShiftStructure.upsResourcesCombine != "" {
            resourceaL.text = updateShiftStructure.upsResourcesCombine
        }
        attribute = "journalDateSearch"
        journalCount = theJournalCount(entity: "Journal")
        journalCountL.text = "\(journalCount) Journal"
        journalCountL.setNeedsDisplay()
        
        self.userDefaults.set(1, forKey: FJkSTARTUPDATEENDSHIFT)
        self.userDefaults.set(true, forKey: FJkSTARTSHIFTENDSHIFTBOOL)
        self.userDefaults.synchronize()
        startEndShift = true
        viewWillLayoutSubviews()
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

extension Destial04132020ViewController: EndShiftDashboardModalTVCDelegate {
    func endShiftSave(shift: MenuItems, EndShift: EndShiftData) {
        endShiftStructure = EndShift
        shiftExists = true
        if endShiftStructure.esFireStationTF != "" {
            fireStationL.text = endShiftStructure.esFireStationTF
        }
        attribute = "journalDateSearch"
        journalCount = theJournalCount(entity: "Journal")
        journalCountL.text = "\(journalCount) Journal"
        journalCountL.setNeedsDisplay()
        
        self.userDefaults.set(2, forKey: FJkSTARTUPDATEENDSHIFT)
        self.userDefaults.set(false, forKey: FJkSTARTSHIFTENDSHIFTBOOL)
        
        self.userDefaults.synchronize()
        startEndShift = false
        viewWillLayoutSubviews()
        let shouldAlert = userDefaults.bool(forKey: FJkEndShiftDontShowAgain)
        self.dismiss(animated: true, completion: {
            if !shouldAlert {
                if !self.alertUp {
                    self.presentEndAlert()
                }
            }
        })
    }
    
    func endShiftCancel() {
        self.dismiss(animated: true, completion: nil)
        self.shift = .start
        viewWillLayoutSubviews()
    }
    
    func presentEndAlert() {
        let message = "Your End Shift has been recorded into your Journal Entries, you can add more information into the Discussion, Next Steps and Summary areas of the Journal"
        let alert = UIAlertController.init(title: "End Shift Support Notes", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
        })
        let dontShow = UIAlertAction.init(title: "Don't Show Again", style: .default, handler: {_ in
            self.userDefaults.set(true, forKey: FJkUpdateShiftDontShowAgain)
            self.userDefaults.synchronize()
        })
        alert.addAction(okAction)
        alert.addAction(dontShow)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    
    
}

extension Destial04132020ViewController: UpdateShiftDashboardModalTVCDelegate {
    func updateShiftCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func updateShiftSave(shift: MenuItems, UpdateShift: UpdateShiftData) {
        updateShiftStructure = UpdateShift
        shiftExists = true
        if updateShiftStructure.upsFireStationTF != "" {
            fireStationL.text = updateShiftStructure.upsFireStationTF
        }
        attribute = "journalDateSearch"
        journalCount = theJournalCount(entity: "Journal")
        journalCountL.text = "\(journalCount) Journal"
        journalCountL.setNeedsDisplay()
        
        self.userDefaults.set(1, forKey: FJkSTARTUPDATEENDSHIFT)
        self.userDefaults.set(true, forKey: FJkSTARTSHIFTENDSHIFTBOOL)
        self.userDefaults.synchronize()
        startEndShift = true
        viewWillLayoutSubviews()
        let shouldAlert = userDefaults.bool(forKey: FJkUpdateShiftDontShowAgain)
        self.dismiss(animated: true, completion: {
            if !shouldAlert {
                if !self.alertUp {
                    self.presentUpdateAlert()
                }
            }
        })
    }
    
    func presentUpdateAlert() {
        let message = "Your Update Shift has been recorded into your Journal Entries, you can add more information into the Discussion, Next Steps and Summary areas of the Journal"
        let alert = UIAlertController.init(title: "Update Shift Support Notes", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
        })
        let dontShow = UIAlertAction.init(title: "Don't Show Again", style: .default, handler: {_ in
            self.userDefaults.set(true, forKey: FJkUpdateShiftDontShowAgain)
            self.userDefaults.synchronize()
        })
        alert.addAction(okAction)
        alert.addAction(dontShow)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    
    
}

extension Destial04132020ViewController: StartShiftDashbaordModalTVCDelegate {
    
    func startShiftSave(shift: MenuItems, startShift: StartShiftData) {
        startShiftStructure = startShift
        shiftExists = true
        if startShiftStructure.ssPlatoonTF != "" {
            platoonL.text = startShiftStructure.ssPlatoonTF
        }
        if startShiftStructure.ssFireStationTF != "" {
            fireStationL.text = startShiftStructure.ssFireStationTF
        }
        if startShiftStructure.ssAssignmentTF != "" {
            assignmentL.text = startShiftStructure.ssAssignmentTF
        }
        if startShiftStructure.ssApparatusTF != "" {
            apparatusL.text = startShiftStructure.ssApparatusTF
        }
        if startShiftStructure.ssResourcesCombine != "" {
            resourceaL.text = startShiftStructure.ssResourcesCombine
        }
        if startShiftStructure.ssCrewsTF != "" {
            crewTV.text = startShiftStructure.ssCrewsTF
        }
        if startShiftStructure.ssAMReliefDefault {
            statusL.text = "AM Relief"
        } else {
            statusL.text = "Overtime"
        }
        print("here is startshift \(startShift)")
        attribute = "journalDateSearch"
        journalCount = theJournalCount(entity: "Journal")
        journalCountL.text = "\(journalCount) Journal"
        journalCountL.setNeedsDisplay()
        
        self.userDefaults.set(0, forKey: FJkSTARTUPDATEENDSHIFT)
        self.userDefaults.set(true, forKey: FJkSTARTSHIFTENDSHIFTBOOL)
        self.userDefaults.synchronize()
        startEndShift = true
        viewWillLayoutSubviews()
        let shouldAlert = userDefaults.bool(forKey: FJkStartShiftDontShowAgain)
        self.dismiss(animated: true, completion: {
            if !shouldAlert {
                if !self.alertUp {
                    self.presentAlert()
                }
            }
        })
    }
    
    func presentAlert() {
        let message = "Your Start Shift has been recorded into your Journal Entries, you can add more information into the Discussion, Next Steps and Summary areas of the Journal"
        let alert = UIAlertController.init(title: "Start Shift Support Notes", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
        })
        let dontShow = UIAlertAction.init(title: "Don't Show Again", style: .default, handler: {_ in
            self.userDefaults.set(true, forKey: FJkStartShiftDontShowAgain)
            self.userDefaults.synchronize()
        })
        alert.addAction(okAction)
        alert.addAction(dontShow)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    
    func startShiftCancel() {
        self.dismiss(animated: true, completion: nil)
        self.shift = .start
        viewWillLayoutSubviews()
    }
}
