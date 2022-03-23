//
//  NewICS214NewIncidentTVC+Extension.swift
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

extension NewICS214NewIncidentTVC {
    
//    MARK: -USERFDResources-
    func getTheUserFDResources() {
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
                    }
                    
                }
            }  catch {
                let nserror = error as NSError
                let errorMessage = "SettingsUserFDResourcesTVC getUserFDResources Unresolved error \(nserror), \(nserror.userInfo)"
                print(errorMessage)
            }
        }
        
       func getTheUser() {
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
//            MARK: -LOCATION-
            /// incidentLocation archived by SecureCoding
            if incidentStructure.incidentLocation != nil {
                if let location = incidentStructure.incidentLocation {
                    do {
                        let data = try NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: true)
                        fjuIncident.incidentLocationSC = data as NSObject
                    } catch {
                        print("got an error here")
                    }
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
//            MARK: -STRING-
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
//                TODO - CHANGE TO WORK WITH ICS
                getTheLastSaved(entity: "Incident", attribute: "fjpIncGuidForReference", sort: "incidentCreationDate")
                DispatchQueue.main.async {
                    self.nc.post(name:Notification.Name(rawValue:FJkCKNewIncidentCreated),
                            object: nil,
                            userInfo: ["objectID":self.objectID as NSManagedObjectID])
                }
                DispatchQueue.main.async {
                    self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                }
                delegate?.theNewICS214IncidentModalSaved(ojectID: self.objectID, shift: MenuItems.ics214Incident)
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

extension NewICS214NewIncidentTVC: ModalHeaderSaveDismissDelegate {

    
    func modalInfoBTapped(myShift: MenuItems) {
//        <#code#>
    }
    


    func modalDismiss() {
        delegate?.newICS214NewIncidentCanceled()
    }
    
    func modalSave(myShift: MenuItems) {
        saveTheIncident()
    }
}

extension NewICS214NewIncidentTVC: LabelTextFieldCellDelegate {
    func incidentLabelTFEditing(text:String, myShift: MenuItems, type: IncidentTypes){}
    func incidentLabelTFFinishedEditing(text:String,myShift:MenuItems, type: IncidentTypes){}
    func labelTextFieldEditing(text: String, myShift: MenuItems){
        incidentStructure.incidentNumber = text
    }
    func labelTextFieldFinishedEditing(text: String, myShift: MenuItems){
        incidentStructure.incidentNumber = text
    }
    func userInfoTextFieldEditing(text:String, myShift: MenuItems, journalType: JournalTypes ){}
    func userInfoTextFieldFinishedEditing(text:String, myShift: MenuItems, journalType: JournalTypes ){}
}

extension NewICS214NewIncidentTVC: LabelDateTimeButtonCellDelegate {
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

extension NewICS214NewIncidentTVC: DatePickerDelegate {
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

extension NewICS214NewIncidentTVC: SegmentCellDelegate {
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

extension NewICS214NewIncidentTVC: AddressFieldsButtonsCellDelegate {
    
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

extension NewICS214NewIncidentTVC: MapViewCellDelegate {
    
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
extension NewICS214NewIncidentTVC: FDResourceIncidentCellDelegate {
    
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

extension NewICS214NewIncidentTVC: ModalFDResourcesDataDelegate {
    
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

extension NewICS214NewIncidentTVC: LabelYesNoSwitchCellDelegate {
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

extension NewICS214NewIncidentTVC: LabelWithInfoCellDelegate {
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
