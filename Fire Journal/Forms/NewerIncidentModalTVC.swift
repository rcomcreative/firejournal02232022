//
//  NewerIncidentModalTVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 8/22/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import MapKit
import CoreLocation

protocol NewerIncidentModalTVCDelegate: AnyObject {
    func theNewIncidentCancelled()
    func theNewIncidentModalSaved(ojectID: NSManagedObjectID, shift: MenuItems)
}

class NewerIncidentModalTVC: UITableViewController, CLLocationManagerDelegate {

    //    MARK: Objects
    var modalTitle: InfoBodyText  = .newIncidentSubject
    
    var modalInstructions: InfoBodyText =  .newIncident
    
    let userDefaults = UserDefaults.standard
    var fjUserTime:UserTime! = nil
    weak var delegate: NewerIncidentModalTVCDelegate? = nil
    var context:NSManagedObjectContext!
    
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
    
    
    private let vcLaunch = VCLaunch()
    private var launchNC: LaunchNotifications!
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
            cell.delegate = self
            cell.theShift = MenuItems.incidents
            cell.subjectL.text = "Incident Number"
            cell.descriptionTF.tag = 1
            cell.descriptionTF.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1.0)
            if incidentStructure.incidentNumber != "" {
                cell.descriptionTF.text = incidentStructure.incidentNumber
            } else {
                cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "01",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.85)])
            }
            return cell
//            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
////            cell.descriptionTF.keyboardType = .numbersAndPunctuation
////            cell.descriptionTF.reloadInputViews()
//            cell.delegate = self
//            cell.theShift = myShift
//            cell.subjectL.text = "Incident Number"
//            cell.descriptionTF.textColor = UIColor.systemRed
//            if incidentStructure.incidentNumber != "" {
//                cell.descriptionTF.text = incidentStructure.incidentNumber
//            } else {
//                cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "01",attributes: [NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel])
//            }
//            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelDateTimeButtonCell", for: indexPath) as! LabelDateTimeButtonCell
            cell.delegate = self
            cell.type = IncidentTypes.fire
            cell.dateTimeTV.textColor = UIColor.systemRed
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
            cell.dateTimeB.setImage(image, for: .normal)
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! DatePickerCell
            let incidentType:IncidentTypes = .alarm
            cell.delegate2 = self
            cell.incidentType = incidentType
            cell.datePicker.tintColor = .systemRed
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
                cell.modalTitleL.textColor = UIColor.systemRed
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

extension NewerIncidentModalTVC {
    
    private func getTheUserFDResources() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserFDResources")
        var predicate = NSPredicate.init()
        let two: Int64 = 2;
        predicate = NSPredicate(format: "%K = %d", "fdResourceType", two)
        fetchRequest.predicate = predicate
        let sectionSortDescriptor = NSSortDescriptor(key: "fdResource", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.fetchLimit = 10
        do {
            fdResources = try context.fetch(fetchRequest) as! [UserFDResources]
            
            if fdResources.count == 0 {
                print("hey we have zero")
            } else {
                fdResourceCount = fdResources.count
                fdResourceCount = fdResourceCount+1
                for resource in fdResources {
                    if fdResource == nil {
                        fdResource = resource
                    }
                    userFDResourcesCD.append(resource)
                    fdResourcesA.append(resource.fdResource!)
//                    let result = fdResourcesA.filter { $0 == resource.fdResource}
//                    if result.isEmpty {
//                        if resource.fdResourceType == 0002 || resource.fdResourceType == 0001 {
//                            userFDResourcesCD.append(resource)
//                            if fdResourceCount < 10 {
//                                fdResourceCount = fdResourceCount+1
//                            }
//                        }
//                        fdResourcesA.append(resource.fdResource!)
//                    }
                }
                
            }
        }  catch {
            let nserror = error as NSError
            let errorMessage = "SettingsUserFDResourcesTVC getUserFDResources Unresolved error \(nserror), \(nserror.userInfo)"
            print(errorMessage)
        }
    }
    
    private func getTheUser() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FireJournalUser" )
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != %@", "userGuid", "")
        let sectionSortDescriptor = NSSortDescriptor(key: "lastName", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 1
        
        do {
            let count = try context.count(for:fetchRequest)
            if count != 0 {
                do {
                    fetched = try context.fetch(fetchRequest) as! [FireJournalUser]
                    fju = fetched.last as? FireJournalUser
                    incidentStructure.incidentUser = fju.userName ?? ""
                    incidentStructure.incidentFireStation = fju.fireStation ?? ""
                    incidentStructure.incidentPlatoon = fju.tempPlatoon ?? ""
                    incidentStructure.incidentAssignment = fju.tempAssignment ?? ""
                    incidentStructure.incidentApparatus = fju.tempApparatus ?? ""
                } catch let error as NSError {
                    print("ModalTVC line 1806 Fetch Error: \(error.localizedDescription)")
                }
            }
            
        } catch let error as NSError {
            print("ModalTVC line 1806 Fetch Error: \(error.localizedDescription)")
        }
    }
    
    private func saveTheIncident() {
        let fjuIncident = Incident.init(entity: NSEntityDescription.entity(forEntityName: "Incident", in: context)!, insertInto: context)
        let incidentModDate = Date()
        let iGuidDate = GuidFormatter.init(date:incidentModDate)
        let iGuid:String = iGuidDate.formatGuid()
        fjuIncident.fjpIncGuidForReference = "02."+iGuid
        let jGuidDate = GuidFormatter.init(date:incidentModDate)
        let jGuid:String = jGuidDate.formatGuid()
        fjuIncident.fjpJournalReference = "01."+jGuid
        fjuIncident.fjpUserReference = fju.userGuid
        
        let searchDate = FormattedDate.init(date:incidentModDate)
        let sDate:String = searchDate.formatTheDate()
        fjuIncident.incidentSearchDate = sDate
        fjuIncident.incidentDateSearch = sDate
        fjuIncident.incidentNumber = incidentStructure.incidentNumber
        fjuIncident.incidentType = incidentStructure.incidentEmergency
        fjuIncident.situationIncidentImage = incidentStructure.incidentType
        fjuIncident.incidentEntryTypeImageName = incidentStructure.incidentImageName
        
//        MARK: -LOCATION-
        /// incidentLocaiton archived with secureCoding
        if incidentStructure.incidentLocation != nil {
            let location = incidentStructure.incidentLocation!
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: true)
                fjuIncident.incidentLocationSC = data as NSObject
            } catch {
                print("got an error here")
            }
            fjuIncident.incidentStreetNumber = incidentStructure.incidentStreetNum
            fjuIncident.incidentStreetHyway = incidentStructure.incidentStreetName
            fjuIncident.incidentZipCode = incidentStructure.incidentZip
            fjuIncident.incidentLongitude = incidentStructure.incidentLongitude
            fjuIncident.incidentLatitude = incidentStructure.incidentLatitude
        }
        fjuIncident.incidentBackedUp = false
        fjuIncident.incidentNFIRSCompleted = false
        fjuIncident.incidentNFIRSDataComplete = false
        fjuIncident.incidentPhotoTaken = false
        fjuIncident.incidentCreationDate = incidentModDate
        fjuIncident.incidentModDate = incidentModDate
        fjuIncident.fjpIncidentDateSearch = incidentModDate
        
        let fjuIncidentAddress = IncidentAddress.init(entity: NSEntityDescription.entity(forEntityName: "IncidentAddress", in: context)!, insertInto: context)
        
        fjuIncidentAddress.streetHighway = incidentStructure.incidentStreetName
        fjuIncidentAddress.streetNumber = incidentStructure.incidentStreetNum
        fjuIncidentAddress.city = incidentStructure.incidentCity
        fjuIncidentAddress.incidentState = incidentStructure.incidentState
        fjuIncidentAddress.zip = incidentStructure.incidentZip
        fjuIncidentAddress.prefix = incidentStructure.incidentStreetPrefix
        fjuIncidentAddress.streetType = incidentStructure.incidentStreetType
        fjuIncidentAddress.incidentAddressInfo = fjuIncident
        
        let fjuIncidentLocal = IncidentLocal.init(entity: NSEntityDescription.entity(forEntityName: "IncidentLocal", in: context)!, insertInto: context)
        fjuIncidentLocal.incidentLocalType = incidentStructure.incidentLocalType
        fjuIncidentLocal.incidentLocalInfo = fjuIncident
        
        let fjuIncidentNFIRS = IncidentNFIRS.init(entity: NSEntityDescription.entity(forEntityName: "IncidentNFIRS", in: context)!, insertInto: context)
        fjuIncidentNFIRS.incidentTypeNumberNFRIS = incidentStructure.incidentNfirsIncidentTypeNumber
        fjuIncidentNFIRS.incidentTypeTextNFRIS = incidentStructure.incidentNfirsIncidentType
        fjuIncidentNFIRS.incidentFDID = fju.fdid ?? ""
        fjuIncidentNFIRS.fireStationState = fju.fireStationState ?? ""
        fjuIncidentNFIRS.incidentFireStation = fju.fireStation ?? ""
        fjuIncidentNFIRS.incidentLocation = incidentStructure.incidentLocationType
        fjuIncidentNFIRS.incidentNFIRSInfo = fjuIncident
        
        let fjuIncidentNotes = IncidentNotes.init(entity: NSEntityDescription.entity(forEntityName: "IncidentNotes", in: context)!, insertInto: context)
        fjuIncidentNotes.incidentNote = ""
        fjuIncidentNotes.incidentSummaryNotes = "" as NSObject
        fjuIncidentNotes.incidentNotesInfo = fjuIncident
        
        let fjuIncidentTimer = IncidentTimer.init(entity: NSEntityDescription.entity(forEntityName: "IncidentTimer", in: context)!, insertInto: context)
        fjuIncidentTimer.incidentAlarmCombinedDate = incidentStructure.incidentFullAlarmDateS
        fjuIncidentTimer.incidentAlarmDateTime = incidentStructure.incidentAlarmDate
        fjuIncidentTimer.incidentAlarmMonth = incidentStructure.incidentAlarmMM
        fjuIncidentTimer.incidentAlarmDay = incidentStructure.incidentAlarmdd
        fjuIncidentTimer.incidentAlarmYear = incidentStructure.incidentAlarmYYYY
        fjuIncidentTimer.incidentAlarmHours = incidentStructure.incidentAlarmHH
        fjuIncidentTimer.incidentAlarmMinutes = incidentStructure.incidentAlarmmm
        fjuIncidentTimer.incidentTimerInfo = fjuIncident
        
        let fjuUserCrews = UserCrews.init(entity: NSEntityDescription.entity(forEntityName: "UserCrews", in: context)!, insertInto: context)
        fjuUserCrews.userCrewsInfo = fjuIncident
        
        let fjuUserResourcesGroups = UserResourcesGroups.init(entity: NSEntityDescription.entity(forEntityName: "UserResourcesGroups", in: context)!, insertInto: context)
        fjuUserResourcesGroups.userResourcesGroupInfo = fjuIncident
        
        let fjuIncidentTags = IncidentTags.init(entity: NSEntityDescription.entity(forEntityName: "IncidentTags", in: context)!, insertInto: context)
        fjuIncident.addToIncidentTagDetails(fjuIncidentTags)
        
        let fjuIncidentTeam = IncidentTeam.init(entity:NSEntityDescription.entity(forEntityName: "IncidentTeam", in: context)!, insertInto: context)
        fjuIncident.addToTeamMemberDetails(fjuIncidentTeam)
        
        if chosenIncidentUserResources.isEmpty {
            let fjuIncidentResources = IncidentResources.init(entity:NSEntityDescription.entity(forEntityName: "IncidentResources", in: context)!, insertInto: context)
            fjuIncident.addToIncidentResourceDetails(fjuIncidentResources)
        } else {
            let modDate = Date()
            for resource in chosenIncidentUserResources {
                 let fjuIncidentResources = IncidentResources.init(entity:NSEntityDescription.entity(forEntityName: "IncidentResources", in: context)!, insertInto: context)
                fjuIncidentResources.incidentReference = fjuIncident.fjpIncGuidForReference
                fjuIncidentResources.incidentResource = resource.imageName
                fjuIncidentResources.incidentResourceBackup = false
                fjuIncidentResources.incidentResourceModDate = modDate
                fjuIncidentResources.resourceCustom = resource.customOrNot
                fjuIncidentResources.resourceType = 0001
                fjuIncidentResources.fjpIncGuidForReference = fjuIncident.fjpIncGuidForReference
                fjuIncident.addToIncidentResourceDetails(fjuIncidentResources)
                fjuIncidentResources.addToIncidentResourceInfo(fjuIncident)
            }
        }
        
        let fjuActionsTaken = ActionsTaken.init(entity: NSEntityDescription.entity(forEntityName: "ActionsTaken", in: context)!, insertInto: context)
        fjuActionsTaken.actionsTakenInfo = fjuIncident
        
        let fjuIncidentNFIRSCompleteMods = IncidentNFIRSCompleteMods.init(entity: NSEntityDescription.entity(forEntityName: "IncidentNFIRSCompleteMods", in: context)!, insertInto: context)
        fjuIncidentNFIRSCompleteMods.addToCompletedModuleInfo(fjuIncident)
        
        let fjuIncidentNFIRSKSec = IncidentNFIRSKSec.init(entity: NSEntityDescription.entity(forEntityName: "IncidentNFIRSKSec", in: context)!, insertInto: context)
        fjuIncidentNFIRSKSec.incidentNFIRSKSecInto = fjuIncident
        
        let fjuIncidentNFIRSRequiredModules = IncidentNFIRSRequiredModules.init(entity: NSEntityDescription.entity(forEntityName: "IncidentNFIRSRequiredModules", in: context)!, insertInto: context)
        fjuIncidentNFIRSRequiredModules.addToRequiredModuleInfo(fjuIncident)
        
        let fjuIncidentNFIRSsecL = IncidentNFIRSsecL.init(entity: NSEntityDescription.entity(forEntityName: "IncidentNFIRSsecL", in: context)!, insertInto: context)
        fjuIncidentNFIRSsecL.sectionLInfo = fjuIncident
        
        let fjuIncidentNFIRSsecM = IncidentNFIRSsecM.init(entity: NSEntityDescription.entity(forEntityName: "IncidentNFIRSsecM", in: context)!, insertInto: context)
        fjuIncidentNFIRSsecM.sectionMInfo = fjuIncident
        
        let fjuIncidentPhotos = IncidentPhotos.init(entity: NSEntityDescription.entity(forEntityName: "IncidentPhotos", in: context)!, insertInto: context)
        let photos = fjuIncident.mutableSetValue(forKey: "incidentPhotoDetails")
        photos.add(fjuIncidentPhotos)
        
        
        
        let fjuJournal = Journal.init(entity: NSEntityDescription.entity(forEntityName: "Journal", in: context)!, insertInto: context)
        fjuJournal.fjpJGuidForReference = "01."+jGuid
        fjuJournal.fjpIncReference = "02."+iGuid
        fjuJournal.fjpUserReference = fju.userGuid
        fjuJournal.journalDateSearch = sDate
        fjuJournal.journalModDate = incidentModDate
        fjuJournal.journalCreationDate = incidentModDate
        fjuJournal.fjpJournalModifiedDate = incidentModDate
        fjuJournal.journalEntryType = fjuIncident.situationIncidentImage
        fjuJournal.journalEntryTypeImageName = "NOTJournal"
        let incidentNumber = fjuIncident.incidentNumber ?? ""
        fjuJournal.journalHeader = "Incident Entry #\(incidentNumber) \(sDate)"
        
        fjuIncident.incidentInfo = fjuJournal
        fjuIncident.fireJournalUserIncInfo = fju
        
        for resource in fdResources {
            resource.fdResourceType = 0002
        }
        
        saveToCD()
        
    }
    
    private func saveToCD() {
        do {
            try context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"Newer Incident merge that"])
            }
            
            getTheLastSaved(entity: "Incident", attribute: "fjpIncGuidForReference", sort: "incidentCreationDate")
            DispatchQueue.main.async {
                self.nc.post(name:Notification.Name(rawValue:FJkCKNewIncidentCreated),
                        object: nil,
                        userInfo: ["objectID":self.objectID as NSManagedObjectID])
            }
            DispatchQueue.main.async {
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
            delegate?.theNewIncidentModalSaved(ojectID: self.objectID, shift: MenuItems.incidents)
        }   catch let error as NSError {
            let nserror = error
            
            let errorMessage = "StartShiftModalTVC saveToCD The context was unable to save due to \(nserror), \(nserror.userInfo)"
            print(errorMessage)
        }
    }
    
    private func getTheLastSaved(entity:String,attribute:String,sort:String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != %@", attribute, "")
        let sectionSortDescriptor = NSSortDescriptor(key: sort, ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 1
        
        do {
                fetched = try context.fetch(fetchRequest) as! [Incident]
                let incident = fetched.last as! Incident
                self.objectID = incident.objectID
        } catch let error as NSError {
            print("ModalTVC line 1721 Fetch Error: \(error.localizedDescription)")
        }
    }
}


extension NewerIncidentModalTVC: ModalHeaderSaveDismissDelegate {
   
    func modalInfoBTapped(myShift: MenuItems) {
        
    }
    
    func modalDismiss() {
        delegate?.theNewIncidentCancelled()
    }
    
    func modalSave(myShift: MenuItems) {
        saveTheIncident()
    }
}

extension NewerIncidentModalTVC: LabelTextFieldCellDelegate {
    func incidentLabelTFEditing(text:String, myShift: MenuItems, type: IncidentTypes){}
    func incidentLabelTFFinishedEditing(text:String,myShift:MenuItems, type: IncidentTypes){}
    func labelTextFieldEditing(text: String, myShift: MenuItems){
        incidentStructure.incidentNumber = text
    }
    func labelTextFieldFinishedEditing(text: String, myShift: MenuItems, tag: Int){
        incidentStructure.incidentNumber = text
    }
    func userInfoTextFieldEditing(text:String, myShift: MenuItems, journalType: JournalTypes ){}
    func userInfoTextFieldFinishedEditing(text:String, myShift: MenuItems, journalType: JournalTypes ){}
}

extension NewerIncidentModalTVC: LabelDateTimeButtonCellDelegate {
    func dateTimeButtonTapped(type: IncidentTypes) {
        if showPicker {
            showPicker = false
            if (incidentStructure != nil) {
                let date = Date()
                    incidentStructure.incidentAlarmDate = date
                    incidentStructure.incidentFullAlarmDateS = vcLaunch.fullDateString(date:date)
                    incidentStructure.incidentAlarmMM = vcLaunch.monthString(date: date)
                    incidentStructure.incidentAlarmdd = vcLaunch.dayString(date: date)
                    incidentStructure.incidentAlarmYYYY = vcLaunch.yearString(date: date)
                    incidentStructure.incidentAlarmHH = vcLaunch.hourString(date: date)
                    incidentStructure.incidentAlarmmm = vcLaunch.minuteString(date: date)
            }
        } else {
            showPicker = true
        }
        tableView.reloadData()
    }
}

extension NewerIncidentModalTVC: DatePickerDelegate {
    func alarmTimeChosenDate(date:Date,incidentType:IncidentTypes){
        incidentStructure.incidentAlarmDate = date
        incidentStructure.incidentFullAlarmDateS = vcLaunch.fullDateString(date:date)
        incidentStructure.incidentAlarmMM = vcLaunch.monthString(date: date)
        incidentStructure.incidentAlarmdd = vcLaunch.dayString(date: date)
        incidentStructure.incidentAlarmYYYY = vcLaunch.yearString(date: date)
        incidentStructure.incidentAlarmHH = vcLaunch.hourString(date: date)
        incidentStructure.incidentAlarmmm = vcLaunch.minuteString(date: date)
        tableView.reloadData()
    }
    func arrivalTimeChosenDate(date:Date,incidentType:IncidentTypes){}
    func controlledTimeChosenDate(date:Date,incidentType:IncidentTypes){}
    func lastUnitTimeChosenDate(date:Date,incidentType:IncidentTypes){}
    func nfirsSecMOfficersChosenDate(date:Date,incidentType:IncidentTypes){}
    func nfirsSecMMembersChosenDate(date:Date,incidentType:IncidentTypes){}
}

extension NewerIncidentModalTVC: SegmentCellDelegate {
    func sectionChosen(type: MenuItems) {
        switch type {
        case .fire:
            incidentStructure.incidentType = "Fire"
            incidentStructure.incidentImageName = "100515IconSet_092016_fireboard"
        case .ems:
            incidentStructure.incidentType = "EMS"
            incidentStructure.incidentImageName = "100515IconSet_092016_emsboard"
        case .rescue:
            incidentStructure.incidentType = "Rescue"
            incidentStructure.incidentImageName = "100515IconSet_092016_rescueboard"
        default:
            print("no type")
        }
        segmentType = type
        tableView.reloadData()
    }
}

extension NewerIncidentModalTVC: AddressFieldsButtonsCellDelegate {
    
    func addressFieldFinishedEditing(address: String, tag: Int) {
        addressTyped = true
        switch tag {
        case 1:
            if let range = address.range(of: ".") {
                let substring = address[..<range.lowerBound]
                let numString = String(substring)
                incidentStructure.incidentStreetNum = numString
                let sString = address.suffix(from: range.upperBound )
                let streetString = String(sString)
                incidentStructure.incidentStreetName = streetString
            }
        case 2:
            incidentStructure.incidentCity = address
        case 3:
            incidentStructure.incidentState = address
        case 4:
            incidentStructure.incidentZip = address
        default:
            break;
        }
    }
    
    func worldBTapped() {
        let indexPath = IndexPath(row: 6, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! AddressFieldsButtonsCell
        if cell.addressTF.text != "" {
            var address = ""
            if let streetNum = cell.addressTF.text {
                address = streetNum
            }
            if let city = cell.cityTF.text {
                address = "\(address) \(city)"
            }
            if let state = cell.stateTF.text {
                address = "\(address) \(state)"
            }
            if let zip = cell.zipTF.text {
                address = "\(address) \(zip)"
            }
            
            let geocoder = CLGeocoder()
            
            geocoder.geocodeAddressString(address) {
                placemarks, error in
                let placemark = placemarks?.first
                if let location = placemark?.location {
                    self.incidentStructure.incidentLocation = location
                    if self.showMap {
                        self.showMap = false
                    } else {
                        self.showMap = true
                    }
                    self.tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
                }
            }
        } else {
            print("world tapped")
            if showMap {
                showMap = false
            } else {
                showMap = true
            }
            switch myShift {
            case .incidents:
                let rowNumber: Int = 7
                let sectionNumber: Int = 0
                let indexPath = IndexPath(item: rowNumber, section: sectionNumber)
                tableView.reloadRows(at: [indexPath], with: .fade)
                tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
            default:
                break;
            }
            tableView.reloadData()
            if showMap {
                let rowNumber: Int = 7
                let sectionNumber: Int = 0
                let indexPath = IndexPath(item: rowNumber, section: sectionNumber)
                tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
            }
        }
    }
    
    func locationBTapped() {
        print("location tapped")
        determineLocation()
    }
    
    
    func determineLocation() {
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            //            locationManager.requestAlwaysAuthorization()
            //            locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        manager.stopUpdatingLocation()
        CLGeocoder().reverseGeocodeLocation(userLocation, completionHandler: {(placemarks, error) -> Void in
            print(userLocation)
            
            if error != nil {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            
            if placemarks?.count != 0 {
                let pm = placemarks![0]
                print(pm.locality!)
                self.incidentStructure.incidentLatitude = String(userLocation.coordinate.latitude)
                self.incidentStructure.incidentLongitude = String(userLocation.coordinate.longitude)
                self.city = "\(pm.locality!)"
                self.incidentStructure.incidentCity = self.city
                self.streetNum = "\(pm.subThoroughfare!)"
                self.incidentStructure.incidentStreetNum = self.streetNum
                self.streetName = "\(pm.thoroughfare!)"
                self.incidentStructure.incidentStreetName = self.streetName
                self.stateName = "\(pm.administrativeArea!)"
                self.incidentStructure.incidentState = self.stateName
                self.zipNum = "\(pm.postalCode!)"
                self.incidentStructure.incidentZip = self.zipNum
                self.incidentStructure.incidentLocation = userLocation
                self.tableView.reloadData()
            }
            else {
                print("Problem with the data received from geocoder")
            }
        })
    }
    func addressHasBeenFinished(){}
}

extension NewerIncidentModalTVC: MapViewCellDelegate {
    
    func theMapCellInfoBTapped() {
           presentAlert()
       }
       
       func presentAlert() {
           let title: InfoBodyText = .mapSupportNotesSubject
           let message: InfoBodyText = .mapSupportNotes
           let alert = UIAlertController.init(title: title.rawValue , message: message.rawValue, preferredStyle: .alert)
           let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
               self.alertUp = false
           })
           alert.addAction(okAction)
           alertUp = true
           self.present(alert, animated: true, completion: nil)
       }
    
    func theMapLocationHasBeenChosen(location:CLLocation){}
    
    func theMapCancelButtonTapped() {
        if showMap {
            showMap = false
        } else {
            showMap = true
        }
        tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
    }
    
    func theAddressHasBeenChosen(addressStreetNum:String,addressStreetName:String, addressCity: String, addressState: String, addressZip: String, location: CLLocation) {
        currentLocation = location
        streetNum = addressStreetNum
        incidentStructure.incidentStreetNum = addressStreetNum
        streetName = addressStreetName
        incidentStructure.incidentStreetName = addressStreetName
        city = addressCity
        incidentStructure.incidentCity = addressCity
        stateName = addressState
        incidentStructure.incidentState = addressState
        zipNum = addressZip
        incidentStructure.incidentZip = addressZip
        incidentStructure.incidentLocation = location
        self.incidentStructure.incidentLatitude = String(location.coordinate.latitude)
        self.incidentStructure.incidentLongitude = String(location.coordinate.longitude)
        if showMap {
            showMap = false
        } else {
            showMap = true
        }
        self.tableView.reloadData()
    }
}
//FDResourceIncidentCellDelegate
extension NewerIncidentModalTVC: FDResourceIncidentCellDelegate {
    
    func additionalStationApparatusCalled() {
    }
    
    func aFDResourceInfoBTapped() {
        if !alertUp {
            let message: InfoBodyText = .additionalFireEMSResources
            let title: InfoBodyText = .additionalFireEMSResourcesSubject2
            let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
                self.alertUp = false
            })
            alert.addAction(okAction)
            alertUp = true
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func aFDResourceHasBeenTappedForSelection(resource: IncidentUserResource) {
        var r = resource
        let imageName = resource.imageName
        if !chosenIncidentResourceName.contains(imageName) {
            r.type = 1
            r.assetName = "RedSelectedCHECKED"
           chosenIncidentUserResources.append(r)
           chosenIncidentResourceName.append(imageName)
        } else {
            chosenIncidentUserResources = chosenIncidentUserResources.filter{ $0.imageName != resource.imageName }
            chosenIncidentResourceName = chosenIncidentResourceName.filter{ $0 != imageName }
        }
    }
    
    func aFDResourceDirectionalTapped(){
        presentResource()
    }
    
    fileprivate func presentResource() {
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let dataTVC = storyBoard.instantiateViewController(withIdentifier: "ModalFDResourcesDataTVC") as! ModalFDResourcesDataTVC
        dataTVC.delegate = self
        dataTVC.transitioningDelegate = slideInTransitioningDelgate
        dataTVC.titleName = "Fire/EMS Resources"
        dataTVC.modalPresentationStyle = .custom
        self.present(dataTVC, animated: true, completion: nil)
    }
}

extension NewerIncidentModalTVC: ModalFDResourcesDataDelegate {
    
    func theResourcesHaveBeenCollected(collectionOfResources: [UserResources]) {
        self.dismiss(animated: true, completion: nil)
        for r in collectionOfResources {
            var iur = IncidentUserResource.init(imageName: r.resource!)
            iur.type = 0002
            iur.customOrNot = r.resourceCustom
            iur.assetName = "GreenAvailable"
            incidentUserResources.append(iur)
        }
        fdResourceCount = incidentUserResources.count
        let indexPath = IndexPath(row: 8, section: 0)
        tableView.reloadRows(at: [indexPath], with: .top)
    }
    
    func theResourcesHasBeenCancelled() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension NewerIncidentModalTVC: LabelYesNoSwitchCellDelegate {
    func labelYesNoSwitchTapped(theShift: MenuItems, yesNoB: Bool, type: IncidentTypes) {
        yesNo = yesNoB
        incidentType = type
        switch type {
        case .emergency:
            incidentStructure.incidentEmergencyYesNo = yesNo
            if incidentStructure.incidentEmergencyYesNo {
                incidentStructure.incidentEmergency = "Emergency"
            } else {
                incidentStructure.incidentEmergency = "Non-Emergency"
            }
        default:break
        }
        self.tableView.reloadData()
    }
}

extension NewerIncidentModalTVC: LabelWithInfoCellDelegate {
    func theInfoBTapped() {
        if !alertUp {
            let alert = UIAlertController.init(title: modalTitle.rawValue, message: modalInstructions.rawValue, preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
                self.alertUp = false
            })
            alert.addAction(okAction)
            alertUp = true
            self.present(alert, animated: true, completion: nil)
        }
    }
}
