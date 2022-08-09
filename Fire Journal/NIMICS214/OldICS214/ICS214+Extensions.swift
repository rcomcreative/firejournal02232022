//
//  ICS214+Extensions.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/23/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import Contacts
import ContactsUI
import T1Autograph
import MapKit
import CoreLocation
import CloudKit



extension ICS214DetailViewController: ThreeFieldDelegate {
    
    func theAddButtonTapped() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "ICS214Form", bundle:nil)
        let modalTVC = storyBoard.instantiateViewController(withIdentifier: "TeamTVC") as! TeamTVC
        modalTVC.delegateTeam = self
        modalTVC.chosenMembers = ics214UserAttendees
        let modalNavigationController:UINavigationController = UINavigationController(rootViewController: modalTVC)
        modalNavigationController.modalPresentationStyle = .formSheet
        self.present(modalNavigationController, animated: true, completion: nil)
    }
    
    func threeAnswersChosen(array: Array<Any>) {
        let field1:String = "\(array[0])"
        let field2:String = "\(array[1])"
        let field3:String = "\(array[2])"
        let teamArray: Array<String> = [field1,field2, field3]
        teams.append(teamArray)
        
        let obID = NSManagedObjectID()
        let logDate = Date()
        let cellEntered = ICS214Cell2Entered.init(header: "", date: logDate, id: obID)
        cellEntered.field1 = field1
        cellEntered.field2 = field2
        cellEntered.field3 = field3
        
        let e:Int = theCells.firstIndex(where: { $0.tag == 6 })!
        let t:Int = e+1
        theCells.insert(cellEntered, at: t)
        
        tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
    }
    
}

//      MARK: -TwoFieldDelegate-
extension ICS214DetailViewController: TwoFieldDelegate {
    
    private func removeActivityLogs() {
        if let theGuid = nims.ics214Guid {
            DispatchQueue.main.async {
                self.nc.post(name: Notification.Name(rawValue: FJkDELETEMODIFIEDICS214ACTIVITYLOG_TOCLOUDKIT),
                             object: nil, userInfo: ["theGuid":theGuid])
            }
        }
        removeActivityLogsFromCD()
    }
    
    private func removeActivityLogsFromCD() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ICS214ActivityLog")
        let predicate = NSPredicate(format: "ics214Guid == %@", nims.ics214Guid!)
        let predicate1 = NSPredicate(format: "ics214Guid == %@", "")
        
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.or, subpredicates: [predicate,predicate1])
        fetchRequest.predicate = predicateCan
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let fetchedRequest = try context.fetch(fetchRequest) as! [ICS214ActivityLog]
            for activity:ICS214ActivityLog in fetchedRequest {
                nims.removeFromIcs214ActivityDetail(activity)
                context.delete(activity)
            }
            do {
                try context.save()
                DispatchQueue.main.async {
                    self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"ICS214+EXTENSION merge that"])
                }
            } catch {
                let nserror = error as NSError
                
                let errorMessage = "ICS214DetailViewController removeActivityLogsFromCD fetchRequest save Unresolved error \(nserror)"
                print(errorMessage)
            }
        } catch {
            let nserror = error as NSError
            
            let errorMessage = "ICS214DetailViewController removeActivityLogsFromCD fetchRequest 2 save Unresolved error \(nserror)"
            print(errorMessage)
        }
    }
    
    private func createNewActivityLog(date:Date,dateString:String,logActivity:String) {
        ics214Guid = nims.ics214Guid
        let logString = logActivity
        var uuidA:String = NSUUID().uuidString.lowercased()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYDDDHHmmAAAAAAAA"
        let dateFrom = dateFormatter.string(from: date)
        uuidA = uuidA+dateFrom
        let logGuid = "81."+uuidA
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ICS214ActivityLog")
        fetchRequest.predicate = NSPredicate(format: "ics214ActivityLog == %@ && ics214Guid == %@", logString,ics214Guid)
        do {
            let fetchedActivity = try context.fetch(fetchRequest) as! [ICS214ActivityLog]
            if fetchedActivity.count == 0 {
                let icsS214ActivityLog = ICS214ActivityLog.init(entity: NSEntityDescription.entity(forEntityName: "ICS214ActivityLog", in: context)!, insertInto: context)
                icsS214ActivityLog.ics214ActivityGuid = logGuid
                icsS214ActivityLog.ics214Guid = ics214Guid
                icsS214ActivityLog.ics214AcivityModDate = date
                icsS214ActivityLog.ics214ActivityCreationDate = date
                icsS214ActivityLog.ics214ActivityBackedUp = false
                icsS214ActivityLog.ics214ActivityDate = date
                icsS214ActivityLog.ics214ActivityLog = logString
                icsS214ActivityLog.ics214ActivityStringDate = dateString
                nims.addToIcs214ActivityDetail(icsS214ActivityLog)
                do {
                    try context.save()
                    DispatchQueue.main.async {
                        self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"ICS214+EXTENSION merge that"])
                    }
                    buildActivityLogs()
                } catch {
                    let nserror = error as NSError
                    
                    let errorMessage = "ICS214DetailViewController createNewActivityLog save Unresolved error \(nserror)"
                    print(errorMessage)
                }
            }
        } catch {
            let nserror = error as NSError
            
            let errorMessage = "ICS214DetailViewController createNewActivityLog save Unresolved error \(nserror)"
            print(errorMessage)
        }
    }
    
    private func buildActivityLogs() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ICS214ActivityLog")
        fetchRequest.predicate = NSPredicate(format: "ics214Guid == %@", ics214Guid)
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let fetchedActivities = try context.fetch(fetchRequest) as! [ICS214ActivityLog]
            for activity in fetchedActivities {
                if !ics214ActivityLogs.contains(activity) {
                    ics214ActivityLogs.append(activity)
                }
                let log = activity.ics214ActivityLog ?? ""
                let logDateString = activity.ics214ActivityStringDate ?? ""
                let logDate = activity.ics214ActivityDate ?? Date()
                let activityC = ActivityCaptured.init(log: log, logDateString: logDateString, logDate: logDate)
                if !ics214Activities.contains(activityC!) {
                    ics214Activities.append(activityC!)
                }
            }
        } catch {
            let nserror = error as NSError
            let errorMessage = "ICS214DetailViewController buildActivityLogs() Unresolved error \(nserror)"
            print(errorMessage)
        }
    }
    
    private func buildActivityLogCells() {
        ics214Guid = nims.ics214Guid!
        for activity in ics214Activities {
            var uuidA:String = NSUUID().uuidString.lowercased()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYYDDDHHmmAAAAAAAA"
            let dateFrom = dateFormatter.string(from: Date())
            uuidA = uuidA+dateFrom
            let logGuid = "81."+uuidA
            let icsS214ActivityLog = ICS214ActivityLog.init(entity: NSEntityDescription.entity(forEntityName: "ICS214ActivityLog", in: context)!, insertInto: context)
            icsS214ActivityLog.ics214ActivityGuid = logGuid
            icsS214ActivityLog.ics214Guid = ics214Guid
            icsS214ActivityLog.ics214AcivityModDate = activity.logDate
            icsS214ActivityLog.ics214ActivityCreationDate = activity.logDate
            icsS214ActivityLog.ics214ActivityBackedUp = false
            icsS214ActivityLog.ics214ActivityDate = activity.logDate
            icsS214ActivityLog.ics214ActivityLog = activity.log
            icsS214ActivityLog.ics214ActivityStringDate = activity.logDateString
            nims.addToIcs214ActivityDetail(icsS214ActivityLog)
            saveToCDForActivityLog(guid: logGuid)
            
            let obID = NSManagedObjectID()
            let cellEntered = ICS214Cell3Entered.init(header: "", date: activity.logDate ?? Date(), id: obID)
            cellEntered.field1 = activity.logDateString ?? ""
            cellEntered.field2 = activity.log ?? ""
            
            let e:Int = theCells.firstIndex(where: { $0.tag == 10 })!
            let t:Int = e+1
            theCells.insert(cellEntered, at: t)
        }
        tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
    }
    
    func twoAnswersAndDateChosen(dateString:String,logActivity:String,activityDate:Date) {
        ics214ActivityLogs.removeAll()
        ics214Activities.removeAll()
        var cells = [CellStorage]()
        for cell in theCells {
            if cell.tag != 15 {
                cells.append(cell)
            }
        }
        theCells.removeAll()
        theCells = cells
//        ics214Guid = nims.ics214Guid!
        createNewActivityLog(date:activityDate,dateString: dateString,logActivity: logActivity)
        removeActivityLogs()
        buildActivityLogCells()
        
    }
    
    func oneAnswerChosen() {}
    
    func timeButtonTappedWTV(){
        if(showPickerTwo) {
            showPickerThree = false
            showPickerTwo = false
            showPicker = false
        } else {
            showPickerThree = false
            showPicker = false
            showPickerTwo = true
        }
        
        tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
    }
    
}

        // MARK: -LocationCellDelegate-
/*extension ICS214DetailViewController: LocationCellDelegate,CLLocationManagerDelegate {
    
    func theTextFieldOnLocationComplete(complete: Bool) {
       presentAlert()
    }
    
    func theLocationBTapped() {
         self.resignFirstResponder()
        determineLocation()
    }
    
    func determineLocation() {
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
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
//                self.searchARCForm.arcLocationAvailable = false
                return
            }
            
            if placemarks?.count != 0 {
                let pm = placemarks![0]
                print(pm.locality!)
//                self.searchARCForm.arcLocationCity = "\(pm.locality!)"
//                self.streetNum = "\(pm.subThoroughfare!)"
//                self.streetName = "\(pm.thoroughfare!)"
//                self.searchARCForm.arcLocationAddress = "\(self.streetNum) \(self.streetName)"
//                self.state = "\(pm.administrativeArea!)"
//                self.searchARCForm.arcLocaitonState = self.state
//                self.zip = "\(pm.postalCode!)"
//                self.searchARCForm.arcLocationZip = self.zip
//                self.searchARCForm.arcLocationAvailable = true
//                self.searchARCForm.arcLocation = userLocation
//                self.buildTheCells()
//                self.tableView.reloadData()
            }
            else {
                print("Problem with the data received from geocoder")
//                self.searchARCForm.arcLocationAvailable = false
            }
        })
    }
    
    func theMapButtonTapped() {
//        <#code#>
    }
    
    func theTextFieldOnLocationCTyped(textLocation: [String : String]) {
//        <#code#>
    }
    
    
}*/

        // MARK: -TwoButtonCellDelegate-
extension ICS214DetailViewController: TwoButtonCellDelegate {
    
    func buttonOneTapped(date: Date) {
        //fromDate = date
        dateType = true
        showPicker = true
        showPickerTwo = false
        self.tableView.reloadData()
    }
    
    func buttonTwoTapped(date: Date) {
        //        toDate = date
        dateType = false
        showPicker = true
        showPickerTwo = false
        
        self.tableView.reloadData()
    }
}

//      MARK: -FormDatePickerCellDelegate-
extension ICS214DetailViewController: FormDatePickerCellDelegate {
    
    func chosenToDate(date: Date) {
        icsDateTo = date
        showPicker = false
        
        tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
    }
    
    func chosenFromDate(date: Date) {
        fromDate = date
        icsDate = date
        showPicker = false
        
        tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
    }
    
    func chosenActivityDate(date: Date) {
        activityDate = date
        showPickerTwo = false
        
        tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
    }
    
    func chosenSignatureDate(date: Date) {
        signatureDate = date
        showPickerThree = false
        
        tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
    }
    
//    OPTIONAL
    func chosenIncidentDate(date: Date) {}
    
}

//      MARK: -OneButtonCellDelegate - DoubleTextFieldWButtonCell -
//      MARK: -T1Autograph delegate methods used
extension ICS214DetailViewController: OneButtonCellDelegate,T1AutographDelegate  {
    
    /// time button tapped on DoubleTextFieldWButtonCell
    ///
    /// - Parameter date: date when tapped
    func bOneTapped(date: Date ) {
        if(showPickerThree) {
            showPickerThree = false
            showPickerTwo = false
            showPicker = false
        } else {
            showPickerThree = true
            showPicker = false
            showPickerTwo = false
        }
        tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
    }
    
    /// - Parameter string: text input into certain text field
    func fourTextFieldsTF1(string: String) {
        ics214stucture.preparedByName = string
    }
    func fourTextFieldsTF2(string: String) {
        ics214stucture.preparedPosition = string
    }
    func fourTextFieldsTF3(string: String) {
        ics214stucture.preparedSignature = string
    }
    func fourTextFieldsTF4(string: String) {
    }
    
    //    TODO: -AUTOGRAPH needs to be hooked in
    func signatureButtonTapped() {
        autograph = T1Autograph.autograph(withDelegate: self, modalDisplay: "ICS 214 Activity Log Signature") as! T1Autograph
        
        // Enter license code here to remove the watermark
        autograph.licenseCode = "9186d2059ae047426bd0c571a0cf637ef569a6c4"
        
        // any optional configuration done here
        autograph.showDate = false
        autograph.strokeColor = UIColor.darkGray
    }
    
    func autograph(_ autograph: T1Autograph!, didCompleteWith signature: T1Signature!) {
        signatureDate = Date()
        signatureImage = UIImage(data:signature.imageData,scale:1.0)
        signatureBool = true
        tableView.reloadData()
    }
    
    func autographDidCancelModalView(_ autograph: T1Autograph!) {
        signatureBool = false
        signatureImage = nil
        tableView.reloadData()
    }
    
    func autographDidCompleteWithNoSignature(_ autograph: T1Autograph!) {
        signatureBool = false
        signatureImage = nil
        tableView.reloadData()
    }
    
    func autograph(_ autograph: T1Autograph!, didEndLineWithSignaturePointCount count: UInt) {
        // Note: You can use the 'count' parameter to determine if the line is substantial enough to enable the done or clear button.
    }
    
    func autograph(_ autograph: T1Autograph!, willCompleteWith signature: T1Signature!) {
        NSLog("Autograph will complete with signature")
    }
    
}

//      MARK: -TeamTVCDelegate-
extension ICS214DetailViewController: TeamTVCDelegate {
    
    //    MARK: find all icsPersonnel associated with this form
    //    MARK: delete all and then add the new ones in next function
    private func removePersonnel() {
        if let theGuid = nims.ics214Guid {
            DispatchQueue.main.async {
                self.nc.post(name: Notification.Name(rawValue: FJkDELETEMODIFIEDICS214PERSONNEL_TOCLOUDKIT),
                             object: nil, userInfo: ["theGuid":theGuid])
            }
        }
        removePersonnelFromCD()
    }
    
    private func removePersonnelFromCD() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ICS214Personnel")
        fetchRequest.predicate = NSPredicate(format: "ics214Guid == %@", nims.ics214Guid!)
        do {
            let fetchedRequest = try context.fetch(fetchRequest) as! [ICS214Personnel]
            for personnel:ICS214Personnel in fetchedRequest {
                    nims.removeFromIcs214PersonneDetail(personnel)
                    context.delete(personnel)
            }
        } catch {
            let nserror = error as NSError
            
            let errorMessage = "ICS214DetailViewController effortHasChangedToComplete() fetchRequest 2 save Unresolved error \(nserror)"
            print(errorMessage)
        }
        do {
            try context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"ICS214+EXTENSION merge that"])
            }
        } catch {
            let nserror = error as NSError
            
            let errorMessage = "ICS214DetailViewController effortHasChangedToComplete() fetchRequest save Unresolved error \(nserror)"
            print(errorMessage)
        }
    }
    
    private func createPersonnel(guid2: String) {
        let fjuICS214Personnel = ICS214Personnel.init(entity: NSEntityDescription.entity(forEntityName: "ICS214Personnel", in: context)!, insertInto: context)
        fjuICS214Personnel.ics214Guid = nims.ics214Guid
//        fjuICS214Personnel.ics214Reference = nims.ics214CKReference
        var uuidA:String = NSUUID().uuidString.lowercased()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYDDDHHmmAAAAAAAA"
        let resourceDate = Date()
        let dateFrom = dateFormatter.string(from: resourceDate)
        uuidA = uuidA+dateFrom
        let uuidA1 = "80."+uuidA
        fjuICS214Personnel.ics214PersonelGuid = uuidA1
        fjuICS214Personnel.userAttendeeGuid = guid2
        nims.addToIcs214PersonneDetail(fjuICS214Personnel)
        saveToCDForPersonnel(guid: uuidA1)
    }
    
    /// Delegate from TeamsTVC
    ///
    /// - Parameter resource: ResourcesAttendees that were chosen returned
    func namesArraySent(names: [UserAttendees]) {
        ics214UserAttendees.removeAll()
        var cells = [CellStorage]()
        for cell in theCells {
            if cell.tag != 16 {
                cells.append(cell)
            }
        }
        theCells.removeAll()
        theCells = cells
        removePersonnel()
        for attendee:UserAttendees in names {
            if !(ics214UserAttendees.contains(attendee)) {
                ics214UserAttendees.append(attendee)
                var phone:String = ""
                var name:String = ""
                var email:String = ""
                var icsPosition:String = ""
                var homeAgency:String = ""
                var guid:String = ""
                if let resource = attendee.attendee {
                    name = resource
                }
                if let cell = attendee.attendeePhone {
                    phone = cell
                }
                if let mail = attendee.attendeeEmail {
                    email = mail
                }
                if let agency = attendee.attendeeHomeAgency {
                    homeAgency = agency
                }
                if let position = attendee.attendeeICSPosition {
                    icsPosition = position
                }
                if let uuidA = attendee.attendeeGuid {
                    guid = uuidA
                }
                
                
                let obID = attendee.objectID
                let logDate = Date()
                let cellEntered = ICS214Cell2Entered.init(header: "", date: logDate, id: obID)
                cellEntered.field1 = name
                cellEntered.field2 = icsPosition
                cellEntered.field3 = homeAgency
                cellEntered.field4 = email
                cellEntered.cellValue1 = phone
                cellEntered.cellValue2 = guid
                
                let e:Int = theCells.firstIndex(where: { $0.tag == 6 })!
                let t:Int = e+1
                theCells.insert(cellEntered, at: t)
                
                
                let aGuid = attendee.attendeeGuid
                createPersonnel(guid2: aGuid!)
            }
        }
        tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
    }
    
    func namesChosen(resource: [ICS214Resources]) {
//        print("ya gotta let me out of here")
        for entry in resource {
            var phone:String = ""
            var name:String = ""
            var email:String = ""
            var icsPosition:String = ""
            var homeAgency:String = ""
            var guid:String = ""
            if let resource = entry.resource["name"] {
                name = resource
            }
            if let cell = entry.phone["phone"] {
                phone = cell
            }
            if let mail = entry.email["email"] {
                email = mail
            }
            if let agency = entry.agency["agency"] {
                homeAgency = agency
            }
            if let position = entry.icsPosition["icsPosition"] {
                icsPosition = position
            }
            if let uuidA = entry.resourceGuid["guid"] {
                guid = uuidA
            }
            let attendee1 = ICS214Resources.init(resource: [ "name":name ], icsPosition: [ "icsPosition": icsPosition ], agency: [ "agency":homeAgency ], email: [ "email":email ], phone: [ "phone":phone ], resourceGuid: [ "guid":guid ])
            let resource1 = ResourceAttendee.init(name: name, email: email, phone: phone, icsPosition: icsPosition, homeAgency: homeAgency, guid: guid)
            if !(resources.contains(resource1!)) {
                resources.append(resource1!)
                
                let obID = NSManagedObjectID()
                let logDate = Date()
                let cellEntered = ICS214Cell2Entered.init(header: "", date: logDate, id: obID)
                cellEntered.field1 = name
                cellEntered.field2 = icsPosition
                cellEntered.field3 = homeAgency
                cellEntered.field4 = email
                cellEntered.cellValue1 = phone
                cellEntered.cellValue2 = guid
                
                let e:Int = theCells.firstIndex(where: { $0.tag == 6 })!
                let t:Int = e+1
                theCells.insert(cellEntered, at: t)
                
                tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
            }
            if !(ics214resources.contains(attendee1)) {
                
                ics214resources.append(attendee1)
            }
        }
        saveICS214(self)
    }
    
    func cancelButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
}

//      MARK: -TwoInputCellwTextViewDelegate-
extension ICS214DetailViewController: TwoInputCellwTextViewDelegate {
    
    func twoAnswersChosenWTV(array: Array<Any>) {}
    
    func textViewHasBegunChanging() {}
    
    func timeButtonTapped() {
        if(showPickerTwo) {
            showPickerThree = false
            showPickerTwo = false
            showPicker = false
        } else {
            showPickerThree = false
            showPicker = false
            showPickerTwo = true
        }
        
        
        tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
    }
    
}

//      MARK: -TextFieldInputCellDelegate-
extension ICS214DetailViewController: TextFieldInputCellDelegate {
    
    /// delegate from singleTextFieldInput
    ///
    /// - Parameters:
    ///   - type: ValueType - cell assigned when table built
    ///   - input: text input into the cells text field
    func singleTextFieldInput(type: ValueType, input: String ) {
        switch type {
        case .fjKISCUnitName:
            ics214stucture.icsUnitName = input
        case .fjKIncidentName:
            ics214stucture.incidentName = input
        case .fjKUnitLeader:
            ics214stucture.unitLeader = input
        case .fjKICSPosition:
            ics214stucture.icsPosition = input
        default:
            break
        }
    }
    
    func singleTextFieldInputWithForm(type: CellType, input: String, section:Sections ) {
        
    }
}

//      MARK: -NewICS214ModalTVCDelegate-
extension ICS214DetailViewController: NewICS214ModalTVCDelegate {
    
    func theCancelCalledOnNewICS214Modal() {
//        print("detail listing")
        navigationController?.popViewController(animated: true)
    }
    
    func theNewICS214Created(ics214OID: NSManagedObjectID) {
        
    }
    
}

//      MARK: -SectionHeaderCellDelgate-
extension ICS214DetailViewController: SectionHeaderCellDelgate {
    
    func effortHasChangedToComplete(complete: Bool, completed:String ) {
        completedB = complete
        tableView.reloadData()
        if completedB {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ICS214Form")
            fetchRequest.predicate = NSPredicate(format: "ics214MasterGuid == %@", masterGuid)
            do {
                let fetchedRequest = try context.fetch(fetchRequest) as! [ICS214Form]
                for form:ICS214Form in fetchedRequest {
                    form.ics214Completed = completedB
                    let modDate = Date()
                    form.ics214ModDate = modDate
                    form.ics214CompletionDate = modDate
                    form.ics214BackedUp = false
                }
                do {
                    try context.save()
                    DispatchQueue.main.async {
                        self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"ICS214+EXTENSION merge that"])
                    }
                } catch {
                    let nserror = error as NSError
                    
                    let errorMessage = "ICS214DetailViewController effortHasChangedToComplete() fetchRequest save Unresolved error \(nserror)"
                    print(errorMessage)
                }
            } catch {
                let nserror = error as NSError
                
                let errorMessage = "ICS214DetailViewController effortHasChangedToComplete() fetchRequest 2 save Unresolved error \(nserror)"
                print(errorMessage)
            }
        } else {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ICS214Form")
            fetchRequest.predicate = NSPredicate(format: "ics214MasterGuid == %@", masterGuid)
            do {
                let fetchedRequest = try context.fetch(fetchRequest) as! [ICS214Form]
                for form:ICS214Form in fetchedRequest {
                    form.ics214Completed = completedB
                    let modDate = Date()
                    form.ics214ModDate = modDate
                    form.ics214CompletionDate = modDate
                    form.ics214BackedUp = false
                }
                do {
                    try context.save()
                    DispatchQueue.main.async {
                        self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"ICS214+EXTENSION merge that"])
                    }
                } catch {
                    let nserror = error as NSError
                    
                    let errorMessage = "ICS214DetailViewController effortHasChangedToComplete() fetchRequest save3 Unresolved error \(nserror)"
                    print(errorMessage)
                }
            } catch {
                let nserror = error as NSError
                
                let errorMessage = "ICS214DetailViewController effortHasChangedToComplete() fetchRequest save4 Unresolved error \(nserror)"
                print(errorMessage)
            }
        }
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: notificationKeyICS5), object: nil, userInfo:nil)
        }
    }
    
}

//      MARK: -NewIncidentMapDelegate-
extension ICS214DetailViewController: NewIncidentMapDelegate {
    
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
    
    func theMapCancelButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func theMapLocationHasBeenChosen(location: CLLocation) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

//      MARK: -CompletedThreeFieldCellDelgate-
extension ICS214DetailViewController: CompletedThreeFieldCellDelgate {
    
    func nameTextFieldEdited(string:String, indexPath:IndexPath) {
        
    }
    
    func positionTextFieldEdited(position:String, indexPath:IndexPath) {
        let icsPosition = position
        let cellChecked = tableView.cellForRow(at: indexPath) as! CompletedThreeFieldCell
        let name = cellChecked.inputTestFieldOne.text
        let filteredName = ics214UserAttendees.filter({ $0.attendee == name })
        
        for user in filteredName {
            let userAttendee:UserAttendees = user
            userAttendee.attendeeICSPosition = icsPosition
            userAttendee.attendeeHasPosition = true
            userAttendee.attendeeBackUp = false
            do {
                try context.save()
                DispatchQueue.main.async {
                    self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"ICS214+EXTENSION merge that"])
                }
            } catch {
                let nserror = error as NSError
                
                let errorMessage = "ICS214DetailViewController positionTextFieldEdited() save Unresolved error \(nserror)"
                print(errorMessage)
            }
            var members3 = [userAttendee]
            for user in ics214UserAttendees {
                members3.append(user)
            }
            ics214UserAttendees.removeAll()
            ics214UserAttendees = members3.sorted(by: {$0.attendee! > $1.attendee!})
        }
    }
    
    func agencyTextFieldEdited(agency:String, indexPath:IndexPath) {
        let icsAgency = agency
        let cellChecked = tableView.cellForRow(at: indexPath) as! CompletedThreeFieldCell
        let name = cellChecked.inputTestFieldOne.text
        let filteredName = ics214UserAttendees.filter({ $0.attendee == name })
        
        for user in filteredName {
            let userAttendee:UserAttendees = user
            userAttendee.attendeeHomeAgency = icsAgency
            userAttendee.attendeeBackUp = false
            do {
                try context.save()
                DispatchQueue.main.async {
                    self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"ICS214+EXTENSION merge that"])
                }
            } catch {
                let nserror = error as NSError
                
                let errorMessage = "ICS214DetailViewController agencyTextFieldEdited() save Unresolved error \(nserror)"
                print(errorMessage)
            }
            var members3 = [user]
            for user in ics214UserAttendees {
                members3.append(user)
            }
            ics214UserAttendees.removeAll()
            ics214UserAttendees = members3.sorted(by: {$0.attendee! > $1.attendee!})
        }
    }
    
}

//      MARK: -SAVE TO CD-
extension ICS214DetailViewController {
    
    fileprivate func saveToCDForActivityLog(guid: String) {
        do {
            try context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"ICS214+EXTENSION merge that"])
            }
            DispatchQueue.main.async {
                let objectID = self.getTheLastSavedICS214ActivityLog(guid: guid)
                self.nc.post(name: Notification.Name(rawValue: FJkNEWICS214ACTIVITYLOG_TOCLOUDKIT),
                             object: nil, userInfo: ["objectID":objectID])
            }
        } catch {
            let nserror = error as NSError
            print("ICS214Activity The context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo)")
        }
    }
    
    private func getTheLastSavedICS214ActivityLog(guid: String)->NSManagedObjectID {
        var objectID: NSManagedObjectID!
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ICS214ActivityLog" )
        let predicate = NSPredicate(format: "%K == %@", "ics214ActivityGuid",guid)
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 1
        do {
            let fetched = try context.fetch(fetchRequest) as! [ICS214ActivityLog]
            let ics214ActivityLog = fetched.last
            objectID = ics214ActivityLog?.objectID
            return objectID!
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        return objectID
    }
    
//    MARK: -QUESTIONABLE IN USE???-
    func twoAnswersChosen(array: Array<Any>) {
        let fieldOne:String = "\(array[0])"
        let fieldTwo:String = "\(array[1])"
        
        let obID = NSManagedObjectID()
        let logDate = Date()
        let cellEntered = ICS214Cell3Entered.init(header: "", date: logDate, id: obID)
        cellEntered.field1 = fieldOne
        cellEntered.field2 = fieldTwo
        
        let e:Int = theCells.firstIndex(where: { $0.tag == 10 })!
        let t:Int = e+1
        theCells.insert(cellEntered, at: t)
        
        tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
    }
    
}

//          MARK: - REGISTER CELLS
extension ICS214DetailViewController {
    
    
    func registerTheCellsForICS214() {
        tableView.register(UINib(nibName: "CustomCellOne", bundle: nil), forCellReuseIdentifier: "CustomCellOne")
        tableView.register(UINib(nibName: "CustomCellTwo", bundle: nil), forCellReuseIdentifier: "CustomCellTwo")
        tableView.register(UINib(nibName: "SectionHeaderCell", bundle: nil), forCellReuseIdentifier: "SectionHeaderCell")
        tableView.register(UINib(nibName: "TextFieldInputCell", bundle: nil), forCellReuseIdentifier: "TextFieldInputCell")
        tableView.register(UINib(nibName: "DoubleTextFieldWButtonCell", bundle: nil), forCellReuseIdentifier: "DoubleTextFieldWButtonCell")
        tableView.register(UINib(nibName: "FormThreeInputCell", bundle: nil), forCellReuseIdentifier: "FormThreeInputCell")
        tableView.register(UINib(nibName: "FormTwoInputCell", bundle: nil), forCellReuseIdentifier: "FormTwoInputCell")
        tableView.register(UINib(nibName: "CompletedThreeFieldCell", bundle: nil), forCellReuseIdentifier: "CompletedThreeFieldCell")
        tableView.register(UINib(nibName: "CompletedTwoFieldCell", bundle: nil), forCellReuseIdentifier: "CompletedTwoFieldCell")
        tableView.register(UINib(nibName: "TwoButtonFourInputCell", bundle: nil), forCellReuseIdentifier: "TwoButtonFourInputCell")
        tableView.register(UINib(nibName: "FormDatePickerCell", bundle: nil), forCellReuseIdentifier: "FormDatePickerCell")
        tableView.register(UINib(nibName: "CompletedTwoFieldCellwTextV", bundle: nil), forCellReuseIdentifier: "CompletedTwoFieldCellwTextV")
        tableView.register(UINib(nibName: "FormTwoInputCellwTextView", bundle: nil), forCellReuseIdentifier: "FormTwoInputCellwTextView")
    }
    
    func theFormBody() {
        ics214ActivityLogs.removeAll()
        ics214UserAttendees.removeAll()
        ics214Activities.removeAll()
        if (objectID) != nil {
            nims = context.object(with: objectID!) as? ICS214Form
            ics214Guid = nims.ics214Guid
            if nims.ics214SignatureAdded {
                signatureBool = true
                if(nims.ics214Signature != nil) {
                    let imageUIImage: UIImage = UIImage(data: nims.ics214Signature!)!
                    signatureImage = imageUIImage
                    signatureDate = nims.ics214SignatureDate
                }
            } else {
                signatureBool = false
            }
            
            resources.removeAll()
//            print(nims)
            if let test = nims {
                ics214 = test
                dataAvailable = true
//                print(ics214)
                if ((ics214.ics214FromTime) != nil) {
                    icsDate = ics214.ics214FromTime! as Date
                    masterGuid = ics214.ics214MasterGuid
                    _ = ics214.ics214Guid
                    completedB = ics214.ics214Completed
                    
                    
                    var personnelA = [String]()
                    for personnel in ics214.ics214PersonneDetail as! Set<ICS214Personnel> {
                        let pGuid = personnel.userAttendeeGuid ?? ""
                        personnelA.append(pGuid)
                    }
                    
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ICS214Personnel" )
                    let predicate = NSPredicate(format: "%K ==  %@","ics214Guid",ics214.ics214Guid!)
                    let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
                    fetchRequest.predicate = predicateCan
                    fetchRequest.returnsObjectsAsFaults = false
                    //                            fetchRequest.fetchBatchSize = 1
                    
                    do {
                        let fetched = try context.fetch(fetchRequest) as! [ICS214Personnel]
                        if fetched.isEmpty {} else {
                            
                        }
                    } catch {
                        
                    }
                    
                    ics214resources.removeAll()
                    var cells = [ICS214Cell2Entered]()
                    if !personnelA.isEmpty {
                        for ( _, guid ) in personnelA.enumerated() {
                            var attendee:UserAttendees!
                            let entity = "UserAttendees"
                            let attribute = "attendeeGuid"
                            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
                            let predicate = NSPredicate(format: "%K == %@", attribute, guid)
                            let predicate1 = NSPredicate(format: "%K != %@", "attendeeICSPosition", "")
                            let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate,predicate1])
                            fetchRequest.predicate = predicateCan
//                            fetchRequest.fetchBatchSize = 1
                            
                            do {
                                let fetched = try context.fetch(fetchRequest) as! [UserAttendees]
                                if fetched.isEmpty {
//                                    print("no user available")
                                    return
                                } else {
                                    attendee = fetched.last
                                    let attendee1 = ICS214Resources.init(resource: [ "name":attendee.attendee ?? "" ], icsPosition: [ "icsPosition": attendee.attendeeICSPosition ?? "" ], agency: [ "agency":attendee.attendeeHomeAgency ?? "" ], email: [ "email":attendee.attendeeEmail ?? "" ], phone: [ "phone":attendee.attendeePhone ?? "" ], resourceGuid: [ "guid":attendee.attendeeGuid ?? ""])
                                    ics214resources.append(attendee1)
                                    
                                    let obID = NSManagedObjectID()
                                    let logDate = Date()
                                    let cellEntered = ICS214Cell2Entered.init(header: "", date: logDate, id: obID)
                                    cellEntered.field1 = attendee.attendee ?? ""
                                    cellEntered.field2 = attendee.attendeeICSPosition ?? ""
                                    cellEntered.field3 = attendee.attendeeHomeAgency ?? ""
                                    cellEntered.field4 = attendee.attendeeEmail ?? ""
                                    cellEntered.cellValue1 = attendee.attendeePhone ?? ""
                                    cellEntered.cellValue2 = attendee.attendeeGuid ?? ""
                                    cells.append(cellEntered)
                                    
                                    ics214UserAttendees.append(attendee)
                                }
                            } catch let error as NSError {
                                print("ICS214DetailViewControllerTVC line 519 Fetch Error: \(error.localizedDescription)")
                            }
                            
                            
                            
                        }
                    }
                    cells = cells.sorted(by: { $0.field1 > $1.field1})
                    for cellEntered in cells {
                        let e:Int = theCells.firstIndex(where: { $0.tag == 6 })!
                        let t:Int = e+1
                        theCells.insert(cellEntered, at: t)
                    }
                    
                    activityLogs.removeAll()
                    ics214Activities.removeAll()
                    ics214ActivityLogs.removeAll()
                    
                    for log in ics214.ics214ActivityDetail as! Set<ICS214ActivityLog> {
                        
                        let ics214GuidA = log.ics214Guid
                        if ics214GuidA == "" {
                            log.ics214Guid = ics214Guid
                            do {
                                try context.save()
                                DispatchQueue.main.async {
                                    self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"ICS214+EXTENSION merge that"])
                                }
                            } catch let error as NSError {
                                print("ICS214DetailViewControllerTVC line 959 Fetch Error: \(error.localizedDescription)")
                            }
                        }
                        
                        let activityLog = log.ics214ActivityLog ?? ""
                        let activityStringDate = log.ics214ActivityStringDate ?? ""
                        let activityDate = log.ics214ActivityDate ?? Date()
                        let a1 = ActivityCaptured.init(log: activityLog, logDateString: activityStringDate, logDate: activityDate)
                        
                        if !ics214Activities.contains(a1!) {
                            ics214Activities.append(a1!)
                            ics214ActivityLogs.append(log)
                            
                            let obID = NSManagedObjectID()
                            let logDate = activityDate
                            let cellEntered = ICS214Cell3Entered.init(header: "", date: logDate, id: obID)
                            cellEntered.field1 = activityStringDate
                            cellEntered.field2 = activityLog
                            
                            let e:Int = theCells.firstIndex(where: { $0.tag == 10 })!
                            let t:Int = e+1
                            theCells.insert(cellEntered, at: t)
                        
                        }
                    }

//                    if !logA.isEmpty {
//                        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ICS214ActivityLog")
//                        let predicate = NSPredicate(format: "%K == %@", "ics214Guid", ics214Guid)
//                        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
//                        fetchRequest.returnsObjectsAsFaults = false
//                        fetchRequest.predicate = predicateCan
//
//                        do {
//                            let fetched = try context.fetch(fetchRequest) as! [ICS214ActivityLog]
//                            if fetched.isEmpty {
//                                print("no activity logs availalble for this guid \(ics214Guid ?? "no guid available")")
//                                return
//                            } else {
//                                for activity:ICS214ActivityLog in fetched {
//                                    let activityLog = activity.ics214ActivityLog ?? ""
//                                    let activityStringDate = activity.ics214ActivityStringDate ?? ""
//                                    let activityDate = activity.ics214ActivityDate ?? Date()
//                                    let a1 = ActivityCaptured.init(log: activityLog, logDateString: activityStringDate, logDate: activityDate)
//                                    ics214Activities.append(a1!)
//                                    ics214ActivityLogs.append(activity)
//
//                                    let obID = NSManagedObjectID()
//                                    let logDate = activityDate
//                                    let cellEntered = ICS214Cell3Entered.init(header: "", date: logDate, id: obID)
//                                    cellEntered.field1 = activityStringDate
//                                    cellEntered.field2 = activityLog
//
//                                    let e:Int = theCells.index(where: { $0.tag == 10 })!
//                                    let t:Int = e+1
//                                    theCells.insert(cellEntered, at: t)
//                                }
//                            }
//                        } catch {
//                            let nserror = error as NSError
//                            let errorMessage = "ICS214DetailViewController theFormBody() Activities fetch Unresolved error \(nserror)"
//                            print(errorMessage)
//                        }
//                    }
                    
                }
            }
        }
    }
}

//          MARK: -SAVE ICS214 ROUTINES-
extension ICS214DetailViewController {
    
    @objc func saveICS214(_ sender:Any) {
        nims.ics214IncidentName = ics214stucture.incidentName
        nims.ics214UserName = ics214stucture.unitLeader
        nims.ics214ICSPosition = ics214stucture.icsPosition
        nims.ics241HomeAgency = ics214stucture.icsUnitName
        nims.ics214FromTime = ics214stucture.dateFrom
        if ics214stucture.dateTo != nil {
            nims.ics214ToTime = ics214stucture.dateTo
        }
        nims.icsPreparfedName = ics214stucture.preparedByName
        nims.icsPreparedPosition = ics214stucture.preparedPosition
        //        TODO: -AUTOGRAPH
        if signatureDate != nil {
            nims.ics214SignatureDate = signatureDate
        }
        if signatureBool {
            if signatureImage != nil {
                if let imageD = signatureImage!.pngData() as NSData? {
                    nims.ics214Signature = imageD as Data
                }
            }
            nims.ics214SignatureAdded = true
        }
        nims.ics214BackedUp = false
        nims.ics214ModDate = Date()
        for ( _, activity ) in activities.enumerated() {
            let guid2:String = activity.activityGuid["guidValue"] ?? ""
            var guid = ""
            if let g = nims.ics214Guid {
                guid = g
            }
            
            let count = theCountForLogs(guid: guid, guid2: guid2)
            
            if count == 0 {
//                let fjuActivityLog = ICS214ActivityLog.init(entity: NSEntityDescription.entity(forEntityName: "ICS214ActivityLog", in: context)!, insertInto: context)
//                fjuActivityLog.ics214AcivityModDate = Date()
//                fjuActivityLog.ics214ActivityBackedUp = false
//                fjuActivityLog.ics214ActivityChanged = true
//                fjuActivityLog.ics214ActivityCreationDate = Date()
//                fjuActivityLog.ics214ActivityDate = activity.activityDate["datedvalue"] ?? Date()
//                fjuActivityLog.ics214ActivityGuid = activity.activityGuid["guidValue"] ?? ""
//                fjuActivityLog.ics214ActivityLog = activity.activity["logvalue"] ?? ""
//                fjuActivityLog.ics214ActivityStringDate = activity.activityDateString["datevalue"] ?? ""
//                fjuActivityLog.ics214Guid = guid
//                nims.addToIcs214ActivityDetail(fjuActivityLog)
//                saveToCDForActivityLog(guid: guid)
            }
        }
        
        saveToCD()
        getTheRightOrder()
        
         tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
    }
    
    fileprivate func saveToCD() {
        do {
            try context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"ICS214+EXTENSION merge that"])
            }
            DispatchQueue.main.async {
                self.nc.post(name: Notification.Name(rawValue: FJkRELOADTHELIST),
                             object: nil, userInfo: ["shift":MenuItems.ics214])
                
                self.nc.post(name: NSNotification.Name(rawValue: notificationKeyMODIFIED), object: nil, userInfo:["objectID":self.nims.objectID])
                
            }
        } catch let error as NSError {
            print("ICS214DetailViewControllerTVC line 639 Fetch Error: \(error.localizedDescription)")
            
        }
    }
    
    private func getTheRightOrder() {
        var theGathered = [CellStorage]()
        var theStationary = [CellStorage]()
        for cells in theCells {
            if cells.tag == 16 {
                theGathered.append(cells)
            } else {
                theStationary.append(cells)
            }
        }
        theCells.removeAll()
        theCells = theStationary
        theGathered = theGathered.sorted(by: { $0.field1 > $1.field1 })
        for cell in theGathered {
            let i:Int = theCells.firstIndex(where: { $0.tag == 6 })!
            let d:Int = i+1
            theCells.insert(cell, at: d)
        }
    }
    
    fileprivate func saveToCDForPersonnel(guid:String) {
        do {
            try context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"ICS214+EXTENSION merge that"])
            }
            DispatchQueue.main.async {
                let objectID = self.getTheLastSavedICS214Personnel(guid: guid)
                self.nc.post(name: Notification.Name(rawValue: FJkNEWICS214PERSONNEL_TOCLOUDKIT),
                             object: nil, userInfo: ["objectID":objectID])
            }
        } catch {
            let nserror = error as NSError
            print("ICS214Personnel The context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo)")
        }
    }
    
    private func getTheLastSavedICS214Personnel(guid: String)->NSManagedObjectID {
        var objectID: NSManagedObjectID!
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ICS214Personnel" )
        let predicate = NSPredicate(format: "%K = nil", "ics214PersonnelCKR")
        let predicate2 = NSPredicate(format: "%K == %@", "ics214PersonelGuid", guid)
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate,predicate2])
        fetchRequest.predicate = predicateCan
        fetchRequest.fetchBatchSize = 1
        do {
            let fetched = try context.fetch(fetchRequest) as! [ICS214Personnel]
            let ics214Personnel = fetched.last
            objectID = ics214Personnel?.objectID
            return objectID
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        return objectID
    }
    
    private func theCountForLogs(guid: String, guid2: String)->Int {
        let attribute = "ics214Guid"
        let entity = "ICS214ActivityLog"
        let subAttribute = "ics214ActivityGuid"
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        let predicate = NSPredicate(format: "%K == %@", attribute, guid)
        let predicate2 = NSPredicate(format: "%K == %@", subAttribute, guid2)
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate,predicate2])
        fetchRequest.predicate = predicateCan
        do {
            let count = try context.count(for:fetchRequest)
            return count
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return 0
        }
    }
    
    private func theCountForAttendee(guid: String, guid2: String)->Int {
        let attribute = "ics214Guid"
        let entity = "ICS214Personnel"
        let subAttribute = "userAttendeeGuid"
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        let predicate = NSPredicate(format: "%K == %@", attribute, guid)
        let predicate2 = NSPredicate(format: "%K == %@", subAttribute, guid2)
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate,predicate2])
        fetchRequest.predicate = predicateCan
        do {
            let count = try context.count(for:fetchRequest)
            return count
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return 0
        }
    }
}
