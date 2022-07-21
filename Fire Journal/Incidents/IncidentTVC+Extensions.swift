    //
    //  IncidentTVC+Extensions.swift
    //  Fire Journal
    //
    //  Created by DuRand Jones on 4/23/19.
    //  Copyright © 2020 PureCommand, LLC. All rights reserved.
    //

    import UIKit
    import Foundation
    import CoreData
    import MapKit
    import CoreLocation
    import T1Autograph

    //   MARK: -IncidentPOVNotesDelegate
    extension IncidentTVC: IncidentPOVNotesDelegate {
        func incidentPOVNotesCanceled() {
            self.dismiss(animated: true, completion: nil)
        }
        
        func incidentPOVNotesSaved(data: IncidentData) {
            self.dismiss(animated: true, completion: nil)
            incidentStructure.incidentPersonalJournalReference = data.incidentPersonalJournalReference
            let indexPath = IndexPath(row: 10, section: 0)
            //        let cell = tableView.cellForRow(at: indexPath) as! IncidentNotesTextViewCell
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        func presentPOVModal(data: IncidentData) {
            slideInTransitioningDelgate.direction = .bottom
            slideInTransitioningDelgate.disableCompactHeight = true
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let dataTVC = storyBoard.instantiateViewController(withIdentifier: "IncidentPOVNotesTVC") as! IncidentPOVNotesTVC
            dataTVC.delegate = self
            dataTVC.transitioningDelegate = slideInTransitioningDelgate
            dataTVC.modalPresentationStyle = .custom
            dataTVC.incidentStructure = IncidentData.init()
            dataTVC.incidentStructure = incidentStructure
            if incidentStructure.incidentPersonalJournalReference != "" {
                dataTVC.guidOrNot = true
            } else {
                dataTVC.guidOrNot = false
            }
            self.present(dataTVC, animated: true, completion: nil)
        }
        
    }

    //  MARK: -MapFormHeaderVDelegate-
    extension IncidentTVC: MapFormHeaderVDelegate {
        
        func mapFormHeaderBackBTapped(type: IncidentTypes) {
            if (Device.IS_IPHONE) {
                if fju != nil {
                    let id = fju.objectID
                    vcLaunch.mapCalledPhone(type: type, theUserOID: id)
                }
            } else {
                if fju != nil {
                    let id = fju.objectID
                vcLaunch.mapCalled(type: type, theUserOID: id )
                }
            }
        }
        
        func mapFormHeaderSaveBTapped() {
            saveTheIncident()
        }
        
    }

    //   MARK: -IncidentInfoModalTVCDelegate
    extension IncidentTVC: IncidentInfoModalTVCDelegate {
        func incidentInfoUpdateCancelled() {
            self.dismiss(animated: true, completion: nil)
        }
        
        func incidentInfoUpdated(incidentStructured: IncidentData) {
            self.dismiss(animated: true, completion: nil)
            incidentStructure.incidentNumber = incidentStructured.incidentNumber
            incidentStructure.incidentFullAlarmDateS = incidentStructured.incidentFullAlarmDateS
            incidentStructure.incidentFullDateS = incidentStructured.incidentFullAlarmDateS
            incidentStructure.incidentAlarmdd = incidentStructured.incidentAlarmdd
            incidentStructure.incidentAlarmHH = incidentStructured.incidentAlarmHH
            incidentStructure.incidentAlarmMM = incidentStructured.incidentAlarmMM
            incidentStructure.incidentAlarmmm = incidentStructured.incidentAlarmmm
            incidentStructure.incidentAlarmDate = incidentStructured.incidentAlarmDate
            incidentStructure.incidentAlarmYYYY = incidentStructured.incidentAlarmYYYY
            incidentStructure.incidentFullAddress = incidentStructured.incidentFullAddress
            incidentStructure.incidentStreetNum = incidentStructured.incidentStreetNum
            incidentStructure.incidentStreetName = incidentStructured.incidentStreetName
            incidentStructure.incidentCity = incidentStructured.incidentCity
            incidentStructure.incidentState = incidentStructured.incidentState
            incidentStructure.incidentZip = incidentStructured.incidentZip
            incidentStructure.incidentLocation = incidentStructured.incidentLocation
            incidentStructure.incidentLatitude = incidentStructured.incidentLatitude
            incidentStructure.incidentLongitude = incidentStructured.incidentLongitude
            let num = incidentStructure.incidentStreetNum
            let street = incidentStructure.incidentStreetName
            let city = incidentStructure.incidentCity
            let state = incidentStructure.incidentState
            let zip = incidentStructure.incidentZip
            incidentStructure.incidentFullAddress = "\(num) \(street) \(city),\(state) \(zip)"
            saveTheIncident()
            tableView.reloadData()
        }
    }
    //    MARK: -ControllerLabelCellDelegate
    extension IncidentTVC: ControllerLabelCellDelegate {
        func incidentInfoBTapped() {
            print("I've been tapped incidentInfoBTapped()")
            slideInTransitioningDelgate.direction = .bottom
            slideInTransitioningDelgate.disableCompactHeight = true
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let dataTVC = storyBoard.instantiateViewController(withIdentifier: "IncidentInfoModalTVC") as! IncidentInfoModalTVC
            dataTVC.delegate = self
            dataTVC.incidentStructure = IncidentData.init()
            dataTVC.incidentStructure = incidentStructure
            dataTVC.transitioningDelegate = slideInTransitioningDelgate
            dataTVC.modalPresentationStyle = .custom
            self.present(dataTVC, animated: true, completion: nil)
        }
    }

    //    MARK: -NFIRSLabelTimeButtonDelegate
    extension IncidentTVC: NFIRSLabelTimeButtonDelegate {
        func nfirsTimeBTapped(type: IncidentTypes) {
            switch type {
            case .nfirsSecMOfficersDate:
                if showPickerSecMOfficer {
                    showPickerSecMOfficer = false
                } else {
                    showPickerSecMOfficer = true
                }
            case .nfirsSecMMembersDate:
                if showPickerSecMMember {
                    showPickerSecMMember = false
                } else {
                    showPickerSecMMember = true
                }
            default: break
            }
            tableView.reloadSections(NSIndexSet(index: 13) as IndexSet, with: .automatic)
        }
    }

    //    MARK: -NFIRSSignatureCellDelegate-
    //    MARK: -T1AutogeraphDelegate-
    extension IncidentTVC: NFIRSSignatureCellDelegate,T1AutographDelegate {
        func signatureBTapped(type: IncidentTypes) {
            nfirsSigType = type
            switch type {
            case .nfirsSecMOfficerSignature:
                autographOfficer = T1Autograph.autograph(withDelegate: self, modalDisplay: "Officer Signature") as! T1Autograph
                
                // Enter license code here to remove the watermark
                autographOfficer.licenseCode = "9186d2059ae047426bd0c571a0cf637ef569a6c4"
                
                // any optional configuration done here
                autographOfficer.showDate = false
                autographOfficer.strokeColor = UIColor.darkGray
                signatureType = "Officer"
            case .nfirsSecMMembersSignature:
                autographMember = T1Autograph.autograph(withDelegate: self, modalDisplay: "Member Signature") as! T1Autograph
                
                // Enter license code here to remove the watermark
                autographMember.licenseCode = "9186d2059ae047426bd0c571a0cf637ef569a6c4"
                
                // any optional configuration done here
                autographMember.showDate = false
                autographMember.strokeColor = UIColor.darkGray
                signatureType = "Member"
            default:
                break
            }
        }
        
        //    MARK: -T1AutographDelegate-
        func autograph(_ autograph: T1Autograph!, didCompleteWith signature: T1Signature!) {
            switch nfirsSigType {
            case .nfirsSecMOfficerSignature?:
                let image: UIImage = UIImage(data:signature.imageData,scale:1.0)!
                incidentStructure.incidentNFIRSSecMOfficiersSignature = signature.imageData
                theOfficerSignatureB = true
                incidentStructure.incidentNFIRSSecMOfficiersSignatureB = true
                incidentStructure.incidentNFIRSSecMOfficiersSignatureI = image
                let date = Date()
                incidentStructure.incidentNFIRSSecMOfficiersSignatureDate = date
                incidentStructure.incidentNFIRSSecMOfficiersSignatureDateS = vcLaunch.fullDateString(date:date)
                incidentStructure.incidentNFIRSSecMOfficersSignatureDateMM = vcLaunch.monthString(date: date)
                incidentStructure.incidentNFIRSSecMOfficersSignatureDateDD = vcLaunch.dayString(date: date)
                incidentStructure.incidentNFIRSSecMOfficersSignatureDateYYYY = vcLaunch.yearString(date: date)
            case .nfirsSecMMembersSignature?:
                let image: UIImage = UIImage(data:signature.imageData,scale:1.0)!
                incidentStructure.incidentNFIRSSecMMembersSignature = signature.imageData
                theMemberMakingSignatureB = true
                incidentStructure.incidentNFIRSSecMMembersSignatureB = true
                incidentStructure.incidentNFIRSSecMMembersSignatureI = image
                let date = Date()
                incidentStructure.incidentNFIRSSecMMembersSignatureDate = date
                incidentStructure.incidentNFIRSSecMMembersSignatureDateS = vcLaunch.fullDateString(date:date)
                incidentStructure.incidentNFIRSSecMMembersSignatureDateMM = vcLaunch.monthString(date: date)
                incidentStructure.incidentNFIRSSecMMembersSignatureDateDD = vcLaunch.dayString(date: date)
                incidentStructure.incidentNFIRSSecMMembersSignatureDateYYYY = vcLaunch.yearString(date: date)
            default:break
            }
            tableView.reloadData()
        }
        func autographDidCancelModalView(_ autograph: T1Autograph!) {
            NSLog("Autograph modal signature has been cancelled")
            switch nfirsSigType {
            case .nfirsSecMOfficerSignature?:
                incidentStructure.incidentNFIRSSecMOfficiersSignature = nil
                incidentStructure.incidentNFIRSSecMOfficiersSignatureB = false
                incidentStructure.incidentNFIRSSecMOfficiersSignatureI = nil
                theOfficerSignatureB = false
            case .nfirsSecMMembersSignature?:
                incidentStructure.incidentNFIRSSecMMembersSignature = nil
                incidentStructure.incidentNFIRSSecMMembersSignatureB = false
                incidentStructure.incidentNFIRSSecMMembersSignatureI = nil
                theMemberMakingSignatureB = false
            default:break
            }
            tableView.reloadData()
        }
        
        func autographDidCompleteWithNoSignature(_ autograph: T1Autograph!) {
            NSLog("User pressed the done button without signing")
            switch nfirsSigType {
            case .nfirsSecMOfficerSignature?:
                incidentStructure.incidentNFIRSSecMOfficiersSignature = nil
                incidentStructure.incidentNFIRSSecMOfficiersSignatureB = false
                theOfficerSignatureB = false
                incidentStructure.incidentNFIRSSecMOfficiersSignatureI = nil
            case .nfirsSecMMembersSignature?:
                incidentStructure.incidentNFIRSSecMMembersSignature = nil
                incidentStructure.incidentNFIRSSecMMembersSignatureB = false
                theMemberMakingSignatureB = false
                incidentStructure.incidentNFIRSSecMMembersSignatureI = nil
            default:break
            }
            tableView.reloadData()
        }
        
        func autograph(_ autograph: T1Autograph!, didEndLineWithSignaturePointCount count: UInt) {
            NSLog("Line ended with total signature point count of %d", count)
        }
        
        func autograph(_ autograph: T1Autograph!, willCompleteWith signature: T1Signature!) {
            NSLog("Autograph will complete with signature")
        }
    }

    //    MARK: -LabelInstructionWSwitchDelegate-
    extension IncidentTVC: LabelInstructionWSwitchDelegate {
        func onOffSwitchWasTapped(type: MenuItems,yesNoB: Bool) {
            switch type {
            case .nfirsSecGInstruction1:
                instructionOnOff = yesNoB
            case .nfirsSecGInstruction2:
                instruction2OnOff = yesNoB
            case .nfirsSecGInstruction3:
                instruction3OnOff = yesNoB
            case .nfirsSecHInstruction1:
                nfirsSecHInstruction1Off = yesNoB
            case .nfirsSecHInstruction2:
                nfirsSecHInstruction2Off = yesNoB
            case .nfirsSecJPULookUp:
                incidentStructure.incidentNFIRSSecJPULookup = yesNoB
            case .nfirsSecKSameAddress:
                incidentStructure.incidentNFIRSSecKSameAddress = yesNoB
            case .nfirsSecLRemarksB:
                incidentStructure.incidentNFIRSSecLRemarksMoreB = yesNoB
            case .nfirsSecMSameAsOfficer:
                incidentStructure.incidentNFIRSSecMOfficerMakingReportB = yesNoB
            default:
                break
            }
            tableView.reloadData()
        }
    }

    //    MARK: -NFIRSLabelDateTimeButtonDelegate-
    extension IncidentTVC: NFIRSLabelDateTimeButtonDelegate {
        
        func nfirsDateBTapped(type: IncidentTypes){
            switch type {
            case .nfirsArrival:
                if showPickerSecEArrive {
                    showPickerSecEArrive = false
                } else {
                    showPickerSecEArrive = true
                }
            case .nfirsLastUnit:
                if showPickerSecELastUnit {
                    showPickerSecELastUnit = false
                } else {
                    showPickerSecELastUnit = true
                }
            case .nfirsControlled:
                if showPickerSecEControlled {
                    showPickerSecEControlled = false
                } else {
                    showPickerSecEControlled = true
                }
            default:
                break
            }
            tableView.reloadSections(NSIndexSet(index: 5) as IndexSet, with: .automatic)
        }
        
        func nfirsAlarmSameBTapped(type: IncidentTypes){
            if incidentStructure.incidentFullAlarmDateS != "" {
                switch type {
                case .nfirsArrival:
                    incidentStructure.nfirsTimesTheSame(type:.nfirsArrival)
                case .nfirsControlled:
                    incidentStructure.nfirsTimesTheSame(type:.nfirsControlled)
                case .nfirsLastUnit:
                    incidentStructure.nfirsTimesTheSame(type:.nfirsLastUnit)
                default:
                    break
                }
            }
            tableView.reloadSections(NSIndexSet(index: 5) as IndexSet, with: .automatic)
        }
        
    }

    //    MARK: -IncidentTFwDirectionalSwitchCellDelegate-
    //    TODO: need to complete
    extension IncidentTVC: IncidentTFwDirectionalSwitchCellDelegate {
        func incidentDirectionalTapped(type: IncidentTypes,myShift:MenuItems) {}
        func incidentTFSwitchTapped(type: IncidentTypes,myShift:MenuItems) {}
    }

    //    MARK: -LabelTextFieldCellDelegate-
    //    TODO: need to complete
    extension IncidentTVC: LabelTextFieldCellDelegate {
        func labelTextFieldEditing(text: String, myShift: MenuItems){
            switch myShift {
            case .incidents:
                incidentStructure.incidentNumber = text
            default:break
            }
        }
        func labelTextFieldFinishedEditing(text: String, myShift: MenuItems, tag: Int){
            switch myShift {
            case .incidents:
                incidentStructure.incidentNumber = text
            default:
                print("NO TEXT")
            }
        }
        
        func incidentLabelTFEditing(text:String, myShift: MenuItems, type: IncidentTypes){}
        func incidentLabelTFFinishedEditing(text:String,myShift:MenuItems, type: IncidentTypes){}
        
        func userInfoTextFieldEditing(text:String, myShift: MenuItems, journalType: JournalTypes ){}
        func userInfoTextFieldFinishedEditing(text:String, myShift: MenuItems, journalType: JournalTypes ){}
    }

    //    MARK: LabelDateTimeButtonCellDelegate-
    extension IncidentTVC: LabelDateTimeButtonCellDelegate {
        func dateTimeButtonTapped(type: IncidentTypes) {
            switch type {
            case .nfirsAlarm:
                if showPickerSecEAlarm {
                    showPickerSecEAlarm = false
                    if (incidentStructure != nil) {
                        let date = Date()
                        _ = incidentStructure.incidentDateTime(type:.alarm,date:date)
                    }
                } else {
                    showPickerSecEAlarm = true
                }
                tableView.reloadSections(NSIndexSet(index: 5) as IndexSet, with: .automatic)
            case .nfirsSecMOfficersDate:
                if showPickerSecMOfficer {
                    showPickerSecMOfficer = false
                    if incidentStructure != nil {
                        let date = Date()
                        _ = incidentStructure.incidentDateTime(type:IncidentTypes.nfirsSecMOfficersDate,date: date)
                    }
                } else {
                    showPickerSecMOfficer = true
                }
                tableView.reloadData()
            default:
                if showPickerSec1 {
                    showPickerSec1 = false
                    if (incidentStructure != nil) {
                        let date = Date()
                        _ = incidentStructure.incidentDateTime(type:IncidentTypes.alarm,date: date)
                    }
                } else {
                    showPickerSec1 = true
                }
                tableView.reloadData()
            }
        }
    }

    //      MARK: -NFIRSsectionHeaderTHFVDelegate-
    extension IncidentTVC: NFIRSsectionHeaderTHFVDelegate {
        func theSectionBTapped(header: NFIRSsectionHeaderTHFV, section: Int, collapsed: Bool, rowCount: Int) {
            var data = theSections[section]
            if data.isCollapsible {
                let collapse = !data.isCollapsed
                data.isCollapsed = collapse
                sectionOpen = data.section
                sectionCollapsed = !collapse
                header.setCollapsed(collapsed: collapse)
                tableView.reloadSections([section], with: .none)
            }
        }
    }

    //    MARK: -IncidentNotesTextViewCellDelegate-
    extension IncidentTVC: IncidentNotesTextViewCellDelegate {
        
        private func incidentNotesUpdate() {
            let indexPath = IndexPath(row: 11, section: 0)
            let cell = tableView.cellForRow(at: indexPath) as! IncidentNotesTextViewCell
            let size = CGSize(width: cell.descriptionTV.frame.width, height: .infinity)
            let estimatedSize = cell.descriptionTV.sizeThatFits(size)
            
            incidentNotesHeight = estimatedSize.height + 80
            tableView.beginUpdates()
            cell.descriptionTV.constraints.forEach { (constraint) in
                if constraint.firstAttribute == .height {
                    if Device.IS_IPAD {
                        constraint.constant = estimatedSize.height
                    } else {
                        if estimatedSize.height < 400 {
                            constraint.constant = estimatedSize.height
                        } else {
                            constraint.constant = 400
                        }
                    }
                }
                
            }
            tableView.endUpdates()
        }
        
        func incidentTextViewEditing(text: String, myShift: MenuItems, incidentType: IncidentTypes){
            incidentStructure.incidentNotes = text
            incidentNotesUpdate()
        }
        
        func incidentTextViewDoneEditing(text: String, myShift: MenuItems, incidentType: IncidentTypes){
            self.resignFirstResponder()
            incidentStructure.incidentNotes = text
            incidentNotesUpdate()
        }
        
        
        func supportNotesBTapped() {
            presentPOVModal(data: incidentStructure)
        }
        
        func incidentAndSupportNotesInfoBTapped() {
            if !alertUp {
                let message: InfoBodyText = .incidentAndSupportNotes
                let title: InfoBodyText = .incidentAndSupportNotesSubject
                let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
                let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
                    self.alertUp = false
                })
                alert.addAction(okAction)
                alertUp = true
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }


    //    MARK: -TagsTVCDelegate
    extension IncidentTVC: TagsTVCDelegate {
        
        func theCancelTagsBTapped() {
            self.dismiss(animated: true, completion: nil)
        }
        
        func theTagsHaveBeenChosen(tags:Array<String>) {
            theTags = tags.filter { $0 != "" }
            let tag:String = theTags.joined(separator: ", ")
            incidentStructure.incidentTags = tag
            incidentStructure.incidentTagsA = theTags
            tableView.reloadData()
        }
    }

    //    MARK: -CrewModalTVCDelegate
    extension IncidentTVC: CrewModalTVCDelegate {
        
        func theCrewModalCancelTapped() {
            self.dismiss(animated: true, completion: nil)
        }
        
        func theCrewModalChosenTapped(crew: TheCrew, objectID: NSManagedObjectID) {
            theUserCrew = context.object(with: objectID) as? UserCrews
            let members = crew.crew
            incidentStructure.incidentCrewCombine = " \(members)"
            incidentStructure.incidentCrewName = crew.crewName
            incidentStructure.incidentCrew = crew.crew
            incidentStructure.incidentCrewA = crew.crew.components(separatedBy: ",")
            theCrew = crew
            self.dismiss(animated: true, completion:nil)
            tableView.reloadData()
        }
    }

    //    MARK: -ModalResourcesTVCDelegate
    extension IncidentTVC: ModalResourcesTVCDelegate {
        
        func theModalResourceCancelHasBeenTapped(){
            self.dismiss(animated: true, completion: nil)
        }
        
        func theResourcesChoiceHasBeenMade(resourceGroup: ResourcesItem, objectID: NSManagedObjectID ){
            incidentStructure.incidentResources = resourceGroup.resourceString
            incidentStructure.incidentResourcesName = resourceGroup.resourceGroupName
            let groupString = resourceGroup.resourceString
            incidentStructure.incidentResourcesCombined = "\(groupString)"
            incidentStructure.incidentResourcesA = resourceGroup.resources
            group = resourceGroup
            self.dismiss(animated: true, completion:nil)
            tableView.reloadData()
        }
    }

    //      MARK: -ModalDataTVCDelegate-
extension IncidentTVC: ModalDataTVCDelegate {
    
    func theModalDataTapped(object: NSManagedObjectID, type: IncidentTypes, index: IndexPath) {
    }
    
        
        func theModalDataCancelTapped() {
            self.dismiss(animated: true, completion: nil)
        }
        
        func theDataTVCCancelled() {
            self.dismiss(animated: true, completion: nil)
        }
        
        func theModalDataTapped(object:NSManagedObject,type:IncidentTypes){
                    }
        
        func theModalDataWithTapped(type: IncidentTypes) {
            switch type {
            case .tags:
                incidentStructure.incidentTags = "Emergency, September, E76"
            case .crew:
                incidentStructure.incidentCrew = "FF Barrett, FF Cameron, Captain Smith, EMT Marks, EMT Smith"
            case .nfirsIncidentType:
                incidentStructure.incidentNfirsIncidentType = "121 Fire in mobile home used as a fixed residence. Includes mobile homes when not in transit and used as a structure for residential purposes; and manufactured homes built on a permanent chassis."
            case .localIncidentType:
                incidentStructure.incidentLocalType = "Structure Fire"
            case .locationType:
                incidentStructure.incidentLocationType = "Street Address"
            case .streetType:
                incidentStructure.incidentStreetType = "RD Road"
            case .streetPrefix:
                incidentStructure.incidentStreetPrefix = "N"
            //        case .resources:
            //            incidentStructure.incidentResources = "E76, Bike1, DIV2"
            case .firstAction:
                incidentStructure.incidentAction1No = "20"
                incidentStructure.incidentAction1S = "Search and rescue, other."
            case .secondAction:
                incidentStructure.incidentAction2No = "10"
                incidentStructure.incidentAction3S = "Fire control or extinguishment, other."
            default:
                print("none of the above")
            }
            self.tableView.reloadData()
            self.dismiss(animated: true, completion: nil)
        }
        
        func theJournalDataSaveTapped(type: JournalTypes,user:UserEntryInfo) {}
        
    }

    //   MARK: -IncidentShortTVWithDirectionalCellDelegate-
    extension IncidentTVC: IncidentShortTVWithDirectionalCellDelegate {
        
        func shortTVDirectionalTapped(type: IncidentTypes) {
            switch type {
            case .nfirsIncidentType:
                presentModal(menuType: myShift, title: "NFIRS Incident Types", type: type)
            case .crew:
                presentCrew(menuType: myShift, title: "Crew", type: type)
            case .tags:
                presentTags(menuType: myShift, title: "Tags", type: type)
            default:
                print("nothing here")
            }
        }
        
        func shortTVBeganEditing(text: String, type: IncidentTypes) {
            switch type {
            case .nfirsIncidentType:
                incidentStructure.incidentNfirsIncidentType = text
            case .crew:
                incidentStructure.incidentCrew = text
            case .tags:
                incidentStructure.incidentTags = text
            default:
                print("no incidenttype")
            }
            
            self.tableView.reloadData()
        }
        
        func shortTVDoneEditing(text: String, type: IncidentTypes) {
            switch type {
            case .nfirsIncidentType:
                incidentStructure.incidentNfirsIncidentType = text
            case .crew:
                incidentStructure.incidentCrew = text
            case .tags:
                incidentStructure.incidentTags = text
            default:
                print("no incidenttype")
            }
            
            self.tableView.reloadData()
        }
        
        func shortTVNFIRSIncidentTyped(code: String) {
            if code.count == 3 {
                let prefix = String(code.prefix(1))
                let entity = "NFIRSIncidentType"
                let attribute = "incidentTypeNumber"
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
                var predicate = NSPredicate.init()
                predicate = NSPredicate(format: "%K = %@",attribute,code)
                fetchRequest.predicate = predicate
                fetchRequest.fetchBatchSize = 1
                do {
                    self.fetched = try context.fetch(fetchRequest) as! [NFIRSIncidentType]
                    if !self.fetched.isEmpty {
                        let nfirsIncidentType = self.fetched.last as! NFIRSIncidentType
                        var number: String = ""
                        var name: String = ""
                        if let nfirsNum = nfirsIncidentType.incidentTypeNumber {
                            number = nfirsNum
                        }
                        if let nfirsName = nfirsIncidentType.incidentTypeName {
                            name = nfirsName
                        }
                        incidentStructure.incidentNFIRSType = "\(name)"
                        incidentStructure.incidentNfirsIncidentType = "\(number) \(name)"
                        incidentStructure.incidentNfirsIncidentTypeNumber = "\(number)"
                        let indexPath = IndexPath(row: 6, section: 0)
                        let cell = tableView.cellForRow(at: indexPath) as! IncidentShortTVWithDirectionalCell
                        cell.descriptionTV.text = incidentStructure.incidentNfirsIncidentType
                        cell.descriptionTV.setNeedsDisplay()
                    } else {
                        if !alertUp {
                            let title: InfoBodyText = .nfirsIncidentTypeErrorSubject
                            let messageBody: InfoBodyText = .nfirsIncidentTypeError
                            let message = "\(code) \(messageBody.rawValue) \(prefix)"
                            let alert = UIAlertController.init(title: title.rawValue, message: message, preferredStyle: .alert)
                            let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
                                self.alertUp = false
                                self.presentModal(menuType: self.myShift, title: "NFIRS Incident Types", type: IncidentTypes.nfirsIncidentType)
                            })
                            alert.addAction(okAction)
                            alertUp = true
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
        }
        
        func shortTVNFIRSInfoBTapped() {
            if !alertUp {
                let title: InfoBodyText = .nfirsIncidentTypeSubject
                let message: InfoBodyText = .nfirsIncidentType
                let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
                let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
                    self.alertUp = false
                })
                alert.addAction(okAction)
                alertUp = true
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }

    //    MARK: -PhotosTVCellDelegate
    //    TODL: -for Camera
    extension IncidentTVC: PhotoTVCellDelegate {
        func cameraButtonTapped() {
            //        <#code#>
        }
    }

    //    MARK: -LabelYesNoSwitchCellDelegate
    extension IncidentTVC: LabelYesNoSwitchCellDelegate {
        
        func labelYesNoSwitchTapped(theShift: MenuItems, yesNoB:Bool,type:IncidentTypes) {
            yesNo = yesNoB
            incidentType = type
            switch type {
            case .arson:
                incidentStructure.incidentArson = yesNo
            case .emergency:
                incidentStructure.incidentEmergencyYesNo = yesNo
                if incidentStructure.incidentEmergencyYesNo {
                    incident.incidentType = "Emergency"
                    incidentStructure.incidentEmergency = "Emergency"
                } else {
                    incident.incidentType = "Non-Emergency"
                    incidentStructure.incidentEmergency = "Non-Emergency"
                }
            case .nfirsSecHCasualties:
                incidentStructure.incidentNFIRSSecHCasualties = yesNoB
            case .nfirsSecHDAlerted:
                incidentStructure.incidentNFIRSSecHDAlerted = yesNoB
            case .nfirsSecHDNotAlerted:
                incidentStructure.incidentNFIRSSecHDNotAlerted = yesNoB
            case .nfirsSecHDUnknown:
                incidentStructure.incidentNFIRSSecHDUnknown = yesNoB
            case .nfirsSecHHRelease:
                incidentStructure.incidentNFIRSSecHHazardRelease = yesNoB
            case .nfirsSecJPropertyUse:
                incidentStructure.incidentNFIRSSecJPropertyUse = yesNoB
            default:break
            }
            self.tableView.reloadData()
        }
    }

    //      MARK: -LabelDoubleTextFieldDirectionalCellDelegate-
    //      TODO: ???
    extension IncidentTVC:  LabelDoubleTextFieldDirectionalCellDelegate {
        
        func twoTFDirectionalBTapped(type:IncidentTypes) {
            switch type {
            case .firstAction:
                presentModal(menuType: myShift, title: "Actions Taken 1", type: type)
            case .secondAction:
                presentModal(menuType: myShift, title: "Actions Taken 2", type: type)
            case .thirdAction:
                presentModal(menuType: myShift, title: "Actions Taken 3", type: type)
            default: break
            }
        }
        
        func theTextFieldHasBeenEdited(text: String, type: UserInfo) {}
        func twoTFBeganEditing(text: String, myShift: MenuItems,incidentType:IncidentTypes) {}
        func twoTFDidFinishEditing(text: String, myShift: MenuItems,incidentType:IncidentTypes) {}
    }

    //      MARK: -MapViewCellDelegate-
    extension IncidentTVC: MapViewCellDelegate {
        
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

    //      MARK: -AddressFieldsButtonsCellDelegate-
    extension IncidentTVC: AddressFieldsButtonsCellDelegate {
        func addressFieldFinishedEditing(address: String, tag: Int) {
            //        TODO:
        }
        
        //    MARK: -AddressFieldsButtonsCellDelegate
        
        func worldBTapped() {
            if showMap {
                showMap = false
            } else {
                showMap = true
            }
            //        tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
            tableView.reloadData()
            if showMap {
                let rowNumber: Int = 2
                let sectionNumber: Int = 0
                let indexPath = IndexPath(item: rowNumber, section: sectionNumber)
                tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
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
        
        func addressHasBeenFinished() {}
        
    }

    //    MARK: -DatePickerDelegate
    extension IncidentTVC: DatePickerDelegate {
        
        func alarmTimeChosenDate(date: Date, incidentType: IncidentTypes) {
            if incidentType == .alarm {
                incidentStructure.incidentFullAlarmDateS = incidentStructure.incidentDateTime(type:IncidentTypes.alarm,date:date)
                self.tableView.reloadData()
            }
        }
        
        func arrivalTimeChosenDate(date: Date, incidentType: IncidentTypes) {
            if incidentType == .arrival {
                incidentStructure.incidentFullArrivalDateS = incidentStructure.incidentDateTime(type:IncidentTypes.arrival,date:date)
                self.tableView.reloadData()
            }
        }
        
        func controlledTimeChosenDate(date: Date, incidentType: IncidentTypes) {
            if incidentType == .controlled {
                incidentStructure.incidentFullControlledDateS = incidentStructure.incidentDateTime(type:IncidentTypes.controlled,date:date)
                self.tableView.reloadData()
            }
        }
        
        func lastUnitTimeChosenDate(date: Date, incidentType: IncidentTypes) {
            if incidentType == .lastunitstanding {
                incidentStructure.incidentFullLastUnitDateS = incidentStructure.incidentDateTime(type:IncidentTypes.lastunitstanding,date:date)
                self.tableView.reloadData()
            }
        }
        
        func nfirsSecMOfficersChosenDate(date: Date, incidentType: IncidentTypes) {
            if incidentType == .nfirsSecMOfficersDate {
                _ = incidentStructure.incidentDateTime(type:IncidentTypes.nfirsSecMOfficersDate,date:date)
            }
            tableView.reloadData()
        }
        
        func nfirsSecMMembersChosenDate(date: Date, incidentType: IncidentTypes) {
            if incidentType == .nfirsSecMMembersDate {
                _ = incidentStructure.incidentDateTime(type:IncidentTypes.nfirsSecMMembersDate,date:date)
            }
            tableView.reloadData()
        }
    }

    //    MARK: -LabelTextViewCellDELEGATE
    extension IncidentTVC: LabelTextViewCellDelegate {
        
        private func textViewUpdate(theRow: Int, incidentType: IncidentTypes) {
            let indexPath = IndexPath(row: theRow, section: 0)
            let cell = tableView.cellForRow(at: indexPath) as! LabelTextViewCell
            let size = CGSize(width: cell.descriptionTV.frame.width, height: .infinity)
            let estimatedSize = cell.descriptionTV.sizeThatFits(size)
            
            switch incidentType {
            case .alarmNote:
                incidentAlarmNotesHeight = estimatedSize.height + 80
            case .arrivalNote:
                incidentArrivalNotesHeight = estimatedSize.height + 80
            case .controlledNote:
                incidentControlledNotesHeight = estimatedSize.height + 80
            case .lastUnitStandingNote:
                incidentLastUnitNotesHeight = estimatedSize.height + 80
            default: break
            }
            
            tableView.beginUpdates()
            cell.descriptionTV.constraints.forEach { (constraint) in
                if constraint.firstAttribute == .height {
                    if Device.IS_IPAD {
                        constraint.constant = estimatedSize.height
                    } else {
                        if estimatedSize.height < 400 {
                            constraint.constant = estimatedSize.height
                        } else {
                            constraint.constant = 400
                        }
                    }
                }
                
            }
            tableView.endUpdates()
        }
        
        func textViewEditing(text: String, myShift: MenuItems, journalType: JournalTypes) {}
        func textViewDoneEditing(text: String, myShift: MenuItems, journalType: JournalTypes) {}
        func textViewEditing(text: String, myShift: MenuItems,incidentType: IncidentTypes) {
            self.incidentType = incidentType
            switch self.incidentType {
            case .incidentNote:
                incidentStructure.incidentNotes = text
            case .alarmNote:
                incidentStructure.incidentAlarmNotes = text
                textViewUpdate(theRow: 14, incidentType: IncidentTypes.alarmNote)
            case .arrivalNote:
                incidentStructure.incidentArrivalNotes = text
                textViewUpdate(theRow: 17, incidentType: IncidentTypes.arrivalNote)
            case .controlledNote:
                incidentStructure.incidentControlledNotes = text
                textViewUpdate(theRow: 20, incidentType: IncidentTypes.controlledNote)
            case .lastUnitStandingNote:
                incidentStructure.incidentLastUnitNotes = text
                textViewUpdate(theRow: 23, incidentType: IncidentTypes.lastUnitStandingNote)
            case .nfirsSecLRemarks:
                incidentStructure.incidentNFIRSSecLRemarks = text
            default: break
            }
        }
        func textViewDoneEditing(text: String, myShift: MenuItems,incidentType: IncidentTypes) {
            self.resignFirstResponder()
            self.incidentType = incidentType
            switch self.incidentType {
            case .incidentNote:
                incidentStructure.incidentNotes = text
            case .alarmNote:
                incidentStructure.incidentAlarmNotes = text
                textViewUpdate(theRow: 14, incidentType: IncidentTypes.alarmNote)
            case .arrivalNote:
                incidentStructure.incidentArrivalNotes = text
                textViewUpdate(theRow: 17, incidentType: IncidentTypes.arrivalNote)
            case .controlledNote:
                incidentStructure.incidentControlledNotes = text
                textViewUpdate(theRow: 20, incidentType: IncidentTypes.controlledNote)
            case .lastUnitStandingNote:
                incidentStructure.incidentLastUnitNotes = text
                textViewUpdate(theRow: 23, incidentType: IncidentTypes.lastUnitStandingNote)
            default: break
            }
            saveTheIncident()
        }
    }

    //    MARK: -TimeAndDateIncidentCellDelegate
    extension IncidentTVC: TimeAndDateIncidentCellDelegate {
        
        func theTimeBWasTapped(incidentType: IncidentTypes) {
            switch incidentType {
            case .arrival:
                if showPicker2 {
                    showPicker2 = false
                    if incidentStructure.incidentArrivalDate != nil {
                        let dateS = incidentStructure.incidentDateTime(type:IncidentTypes.arrival,date: incidentStructure.incidentArrivalDate! )
                        incidentStructure.incidentFullArrivalDateS = dateS
                    } else {
                        let date = Date()
                        let dateS = incidentStructure.incidentDateTime(type:IncidentTypes.arrival,date: date)
                        incidentStructure.incidentFullArrivalDateS = dateS
                    }
                } else {
                    showPicker2 = true
                }
                self.tableView.reloadData()
            case .controlled:
                if showPicker3 {
                    showPicker3 = false
                    if incidentStructure.incidentControlledDate != nil {
                        let dateS = incidentStructure.incidentDateTime(type:IncidentTypes.arrival,date: incidentStructure.incidentControlledDate! )
                        incidentStructure.incidentFullControlledDateS = dateS
                    } else {
                        let date = Date()
                        let dateS = incidentStructure.incidentDateTime(type:IncidentTypes.controlled,date: date)
                        incidentStructure.incidentFullControlledDateS = dateS
                    }
                } else {
                    showPicker3 = true
                }
                self.tableView.reloadData()
            case .lastunitstanding:
                if showPicker4 {
                    showPicker4 = false
                    if incidentStructure.incidentLastUnitDate != nil {
                        let dateS = incidentStructure.incidentDateTime(type:IncidentTypes.arrival,date: incidentStructure.incidentLastUnitDate! )
                        incidentStructure.incidentFullLastUnitDateS = dateS
                    } else {
                        let date = Date()
                        let dateS = incidentStructure.incidentDateTime(type:IncidentTypes.lastunitstanding,date: date)
                        incidentStructure.incidentFullLastUnitDateS = dateS
                    }
                } else {
                    showPicker4 = true
                }
                self.tableView.reloadData()
            default:
                print("no timer")
            }
            
        }
        
        func theNotesBWasTapped(incidentType: IncidentTypes) {
            switch incidentType {
            case .arrival:
                if arrivalNotes {
                    arrivalNotes = false
                } else {
                    arrivalNotes = true
                }
            case .controlled:
                if controlledNotes {
                    controlledNotes = false
                } else {
                    controlledNotes = true
                }
            case .lastunitstanding:
                if lastUnitStandingNotes {
                    lastUnitStandingNotes = false
                } else {
                    lastUnitStandingNotes = true
                }
            default:
                print("no notes")
            }
            self.tableView.reloadData()
        }
    }

    //    MARK: -TimeAndDateArrivalCellDelegate
    extension IncidentTVC: TimeAndDateArrivalCellDelegate {
        
        func alarmTimeBTapped(incidentType: IncidentTypes) {
            if incidentType == .alarm {
                if showPicker1 {
                    showPicker1 = false
                    if incidentStructure.incidentAlarmDate != nil {
                        let dateS = incidentStructure.incidentDateTime(type:IncidentTypes.arrival,date: incidentStructure.incidentAlarmDate! )
                        incidentStructure.incidentFullAlarmDateS = dateS
                    } else {
                        let date = Date()
                        let dateS = incidentStructure.incidentDateTime(type:IncidentTypes.lastunitstanding,date: date)
                        incidentStructure.incidentFullAlarmDateS = dateS
                    }
                } else {
                    showPicker1 = true
                }
                self.tableView.reloadData()
            }
        }
        
        func alarmNotesBTapped(incidentType: IncidentTypes) {
            self.incidentType = incidentType
            switch self.incidentType {
            case .alarmNote:
                alarmNotes = true
                arrivalNotes = false
                controlledNotes = false
                lastUnitStandingNotes = false
            case .arrivalNote:
                alarmNotes = false
                arrivalNotes = true
                controlledNotes = false
                lastUnitStandingNotes = false
            case .controlledNote:
                alarmNotes = false
                arrivalNotes = false
                controlledNotes = true
                lastUnitStandingNotes = false
            case .lastUnitStandingNote:
                alarmNotes = false
                arrivalNotes = false
                controlledNotes = false
                lastUnitStandingNotes = true
            default:break
            }
            if incidentType == .alarm {
                if alarmNotes {
                    alarmNotes = false
                } else {
                    alarmNotes = true
                }
                self.tableView.reloadData()
            }
        }
    }

    //    MARK: -LabelTextFieldWithDirectionCellDelegate
    extension IncidentTVC: LabelTextFieldWithDirectionCellDelegate {
        
        func directionalBTapped(type:IncidentTypes) {
            switch type {
            case .localIncidentType:
                presentModal(menuType: myShift, title: "Local Incident Type", type: type)
            case .locationType:
                presentModal(menuType: myShift, title: "Location Type", type: type)
            case .streetType:
                presentModal(menuType: myShift, title: "Street Type", type: type)
            case .streetPrefix:
                presentModal(menuType: myShift, title: "Street Prefix", type: type)
            case .resources:
                presentResource(menuType: myShift, title: "Fire/EMS Resources", type: type)
            case .officersRank:
                presentModal(menuType: myShift, title: "Officer's Rank", type: type)
            case .officersAssignment:
                presentModal(menuType: myShift, title: "Officer's Assignment", type: type)
            case .membersRank:
                presentModal(menuType: myShift, title: "Member's Rank", type: type)
            case .membersAssignment:
                presentModal(menuType: myShift, title: "Members's Assignemnt", type: type)
            default:
                print("nothing here")
            }
        }
        func directionalBJWasTapped(type: UserInfo) {}
        
        func theTextFieldHasBeenEdited2(text: String) {}
        
    }

    //    MARK: -IncidentTextViewWithDirectionalCellDelegate
    //    TODO: ???
    extension IncidentTVC: IncidentTextViewWithDirectionalCellDelegate {
        
        func theIncidentDirectionalButtonWasTapped() {}
        func theIncidentTextViewIsFinishedEditing() {}
        
        func nfirstIncidentTyped(code: String){}
        
        
        func nfirsIncidentTypeInfoTapped() {
            if !alertUp {
                let title: InfoBodyText = .nfirsIncidentTypeSubject
                let message: InfoBodyText = .nfirsIncidentType
                let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
                let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
                    self.alertUp = false
                })
                alert.addAction(okAction)
                alertUp = true
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }

    //    MARK: -SegmentCellDelegate
    extension IncidentTVC: SegmentCellDelegate {
        
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
            case .change:
                incidentStructure.incidentNFIRSSec1Exposure = "Change"
            case .delete:
                incidentStructure.incidentNFIRSSec1Exposure = "Delete"
            case .noactivity:
                incidentStructure.incidentNFIRSSec1Exposure = "No Activity"
            case .mr:
                nfirsSecKNamePrefix = type
                incidentStructure.incidentNFIRSSecKNamePrefix = "Mr."
            case .ms:
                nfirsSecKNamePrefix = type
                incidentStructure.incidentNFIRSSecKNamePrefix = "Ms."
            case .mrs:
                nfirsSecKNamePrefix = type
                incidentStructure.incidentNFIRSSecKNamePrefix = "Mrs."
            case .mr2:
                nfirsSecKNamePrefix2 = type
                incidentStructure.incidentNFIRSSecK2NamePrefix = "Mr."
            case .ms2:
                nfirsSecKNamePrefix2 = type
                incidentStructure.incidentNFIRSSecK2NamePrefix = "Ms."
            case .mrs2:
                nfirsSecKNamePrefix2 = type
                incidentStructure.incidentNFIRSSecK2NamePrefix = "Mrs."
            default:
                print("no")
            }
            segmentType = type
            tableView.reloadData()
        }
        
    }

    //    MARK: -StartShiftOvertimeSwitchDelegate
    //    TODO: ????
    extension IncidentTVC: StartShiftOvertimeSwitchDelegate {
        
        func switchTapped(type: String, startOrEnd: Bool, myShift: MenuItems) {}
        
    }

    extension IncidentTVC: ModalFDResourcesDataDelegate {
        
        func theResourcesHaveBeenCollected(collectionOfResources: [UserResources]){
            var resourcesA = [String]()
            for r in collectionOfResources {
                var iur = IncidentUserResource.init(imageName: r.resource!)
                iur.type = 0001
                iur.customOrNot = r.resourceCustom
                iur.assetName = "RedSelectedCHECKED"
                iur.incidentGuid = incidentStructure.incidentGuid
                let result = incidentUserResources.filter{ $0.imageName == iur.imageName }
                if result.isEmpty {
                    incidentUserResources.append(iur)
                    incidentStructure.incidentUserResourcesA.append(iur)
                    resourcesA.append(iur.imageName)
                }
            }
            fdResourceCount = incidentUserResources.count
            saveTheIncident()
            
            let indexPath = IndexPath(row: 5, section: 0)
            tableView.reloadRows(at: [indexPath], with: .automatic)
            self.dismiss(animated: true, completion: nil)
        }
        
        func theResourcesHasBeenCancelled() {
            self.dismiss(animated: true, completion: nil)
        }
        
    }

    //      MARK: -presentModals
    //      MARK: -REGISTER CELLS
    extension IncidentTVC {
        
        fileprivate func presentCrew(menuType:MenuItems, title:String, type:IncidentTypes){
            slideInTransitioningDelgate.direction = .bottom
            slideInTransitioningDelgate.disableCompactHeight = true
            let storyBoard : UIStoryboard = UIStoryboard(name: "RelieveSupervisorModal", bundle:nil)
            let dataTVC = storyBoard.instantiateViewController(withIdentifier: "RelieveSupervisorModalTVC") as! RelieveSupervisorModalTVC
            dataTVC.delegate = self
            //        if relieveOrSupervisor == "Relieve" {
            //            dataTVC.relieveOrSupervisor = true
            //            dataTVC.headerTitle = "Relieved By"
            //        } else if relieveOrSupervisor == "Supervisor" {
            //            dataTVC.relieveOrSupervisor = false
            //            dataTVC.headerTitle = "Supervisor"
            //        }
            dataTVC.headerTitle = "Crew"
            dataTVC.menuType = MenuItems.incidents
            dataTVC.transitioningDelegate = slideInTransitioningDelgate
            dataTVC.modalPresentationStyle = .custom
            self.present(dataTVC, animated: true, completion: nil)
            //        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            //        let dataTVC = storyBoard.instantiateViewController(withIdentifier: "CrewModalTVC") as! CrewModalTVC
            //        dataTVC.delegate = self
            //        dataTVC.transitioningDelegate = slideInTransitioningDelgate
            //        dataTVC.headerTitle = title
            //        dataTVC.myShift = menuType
            //        dataTVC.incidentType = type
            //        dataTVC.modalPresentationStyle = .custom
            //        self.present(dataTVC, animated: true, completion: nil)
        }
        
        fileprivate func presentResource(menuType:MenuItems, title:String, type:IncidentTypes) {
            slideInTransitioningDelgate.direction = .bottom
            slideInTransitioningDelgate.disableCompactHeight = true
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let dataTVC = storyBoard.instantiateViewController(withIdentifier: "ModalFDResourcesDataTVC") as! ModalFDResourcesDataTVC
            dataTVC.delegate = self
            dataTVC.transitioningDelegate = slideInTransitioningDelgate
            dataTVC.titleName = title
            dataTVC.modalPresentationStyle = .custom
            self.present(dataTVC, animated: true, completion: nil)
        }
        
        fileprivate func presentTags(menuType:MenuItems, title:String, type:IncidentTypes) {
            slideInTransitioningDelgate.direction = .bottom
            slideInTransitioningDelgate.disableCompactHeight = true
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let dataTVC = storyBoard.instantiateViewController(withIdentifier: "TagsTVC") as! TagsTVC
            dataTVC.delegate = self
            dataTVC.shift = MenuItems.incidents
            dataTVC.transitioningDelegate = slideInTransitioningDelgate
            if incidentStructure.incidentTagsA.count != 0 {
                dataTVC.selected = incidentStructure.incidentTagsA
            }
            dataTVC.modalPresentationStyle = .custom
            self.present(dataTVC, animated: true, completion: nil)
        }
        
        fileprivate func presentModal(menuType: MenuItems, title: String, type: IncidentTypes) {
            slideInTransitioningDelgate.direction = .bottom
            slideInTransitioningDelgate.disableCompactHeight = true
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let dataTVC = storyBoard.instantiateViewController(withIdentifier: "ModalDataTVC") as! ModalDataTVC
            dataTVC.delegate = self
            dataTVC.transitioningDelegate = slideInTransitioningDelgate
            dataTVC.headerTitle = title
            dataTVC.myShift = menuType
            dataTVC.incidentType = type
            dataTVC.context = context
            switch type {
            case .nfirsIncidentType:
                dataTVC.entity = "NFIRSIncidentType"
                dataTVC.attribute = "incidentTypeName"
            case .localIncidentType:
                dataTVC.entity = "UserLocalIncidentType"
                dataTVC.attribute = "localIncidentTypeName"
            case .locationType:
                dataTVC.entity = "NFIRSLocation"
                dataTVC.attribute = "location"
            case .streetType:
                dataTVC.entity = "NFIRSStreetType"
                dataTVC.attribute = "streetType"
            case .streetPrefix:
                dataTVC.entity = "NFIRSStreetPrefix"
                dataTVC.attribute = "streetPrefix"
            case .firstAction:
                dataTVC.entity = "NFIRSActionsTaken"
                dataTVC.attribute = "actionTaken"
            case .secondAction:
                dataTVC.entity = "NFIRSActionsTaken"
                dataTVC.attribute = "actionTaken"
            case .thirdAction:
                dataTVC.entity = "NFIRSActionsTaken"
                dataTVC.attribute = "actionTaken"
            case .officersRank:
                dataTVC.entity = "UserRank"
                dataTVC.attribute = "rank"
            case .officersAssignment:
                dataTVC.entity = "UserAssignments"
                dataTVC.attribute = "assignment"
            case .membersRank:
                dataTVC.entity = "UserRank"
                dataTVC.attribute = "rank"
            case .membersAssignment:
                dataTVC.entity = "UserAssignments"
                dataTVC.attribute = "assignment"
            default:break
            }
            dataTVC.modalPresentationStyle = .custom
            self.present(dataTVC, animated: true, completion: nil)
        }
        
        func registerCellsForTable() {
            tableView.register(UINib(nibName: "ControllerLabelCell", bundle: nil), forCellReuseIdentifier: "ControllerLabelCell")
            tableView.register(UINib(nibName: "AddressFieldsButtonsCell", bundle: nil), forCellReuseIdentifier: "AddressFieldsButtonsCell")
            tableView.register(UINib(nibName: "MapViewCell", bundle: nil), forCellReuseIdentifier: "MapViewCell")
            tableView.register(UINib(nibName: "startShiftOvertimeSwitchCell", bundle: nil), forCellReuseIdentifier: "startShiftOvertimeSwitchCell")
            tableView.register(UINib(nibName: "SegmentCell", bundle: nil), forCellReuseIdentifier: "SegmentCell")
            tableView.register(UINib(nibName: "LabelTextFieldWithDirectionCell", bundle: nil), forCellReuseIdentifier: "LabelTextFieldWithDirectionCell")
            tableView.register(UINib(nibName: "IncidentTextViewWithDirectionalCell", bundle: nil), forCellReuseIdentifier: "IncidentTextViewWithDirectionalCell")
            tableView.register(UINib(nibName: "TimeAndDateArrivalCell", bundle: nil), forCellReuseIdentifier: "TimeAndDateArrivalCell")
            tableView.register(UINib(nibName: "TimeAndDateIncidentCell", bundle: nil), forCellReuseIdentifier: "TimeAndDateIncidentCell")
            tableView.register(UINib(nibName: "DatePickerCell", bundle: nil), forCellReuseIdentifier: "DatePickerCell")
            tableView.register(UINib(nibName: "LabelTextViewCell", bundle: nil), forCellReuseIdentifier: "LabelTextViewCell")
            tableView.register(UINib(nibName: "LabelDoubleTextFieldDirectionalCell", bundle: nil), forCellReuseIdentifier: "LabelDoubleTextFieldDirectionalCell")
            tableView.register(UINib(nibName: "LabelYesNoSwitchCell", bundle: nil), forCellReuseIdentifier: "LabelYesNoSwitchCell")
            tableView.register(UINib(nibName: "PhotosTVCell", bundle: nil), forCellReuseIdentifier: "PhotosTVCell")
            tableView.register(UINib(nibName: "IncidentShortTVWithDirectionalCell", bundle: nil), forCellReuseIdentifier: "IncidentShortTVWithDirectionalCell")
            tableView.register(UINib(nibName: "IncidentNotesTextViewCell", bundle: nil), forCellReuseIdentifier: "IncidentNotesTextViewCell")
            tableView.register(UINib(nibName: "LabelDateTimeButtonCell", bundle: nil), forCellReuseIdentifier: "LabelDateTimeButtonCell")
            tableView.register(UINib(nibName: "LabelTextFieldCell", bundle: nil), forCellReuseIdentifier: "LabelTextFieldCell")
            tableView.register(UINib(nibName: "IncidentTFwDirectionalSwitchCell", bundle: nil), forCellReuseIdentifier: "IncidentTFwDirectionalSwitchCell")
            tableView.register(UINib(nibName: "NFIRSDateTimeInstructCell", bundle: nil), forCellReuseIdentifier: "NFIRSDateTimeInstructCell")
            tableView.register(UINib(nibName: "LabelCell", bundle: nil), forCellReuseIdentifier: "LabelCell")
            tableView.register(UINib(nibName: "NFIRSLabelDateTimeButtonCell", bundle: nil), forCellReuseIdentifier: "NFIRSLabelDateTimeButtonCell")
            tableView.register(UINib(nibName: "LabelInstructionWSwitchCell", bundle: nil), forCellReuseIdentifier: "LabelInstructionWSwitchCell")
            tableView.register(UINib(nibName: "NFIRSSignatureCell", bundle: nil), forCellReuseIdentifier: "NFIRSSignatureCell")
            tableView.register(UINib(nibName: "NFIRSLabelTimeButtonCell", bundle: nil), forCellReuseIdentifier: "NFIRSLabelTimeButtonCell")
            tableView.register(UINib(nibName: "FlatTVCell", bundle: nil), forCellReuseIdentifier: "FlatTVCell")
            //        MARK: - ADDING COLLECTION VIEW FOR FD RESOURCES
            tableView.register(UINib(nibName: "FDResourceIncidentCell", bundle: nil), forCellReuseIdentifier: "FDResourceIncidentCell")
            let nib = UINib(nibName: "NFIRSsectionHeaderTHFV", bundle: nil)
            tableView.register(nib, forHeaderFooterViewReuseIdentifier: "NFIRSsectionHeaderTHFV")
        }
        
    }

    extension IncidentTVC: RelieveSupervisorModalTVCDelegate {
        func relieveSupervisorModalCancel() {
            self.dismiss(animated: true, completion: nil)
        }
        
        func relieveSupervisorModalSave(relieveSupervisor: [UserAttendees], relieveOrSupervisor: Bool) {
            let crews = relieveSupervisor
            var array = [String]()
            for crew in crews {
                if crew.attendee != "" {
                    array.append(crew.attendee!)
                }
            }
            incidentStructure.incidentCrewCombine = array.joined(separator: ",")
            incidentStructure.incidentCrewA = array
            let indexPath = IndexPath(row: 24, section: 0)
            tableView.reloadRows(at: [indexPath], with: .automatic)
            self.dismiss(animated: true, completion: nil)
        }
    }

    extension IncidentTVC: IncidentAdditionalStationApparatusTVCDelegate {
        
        func incidentAddtionalStationApparatusChosen(collectionOfResources: [UserFDResources]) {
            var resourcesA = [String]()
            userFDResourcesSelected = collectionOfResources
            for resource in collectionOfResources {
                var iur = IncidentUserResource.init(imageName: resource.fdResourceImageName ?? "")
                iur.customOrNot = resource.customResource
                iur.type = 0001 //resource.fdResourceType
                iur.assetName = "RedSelectedCHECKED"
                iur.incidentGuid = incidentStructure.incidentGuid
                //resource.fdResourceGuid ?? ""
                let result = incidentUserResources.filter{ $0.imageName == iur.imageName }
                if result.isEmpty {
                    incidentUserResources.append(iur)
                    incidentStructure.incidentUserResourcesA.append(iur)
                    resourcesA.append(iur.imageName)
                }
            }
            fdResourceCount = incidentUserResources.count
            saveTheIncident()
            //        tableView.reloadData()
            let indexPath = IndexPath(row: 5, section: 0)
            tableView.reloadRows(at: [indexPath], with: .automatic)
            self.dismiss(animated: true, completion: nil)
        }
        
        func incidentAdditionalStationApparatusCanceled() {
            self.dismiss(animated: true, completion: nil)
        }
        
        
    }

    extension IncidentTVC: FDResourceIncidentCellDelegate {
        
        func additionalStationApparatusCalled() {
            slideInTransitioningDelgate.direction = .bottom
            slideInTransitioningDelgate.disableCompactHeight = true
            
            let storyboard = UIStoryboard(name: "AdditionalStationApparatus", bundle: nil)
            let incidentAdditionalStationApparatusTVC  = storyboard.instantiateViewController(identifier: "IncidentAdditionalStationApparatusTVC") as! IncidentAdditionalStationApparatusTVC
            incidentAdditionalStationApparatusTVC.selectedResources = userFDResourcesSelected
            incidentAdditionalStationApparatusTVC.delegate = self
            incidentAdditionalStationApparatusTVC.transitioningDelegate = slideInTransitioningDelgate
            incidentAdditionalStationApparatusTVC.modalPresentationStyle = .custom
            self.present(incidentAdditionalStationApparatusTVC, animated: true, completion: nil)
        }
        
        // MARK: -Resources Collection View PRotocol
        func aFDResourceHasBeenTappedForSelection(resource: IncidentUserResource) {
            let imageName = resource.imageName
            if !incidentUserResources.contains(resource) {
                incidentUserResources.append(resource)
                chosenIncidentResourceName.append(imageName)
            } else {
                incidentUserResources = incidentUserResources.filter{ $0.imageName != resource.imageName }
                chosenIncidentResourceName = chosenIncidentResourceName.filter{ $0 != imageName }
            }
            if !incidentStructure.incidentUserResourcesA.contains(resource){
                incidentStructure.incidentUserResourcesA.append(resource)
            } else {
                incidentStructure.incidentUserResourcesA.remove(object: resource)
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
        
        func aFDResourceInfoBTapped() {
            if !alertUp {
                let message: InfoBodyText = .additionalFireEMSResources2
                let title: InfoBodyText = .additionalFireEMSResourcesSubject
                let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
                let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
                    self.alertUp = false
                })
                alert.addAction(okAction)
                alertUp = true
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        
    }

    //      MARK: -BUILD THE INCIDENT STRUCTURE-
    //      MARK: -SAVE MECHANISM
    //      MARK: -get user data
    extension IncidentTVC {
        
        func fetchTheResources(guid:String) {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "IncidentResources" )
            let predicate = NSPredicate(format: "%K == %@", "incidentReference", guid)
            let sectionSortDescriptor = NSSortDescriptor(key: "incidentResource", ascending: true)
            let sortDescriptors = [sectionSortDescriptor]
            fetchRequest.sortDescriptors = sortDescriptors
            fetchRequest.predicate = predicate
            fetchRequest.fetchBatchSize = 20
            fetchRequest.returnsObjectsAsFaults = false
            do {
                theResources = try context.fetch(fetchRequest) as! [IncidentResources]
                for iResource in theResources {
                    let imageName = iResource.incidentResource!
                    fetchTheUserFDResourcesForSelection(imageName: imageName)
                }
            } catch let error as NSError {
                print("IncidentTVC line 1132 Fetch Error: \(error.localizedDescription)")
            }
        }
        
        func fetchTheUserFDResourcesForSelection(imageName: String) {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserFDResources" )
            let predicate = NSPredicate(format: "%K == %@", "fdResourceImageName", imageName)
            let sectionSortDescriptor = NSSortDescriptor(key: "fdResourceImageName", ascending: true)
            let sortDescriptors = [sectionSortDescriptor]
            fetchRequest.sortDescriptors = sortDescriptors
            fetchRequest.predicate = predicate
            fetchRequest.fetchBatchSize = 20
            fetchRequest.returnsObjectsAsFaults = false
            do {
                let fetchResult = try context.fetch(fetchRequest) as! [UserFDResources]
                if fetchResult.count != 0 {
                    let fetched = fetchResult.last!
                    userFDResourcesSelected.append(fetched)
                }
            } catch let error as NSError {
                print("IncidentTVC line 1652 Fetch Error: \(error.localizedDescription)")
            }
        }
        
        func buildTheIncidentStructure() {
            incident = context.object(with: id) as? Incident
            let incidentAddress = incident.incidentAddressDetails
            let incidentNFIRS = incident.incidentNFIRSDetails
            let incidentTimer = incident.incidentTimerDetails
            //        let incidentUserResourcesGroups = incident.userResourcesGroupDetails
            //        let incidentTeam = incident.teamMemberDetails
            //        let incidentResources = incident.incidentResourceDetails
            //        let incidentPhotos = incident.incidentPhotoDetails
            //        let userCrews = incident.userCrewsDetails
            let actionsTaken = incident.actionsTakenDetails
            let incidentLocal = incident.incidentLocalDetails
            //        let incidentTags = incident.incidentTagDetails
            let nfirsSecM = incident.sectionMDetails
            
            incidentStructure.incidentGuid = incident.fjpIncGuidForReference ?? ""
            incidentStructure.incidentPersonalJournalReference = incident.fjpPersonalJournalReference ?? ""
            incidentStructure.incidentNumber = incident.incidentNumber ?? ""
            incidentStructure.incidentDate = incident.incidentCreationDate ?? Date()
            incidentStructure.incidentType = incident.situationIncidentImage ?? ""
            incidentStructure.incidentImageName = incident.incidentEntryTypeImageName ?? ""
            if incident.incidentLocationSC != nil {
                if let location = incident.incidentLocationSC {
                    guard let  archivedData = location as? Data else { return }
                    do {
                        guard let unarchivedLocation = try NSKeyedUnarchiver.unarchivedObject(ofClass: CLLocation.self , from: archivedData) else { return }
                        let location:CLLocation = unarchivedLocation
                        incidentStructure.incidentLocation = location
                    } catch {
                        print("something's going on here")
                    }
                }
                incidentStructure.incidentLatitude = incident.incidentLatitude ?? ""
                incidentStructure.incidentLongitude = incident.incidentLongitude ?? ""
                incidentStructure.incidentStreetNum = incident.incidentStreetNumber ?? ""
                incidentStructure.incidentStreetName = incident.incidentStreetHyway ?? ""
                incidentStructure.incidentCity = incidentAddress?.city ?? ""
                incidentStructure.incidentState = incidentAddress?.incidentState ?? ""
                incidentStructure.incidentZip = incident.incidentZipCode ?? ""
                let num = incidentStructure.incidentStreetNum
                let street = incidentStructure.incidentStreetName
                let city = incidentStructure.incidentCity
                let state = incidentStructure.incidentState
                let zip = incidentStructure.incidentZip
                incidentStructure.incidentFullAddress = "\(num) \(street) \(city),\(state) \(zip)"
            }
            incidentStructure.incidentStreetPrefix = incidentAddress?.prefix ?? ""
            incidentStructure.incidentStreetType = incidentAddress?.streetType ?? ""
            let fullDate = vcLaunch.incidentFullDate(date: incident.incidentCreationDate ?? Date())
            incidentStructure.incidentFullDateS = fullDate
            incidentStructure.incidentEmergency = incident.incidentType ?? ""
            incidentStructure.incidentArson = incident.arsonInvestigation
            if incident.incidentType == "Emergency" {
                incidentStructure.incidentEmergencyYesNo = true
            } else {
                incidentStructure.incidentEmergencyYesNo = false
            }
            if incidentStructure.incidentType == "Fire" {
                segmentType = .fire
            } else if incidentStructure.incidentType == "EMS" {
                segmentType = .ems
            } else if incidentStructure.incidentType == "Rescue" {
                segmentType = .rescue
            } else {
                segmentType = .fire
            }
            let incidentNotes:IncidentNotes = (incident?.incidentNotesDetails)!
            incidentStructure.incidentNotes = incidentNotes.incidentNote ?? ""
            incidentStructure.incidentNfirsIncidentType = incidentNFIRS?.incidentTypeTextNFRIS ?? ""
            incidentStructure.incidentNfirsIncidentTypeNumber = incidentNFIRS?.incidentTypeNumberNFRIS ?? ""
            incidentStructure.incidentLocationType = incidentNFIRS?.incidentLocation ?? ""
            
            incidentStructure.incidentLocalType = incidentLocal?.incidentLocalType ?? ""
            
            incidentStructure.incidentFullAlarmDateS = incidentTimer?.incidentAlarmCombinedDate ?? ""
            incidentStructure.incidentAlarmNotes = incidentTimer?.incidentAlarmNotes  as? String ?? ""
            incidentStructure.incidentFullArrivalDateS = incidentTimer?.incidentArrivalCombinedDate ?? ""
            incidentStructure.incidentArrivalNotes = incidentTimer?.incidentArrivalNotes  as? String ?? ""
            incidentStructure.incidentFullControlledDateS = incidentTimer?.incidentControlledCombinedDate ?? ""
            incidentStructure.incidentControlledNotes = incidentTimer?.incidentControlledNotes  as?  String ?? ""
            incidentStructure.incidentFullLastUnitDateS = incidentTimer?.incidentLastUnitCalledCombinedDate ?? ""
            incidentStructure.incidentLastUnitNotes = incidentTimer?.incidentLastUnitClearedNotes  as? String ?? ""
            
            if actionsTaken?.primaryActionNumber != nil {
                incidentStructure.incidentAction1No = actionsTaken?.primaryActionNumber ?? ""
                incidentStructure.incidentAction1S = actionsTaken?.primaryAction ?? ""
                incidentStructure.incidentAction2No = actionsTaken?.additionalTwoNumber ?? ""
                incidentStructure.incidentAction2S = actionsTaken?.additionalTwo ?? ""
                incidentStructure.incidentAction3No = actionsTaken?.additionalThreeNumber ?? ""
                incidentStructure.incidentAction3S = actionsTaken?.additionalThree ?? ""
                //            theActionsTaken = actionsTaken
            } else {
                print("ActionsTaken is empty")
            }
            
            //        let tags = incident?.incidentTagDetails
            var tagsA = [String]()
            for tags in incident?.incidentTagDetails as! Set<IncidentTags> {
                print(tags.incidentTag ?? "no tag")
                let tag = tags.incidentTag ?? ""
                tagsA.append(tag)
            }
            
            tagsA = tagsA.filter { $0 != ""}
            tagsA = Array(NSOrderedSet(array: tagsA)) as! [String]
            incidentStructure.incidentTagsA = tagsA
            let tag:String = tagsA.joined(separator: ", ")
            incidentStructure.incidentTags = tag
            
            var crewA = [String]()
            for teams in incident?.teamMemberDetails as! Set<IncidentTeam> {
                let team = teams.teamMember ?? ""
                crewA.append(team)
            }
            
            crewA = crewA.filter { $0 != "" }
            crewA = Array(NSOrderedSet(array: crewA)) as! [String]
            incidentStructure.incidentCrewA = crewA
            let crew:String = crewA.joined(separator: ", ")
            incidentStructure.incidentCrewCombine = crew
            
            var resourcesA = [String]()
            fetchTheResources(guid:incidentStructure.incidentGuid)
            if theResources.count != 0 {
                for resources in theResources {
                    var iur = IncidentUserResource.init(imageName: resources.incidentResource ?? "")
                    iur.customOrNot = resources.resourceCustom
                    iur.type = resources.resourceType
                    iur.assetName = "RedSelectedCHECKED"
                    iur.incidentGuid = resources.incidentReference ?? ""
                    incidentUserResources.append(iur)
                    incidentStructure.incidentUserResourcesA.append(iur)
                    resourcesA.append(iur.imageName)
                }
                fdResourceCount = incidentUserResources.count
            }
            
            resourcesA = resourcesA.filter { $0 != "" }
            resourcesA = Array(NSOrderedSet(array: resourcesA)) as! [String]
            incidentStructure.incidentResourcesA = resourcesA
            let resource:String = resourcesA.joined(separator: ", ")
            incidentStructure.incidentResourcesCombined = resource
            
            if incidentStructure.incidentCrewCombine == "" {
                if fju.crewDefault {
                    if let crew = fju.defaultCrew {
                        incidentStructure.incidentCrew = crew
                        incidentStructure.incidentCrewCombine = crew
                        incidentStructure.incidentCrewA = crew.components(separatedBy: ",")
                    }
                } else {
                    if let crew = fju.crewOvertime {
                        incidentStructure.incidentCrew = crew
                        incidentStructure.incidentCrewCombine = crew
                        incidentStructure.incidentCrewA = crew.components(separatedBy: ",")
                    }
                }
            }
            
            if incidentStructure.incidentResourcesCombined == "" {
                if fju.resourcesDefault {
                    if let resources = fju.defaultResources {
                        incidentStructure.incidentResourcesCombined = resources
                        incidentStructure.incidentResources = resources
                        incidentStructure.incidentResourcesA = resources.components(separatedBy: ", ")
                    }
                } else {
                    if let resources = fju.tempResources {
                        incidentStructure.incidentResourcesCombined = resources
                        incidentStructure.incidentResources = resources
                        incidentStructure.incidentResourcesA = resources.components(separatedBy: ", ")
                    }
                }
            }
            
            if nfirsSecM?.officerDate == nil {
                incidentStructure.incidentNFIRSSecMOfficiersSignatureDate = incidentStructure.incidentDate
            } else {
                incidentStructure.incidentNFIRSSecMOfficiersSignatureDate = nfirsSecM?.officerDate ?? Date()
            }
            
            if nfirsSecM?.memberDate == nil {
                incidentStructure.incidentNFIRSSecMMembersSignatureDate = incidentStructure.incidentDate
            } else {
                incidentStructure.incidentNFIRSSecMMembersSignatureDate = nfirsSecM?.memberDate ?? Date()
            }
            
        }
        
        func saveTheIncident() {
            let incidentAddress = incident.incidentAddressDetails
            let incidentNFIRS = incident.incidentNFIRSDetails
            let incidentTimer = incident.incidentTimerDetails
            //        let incidentPhotos = incident.incidentPhotoDetails
            //       let incidentTags = incident.incidentTagDetails
            //        let userCrews = incident.userCrewsDetails
            //        let incidentTeam = incident.teamMemberDetails
            let actionsTaken = incident.actionsTakenDetails
            let incidentLocal = incident.incidentLocalDetails
            //        let userResourcesGroups = incident.userResourcesGroupDetails
            let incidentNotes = incident.incidentNotesDetails
            
            incident.incidentNumber = incidentStructure.incidentNumber
            incident.incidentType = incidentStructure.incidentEmergency
            incident.situationIncidentImage = incidentStructure.incidentType
            incident.incidentEntryTypeImageName = incidentStructure.incidentImageName
            
            //        MARK: -LOCATION-
            /// incidentLocaiton archived with secureCoding
            if incidentStructure.incidentLocation != nil {
                let location = incidentStructure.incidentLocation!
                do {
                    let data = try NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: true)
                    incident.incidentLocationSC = data as NSObject
                } catch {
                    print("got an error here")
                }
                incident.incidentLatitude = incidentStructure.incidentLatitude
                incident.incidentLongitude = incidentStructure.incidentLongitude
                incident.incidentStreetNumber = incidentStructure.incidentStreetNum
                incident.incidentStreetHyway = incidentStructure.incidentStreetName
                incident.incidentZipCode = incidentStructure.incidentZip
            }
            incident.incidentBackedUp = false
            let incidentModDate = Date()
            incident.incidentModDate = incidentModDate
            incident.arsonInvestigation = incidentStructure.incidentArson
            incident.fjpPersonalJournalReference = incidentStructure.incidentPersonalJournalReference
            
            incidentAddress?.streetHighway = incidentStructure.incidentStreetName
            incidentAddress?.streetNumber = incidentStructure.incidentStreetNum
            incidentAddress?.city = incidentStructure.incidentCity
            incidentAddress?.incidentState = incidentStructure.incidentState
            incidentAddress?.zip = incidentStructure.incidentZip
            incidentAddress?.prefix = incidentStructure.incidentStreetPrefix
            incidentAddress?.streetType = incidentStructure.incidentStreetType
            
            incidentLocal?.incidentLocalType = incidentStructure.incidentLocalType
            
            incidentNFIRS?.incidentTypeNumberNFRIS = incidentStructure.incidentNfirsIncidentTypeNumber
            incidentNFIRS?.incidentTypeTextNFRIS = incidentStructure.incidentNfirsIncidentType
            incidentNFIRS?.incidentFDID = fju.fdid ?? ""
            incidentNFIRS?.fireStationState = fju.fireStationState ?? ""
            incidentNFIRS?.incidentFireStation = fju.fireStation ?? ""
            incidentNFIRS?.incidentLocation = incidentStructure.incidentLocationType
            
            incidentNotes?.incidentNote = incidentStructure.incidentNotes
            
            
            incidentTimer?.incidentAlarmCombinedDate = incidentStructure.incidentFullAlarmDateS
            incidentTimer?.incidentAlarmDateTime = incidentStructure.incidentAlarmDate
            incidentTimer?.incidentAlarmMonth = incidentStructure.incidentAlarmMM
            incidentTimer?.incidentAlarmDay = incidentStructure.incidentAlarmdd
            incidentTimer?.incidentAlarmYear = incidentStructure.incidentAlarmYYYY
            incidentTimer?.incidentAlarmHours = incidentStructure.incidentAlarmHH
            incidentTimer?.incidentAlarmMinutes = incidentStructure.incidentAlarmmm
            incidentTimer?.incidentAlarmNotes = incidentStructure.incidentAlarmNotes as NSObject
            incidentTimer?.incidentArrivalCombinedDate = incidentStructure.incidentFullArrivalDateS
            incidentTimer?.incidentArrivalDateTime = incidentStructure.incidentArrivalDate
            incidentTimer?.incidentArrivalMonth = incidentStructure.incidentArrivalMM
            incidentTimer?.incidentArrivalDay = incidentStructure.incidentArrivaldd
            incidentTimer?.incidentArrivalYear = incidentStructure.incidentArrivalYYYY
            incidentTimer?.incidentArrivalHours = incidentStructure.incidentArrivalHH
            incidentTimer?.incidentArrivalMinutes = incidentStructure.incidentArrivalmm
            incidentTimer?.incidentArrivalNotes = incidentStructure.incidentArrivalNotes as NSObject
            incidentTimer?.incidentControlledCombinedDate = incidentStructure.incidentFullControlledDateS
            incidentTimer?.incidentControlDateTime = incidentStructure.incidentControlledDate
            incidentTimer?.incidentControlledMonth = incidentStructure.incidentControlledMM
            incidentTimer?.incidentControlledDay = incidentStructure.incidentControlleddd
            incidentTimer?.incidentControlledYear = incidentStructure.incidentControlledYYYY
            incidentTimer?.incidentControlledHours = incidentStructure.incidentControlledHH
            incidentTimer?.incidentControlledMinutes = incidentStructure.incidentControlledmm
            incidentTimer?.incidentControlledNotes = incidentStructure.incidentControlledNotes as NSObject
            incidentTimer?.incidentLastUnitCalledCombinedDate = incidentStructure.incidentFullLastUnitDateS
            incidentTimer?.incidentLastUnitDateTime = incidentStructure.incidentLastUnitDate
            incidentTimer?.incidentLastUnitCalledMonth = incidentStructure.incidentLastUnitMM
            incidentTimer?.incidentLastUnitCalledDay = incidentStructure.incidentLastUnitdd
            incidentTimer?.incidentLastUnitCalledYear = incidentStructure.incidentLastUnitYYYY
            incidentTimer?.incidentLastUnitCalledHours = incidentStructure.incidentLastUnitHH
            incidentTimer?.incidentLastUnitCalledMinutes = incidentStructure.incidentLastUnitmm
            incidentTimer?.incidentLastUnitClearedNotes = incidentStructure.incidentLastUnitNotes as NSObject
            
            actionsTaken?.primaryActionNumber = incidentStructure.incidentAction1No
            actionsTaken?.primaryAction = incidentStructure.incidentAction1S
            actionsTaken?.additionalTwoNumber = incidentStructure.incidentAction2No
            actionsTaken?.additionalTwo = incidentStructure.incidentAction2S
            actionsTaken?.additionalThreeNumber = incidentStructure.incidentAction3No
            actionsTaken?.additionalThree = incidentStructure.incidentAction3S
            //        theActionsTaken = actionsTaken
            
            for ( _, crew ) in incidentStructure.incidentCrewA.enumerated() {
                let count = theCountForCrew(guid: incident.fjpIncGuidForReference ?? "", crew: crew)
                if count == 0 {
                    let fjuIncidentTeam = IncidentTeam.init(entity: NSEntityDescription.entity(forEntityName: "IncidentTeam", in: context)!, insertInto: context)
                    fjuIncidentTeam.teamMember = crew
                    fjuIncidentTeam.teamMemberBackup = false
                    fjuIncidentTeam.teamMemberModDate = Date()
                    fjuIncidentTeam.incidentReference = incident.fjpIncGuidForReference
                    incident.addToTeamMemberDetails(fjuIncidentTeam)
                }
            }
            
            //        for ( _, imageName ) in incidentStructure.incidentUserResourcesA.enumerated() {
            //            let count = theCountForResources(guid: incident.fjpIncGuidForReference ?? "", resource: imageName)
            //            if count == 0 {
            //                let fjuIncidentResouces = IncidentResources.init(entity: NSEntityDescription.entity(forEntityName: "IncidentResources", in: context)!, insertInto: context)
            //                fjuIncidentResouces.incidentResource = imageName
            //                fjuIncidentResouces.incidentResourceBackup = false
            //                fjuIncidentResouces.incidentResourceModDate = Date()
            //                fjuIncidentResouces.incidentReference = incident.fjpIncGuidForReference
            //                incident.addToIncidentResourceDetails(fjuIncidentResouces)
            //            }
            //        }
            
            for resource in incidentStructure.incidentUserResourcesA {
                let imageName = resource.imageName
                if resource.type == 1 {
                    let count = theCountForResources(guid: incident.fjpIncGuidForReference ?? "", resource: imageName)
                    if count == 0 {
                        //                if resource.type == 0001 {
                        let fjuIncidentResources = IncidentResources.init(entity: NSEntityDescription.entity(forEntityName: "IncidentResources", in: context)!, insertInto: context)
                        fjuIncidentResources.incidentResource = imageName
                        fjuIncidentResources.resourceCustom = resource.customOrNot
                        fjuIncidentResources.resourceType = 0001
                        fjuIncidentResources.incidentResourceBackup = false
                        fjuIncidentResources.incidentResourceModDate = Date()
                        fjuIncidentResources.incidentReference = incident.fjpIncGuidForReference
                        incident.addToIncidentResourceDetails(fjuIncidentResources)
                        if !incidentUserResources.contains(resource) {
                            incidentUserResources.append(resource)
                        }
                        //                }
                    }
                }
            }
            
            
            for ( _, tag ) in incidentStructure.incidentTagsA.enumerated() {
                let count = theCountForTags(guid: incident.fjpIncGuidForReference ?? "", tag: tag)
                if count == 0 {
                    let fjuIncidentTags = IncidentTags.init(entity: NSEntityDescription.entity(forEntityName: "IncidentTags", in: context)!, insertInto: context)
                    fjuIncidentTags.incidentTag = tag
                    fjuIncidentTags.incidentTagBackup = false
                    fjuIncidentTags.incidentTagModDate = Date()
                    fjuIncidentTags.incidentReference = incident.fjpIncGuidForReference
                    incident.addToIncidentTagDetails(fjuIncidentTags)
                }
            }
            
            saveToCD()
        }
        
        //    MARK: - save handling
        fileprivate func saveToCD() {
            do {
                try context.save()
                DispatchQueue.main.async {
                    self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"merge that"])
                }
                self.tableView.reloadData()
                DispatchQueue.main.async { [weak self] in
                    //                self?.getTheLastSaved()
                    self?.nc.post(name:Notification.Name(rawValue:FJkCKModifyIncidentToCloud),
                                  object: nil,
                                  userInfo: ["objectID":self?.id as Any])
                }
                DispatchQueue.main.async { [weak self] in
                    self?.nc.post(name: Notification.Name(rawValue: FJkRELOADTHELIST),
                                  object: nil, userInfo: ["shift":MenuItems.incidents])
                }
                if fromMap {
                    if (Device.IS_IPHONE) {
                            if fju != nil {
                                let id = fju.objectID
                            vcLaunch.mapCalledPhone(type: incidentType, theUserOID: id)
                            }
                    } else {
                        if fju != nil {
                            let id = fju.objectID
                            vcLaunch.mapCalled(type: incidentType, theUserOID: id)
                        }
                    }
                }
            }   catch let error as NSError {
                let nserror = error
                
                let errorMessage = "IncidentTVC saveToCD The context was unable to save due to \(nserror), \(nserror.userInfo)"
                print(errorMessage)
            }
        }
        
        private func getTheLastSaved() {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Incident" )
            let predicate = NSPredicate(format: "%K != %@", "fjpIncGuidForReference", "")
            let sectionSortDescriptor = NSSortDescriptor(key: "incidentCreationDate", ascending: true)
            let sortDescriptors = [sectionSortDescriptor]
            fetchRequest.sortDescriptors = sortDescriptors
            fetchRequest.predicate = predicate
            fetchRequest.fetchBatchSize = 20
            do {
                self.fetched = try context.fetch(fetchRequest) as! [Incident]
                let incident = self.fetched.last as! Incident
                self.objectID = incident.objectID
            } catch let error as NSError {
                print("IncidentTVC line 1132 Fetch Error: \(error.localizedDescription)")
            }
        }
        
        private func theCountForCrew(guid: String, crew: String)->Int {
            let attribute = "incidentReference"
            let entity = "IncidentTeam"
            let subAttribute = "teamMember"
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
            let predicate = NSPredicate(format: "%K == %@", attribute, guid)
            let predicate2 = NSPredicate(format: "%K == %@", subAttribute, crew)
            let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate,predicate2])
            fetchRequest.predicate = predicateCan
            do {
                let count = try context.count(for:fetchRequest)
                return count
            } catch let error as NSError {
                print("IncidentTVC line 1278 Fetch Error: \(error.localizedDescription)")
                return 0
            }
        }
        
        private func theCountForTags(guid: String, tag: String)->Int {
            let attribute = "incidentReference"
            let entity = "IncidentTags"
            let subAttribute = "incidentTag"
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
            let predicate = NSPredicate(format: "%K == %@", attribute, guid)
            let predicate2 = NSPredicate(format: "%K == %@", subAttribute, tag)
            let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate,predicate2])
            fetchRequest.predicate = predicateCan
            do {
                let count = try context.count(for:fetchRequest)
                return count
            } catch let error as NSError {
                print("IncidentTVC line 1296 Fetch Error: \(error.localizedDescription)")
                return 0
            }
        }
        
        private func theCountForResources(guid: String, resource: String)->Int {
            let attribute = "incidentReference"
            let entity = "IncidentResources"
            let subAttribute = "incidentResource"
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
            let predicate = NSPredicate(format: "%K == %@", attribute, guid)
            let predicate2 = NSPredicate(format: "%K == %@", subAttribute, resource)
            let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate,predicate2])
            fetchRequest.predicate = predicateCan
            do {
                let count = try context.count(for:fetchRequest)
                return count
            } catch let error as NSError {
                print("IncidentTVC line 1314 Fetch Error: \(error.localizedDescription)")
                return 0
            }
        }
        
        func getTheUserData() {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FireJournalUser" )
            var predicate = NSPredicate.init()
            predicate = NSPredicate(format: "%K != %@", "userGuid", "")
            let sectionSortDescriptor = NSSortDescriptor(key: "lastName", ascending: true)
            let sortDescriptors = [sectionSortDescriptor]
            fetchRequest.sortDescriptors = sortDescriptors
            fetchRequest.predicate = predicate
            fetchRequest.fetchBatchSize = 1
            
            do {
                self.fetched = try context.fetch(fetchRequest) as! [FireJournalUser]
                self.fju = self.fetched.last as? FireJournalUser
            } catch let error as NSError {
                print("IncidentTVC line 802 Fetch Error: \(error.localizedDescription)")
            }
        }
        
        func getTheUserFDResources() {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserFDResources")
            let sectionSortDescriptor = NSSortDescriptor(key: "fdResource", ascending: true)
            let sortDescriptors = [sectionSortDescriptor]
            fetchRequest.sortDescriptors = sortDescriptors
            fetchRequest.returnsObjectsAsFaults = false
            fetchRequest.fetchLimit = 10
            do {
                let fdResources = try context.fetch(fetchRequest) as! [UserFDResources]
                
                if fdResources.count == 0 {
                    print("hey we have zero")
                } else {
                    for r in fdResources {
                        var iur = IncidentUserResource.init(imageName: r.fdResource!)
                        iur.type = 0002
                        iur.customOrNot = r.customResource
                        iur.assetName = "GreenAvailable"
                        incidentUserResources.append(iur)
                        incidentStructure.incidentUserResourcesA.append(iur)
                    }
                    fdResourceCount = incidentUserResources.count
                    
                }
            }  catch {
                let nserror = error as NSError
                let errorMessage = "SettingsUserFDResourcesTVC getUserFDResources Unresolved error \(nserror), \(nserror.userInfo)"
                print(errorMessage)
            }
        }
        
    }
