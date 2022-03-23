//
//  IncidentInfoModalTVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 8/1/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import MapKit
import CoreLocation

protocol IncidentInfoModalTVCDelegate: AnyObject {
    func incidentInfoUpdated(incidentStructured: IncidentData)
    func incidentInfoUpdateCancelled()
}

class IncidentInfoModalTVC: UITableViewController,CLLocationManagerDelegate {
    
    //    MARK: Objects
    var modalTitle: String = ""
    var modalInstructions: String = ""
    let userDefaults = UserDefaults.standard
    var fjUserTime:UserTime! = nil
    weak var delegate: IncidentInfoModalTVCDelegate? = nil
    
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
    
    var fetched:Array<Any>!
    var objectID:NSManagedObjectID!
    
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    var fjIncident:Incident!
    var alertUp: Bool = false
    let nc = NotificationCenter.default
    
    
    private let vcLaunch = VCLaunch()
    private var launchNC: LaunchNotifications!
    

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
        registerCells()
    }
    
    func roundViews() {
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
    }

    // MARK: - Table view data source// MARK: - Table View
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerV = Bundle.main.loadNibNamed("ModalHeaderSaveDismiss", owner: self, options: nil)?.first as! ModalHeaderSaveDismiss
        headerV.modalHTitleL.textColor = UIColor.white
        headerV.modalHCancelB.setTitle("Cancel",for: .normal)
        headerV.modalHCancelB.setTitleColor(UIColor.white, for: .normal)
        headerV.modalHSaveB.setTitle("Save",for: .normal)
        headerV.modalHSaveB.setTitleColor(UIColor.white, for: .normal)
        headerV.modalHTitleL.text = ""
            let color = ButtonsForFJ092018.fillColor38
        headerV.contentView.backgroundColor = color
        
        headerV.myShift = myShift
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
        return 5
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        switch row {
        case 0:
            return 85
        case 1:
            return 80
        case 2:
            if(showPicker) {
                return  132
            } else {
                return 0
            }
        case 3:
            return 287
        case 4:
            if(showMap) {
                return 500
            } else {
                return 0
            }
        default:
            return 44
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        
        switch row {
        case 0:
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
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelDateTimeButtonCell", for: indexPath) as! LabelDateTimeButtonCell
            cell.delegate = self
            cell.type = IncidentTypes.fire
            cell.dateTimeTV.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1.0)
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
                cell.dateTimeTV.attributedPlaceholder = NSAttributedString(string: incidentStructure.incidentFullAlarmDateS,attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.85)])
                //                    cell.dateTimeTV.text = incidentStructure.incidentFullAlarmDateS
            }
            cell.dateTimeL.text = "Date/Time"
            let image = UIImage(named: "ICONS_TimePiece red")
            cell.dateTimeB.setImage(image, for: .normal)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! DatePickerCell
            let incidentType:IncidentTypes = .alarm
            cell.delegate2 = self
            cell.incidentType = incidentType
            cell.datePicker.date = incidentStructure.incidentAlarmDate ?? Date()
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddressFieldsButtonsCell", for: indexPath) as! AddressFieldsButtonsCell
            cell.subjectL.text = "Address"
            if incidentStructure.incidentStreetName == "" {
                cell.addressTF.attributedPlaceholder = NSAttributedString(string: "100 Main Street",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.85)])
            } else {
                streetName = incidentStructure.incidentStreetName
                streetNum = incidentStructure.incidentStreetNum
                cell.addressTF.text = "\(streetNum) \(streetName)"
            }
            cell.addressTF.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
            if incidentStructure.incidentCity == "" {
                cell.cityTF.attributedPlaceholder = NSAttributedString(string: "Your Town",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.85)])
            } else {
                cell.cityTF.text = incidentStructure.incidentCity
            }
            cell.cityTF.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
            if incidentStructure.incidentState == "" {
                cell.stateTF.attributedPlaceholder = NSAttributedString(string: "CA",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.85)])
            } else {
                cell.stateTF.text = incidentStructure.incidentState
            }
            cell.stateTF.textColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
            if incidentStructure.incidentZip == "" {
                cell.zipTF.attributedPlaceholder = NSAttributedString(string: "90001",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.85)])
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
        case 4:
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
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! startShiftOvertimeSwitchCell
            return cell
        }
    }

}

extension IncidentInfoModalTVC: LabelTextFieldCellDelegate {
    func incidentLabelTFEditing(text: String, myShift: MenuItems, type: IncidentTypes) {
        
        //    TODO
    }
    
    func incidentLabelTFFinishedEditing(text: String, myShift: MenuItems, type: IncidentTypes) {
        
        //    TODO
    }
    
    func labelTextFieldEditing(text: String, myShift: MenuItems) {
        incidentStructure.incidentNumber = text
    }
    
    func labelTextFieldFinishedEditing(text: String, myShift: MenuItems) {
        incidentStructure.incidentNumber = text
    }
    
    func userInfoTextFieldEditing(text: String, myShift: MenuItems, journalType: JournalTypes) {
        
        //    TODO
    }
    
    func userInfoTextFieldFinishedEditing(text: String, myShift: MenuItems, journalType: JournalTypes) {
        
        //    TODO
    }
    
    
}

extension IncidentInfoModalTVC: DatePickerDelegate {
    func alarmTimeChosenDate(date: Date, incidentType: IncidentTypes) {
        incidentStructure.incidentAlarmDate = date
        incidentStructure.incidentFullAlarmDateS = vcLaunch.fullDateString(date:date)
        incidentStructure.incidentAlarmMM = vcLaunch.monthString(date: date)
        incidentStructure.incidentAlarmdd = vcLaunch.dayString(date: date)
        incidentStructure.incidentAlarmYYYY = vcLaunch.yearString(date: date)
        incidentStructure.incidentAlarmHH = vcLaunch.hourString(date: date)
        incidentStructure.incidentAlarmmm = vcLaunch.minuteString(date: date)
        tableView.reloadData()
    }
    
    func arrivalTimeChosenDate(date: Date, incidentType: IncidentTypes) {
        
        
        //    TODO
    }
    
    func controlledTimeChosenDate(date: Date, incidentType: IncidentTypes) {
        
        
        //    TODO
    }
    
    func lastUnitTimeChosenDate(date: Date, incidentType: IncidentTypes) {
        
        
        //    TODO
    }
    
    func nfirsSecMOfficersChosenDate(date: Date, incidentType: IncidentTypes) {
        
        
        //    TODO
    }
    
    func nfirsSecMMembersChosenDate(date: Date, incidentType: IncidentTypes) {
        
        
        //    TODO
    }
    
    
}

extension IncidentInfoModalTVC: AddressFieldsButtonsCellDelegate {
    func addressFieldFinishedEditing(address: String, tag: Int) {
        //        TODO:
    }
    
    func addressHasBeenFinished() {
        //    TODO
    }
    
    func worldBTapped() {
        let indexPath = IndexPath(row: 3, section: 0)
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
            if showMap {
               showMap = false
            } else {
                showMap = true
            }
            tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
        }
    }
    
    func locationBTapped() {
        determineLocation()
    }
    
    func determineLocation() {
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
        
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        manager.stopUpdatingLocation()
        CLGeocoder().reverseGeocodeLocation(userLocation, completionHandler: { [weak self] (placemarks, error) -> Void in
            print(userLocation)
            
            if error != nil {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            
            if placemarks?.count != 0 {
                let pm = placemarks![0]
                print(pm.locality!)
                self?.city = "\(pm.locality!)"
                self?.incidentStructure.incidentCity = self?.city ?? ""
                self?.streetNum = "\(pm.subThoroughfare!)"
                self?.incidentStructure.incidentStreetNum = self?.streetNum ?? ""
                self?.streetName = "\(pm.thoroughfare!)"
                self?.incidentStructure.incidentStreetName = self?.streetName ?? ""
                self?.stateName = "\(pm.administrativeArea!)"
                self?.incidentStructure.incidentState = self?.stateName ?? ""
                self?.zipNum = "\(pm.postalCode!)"
                self?.incidentStructure.incidentZip = self?.zipNum ?? ""
                self?.incidentStructure.incidentLocation = userLocation
                self?.incidentStructure.incidentLatitude = String(userLocation.coordinate.latitude)
                self?.incidentStructure.incidentLongitude = String(userLocation.coordinate.longitude)
                self?.tableView.reloadData()
            }
            else {
                print("Problem with the data received from geocoder")
            }
        })
    }
    
    
}

extension IncidentInfoModalTVC: MapViewCellDelegate {
    
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
    
    func theMapLocationHasBeenChosen(location: CLLocation) {}
    
    func theMapCancelButtonTapped() {
        if showMap {
            showMap = false
        } else {
            showMap = true
        }
        tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
    }
    
    func theAddressHasBeenChosen(addressStreetNum: String, addressStreetName: String, addressCity: String, addressState: String, addressZip: String, location: CLLocation) {
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
        incidentStructure.incidentLatitude = String(location.coordinate.latitude)
        incidentStructure.incidentLongitude = String(location.coordinate.longitude)
        if showMap {
            showMap = false
        } else {
            showMap = true
        }
        self.tableView.reloadData()
    }
    
    
}

extension IncidentInfoModalTVC: LabelDateTimeButtonCellDelegate {
    func dateTimeButtonTapped(type: IncidentTypes) {
        if showPicker {
            showPicker = false
        } else {
            showPicker = true
        }
        tableView.reloadData()
//            if (incidentStructure != nil) {
//                if incidentStructure.incidentAlarmDate != nil {
//                    let date = Date()
//                    incidentStructure.incidentAlarmDate = date
//                    incidentStructure.incidentFullAlarmDateS = vcLaunch.fullDateString(date:date)
//                    incidentStructure.incidentAlarmMM = vcLaunch.monthString(date: date)
//                    incidentStructure.incidentAlarmdd = vcLaunch.dayString(date: date)
//                    incidentStructure.incidentAlarmYYYY = vcLaunch.yearString(date: date)
//                    incidentStructure.incidentAlarmHH = vcLaunch.hourString(date: date)
//                    incidentStructure.incidentAlarmmm = vcLaunch.minuteString(date: date)
//                }
//            } else {
//                showPicker = true
//            }
//            tableView.reloadData()
    }
    
    
}

extension IncidentInfoModalTVC: ModalHeaderSaveDismissDelegate {
    
    func modalInfoBTapped(myShift: MenuItems) {
//        <#code#>
    }
    
    func modalDismiss() {
        delegate?.incidentInfoUpdateCancelled()
    }
    
    func modalSave(myShift: MenuItems) {
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! LabelTextFieldCell
        _ = cell.textFieldShouldEndEditing(cell.descriptionTF)
        delegate?.incidentInfoUpdated(incidentStructured: incidentStructure)
    }
}

extension IncidentInfoModalTVC {
    
    fileprivate func registerCells() {
        tableView.register(UINib(nibName: "LabelTextFieldCell", bundle: nil), forCellReuseIdentifier: "LabelTextFieldCell")
        tableView.register(UINib(nibName: "LabelDateTimeButtonCell", bundle: nil), forCellReuseIdentifier: "LabelDateTimeButtonCell")
        tableView.register(UINib(nibName: "DatePickerCell", bundle: nil), forCellReuseIdentifier: "DatePickerCell")
        tableView.register(UINib(nibName: "AddressFieldsButtonsCell", bundle: nil), forCellReuseIdentifier: "AddressFieldsButtonsCell")
        tableView.register(UINib(nibName: "MapViewCell", bundle: nil), forCellReuseIdentifier: "MapViewCell")
    }
}
