//
//  NewICS214NewIncidentTVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 7/24/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import MapKit
import CoreLocation

protocol NewICS214NewIncidentTVCDelegate: AnyObject {
    func newICS214NewIncidentCanceled()
    func theNewICS214IncidentModalSaved(ojectID: NSManagedObjectID, shift: MenuItems)
}

class NewICS214NewIncidentTVC: UITableViewController, CLLocationManagerDelegate {

    //    MARK: Objects
       weak var delegate: NewICS214NewIncidentTVCDelegate? = nil
       var modalTitle: InfoBodyText  = .newIncidentSubject
       
       var modalInstructions: InfoBodyText =  .newIncident
       
       let userDefaults = UserDefaults.standard
       var fjUserTime:UserTime! = nil
       let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
       
       // MARK: Properties
       var myShift: MenuItems = .journal
       var journalType: JournalTypes = .station
       var incidentType: IncidentTypes = .fire
       var showPicker:Bool = false
       var showMap:Bool = false
       var incidentStructure: IncidentData!
       var city: String = ""
       var streetNum: String = ""
       var streetName: String = ""
       var stateName: String = ""
       var zipNum: String = ""
       var incidentNumber: String = ""
       var alarmDate: String = ""
       var currentLocation: CLLocation!
       var locationManager:CLLocationManager!
       private var tableSize: TableSize!
       var entity: String = "Incident"
       var attribute: String = "fjpIncGuidForReference"
       var addressTyped: Bool = false
       
       var fetched:Array<Any>!
       var objectID:NSManagedObjectID!
       var resourceTapped: Bool = false
       var segmentType: MenuItems = .fire
       var fju:FireJournalUser!
       
       lazy var slideInTransitioningDelgate = SlideInPresentationManager()
       var fjIncident:Incident!
       var alertUp: Bool = false
       let nc = NotificationCenter.default
       
       
       let vcLaunch = VCLaunch()
       var launchNC: LaunchNotifications!
       var yesNo:Bool = false
       
       //    MARK: FDResources
       var fdResources = [UserFDResources]()
       var fdResourceCount: Int = 0
       var fdResourcesA = [String]()
       var fdResource: UserFDResources!
       var incidentFDResources =  [UserFDResources]()
       var userFDResourcesCD = [UserFDResources]()
       var incidentUserResources = [IncidentUserResource]()
       var chosenIncidentUserResources = [IncidentUserResource]()
       var chosenIncidentResourceName = [String]()
       
       func fdResourcesToIncidentUserResources() {
           for fd in userFDResourcesCD {
               var iur = IncidentUserResource.init(imageName: fd.fdResource ?? "")
               iur.customOrNot = fd.customResource
               iur.assetName = "GreenAvailable"
               iur.type = 0002
               incidentUserResources.append(iur)
           }
           fdResourceCount = incidentUserResources.count
       }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Device.IS_IPHONE {
            let frame = self.view.frame
            let height = frame.height - 44
            self.view.frame = CGRect(x: 0, y: 44, width: frame.width, height: height)
            self.tableView = UITableView.init(frame: self.view.frame, style: .grouped)
        }
        vcLaunch.splitVC = self.splitViewController
        launchNC = LaunchNotifications.init(launchVC: vcLaunch)
        launchNC.callNotifications()
        roundViews()
        registerCellsForTable()
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        incidentStructure = IncidentData.init()
        getTheUserFDResources()
        fdResourcesToIncidentUserResources()
        getTheUser()
        
    }
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    
    func roundViews() {
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
    }
    
    func registerCellsForTable() {
        tableView.register(UINib(nibName: "LabelCell", bundle: nil), forCellReuseIdentifier: "LabelCell")
        tableView.register(UINib(nibName: "LabelWithInfoCell", bundle: nil), forCellReuseIdentifier: "LabelWithInfoCell")
        tableView.register(UINib(nibName: "TextViewCell", bundle: nil), forCellReuseIdentifier: "TextViewCell")
        tableView.register(UINib(nibName: "LabelYesNoSwitchCell", bundle: nil), forCellReuseIdentifier: "LabelYesNoSwitchCell")
        tableView.register(UINib(nibName: "LabelTextFieldCell", bundle: nil), forCellReuseIdentifier: "LabelTextFieldCell")
        tableView.register(UINib(nibName: "LabelDateTimeButtonCell", bundle: nil), forCellReuseIdentifier: "LabelDateTimeButtonCell")
        tableView.register(UINib(nibName: "DatePickerCell", bundle: nil), forCellReuseIdentifier: "DatePickerCell")
        tableView.register(UINib(nibName: "SegmentCell", bundle: nil), forCellReuseIdentifier: "SegmentCell")
        tableView.register(UINib(nibName: "AddressFieldsButtonsCell", bundle: nil), forCellReuseIdentifier: "AddressFieldsButtonsCell")
        tableView.register(UINib(nibName: "MapViewCell", bundle: nil), forCellReuseIdentifier: "MapViewCell")
        tableView.register(UINib(nibName: "FDResourceIncidentCell", bundle: nil), forCellReuseIdentifier: "FDResourceIncidentCell")
        //        MARK: -CollectionViewCells
        tableView.register(UINib(nibName: "UserFDResourcesCell", bundle: nil), forCellReuseIdentifier: "UserFDResourcesCell")
        tableView.register(UINib(nibName: "UserFDResourceCVCell", bundle: nil), forCellReuseIdentifier: "UserFDResourceCVCell")
        tableView.register(UINib(nibName: "UserFDResourceCustomCVCell", bundle: nil), forCellReuseIdentifier: "UserFDResourceCustomCVCell")
    }

    // MARK: - Table view data source
    // MARK: - Table view data source// MARK: - Table View
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerV = Bundle.main.loadNibNamed("ModalHeaderSaveDismiss", owner: self, options: nil)?.first as! ModalHeaderSaveDismiss
        headerV.modalHTitleL.textColor = UIColor.white
        headerV.modalHCancelB.setTitle("Cancel",for: .normal)
        headerV.modalHCancelB.setTitleColor(UIColor.white, for: .normal)
        headerV.modalHSaveB.setTitle("Save",for: .normal)
        headerV.modalHSaveB.setTitleColor(UIColor.white, for: .normal)
        headerV.modalHTitleL.text = ""
        let color = UIColor.systemRed //ButtonsForFJ092018.fillColor38

        headerV.contentView.backgroundColor = color

        
        headerV.myShift = MenuItems.incidents
        headerV.delegate = self
        return headerV
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        switch row {
        case 0:
            return 44
        case 1:
            return 65
        case 2:
            return 85
        case 3:
            return 80
        case 4:
            if(showPicker) {
            return  132
        } else {
            return 0
            }
        case 5:
            return 84
        case 6:
            return 287
        case 7:
            if(showMap) {
            return 500
        } else {
            return 0
            }
        case 8:
            if fdResourceCount <= 5 {
                if Device.IS_IPAD {
                    return 290
                } else {
                    return 420
                }
            } else {
                if Device.IS_IPAD {
                    return 310
                } else {
                    return 410
                }
            }
        case 9:
            return 100
        default:
            return 44
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        switch row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelWithInfoCell", for: indexPath) as! LabelWithInfoCell
            cell.subjectL.text = modalTitle.rawValue
            cell.delegate = self
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelYesNoSwitchCell", for: indexPath) as! LabelYesNoSwitchCell
            cell.delegate = self
            cell.yesNotSwitch.onTintColor = UIColor.systemRed
            cell.yesNotSwitch.backgroundColor = UIColor.systemRed//UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.35)
            cell.yesNotSwitch.layer.cornerRadius = 16
            cell.yesNotSwitch.isOn = incidentStructure.incidentEmergencyYesNo
            if incidentStructure.incidentEmergencyYesNo {
               incidentStructure.incidentEmergency = "Emergency"
            } else {
                incidentStructure.incidentEmergency = "Non-Emergency"
            }
            cell.yesNoB = yesNo
            cell.myShift = myShift
            cell.incidentType = .emergency
            cell.subjectL.text = "Emergency"
            cell.leftText = "No"
            cell.rightText = "Yes"
            cell.rightL.textColor = UIColor.systemRed
            cell.leftL.textColor = UIColor.systemRed
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
            cell.descriptionTF.keyboardType = .numbersAndPunctuation
            cell.descriptionTF.reloadInputViews()
            cell.delegate = self
            cell.theShift = myShift
            cell.subjectL.text = "Incident Number"
            cell.descriptionTF.textColor = UIColor.systemRed
            if incidentStructure.incidentNumber != "" {
                cell.descriptionTF.text = incidentStructure.incidentNumber
            } else {
                cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "01",attributes: [NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel])
            }
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelDateTimeButtonCell", for: indexPath) as! LabelDateTimeButtonCell
            cell.delegate = self
            cell.type = IncidentTypes.fire
            cell.dateTimeTV.textColor = UIColor.systemRed//UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1.0)
            if incidentStructure.incidentFullAlarmDateS != "" {
                cell.dateTimeTV.text = incidentStructure.incidentFullAlarmDateS
            } else {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/YYYY HH:mm"
                let date = Date()
                let incidentDate = dateFormatter.string(from: date)
                incidentStructure.incidentFullAlarmDateS = incidentDate
                incidentStructure.incidentDate = date
                incidentStructure.incidentAlarmDate = date
                let month = MonthFormat.init(date: date)
                incidentStructure.incidentAlarmMM = month.monthForDate()
                let day = DayFormat.init(date: date)
                incidentStructure.incidentAlarmdd = day.dayForDate()
                let year = YearFormat.init(date: date)
                incidentStructure.incidentAlarmYYYY = year.yearForDate()
                let hour = HourFormat.init(date: date)
                incidentStructure.incidentAlarmHH = hour.hourForDate()
                let minutes = MinuteFormat.init(date: date)
                incidentStructure.incidentAlarmmm = minutes.minuteForDate()
                cell.dateTimeTV.attributedPlaceholder = NSAttributedString(string: incidentStructure.incidentFullAlarmDateS,attributes: [NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel])
            }
            cell.dateTimeL.text = "Date/Time"
            let image = UIImage(named: "ICONS_TimePiece red")
            cell.dateTimeB.setImage(image, for: .normal )
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! DatePickerCell
            let incidentType:IncidentTypes = .alarm
            cell.delegate2 = self
            cell.incidentType = incidentType
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SegmentCell", for: indexPath) as! SegmentCell
            cell.delegate = self
            cell.subjectL.text = "Incident Type"
            cell.myShift = .incidents
            cell.typeSegment.setTitle("Fire", forSegmentAt: 0)
            cell.typeSegment.setTitle("EMS", forSegmentAt: 1)
            cell.typeSegment.setTitle("Rescue", forSegmentAt: 2)
            
            if incidentStructure.incidentType == "" {
                incidentStructure.incidentType = "Fire"
            }
            
            switch segmentType {
            case .fire:
                cell.typeSegment.selectedSegmentIndex = 0
            case .ems:
                cell.typeSegment.selectedSegmentIndex = 1
            case .rescue:
                cell.typeSegment.selectedSegmentIndex = 2
            default:
                cell.typeSegment.selectedSegmentIndex = 0
            }
            return cell
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddressFieldsButtonsCell", for: indexPath) as! AddressFieldsButtonsCell
            cell.subjectL.text = "Address"
            if incidentStructure.incidentStreetName == "" {
                cell.addressTF.attributedPlaceholder = NSAttributedString(string: "100 Main Street",attributes: [NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel])
            } else {
                streetName = incidentStructure.incidentStreetName
                streetNum = incidentStructure.incidentStreetNum
                cell.addressTF.text = "\(streetNum) \(streetName)"
            }
            cell.addressTF.textColor = UIColor.systemRed
            if incidentStructure.incidentCity == "" {
                cell.cityTF.attributedPlaceholder = NSAttributedString(string: "Your Town",attributes: [NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel])
            } else {
                cell.cityTF.text = incidentStructure.incidentCity
            }
            cell.cityTF.textColor = UIColor.systemRed
            if incidentStructure.incidentState == "" {
                cell.stateTF.attributedPlaceholder = NSAttributedString(string: "CA",attributes: [NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel])
            } else {
                cell.stateTF.text = incidentStructure.incidentState
            }
            cell.stateTF.textColor = UIColor.systemRed
            if incidentStructure.incidentZip == "" {
                cell.zipTF.attributedPlaceholder = NSAttributedString(string: "90001",attributes: [NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel])
            } else {
                cell.zipTF.text = incidentStructure.incidentZip
            }
            cell.zipTF.textColor = UIColor.systemRed
            if incidentStructure.incidentLocation != nil {
                if incidentStructure.incidentLatitude != "" {
                    cell.addressLatitudeTF.text = incidentStructure.incidentLatitude
                    cell.addressLatitudeTF.textColor = UIColor.systemRed
                }
                if incidentStructure.incidentLongitude != "" {
                    cell.addressLongitudeTF.text = incidentStructure.incidentLongitude
                    cell.addressLongitudeTF.textColor = UIColor.systemRed
                }
            } else {
                cell.addressLongitudeTF.attributedPlaceholder = NSAttributedString(string: "Incident Longitude",attributes: [NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel])
                cell.addressLatitudeTF.attributedPlaceholder = NSAttributedString(string: "Incident Latitude",attributes: [NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel])
            }
            cell.delegate = self
            return cell
        case 7:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MapViewCell", for: indexPath) as! MapViewCell
            cell.delegate = self
            switch myShift {
            case .incidents:
                cell.incidentType = incidentStructure.incidentType
            default: break
            }
            if(showMap) {
                let frame = CGRect(
                    origin: CGPoint(x: 0, y: 0),
                    size: CGSize(width: tableView.frame.size.width, height: 500)
                )
                cell.contentView.frame = frame
                cell.useAddressB.isHidden = false
                cell.useAddressB.alpha = 1.0
                if incidentStructure.incidentLocation != nil {
                    cell.currentLocation = incidentStructure.incidentLocation!
                }
                cell.reload()
            } else {
                let frame = CGRect(
                    origin: CGPoint(x: 0, y: 0),
                    size: CGSize(width: tableView.frame.size.width, height: 0)
                )
                cell.contentView.frame = frame
                cell.useAddressB.isHidden = true
                cell.useAddressB.alpha = 0.0
            }
            return cell
        case 8:
            if incidentUserResources.count != 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "FDResourceIncidentCell", for: indexPath) as! FDResourceIncidentCell
                cell.incidentOrNew = false
                cell.instantResources = incidentUserResources
                cell.subjectL.text = "Fire/EMS Resources"
                cell.additionalL.isHidden = true
                cell.additionalL.alpha = 0.0
                cell.addB.isHidden = true
                cell.addB.alpha = 0.0
                cell.addB.isEnabled = false
                cell.delegate = self
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
                cell.modalTitleL.font = cell.modalTitleL.font.withSize(12)
                cell.modalTitleL.adjustsFontSizeToFitWidth = true
                cell.modalTitleL.lineBreakMode = NSLineBreakMode.byWordWrapping
                cell.modalTitleL.numberOfLines = 0
                cell.modalTitleL.setNeedsDisplay()
                cell.modalTitleL.textColor = UIColor.systemRed//UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1.0)
                cell.modalTitleL.text = "You haven't set up your resources yet. To set up your station's apparatus, you'll need to go into Settings, under Additional Fire/EMS Resources and choose up to 10 Fire/EMS Resources to be your base Station Apparatus. Once created, you can manage your Fire/EMS Resources with Front Line, Reserve and Out of Service modes."
                return cell
            }
        case 9:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
            cell.modalTitleL.isHidden = true
            cell.modalTitleL.alpha = 0.0
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
            
            // Configure the cell...
            
            return cell
        }
    }

}
