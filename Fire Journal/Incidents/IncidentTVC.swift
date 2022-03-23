//
//  IncidentTVC.swift
//  dashboard
//
//  Created by DuRand Jones on 9/4/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//


import UIKit
import Foundation
import CoreData
import MapKit
import CoreLocation
import T1Autograph

protocol IncidentTVCDelegate: AnyObject {
    func incidentTapped()
}

class IncidentTVC: UITableViewController,CLLocationManagerDelegate,NSFetchedResultsControllerDelegate {
    
    
    weak var delegate: IncidentTVCDelegate? = nil
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var objectID: NSManagedObjectID!
    var titleName:String = ""
    
    let nc = NotificationCenter.default
    
    let vcLaunch = VCLaunch()
    private var launchNC: LaunchNotifications!
    
    var compact:SizeTrait = .regular
    
    var controllerName:String = ""
    var myShift:MenuItems! = nil
    var showPicker1:Bool = false
    var showPicker2:Bool = false
    var showPicker3:Bool = false
    var showPicker4:Bool = false
    var showPickerSec1:Bool = false
    var showPickerSecEAlarm:Bool = false
    var showPickerSecEArrive:Bool = false
    var showPickerSecEControlled:Bool = false
    var showPickerSecELastUnit:Bool = false
    var showPickerSecMOfficer: Bool = false
    var showPickerSecMMember: Bool = false
    var incidentNotesYesNo:Bool = true
    var alarmNotes:Bool = false
    var arrivalNotes:Bool = false
    var controlledNotes:Bool = false
    var lastUnitStandingNotes:Bool = false
    var secKRemarks: Bool = false
    var showMap:Bool = false
    var incidentType:IncidentTypes = .fire
    var timeType:IncidentTypes = .fire
    var city: String = ""
    var streetNum: String = ""
    var streetName: String = ""
    var stateName: String = ""
    var zipNum: String = ""
    var segmentType: MenuItems = .journal
    var incidentStructure: IncidentData!
    var currentLocation: CLLocation!
    var locationManager:CLLocationManager!
    var yesNo:Bool = false
    var id: NSManagedObjectID!
    var sizeTrait: SizeTrait = .regular
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    var incident:Incident!
    var fju:FireJournalUser!
    
    var fetched:Array<Any>!
    var showSaved:Bool = false
    var alertUp: Bool = false
    var fromMap: Bool = false
    
    var group: ResourcesItem!
    var theCrew: TheCrew!
    var theUserCrew: UserCrews!
//    var theResourcesGroup: UserResourcesGroups!
//    var theActionsTaken: ActionsTaken!
    var theTags = [String]()
    var theSectionTapped: Int = 0
    var theSectionCollapsed: Bool = true
    var theSectionRowCount: Int = 0
    var theOfficerSignatureB: Bool = false
    var theMemberMakingSignatureB: Bool = false
    var instructionOnOff:Bool = false
    var instruction2OnOff:Bool = false
    var instruction3OnOff:Bool = false
    var nfirsSecHInstruction1Off:Bool = false
    var nfirsSecHInstruction2Off:Bool = false
    var nfirsSecHHazardReleaseOff: Bool = false
    var nfirsSecIMixedUseOff: Bool = false
    var nfirsSecJPULookUp: Bool = false
    var nfirsSecMOfficerSame: Bool = false
    //    MARK: -T1Autograph
    var autographOfficer: T1Autograph = T1Autograph()
    var autographMember: T1Autograph = T1Autograph()
    var signatureType: String = ""
    var nfirsSigType: IncidentTypes?
    var nfirsSecKNamePrefix: MenuItems?
    var nfirsSecKNamePrefix2: MenuItems?
    //    MARK: -SECTIONS
    fileprivate let sections = NFIRSBasicOne()
    var theSections = [NFIRSSection]()
    var sectionCollapsed: Bool = false
    var sectionOpen: Int = 0
    
    //    MARK: -Resources Collection View Arrays
    var incidentUserResources = [IncidentUserResource]()
    var chosenIncidentUserResources = [IncidentUserResource]()
    var chosenIncidentResourceName = [String]()
    var fdResourceCount: Int = 0
    var theResources = [IncidentResources]()
    var incidentNotesHeight: CGFloat = 120
    var incidentAlarmNotesHeight: CGFloat = 110
    var incidentArrivalNotesHeight: CGFloat = 110
    var incidentControlledNotesHeight: CGFloat = 110
    var incidentLastUnitNotesHeight: CGFloat = 110
    var userFDResourcesSelected = [UserFDResources]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = titleName
        
        vcLaunch.splitVC = self.splitViewController
        launchNC = LaunchNotifications.init(launchVC: vcLaunch)
        launchNC.callNotifications()
        
        
        
        //        MARK: additional notifications
        nc.addObserver(self, selector: #selector(compactOrRegular(ns:)), name:NSNotification.Name(rawValue: FJkCOMPACTORREGULAR), object: nil)
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        
        //        MARK: INIT incidentStructure
        incidentStructure = IncidentData.init()
        //        MARK: build the sections for TV
        theSections = sections.sections
        
        group = ResourcesItem.init(group: "", resource: [], groupGuid: "")
        
        getTheUserData()
        
        if !fromMap {
            let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveIncident(_:)))
            
            navigationItem.rightBarButtonItem = saveButton
            
            if Device.IS_IPHONE {
                let listButton = UIBarButtonItem(title: "Incident", style: .plain, target: self, action: #selector(returnToList(_:)))
                navigationItem.leftBarButtonItem = listButton
                navigationItem.setLeftBarButtonItems([listButton], animated: true)
                navigationItem.leftItemsSupplementBackButton = false
            }
            
            
            if (Device.IS_IPHONE){
                self.navigationController?.navigationBar.backgroundColor = UIColor.white
                let navigationBarAppearace = UINavigationBar.appearance()
                navigationBarAppearace.tintColor = UIColor.black
            } else {
                let navigationBarAppearace = UINavigationBar.appearance()
                navigationBarAppearace.tintColor = UIColor.black
                navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
            }
        }
        
        //        MARK: -CELLS REGISTERED
        registerCellsForTable()
        
        //        MARK: -incidentBuild
        buildTheIncidentStructure()
//        print(incidentStructure)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
    }
    
    @objc private func returnToList(_ sender:Any) {
        closeItUp()
    }
    
    func closeItUp() {
           if  Device.IS_IPHONE {
                DispatchQueue.main.async {
                    self.nc.post(name:Notification.Name(rawValue:FJkINCIDENTLISTCALLED),
                        object: nil,
                        userInfo: nil)
                }
           }
       }
    
    //    MARK: -ERROR ALERT
    @objc func errorInDataBaseLaunch(ns:Notification) -> Void {
        var errorString: String = ""
        if let userInfo = ns.userInfo as! [String: Any]?
        {
            errorString = userInfo["errorMessage"] as? String ?? "There is no error to report."
        }
        let title:String = "Database Error"
        let alert = UIAlertController.init(title: title, message: errorString, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Thanks for the info", style: .default, handler: {_ in
            
        })
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func compactOrRegular(ns: Notification) {
        if let userInfo = ns.userInfo as! [String: Any]?
        {
            compact = userInfo["compact"] as? SizeTrait ?? .regular
            switch compact {
            case .compact:
                print("compact JOURNAL")
            case .regular:
                print("regular JOURNAL")
            }
        }
        self.tableView.reloadData()
    }
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    @objc private func saveIncident(_ sender:Any) {
        saveTheIncident()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //    MARK: -CALCULATIONS FOR NOTE FIELDS
    private func getIncidentNotesSize() ->CGFloat {
        if incidentStructure.incidentNotes != "" {
            let textView = UITextView()
            textView.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: incidentNotesHeight)
            let size = CGSize(width: textView.frame.width, height: .infinity)
            textView.text = incidentStructure.incidentNotes
            let estimatedSize = textView.sizeThatFits(size)
            
            incidentNotesHeight = estimatedSize.height + 120
        }
        return incidentNotesHeight
    }
    
    private func getIncidentAlarmNotesSize() ->CGFloat {
        if incidentStructure.incidentAlarmNotes != "" {
            let textView = UITextView()
            textView.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: incidentAlarmNotesHeight)
            let size = CGSize(width: textView.frame.width, height: .infinity)
            textView.text = incidentStructure.incidentAlarmNotes
            let estimatedSize = textView.sizeThatFits(size)
            
            incidentAlarmNotesHeight = estimatedSize.height + 150
        }
        return incidentAlarmNotesHeight
    }
    
    private func getIncidentArrivalNotesSize() ->CGFloat {
        if incidentStructure.incidentArrivalNotes != "" {
            let textView = UITextView()
            textView.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: incidentArrivalNotesHeight)
            let size = CGSize(width: textView.frame.width, height: .infinity)
            textView.text = incidentStructure.incidentArrivalNotes
            let estimatedSize = textView.sizeThatFits(size)
            
            incidentArrivalNotesHeight = estimatedSize.height + 150
        }
        return incidentArrivalNotesHeight
    }
    
    private func getIncidentControlledNotesSize() ->CGFloat {
        if incidentStructure.incidentControlledNotes != "" {
            let textView = UITextView()
            textView.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: incidentControlledNotesHeight)
            let size = CGSize(width: textView.frame.width, height: .infinity)
            textView.text = incidentStructure.incidentControlledNotes
            let estimatedSize = textView.sizeThatFits(size)
            
            incidentControlledNotesHeight = estimatedSize.height + 150
        }
        return incidentControlledNotesHeight
    }
    
    
    private func getIncidentLastUnitNotesSize() ->CGFloat {
        if incidentStructure.incidentLastUnitNotes != "" {
            let textView = UITextView()
            textView.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: incidentLastUnitNotesHeight)
            let size = CGSize(width: textView.frame.width, height: .infinity)
            textView.text = incidentStructure.incidentLastUnitNotes
            let estimatedSize = textView.sizeThatFits(size)
            
            incidentLastUnitNotesHeight = estimatedSize.height + 135
        }
        return incidentLastUnitNotesHeight
    }

    // MARK: - Table view data source
    // MARK: - Table view data source// MARK: - Table View
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerV = Bundle.main.loadNibNamed("MapFormHeaderV", owner: self, options: nil)?.first as! MapFormHeaderV
        headerV.incidentType = incidentType
        headerV.delegate = self
        return headerV
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if fromMap {
            if  Device.IS_IPAD {
                return 44
            } else {
                return 0
            }
        } else {
            return 0
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        //        MARK: -SECTIONRETURN
        //        return theSections.count
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
   override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
            switch row {
            case 0:
                return  105
            case 1:
                return 287
            case 2:
                if(showMap) {
                    return 500
                } else {
                    return 0
                }
            case 3:
                return 44
            case 4:
                return 84
            case 5:
                if fdResourceCount <= 5 {
                    if Device.IS_IPAD {
                        return 260
                    } else {
                        return 380
                    }
                } else {
                    if Device.IS_IPAD {
                        return 280
                    } else {
                        return 380
                    }
                }
            case 6:
                return 120
            case 7,8,9,10:
                return 84
            case 11:
                if incidentNotesHeight == 120 {
                    incidentNotesHeight = getIncidentNotesSize()
                }
                return incidentNotesHeight
            case 12:
                return 81
            case 13:
                if(showPicker1) {
                    return 132
                } else {
                    return 0
                }
            case 14:
                if alarmNotes {
                    if incidentAlarmNotesHeight == 110 {
                        incidentAlarmNotesHeight = getIncidentAlarmNotesSize()
                    }
                    return incidentAlarmNotesHeight
                } else {
                    return 0
                }
            case 15:
                return 50
            case 16:
                if(showPicker2) {
                    return 132
                } else {
                    return 0
                }
            case 17:
                if arrivalNotes {
                    if incidentArrivalNotesHeight == 110 {
                        incidentArrivalNotesHeight = getIncidentArrivalNotesSize()
                    }
                    return incidentArrivalNotesHeight
                } else {
                    return 0
                }
            case 18:
                return 50
            case 19:
                if(showPicker3) {
                    return 132
                } else {
                    return 0
                }
            case 20:
                if controlledNotes {
                    if incidentControlledNotesHeight == 110 {
                        incidentControlledNotesHeight = getIncidentControlledNotesSize()
                    }
                    return incidentControlledNotesHeight
                } else {
                    return 0
                }
            case 21:
                return 50
            case 22:
                if(showPicker4) {
                    return 132
                } else {
                    return 0
                }
            case 23:
                if lastUnitStandingNotes {
                    if incidentLastUnitNotesHeight == 110 {
                        incidentLastUnitNotesHeight = getIncidentLastUnitNotesSize()
                    }
                    return incidentLastUnitNotesHeight
                } else {
                    return 0
                }
            case 24:
                return 120
            case 25, 26, 27:
                return 81
            case 28:
                return 44
            case 29:
                return 120
            case 30:
                return 250
            default:
                return 0
            }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        
            switch row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ControllerLabelCell", for: indexPath) as! ControllerLabelCell
                if incidentStructure.incidentFullDateS != "" {
                    cell.dateL.text = incidentStructure.incidentFullDateS
                }
                if incidentStructure.incidentFullAddress != "" {
                    cell.addressL.text = incidentStructure.incidentFullAddress
                }
                if incidentStructure.incidentNumber != "" {
                    let number = incidentStructure.incidentNumber
                    cell.controllerL.text = "# "+number
                }
                var imageName = incidentStructure.incidentImageName
                if imageName == "flameRed58" {
                        imageName = "100515IconSet_092016_fireboard"
                    } else if imageName == "ems58" {
                        imageName = "100515IconSet_092016_emsboard"
                    } else if imageName == "rescue58" {
                        imageName = "100515IconSet_092016_rescueboard"
                }
                
                let image = UIImage(named: imageName)
                cell.typeIV.image = image
                cell.delegate = self
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddressFieldsButtonsCell", for: indexPath) as! AddressFieldsButtonsCell
                cell.subjectL.text = "Address"
                if incidentStructure.incidentStreetName == "" {
                    cell.addressTF.attributedPlaceholder = NSAttributedString(string: "100 Main Street",attributes: [NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel])
                } else {
                    cell.addressTF.text = "\(incidentStructure.incidentStreetNum) \(incidentStructure.incidentStreetName)"
                }
                cell.addressTF.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
                if incidentStructure.incidentCity == "" {
                    cell.cityTF.attributedPlaceholder = NSAttributedString(string: "Los Angeles",attributes: [NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel])
                } else {
                    cell.cityTF.text = incidentStructure.incidentCity
                }
                cell.cityTF.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
                if incidentStructure.incidentState == "" {
                    cell.stateTF.attributedPlaceholder = NSAttributedString(string: "CA",attributes: [NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel])
                } else {
                    cell.stateTF.text = incidentStructure.incidentState
                }
                cell.stateTF.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
                if incidentStructure.incidentZip == "" {
                    cell.zipTF.attributedPlaceholder = NSAttributedString(string: "90001",attributes: [NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel])
                } else {
                    cell.zipTF.text = incidentStructure.incidentZip
                }
                cell.zipTF.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
                if incidentStructure.incidentLocation != nil {
                    if incidentStructure.incidentLatitude != "" {
                        cell.addressLatitudeTF.text = incidentStructure.incidentLatitude
                        cell.addressLatitudeTF.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
                    }
                    if incidentStructure.incidentLongitude != "" {
                        cell.addressLongitudeTF.text = incidentStructure.incidentLongitude
                        cell.addressLongitudeTF.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
                    }
                } else {
                    cell.addressLongitudeTF.attributedPlaceholder = NSAttributedString(string: "Incident Longitude",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.85)])
                    cell.addressLatitudeTF.attributedPlaceholder = NSAttributedString(string: "Incident Latitude",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.85)])
                }
                cell.delegate = self
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "MapViewCell", for: indexPath) as! MapViewCell
                cell.delegate = self
                cell.incidentType = incidentStructure.incidentType
                if(showMap) {
                    let frame = CGRect(
                        origin: CGPoint(x: 0, y: 0),
                        size: CGSize(width: tableView.frame.size.width, height: 500)
                    )
                    cell.currentLocation = incidentStructure.incidentLocation
                    cell.contentView.frame = frame
                    cell.contentView.layer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
                    cell.mapShow = true
                    cell.useAddressB.isHidden = false
                    cell.useAddressB.alpha = 1.0
                } else {
                    let frame = CGRect(
                        origin: CGPoint(x: 0, y: 0),
                        size: CGSize(width: tableView.frame.size.width, height: 0)
                    )
                    cell.contentView.frame = frame
                    cell.contentView.layer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
                    cell.mapShow = false
                    cell.useAddressB.isHidden = true
                    cell.useAddressB.alpha = 0.0
                }
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelYesNoSwitchCell", for: indexPath) as! LabelYesNoSwitchCell
                cell.delegate = self
                cell.yesNotSwitch.onTintColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
                cell.yesNotSwitch.backgroundColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.35)
                cell.yesNotSwitch.layer.cornerRadius = 16
                cell.yesNotSwitch.isOn = incidentStructure.incidentEmergencyYesNo
                if incidentStructure.incidentEmergencyYesNo {
                    incident.incidentType = "Emergency"
                    incidentStructure.incidentEmergency = "Emergency"
                } else {
                    incident.incidentType = "Non-Emergency"
                    incidentStructure.incidentEmergency = "Non-Emergency"
                }
                cell.yesNoB = yesNo
                cell.myShift = myShift
                cell.incidentType = .emergency
                cell.subjectL.text = "Emergency"
                cell.leftText = "No"
                cell.rightText = "Yes"
                cell.rightL.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
                cell.leftL.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
                return cell
            case 4:
                let cell = tableView.dequeueReusableCell(withIdentifier: "SegmentCell", for: indexPath) as! SegmentCell
                cell.delegate = self
                cell.subjectL.text = "Incident Type"
                cell.myShift = .incidents
                cell.typeSegment.setTitle("Fire", forSegmentAt: 0)
                cell.typeSegment.setTitle("EMS", forSegmentAt: 1)
                cell.typeSegment.setTitle("Rescue", forSegmentAt: 2)
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
            case 5:
                
                if incidentUserResources.count != 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "FDResourceIncidentCell", for: indexPath) as! FDResourceIncidentCell
                    cell.delegate = self
                    cell.incidentOrNew = true
                    cell.instantResources = incidentUserResources
                    cell.subjectL.text = "Fire/EMS Resources"
                    cell.incidentFDResourceCV.reloadData()
                    return cell
                } else {
                    getTheUserFDResources()
                    if incidentUserResources.count != 0 {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "FDResourceIncidentCell", for: indexPath) as! FDResourceIncidentCell
                        cell.delegate = self
                        cell.incidentOrNew = false
                        cell.instantResources = incidentUserResources
                        cell.subjectL.text = "Fire/EMS Resources"
                        
                        return cell
                    } else {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
                        cell.modalTitleL.font = cell.modalTitleL.font.withSize(12)
                        cell.modalTitleL.adjustsFontSizeToFitWidth = true
                        cell.modalTitleL.lineBreakMode = NSLineBreakMode.byWordWrapping
                        cell.modalTitleL.numberOfLines = 0
                        cell.modalTitleL.setNeedsDisplay()
                        cell.modalTitleL.textColor = UIColor.systemRed
                        cell.modalTitleL.text = "To set up your station's apparatus, you'll need to go into Settings, under Fire/EMS Resources and choose up to 10 Fire/EMS Resources to be your base Station Apparatus. Once created, you can manage your Fire/EMS Resources with Front Line, Reserve and Out of Service modes."
                        return cell
                    }
                }
            case 6:
                let cell = tableView.dequeueReusableCell(withIdentifier: "IncidentShortTVWithDirectionalCell", for: indexPath) as! IncidentShortTVWithDirectionalCell
                cell.delegate = self
                cell.subjectL.text = "NFIRS Incident Type"
                cell.descriptionTV.textColor =  UIColor.systemRed
                if incidentStructure.incidentNfirsIncidentType != "" {
                    cell.descriptionTV.textColor =  UIColor.systemRed
                    let type =  incidentStructure.incidentNfirsIncidentType
//                    let number = incidentStructure.incidentNfirsIncidentTypeNumber
//                    cell.descriptionTV.text = number+" "+type
                    cell.descriptionTV.text = type
                } else {
                    cell.descriptionTV.textColor =  UIColor.secondaryLabel
                    cell.descriptionTV.text = "121 Fire in mobile home used as a fixed residence. Includes mobile homes when not in transit and used as a structure for residential purposes; and manufactured homes built on a permanent chassis."
                }
                let image = UIImage(named: "ICONS_Directional red")
                cell.directionalB.setImage(image, for: .normal)
                cell.myShift = .incidents
                cell.incidentType = .nfirsIncidentType
                cell.nfirsInfoB.isHidden = false
                cell.nfirsInfoB.alpha = 1.0
                cell.nfirsInfoB.isEnabled = true
                return cell
            case 7:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldWithDirectionCell", for: indexPath) as! LabelTextFieldWithDirectionCell
                cell.delegate = self
                cell.subjectL.text = "Local Incident Type"
                cell.descriptionTF.textColor = UIColor.systemRed
                if incidentStructure.incidentLocalType != "" {
                    cell.descriptionTF.text = incidentStructure.incidentLocalType
                } else {
                    cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "Structure Fire",attributes: [NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel])
                }
                cell.incidenttype = .localIncidentType
                cell.myShift = myShift
                let image = UIImage(named: "ICONS_Directional red")
                cell.moreB.setImage(image, for: .normal)
                return cell
            case 8:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldWithDirectionCell", for: indexPath) as! LabelTextFieldWithDirectionCell
                cell.delegate = self
                cell.subjectL.text = "Location Type"
                cell.descriptionTF.textColor = UIColor.systemRed
                if incidentStructure.incidentLocationType != "" {
                    cell.descriptionTF.text = incidentStructure.incidentLocationType
                } else {
                    cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "In Front Of",attributes: [NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel])
                }
                cell.incidenttype = .locationType
                cell.myShift = myShift
                let image = UIImage(named: "ICONS_Directional red")
                cell.moreB.setImage(image, for: .normal)
                return cell
            case 9:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldWithDirectionCell", for: indexPath) as! LabelTextFieldWithDirectionCell
                cell.delegate = self
                cell.subjectL.text = "Street Type"
                cell.descriptionTF.textColor = UIColor.systemRed
                if incidentStructure.incidentStreetType != "" {
                    cell.descriptionTF.text = incidentStructure.incidentStreetType
                } else {
                    cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "ST Street",attributes: [NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel])
                }
                cell.incidenttype = .streetType
                cell.myShift = myShift
                let image = UIImage(named: "ICONS_Directional red")
                cell.moreB.setImage(image, for: .normal)
                return cell
            case 10:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldWithDirectionCell", for: indexPath) as! LabelTextFieldWithDirectionCell
                cell.delegate = self
                cell.subjectL.text = "Street Prefix"
                cell.descriptionTF.textColor = UIColor.systemRed
                if incidentStructure.incidentStreetPrefix != "" {
                    cell.descriptionTF.text = incidentStructure.incidentStreetPrefix
                } else {
                    cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "North",attributes: [NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel])
                }
                cell.incidenttype = .streetPrefix
                cell.myShift = myShift
                let image = UIImage(named: "ICONS_Directional red")
                cell.moreB.setImage(image, for: .normal)
                return cell
            case 11:
                let cell = tableView.dequeueReusableCell(withIdentifier: "IncidentNotesTextViewCell", for: indexPath) as! IncidentNotesTextViewCell
                cell.subjectL.text = "Incident Notes"
                cell.delegate = self
                cell.myShift = myShift
                cell.incidentType = .incidentNote
                incidentNotesYesNo = true
                cell.descriptionTV.text = incidentStructure.incidentNotes
                cell.descriptionTV.textColor = UIColor.systemRed
                if incidentStructure.incidentPersonalJournalReference != "" {
                    cell.notesAvailableB.isHidden = false
                    cell.notesAvailableB.alpha = 1.0
                    cell.notesAvailableB.isEnabled = false
                } else {
                    cell.notesAvailableB.isHidden = true
                    cell.notesAvailableB.alpha = 0.0
                    cell.notesAvailableB.isEnabled = false
                }
                return cell
            case 12:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TimeAndDateArrivalCell", for: indexPath) as! TimeAndDateArrivalCell
                cell.delegate = self
                cell.incidentType = .alarm
                cell.timeDateTF.text = incidentStructure.incidentFullAlarmDateS
                cell.timeDateTF.textColor = UIColor.systemRed
                return cell
            case 13:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! DatePickerCell
                cell.delegate2 = self
                cell.incidentType = .alarm
                cell.datePicker.tintColor = .systemRed
                return cell
            case 14:
                if alarmNotes {
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextViewCell", for: indexPath) as! LabelTextViewCell
                cell.subjectL.text = "Alarm Notes"
                cell.delegate = self
                cell.myShift = myShift
                cell.incidentType = .alarmNote
                cell.descriptionTV.text = incidentStructure.incidentAlarmNotes
                cell.descriptionTV.textColor = UIColor.systemRed
                return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "FlatTVCell", for: indexPath) as! FlatTVCell
                    return cell
                }
            case 15:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TimeAndDateIncidentCell", for: indexPath) as! TimeAndDateIncidentCell
                cell.delegate = self
                cell.incidentType = .arrival
                cell.subjectL.text = "Arrival"
                cell.timeAndDateTF.text = incidentStructure.incidentFullArrivalDateS
                cell.timeAndDateTF.textColor = UIColor.systemRed
                return cell
            case 16:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! DatePickerCell
                cell.delegate2 = self
                cell.incidentType = .arrival
                cell.pickerDate = incidentStructure.incidentArrivalDate
                cell.datePicker.tintColor = .systemRed
                return cell
            case 17:
                if(arrivalNotes) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextViewCell", for: indexPath) as! LabelTextViewCell
                cell.subjectL.text = "Arrival Notes"
                cell.delegate = self
                cell.myShift = myShift
                cell.incidentType = .arrivalNote
                cell.descriptionTV.text = incidentStructure.incidentArrivalNotes
                cell.descriptionTV.textColor = UIColor.systemRed
                return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "FlatTVCell", for: indexPath) as! FlatTVCell
                    return cell
                }
            case 18:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TimeAndDateIncidentCell", for: indexPath) as! TimeAndDateIncidentCell
                cell.delegate = self
                cell.incidentType = .controlled
                cell.subjectL.text = "Controlled"
                cell.timeAndDateTF.text = incidentStructure.incidentFullControlledDateS
                cell.timeAndDateTF.textColor = UIColor.systemRed
                return cell
            case 19:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! DatePickerCell
                cell.delegate2 = self
                cell.incidentType = .controlled
                cell.datePicker.tintColor = .systemRed
                return cell
            case 20:
                if(controlledNotes) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextViewCell", for: indexPath) as! LabelTextViewCell
                cell.subjectL.text = "Controlled Notes"
                cell.delegate = self
                cell.myShift = myShift
                cell.incidentType = .controlledNote
                cell.descriptionTV.text = incidentStructure.incidentControlledNotes
                cell.descriptionTV.textColor = UIColor.systemRed
                return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "FlatTVCell", for: indexPath) as! FlatTVCell
                    return cell
                }
            case 21:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TimeAndDateIncidentCell", for: indexPath) as! TimeAndDateIncidentCell
                cell.delegate = self
                cell.incidentType = .lastunitstanding
                cell.subjectL.text = "Last Unit Standing"
                cell.timeAndDateTF.text = incidentStructure.incidentFullLastUnitDateS
                cell.timeAndDateTF.textColor = UIColor.systemRed
                return cell
            case 22:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! DatePickerCell
                cell.delegate2  = self
                cell.incidentType = .lastunitstanding
                cell.datePicker.tintColor = .systemRed
                return cell
            case 23:
                if(lastUnitStandingNotes) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextViewCell", for: indexPath) as! LabelTextViewCell
                cell.subjectL.text = "Last Unit Standing Notes"
                cell.delegate = self
                cell.myShift = myShift
                cell.incidentType = .lastUnitStandingNote
                cell.descriptionTV.text = incidentStructure.incidentLastUnitNotes
                cell.descriptionTV.textColor = UIColor.systemRed
                return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "FlatTVCell", for: indexPath) as! FlatTVCell
                    return cell
                }
            case 24:
                let cell = tableView.dequeueReusableCell(withIdentifier: "IncidentShortTVWithDirectionalCell", for: indexPath) as! IncidentShortTVWithDirectionalCell
                cell.delegate = self
                cell.subjectL.text = "Crew"
                cell.descriptionTV.textColor =  UIColor.systemRed
                cell.descriptionTV.text = ""
                if (incidentStructure.incidentCrewCombine != "")
                {
                    cell.descriptionTV.text = incidentStructure.incidentCrewCombine
                }
                cell.descriptionTV.textColor = UIColor.systemRed
                let image = UIImage(named: "ICONS_Directional red")
                cell.directionalB.setImage(image, for: .normal)
                cell.myShift = .incidents
                cell.incidentType = .crew
                cell.nfirsInfoB.isHidden = true
                cell.nfirsInfoB.alpha = 0.0
                cell.nfirsInfoB.isEnabled = false
                return cell
            case 25:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelDoubleTextFieldDirectionalCell", for: indexPath) as! LabelDoubleTextFieldDirectionalCell
                cell.delegate = self
                cell.subjectL.text = "Actions Taken 1"
                cell.incidentType = .firstAction
                cell.myShift = myShift
                cell.firstDescriptionTF.text = ""
                cell.secondDescriptionTF.text = ""
                cell.firstDescriptionTF.textColor = UIColor.systemRed
                if incidentStructure.incidentAction1No != "" {
                    cell.firstDescriptionTF.text = incidentStructure.incidentAction1No
                }
                cell.firstDescriptionTF.textColor = UIColor.systemRed
                cell.secondDescriptionTF.textColor = UIColor.systemRed
                if incidentStructure.incidentAction1S != "" {
                    cell.secondDescriptionTF.text = incidentStructure.incidentAction1S
                }
                let image = UIImage(named: "ICONS_Directional red")
                cell.directionalB.setImage(image, for: .normal)
                return cell
            case 26:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelDoubleTextFieldDirectionalCell", for: indexPath) as! LabelDoubleTextFieldDirectionalCell
                cell.delegate = self
                cell.subjectL.text = "Actions Taken 2"
                cell.incidentType = .secondAction
                cell.myShift = myShift
                cell.firstDescriptionTF.text = ""
                cell.secondDescriptionTF.text = ""
                cell.firstDescriptionTF.textColor = UIColor.systemRed
                if incidentStructure.incidentAction2No != "" {
                    cell.firstDescriptionTF.text = incidentStructure.incidentAction2No
                }
                cell.secondDescriptionTF.textColor = UIColor.systemRed
                if incidentStructure.incidentAction2S != "" {
                    cell.secondDescriptionTF.text = incidentStructure.incidentAction2S
                }
                let image = UIImage(named: "ICONS_Directional red")
                cell.directionalB.setImage(image, for: .normal)
                return cell
            case 27:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelDoubleTextFieldDirectionalCell", for: indexPath) as! LabelDoubleTextFieldDirectionalCell
                cell.delegate = self
                cell.subjectL.text = "Actions Taken 3"
                cell.incidentType = .thirdAction
                cell.myShift = myShift
                cell.firstDescriptionTF.text = ""
                cell.secondDescriptionTF.text = ""
                cell.firstDescriptionTF.textColor = UIColor.systemRed
                if incidentStructure.incidentAction3No != "" {
                    cell.firstDescriptionTF.text = incidentStructure.incidentAction3No
                }
                cell.secondDescriptionTF.textColor = UIColor.systemRed
                if incidentStructure.incidentAction3S != "" {
                    cell.secondDescriptionTF.text = incidentStructure.incidentAction3S
                }
                let image = UIImage(named: "ICONS_Directional red")
                cell.directionalB.setImage(image, for: .normal)
                return cell
            case 28:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelYesNoSwitchCell", for: indexPath) as! LabelYesNoSwitchCell
                cell.delegate = self
                cell.yesNotSwitch.onTintColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
                cell.yesNotSwitch.backgroundColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.35)
                cell.yesNotSwitch.layer.cornerRadius = 16
                cell.yesNotSwitch.isOn = incidentStructure.incidentArson
                cell.yesNoB = yesNo
                cell.myShift = myShift
                cell.incidentType = .arson
                cell.subjectL.text = "Arson Investigation"
                cell.leftText = "No"
                cell.rightText = "Yes"
                cell.rightL.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
                cell.leftL.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
                return cell
            case 29:
                let cell = tableView.dequeueReusableCell(withIdentifier: "IncidentShortTVWithDirectionalCell", for: indexPath) as! IncidentShortTVWithDirectionalCell
                cell.delegate = self
                cell.subjectL.text = "Tags"
                cell.descriptionTV.textColor =  UIColor.systemRed
                cell.descriptionTV.text = ""
                if incidentStructure.incidentTags != "" {
                    cell.descriptionTV.text = incidentStructure.incidentTags
                }
                let image = UIImage(named: "ICONS_Directional red")
                cell.directionalB.setImage(image, for: .normal)
                cell.myShift = .incidents
                cell.incidentType = .tags
                cell.nfirsInfoB.isHidden = true
                cell.nfirsInfoB.alpha = 0.0
                cell.nfirsInfoB.isEnabled = false
                return cell
            case 30:
                let cell = tableView.dequeueReusableCell(withIdentifier: "PhotosTVCell", for: indexPath) as! PhotosTVCell
                cell.delegate = self
                cell.subjectL.text = "Incident Photos"
                cell.myShift = myShift
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                return cell
            }
    }
        
}
