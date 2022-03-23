//
//  ARCFormDetailTVC+Extensions.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/17/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import MapKit
import CoreLocation
import T1Autograph

extension ARCFormDetailTVC {
    
    func scrollToTop() {
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }
    
    func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.cells.count-1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }
    
    func stepperOrSwitchTapped() {
        if !alertUp {
            presentAlert()
        }
    }
    
    func presentAlert() {
        let message: InfoBodyText = .campaignSupportNotes
        let title: InfoBodyText = .campaignSupportNotesSubject
        let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
                self.alertUp = false
            })
            alert.addAction(okAction)
            alertUp = true
            self.present(alert, animated: true, completion: nil)
    }
    
    func syncTheData() {
        searchARCForm.adminDate = arc.adminDate
        searchARCForm.adminName = arc.adminName
        searchARCForm.arcCreationDate = arc.arcCreationDate
        searchARCForm.arcFormCampaignGuid = arc.arcFormCampaignGuid
        searchARCForm.arcFormGuid = arc.arcFormGuid
        searchARCForm.arcLocaitonState = arc.arcLocaitonState
        searchARCForm.arcLocation = arc.arcLocation
        searchARCForm.arcLocationAddress = arc.arcLocationAddress
        searchARCForm.arcLocationAptMobile = arc.arcLocationAptMobile
        searchARCForm.arcLocationAvailable = arc.arcLocationAvailable
        searchARCForm.arcLocationCity = arc.arcLocationCity
        searchARCForm.arcLocationZip = arc.arcLocationZip
        searchARCForm.arcMaster = arc.arcMaster
        searchARCForm.arcModDate = arc.arcModDate
        searchARCForm.campaign = arc.campaign
        searchARCForm.campaignCount = arc.campaignCount
        searchARCForm.campaignName = arc.campaignName
        searchARCForm.cComplete = arc.cComplete
        searchARCForm.cEndDate = arc.cEndDate
        searchARCForm.createFEPlan = arc.createFEPlan
        searchARCForm.cStartDate = arc.cStartDate
        searchARCForm.fjUserGuid = arc.fjUserGuid
        searchARCForm.hazard = arc.hazard
        searchARCForm.ia17Under = arc.ia17Under
        searchARCForm.ia65Over = arc.ia65Over
        searchARCForm.iaDisability = arc.iaDisability
        searchARCForm.iaNotes = arc.iaNotes
        searchARCForm.iaNumPeople = arc.iaNumPeople
        searchARCForm.iaPrexistingSA = arc.iaPrexistingSA
        searchARCForm.iaVets = arc.iaVets
        searchARCForm.iaWorkingSA = arc.iaWorkingSA
        searchARCForm.installerDate = arc.installerDate
        searchARCForm.installerName = arc.installerName
        searchARCForm.installerSigend = arc.installerSigend
        searchARCForm.installerSignature = arc.installerSignature
        searchARCForm.journalGuid = arc.journalGuid
        searchARCForm.localHazard = arc.localHazard
        searchARCForm.localPartner = arc.localPartner
        searchARCForm.nationalPartner = arc.nationalPartner
        searchARCForm.numBatteries = arc.numBatteries
        searchARCForm.numBedShaker = arc.numBedShaker
        searchARCForm.numNewSA = arc.numNewSA
        searchARCForm.option1 = arc.option1
        searchARCForm.option2 = arc.option2
        searchARCForm.residentCellNum = arc.residentCellNum
        searchARCForm.residentContactInfo = arc.residentContactInfo
        searchARCForm.residentEmail = arc.residentEmail
        searchARCForm.residentName = arc.residentName
        searchARCForm.residentOtherPhone = arc.residentOtherPhone
        searchARCForm.residentSigDate = arc.residentSigDate
        searchARCForm.residentSignature = arc.residentSignature
        searchARCForm.residentSigned = arc.residentSigned
        searchARCForm.reviewFEPlan = arc.createFEPlan
    }
    
    func theCells() {
        let c0 = CellBody.init(cellAttributes:[ "value1" : Sections.Header ], type:[ "type" : CellType.header ], fType: [ "fValue1" : aForm.campaignTitle, "fValue2": aForm.campaignTitle ],dType: [ "Date" :Date()],bType:[ "fValue" : false ], objID: [ "id" : nil])
        let c5 = CellBody.init(cellAttributes:[ "value1" : Sections.Campaign ], type: [ "type" : CellType.label ], fType: [ "fValue1" : "Campaign" ], dType: [ "Date" :Date()],bType:[ "fValue" : false ], objID: [ "id" : nil])
        let c1 = CellBody.init(cellAttributes:[ "value1" : Sections.CampaignCell ], type:[ "type" : CellType.campaignSwitch ], fType: [ "fValue1" : aForm.campaignTitle ],dType: [ "Date" :Date(), "fValue3" : aForm.campaignStart, "fValue4" : aForm.campaignEnd ], bType:["fValue2" : aForm.campaign,  "fValue3" : aForm.campaignComplete ], objID: [ "id" : nil])
        let c4 = CellBody.init(cellAttributes:[ "value1" : Sections.HomeAddress ], type: [ "type" : CellType.label ], fType: [ "fValue1" : "Home Address" ], dType: [ "Date" :Date()],bType:[ "fValue" : false ], objID: [ "id" : nil])
        let c2 = CellBody.init(cellAttributes: [ "value1" : Sections.LocationCell ], type: [ "type" : CellType.textLocation ], fType: ["fValue1" : aForm.address, "fValue2" : aForm.city , "fValue3" : aForm.state, "fValue4" : aForm.zip, "fValue5" : aForm.aptMobileNum ], dType: [ "date" : Date()], bType: [ "locationAvailable" : aForm.locationAvailable ], objID: [ "id" : nil])
        let c3 = CellBody.init(cellAttributes:[ "value1" : Sections.ServicesProvided ], type: [ "type" : CellType.label ], fType: [ "fValue1" : "Services Provided" ], dType: [ "Date" :Date()],bType:[ "fValue" : false ], objID: [ "id" : nil])
        let c6 = CellBody.init(cellAttributes:[ "value1" : Sections.NumNewSA  ], type: [ "type" : CellType.stepper ], fType: [ "fValue1" : "# of new smoke alarms installed and tested?", "fValue2" : aForm.numNewSA ], dType: [ "Date" :Date()],bType:[ "fValue" : false ], objID: [ "id" : nil])
        let c7 = CellBody.init(cellAttributes:[ "value1" : Sections.NumBellShaker ], type: [ "type" : CellType.stepper ], fType: [ "fValue1" : "# of new bed shaker alarms\r installed and tested (DHH)", "fValue2" : aForm.numBellShaker ], dType: [ "Date" :Date()],bType:[ "fValue" : false ], objID: [ "id" : nil])
        let c8 = CellBody.init(cellAttributes:[ "value1" : Sections.NumBatteriesReplaced ], type: [ "type" : CellType.stepper ], fType: [ "fValue1" : "# of batteries replaced?", "fValue2" : aForm.numBatteriesReplaced ], dType: [ "Date" :Date()],bType:[ "fValue" : false ], objID: [ "id" : nil])
        let c9 = CellBody.init(cellAttributes:[ "value1" : Sections.CreateFEP ], type: [ "type" : CellType.questionSwitch ], fType: [ "fValue1" : "Did the resident(s) create a fire escape plan?", "fValue2" : "" ], dType: [ "Date" :Date()],bType:[ "fValue3" : aForm.createFEP ], objID: [ "id" : nil])
        let c10 = CellBody.init(cellAttributes:[ "value1" : Sections.ReviewChecklist ], type: [ "type" : CellType.questionSwitch ], fType: [ "fValue1" : "Did the resident(s) review\r the Home Fire Safety Checklist?", "fValue2" : "" ], dType: [ "Date" :Date()],bType:[ "fValue3" : aForm.reviewChecklist ], objID: [ "id" : nil])
        let c11 = CellBody.init(cellAttributes:[ "value1" : Sections.LocalHazard ], type: [ "type" : CellType.questionSwitch ], fType: [ "fValue1" : "Did the resident(s) learn\r about a local hazard?", "fValue2" : "" ], dType: [ "Date" :Date()],bType:[ "fValue3" : aForm.localHazard ], objID: [ "id" : nil])
        let c12 = CellBody.init(cellAttributes:[ "value1" : Sections.DescHazard ], type: [ "type" : CellType.textField ], fType: [ "fValue1" : "If yes, what hazard?", "fValue2" : aForm.descHazard ], dType: [ "Date" :Date()],bType:[ "fValue3" : false ], objID: [ "id" : nil])
        let c14 = CellBody.init(cellAttributes:[ "value1" : Sections.InitialAssessmentUponVisit ], type: [ "type" : CellType.label ], fType: [ "fValue1" : "Initial Assessment Upon Visit" ], dType: [ "Date" :Date()],bType:[ "fValue" : false ], objID: [ "id" : nil])
        let c16 = CellBody.init(cellAttributes:[ "value1" : Sections.IANumPeople ], type: [ "type" : CellType.stepper ], fType: [ "fValue1" : "How many people live here?", "fValue2" : aForm.iaNumPeople ], dType: [ "Date" :Date()],bType:[ "fValue3" : false ], objID: [ "id" : nil])
        let c17 = CellBody.init(cellAttributes:[ "value1" : Sections.IA17Under ], type: [ "type" : CellType.stepper ], fType: [ "fValue1" : "How many youth ages 17 and under live here?", "fValue2" : aForm.ia17Under ], dType: [ "Date" :Date()],bType:[ "fValue3" : false ], objID: [ "id" : nil])
        let c18 = CellBody.init(cellAttributes:[ "value1" : Sections.IA65Over ], type: [ "type" : CellType.stepper ], fType: [ "fValue1" : "How many adults ages 65 and older live here?", "fValue2" : aForm.ia65Over ], dType: [ "Date" :Date()],bType:[ "fValue3" : false ], objID: [ "id" : nil])
        let c19 = CellBody.init(cellAttributes:[ "value1" : Sections.IADisability ], type: [ "type" : CellType.stepper ], fType: [ "fValue1" : "How many inidividuals with a disability, or an access or functional need live here?", "fValue2" : aForm.iaDisability ], dType: [ "Date" :Date()],bType:[ "fValue3" : false ], objID: [ "id" : nil])
        let c20 = CellBody.init(cellAttributes:[ "value1" : Sections.IAVets ], type: [ "type" : CellType.stepper ], fType: [ "fValue1" : "How many veterans, military members, or military family members live here?", "fValue2" : aForm.iaVets ], dType: [ "Date" :Date()],bType:[ "fValue3" : false ], objID: [ "id" : nil])
        let c21 = CellBody.init(cellAttributes:[ "value1" : Sections.IAPrexistingSA ], type: [ "type" : CellType.stepper ], fType: [ "fValue1" : "How many pre-existing smoke alarms\rdoes the household already have?", "fValue2" : aForm.iaPrexistingSA ], dType: [ "Date" :Date()],bType:[ "fValue3" : false ], objID: [ "id" : nil])
        let c22 = CellBody.init(cellAttributes:[ "value1" : Sections.IAWorkingSA ], type: [ "type" : CellType.stepper ], fType: [ "fValue1" : "How many pre-existing smoke\ralarms are working?", "fValue2" : aForm.iaWorkingSA ], dType: [ "Date" :Date()],bType:[ "fValue3" : false ], objID: [ "id" : nil])
        let c23 = CellBody.init(cellAttributes:[ "value1" : Sections.IANotes ], type: [ "type" : CellType.textArea ], fType: [ "fValue1" : "Additional Notes:", "fValue2" : aForm.iaNotes ], dType: [ "Date" :Date()],bType:[ "fValue3" : false ], objID: [ "id" : nil])
        let c24 = CellBody.init(cellAttributes:[ "value1" : Sections.PartnerReporting ], type: [ "type" : CellType.label ], fType: [ "fValue1" : "Partner Reporting" ], dType: [ "Date" :Date()],bType:[ "fValue" : false ], objID: [ "id" : nil])
        let c25 = CellBody.init(cellAttributes:[ "value1" : Sections.NationalPartner ], type: [ "type" : CellType.textField ], fType: [ "fValue1" : "National Partner:", "fValue2" : aForm.nationalPartner ], dType: [ "Date" :Date()],bType:[ "fValue3" : false ], objID: [ "id" : nil])
        let c26 = CellBody.init(cellAttributes:[ "value1" : Sections.LocalPartner ], type: [ "type" : CellType.textField ], fType: [ "fValue1" : "Local Partner(s):", "fValue2" : aForm.localPartner ], dType: [ "Date" :Date()],bType:[ "fValue3" : false ], objID: [ "id" : nil])
        let c27 = CellBody.init(cellAttributes:[ "value1" : Sections.RegionDesignatedReportingFields ], type: [ "type" : CellType.label ], fType: [ "fValue1" : "Region Designated Reporting Fields" ], dType: [ "Date" :Date()],bType:[ "fValue" : false ], objID: [ "id" : nil])
        let c28 = CellBody.init(cellAttributes:[ "value1" : Sections.Option1 ], type: [ "type" : CellType.textField ], fType: [ "fValue1" : "Optional 1.", "fValue2" : aForm.option1 ], dType: [ "Date" :Date()],bType:[ "fValue3" : false ], objID: [ "id" : nil])
        let c29 = CellBody.init(cellAttributes:[ "value1" : Sections.Option2 ], type: [ "type" : CellType.textField ], fType: [ "fValue1" : "Optional 2", "fValue2" : aForm.option2 ], dType: [ "Date" :Date()],bType:[ "fValue3" : false ], objID: [ "id" : nil])
        let c30 = CellBody.init(cellAttributes:[ "value1" : Sections.InfomrationForFuture ], type: [ "type" : CellType.label ], fType: [ "fValue1" : "Information for Future Follow-up" ], dType: [ "Date" :Date()],bType:[ "fValue" : false ], objID: [ "id" : nil])
        let c31 = CellBody.init(cellAttributes:[ "value1" : Sections.ContactInfo ], type: [ "type" : CellType.questionSwitch ], fType: [ "fValue1" : "Did the client provide contact info?", "fValue2" : "" ], dType: [ "Date" :Date()],bType:[ "fValue3" : aForm.contactInfo ], objID: [ "id" : nil])
        let c32 = CellBody.init(cellAttributes:[ "value1" : Sections.ResidentCellNum ], type: [ "type" : CellType.textField ], fType: [ "fValue1" : "Cell Phone Number:", "fValue2" : aForm.residentCellNum ], dType: [ "Date" :Date()],bType:[ "fValue3" : false ], objID: [ "id" : nil])
        let c33 = CellBody.init(cellAttributes:[ "value1" : Sections.ResidentEmail ], type: [ "type" : CellType.textField ], fType: [ "fValue1" : "Email Address:", "fValue2" : aForm.residentEmail ], dType: [ "Date" :Date()],bType:[ "fValue3" : false ], objID: [ "id" : nil])
        let c34 = CellBody.init(cellAttributes:[ "value1" : Sections.ResidentOtherPhone ], type: [ "type" : CellType.textField ], fType: [ "fValue1" : "Other Phone Number:", "fValue2" : aForm.residentOtherPhone ], dType: [ "Date" :Date()],bType:[ "fValue3" : false ], objID: [ "id" : nil])
        let c15 = CellBody.init(cellAttributes:[ "value1" : Sections.Signatures ], type: [ "type" : CellType.label ], fType: [ "fValue1" : "Signatures" ], dType: [ "Date" :Date()],bType:[ "fValue" : false ], objID: [ "id" : nil])
        let c13 = CellBody.init(cellAttributes:[ "value1" : Sections.SignaturesTextArea ], type: [ "type" : CellType.textArea ], fType: [ "fValue1" : "I am a resident of the home at the address above. Today, I received the services Indicated on this form. I also received Instructions about how to use and maintain smoke alarms. It Is my responslblllty to maintain the smoke alarm(s) per the manufacturer's recommendations and to test the alarm(s) monthly. It Is also my responsibility to make sure I have the appropriate type of smoke alarms In my home. Different types of alarms, Ionization and photoelectric, detect fires differently and experts recommend having both types. It Is additionally my responsibility to make sure that I have the appropriate number of smoke alarms and that the alarms are In appropriate locations. Furthermore, the American Red Cross and Its partners are not responsible for determining the appropriate type, number or location of smoke alarms.\r\rYour signature Indicates that you have read the Information above and that you agree with Its content." ], dType: [ "Date" :Date()],bType:[ "fValue3" : false ], objID: [ "id" : nil])
        let c35 = CellBody.init(cellAttributes:[ "value1" : Sections.SignatureCell ], type: [ "type" : CellType.signature ], fType: [ "fValue1" : "Resident's Printed Name", "fValue2" : aForm.residentName ,"fValue3" : "Resident's Signed Date", "fValue4" : "Installer's Printed Name", "fValue5" : aForm.installerName, "fValue6" : "Installer's Signed Date" ], dType:[ "Date" : aForm.residentSigDate ,"Date2" :aForm.installerDate ],bType:[ "fValue" : false ], objID: [ "id" : nil])
        let c39 = CellBody.init(cellAttributes:[ "value1" : Sections.AdministrativeSection ], type: [ "type" : CellType.label ], fType: [ "fValue1" : "Administrative Section: Complete Section Below After Record is Entered into the Online Reporting Portal" ], dType: [ "Date" :Date()],bType:[ "fValue" : false ], objID: [ "id" : nil])
        let c40 = CellBody.init(cellAttributes:[ "value1" : Sections.AdminName ], type: [ "type" : CellType.textField ], fType: [ "fValue1" : "Who entered the record into the online reporting portal?:", "fValue2" : aForm.adminName ], dType: [ "Date" :Date()],bType:[ "fValue3" : false ], objID: [ "id" : nil])
        let c41 = CellBody.init(cellAttributes:[ "value1" : Sections.AdminDate ], type: [ "type" : CellType.textFieldWDate ], fType: [ "fValue1" : "What date was record submitted into the online reporting portal?:", "fValue2" : "" ], dType: [ "Date" : aForm.adminDate ],bType:[ "fValue3" : false ], objID: [ "id" : nil])
        let c42 = CellBody.init(cellAttributes:[ "value1" : Sections.DatePicker ], type: [ "type" : CellType.datePicker ], fType: [ "fValue1" : "" ], dType: [ "Date" :Date()],bType:[ "fValue" : false ], objID: [ "id" : nil])
        
        cells = [c0,c5,c1,c4,c2,c3,c6,c7,c8,c9,c10,c11,c12,c14,c16,c17,c18,c19,c20,c21,c22,c23,c24,c25,c26,c27,c28,c29,c30,c31,c32,c33,c34,c15,c13,c35,c39,c40,c41,c42]
    }
    
    func buildTheCells() {
            cells.removeAll()
            if(objectID) != nil {
                searchARCForm = context.object(with: objectID!) as? ARCrossForm
                arc = ARCFormData.init(theArcForm: searchARCForm)
                
                if(searchARCForm) != nil {
                    if searchARCForm.objectID != objectID {
                        searchARCForm = nil
                        residentData = nil
                        residentSigImage = nil
                        installerData = nil
                        installerSigImage = nil
                        signatureType = ""
                    }
                }
                var campaign:String = ""
                var campaignName:String = ""
                if arc.campaignName != "" {
                    campaignName = arc.campaignName
                    if arc.campaignCount != 0 {
                        let count = String(arc.campaignCount)
                        campaign = "\(campaignName) Count: \(count)"
                    }
                }
                let c0 = CellBody.init(cellAttributes:[ "value1" : Sections.Header ], type:[ "type" : CellType.header ], fType: [ "fValue1" : campaign , "fValue2": aForm.campaignTitle ],dType: [ "Date" :Date()],bType:[ "fValue" : false ], objID: [ "id" : nil])
                let c5 = CellBody.init(cellAttributes:[ "value1" : Sections.Campaign ], type: [ "type" : CellType.label ], fType: [ "fValue1" : "Campaign" ], dType: [ "Date" :Date()],bType:[ "fValue" : false ], objID: [ "id" : nil])
                
                var cellDate2:Date = Date()
                if arc.isThereAcEndDate() {
                    cellDate2 = arc.cEndDate
                }
                var cellDate1:Date = Date()
                if arc.isThereAcStartDate() {
                    cellDate1 = arc.cStartDate
                }
                let c1 = CellBody.init(cellAttributes:[ "value1" : Sections.CampaignCell ], type:[ "type" : CellType.campaignSwitch ], fType: [ "fValue1" : arc.campaignName ],dType: [ "Date" : cellDate1 , "fValue3" : cellDate2 ], bType:["fValue1" : arc.campaign,  "fValue2" : arc.cComplete ], objID: [ "id" : nil])
                let c4 = CellBody.init(cellAttributes:[ "value1" : Sections.HomeAddress ], type: [ "type" : CellType.label ], fType: [ "fValue1" : "Home Address" ], dType: [ "Date" :Date()],bType:[ "fValue" : false ], objID: [ "id" : nil])
                let c2 = CellBody.init(cellAttributes: [ "value1" : Sections.LocationCell ], type: [ "type" : CellType.textLocation ], fType: ["fValue1" : arc.arcLocationAddress, "fValue2" : arc.arcLocationCity , "fValue3" : arc.arcLocaitonState, "fValue4" : arc.arcLocationZip, "fValue5" : arc.arcLocationAptMobile ], dType: [ "date" : Date()], bType: [ "locationAvailable" : arc.arcLocationAvailable ], objID: [ "id" : nil])
                let c3 = CellBody.init(cellAttributes:[ "value1" : Sections.ServicesProvided ], type: [ "type" : CellType.label ], fType: [ "fValue1" : "Services Provided" ], dType: [ "Date" :Date()],bType:[ "fValue" : false ], objID: [ "id" : nil])
                let c6 = CellBody.init(cellAttributes:[ "value1" : Sections.NumNewSA  ], type: [ "type" : CellType.stepper ], fType: [ "fValue1" : "# of new smoke alarms installed and tested?", "fValue2" : arc.numNewSA ], dType: [ "Date" :Date()],bType:[ "fValue" : false ], objID: [ "id" : nil])
                let c7 = CellBody.init(cellAttributes:[ "value1" : Sections.NumBellShaker ], type: [ "type" : CellType.stepper ], fType: [ "fValue1" : "# of new bed shaker alarms\r installed and tested (DHH)", "fValue2" : arc.numBedShaker ], dType: [ "Date" :Date()],bType:[ "fValue" : false ], objID: [ "id" : nil])
                let c8 = CellBody.init(cellAttributes:[ "value1" : Sections.NumBatteriesReplaced ], type: [ "type" : CellType.stepper ], fType: [ "fValue1" : "# of batteries replaced?", "fValue2" : arc.numBatteries ], dType: [ "Date" :Date()],bType:[ "fValue" : false ], objID: [ "id" : nil])
                let c9 = CellBody.init(cellAttributes:[ "value1" : Sections.CreateFEP ], type: [ "type" : CellType.questionSwitch ], fType: [ "fValue1" : "Did the resident(s) create a fire escape plan?", "fValue2" : "" ], dType: [ "Date" :Date()],bType:[ "fValue3" : arc.createFEPlan ], objID: [ "id" : nil])
                let c10 = CellBody.init(cellAttributes:[ "value1" : Sections.ReviewChecklist ], type: [ "type" : CellType.questionSwitch ], fType: [ "fValue1" : "Did the resident(s) review\r the Home Fire Safety Checklist?", "fValue2" : "" ], dType: [ "Date" :Date()],bType:[ "fValue3" : arc.reviewFEPlan ], objID: [ "id" : nil])
                let c11 = CellBody.init(cellAttributes:[ "value1" : Sections.LocalHazard ], type: [ "type" : CellType.questionSwitch ], fType: [ "fValue1" : "Did the resident(s) learn\r about a local hazard?", "fValue2" : "" ], dType: [ "Date" :Date()],bType:[ "fValue3" : arc.localHazard ], objID: [ "id" : nil])
                let c12 = CellBody.init(cellAttributes:[ "value1" : Sections.DescHazard ], type: [ "type" : CellType.textField ], fType: [ "fValue1" : "If yes, what hazard?", "fValue2" : arc.hazard ], dType: [ "Date" :Date()],bType:[ "fValue3" : false ], objID: [ "id" : nil])
                let c14 = CellBody.init(cellAttributes:[ "value1" : Sections.InitialAssessmentUponVisit ], type: [ "type" : CellType.label ], fType: [ "fValue1" : "Initial Assessment Upon Visit" ], dType: [ "Date" :Date()],bType:[ "fValue" : false ], objID: [ "id" : nil])
                let c16 = CellBody.init(cellAttributes:[ "value1" : Sections.IANumPeople ], type: [ "type" : CellType.stepper ], fType: [ "fValue1" : "How many people live here?", "fValue2" : arc.iaNumPeople ], dType: [ "Date" :Date()],bType:[ "fValue3" : false ], objID: [ "id" : nil])
                let c17 = CellBody.init(cellAttributes:[ "value1" : Sections.IA17Under ], type: [ "type" : CellType.stepper ], fType: [ "fValue1" : "How many youth ages 17 and under live here?", "fValue2" : arc.ia17Under ], dType: [ "Date" :Date()],bType:[ "fValue3" : false ], objID: [ "id" : nil])
                let c18 = CellBody.init(cellAttributes:[ "value1" : Sections.IA65Over ], type: [ "type" : CellType.stepper ], fType: [ "fValue1" : "How many adults ages 65 and older live here?", "fValue2" : arc.ia65Over ], dType: [ "Date" :Date()],bType:[ "fValue3" : false ], objID: [ "id" : nil])
                let c19 = CellBody.init(cellAttributes:[ "value1" : Sections.IADisability ], type: [ "type" : CellType.stepper ], fType: [ "fValue1" : "How many inidividuals with a disability, or an access or functional need live here?", "fValue2" : arc.iaDisability ], dType: [ "Date" :Date()],bType:[ "fValue3" : false ], objID: [ "id" : nil])
                let c20 = CellBody.init(cellAttributes:[ "value1" : Sections.IAVets ], type: [ "type" : CellType.stepper ], fType: [ "fValue1" : "How many veterans, military members, or military family members live here?", "fValue2" : arc.iaVets ], dType: [ "Date" :Date()],bType:[ "fValue3" : false ], objID: [ "id" : nil])
                let c21 = CellBody.init(cellAttributes:[ "value1" : Sections.IAPrexistingSA ], type: [ "type" : CellType.stepper ], fType: [ "fValue1" : "How many pre-existing smoke alarms\rdoes the household already have?", "fValue2" : arc.iaPrexistingSA ], dType: [ "Date" :Date()],bType:[ "fValue3" : false ], objID: [ "id" : nil])
                let c22 = CellBody.init(cellAttributes:[ "value1" : Sections.IAWorkingSA ], type: [ "type" : CellType.stepper ], fType: [ "fValue1" : "How many pre-existing smoke\ralarms are working?", "fValue2" : arc.iaWorkingSA ], dType: [ "Date" :Date()],bType:[ "fValue3" : false ], objID: [ "id" : nil])
                let c23 = CellBody.init(cellAttributes:[ "value1" : Sections.IANotes ], type: [ "type" : CellType.textArea ], fType: [ "fValue1" : "Additional Notes:", "fValue2" : arc.iaNotes ], dType: [ "Date" :Date()],bType:[ "fValue3" : false ], objID: [ "id" : nil])
                let c24 = CellBody.init(cellAttributes:[ "value1" : Sections.PartnerReporting ], type: [ "type" : CellType.label ], fType: [ "fValue1" : "Partner Reporting" ], dType: [ "Date" :Date()],bType:[ "fValue" : false ], objID: [ "id" : nil])
                let c25 = CellBody.init(cellAttributes:[ "value1" : Sections.NationalPartner ], type: [ "type" : CellType.textField ], fType: [ "fValue1" : "National Partner:", "fValue2" : arc.nationalPartner ], dType: [ "Date" :Date()],bType:[ "fValue3" : false ], objID: [ "id" : nil])
                let c26 = CellBody.init(cellAttributes:[ "value1" : Sections.LocalPartner ], type: [ "type" : CellType.textField ], fType: [ "fValue1" : "Local Partner(s):", "fValue2" : arc.localPartner ], dType: [ "Date" :Date()],bType:[ "fValue3" : false ], objID: [ "id" : nil])
                let c27 = CellBody.init(cellAttributes:[ "value1" : Sections.RegionDesignatedReportingFields ], type: [ "type" : CellType.label ], fType: [ "fValue1" : "Region Designated Reporting Fields" ], dType: [ "Date" :Date()],bType:[ "fValue" : false ], objID: [ "id" : nil])
                let c28 = CellBody.init(cellAttributes:[ "value1" : Sections.Option1 ], type: [ "type" : CellType.textField ], fType: [ "fValue1" : "Optional 1.", "fValue2" : arc.option1 ], dType: [ "Date" :Date()],bType:[ "fValue3" : false ], objID: [ "id" : nil])
                let c29 = CellBody.init(cellAttributes:[ "value1" : Sections.Option2 ], type: [ "type" : CellType.textField ], fType: [ "fValue1" : "Optional 2", "fValue2" : arc.option2 ], dType: [ "Date" :Date()],bType:[ "fValue3" : false ], objID: [ "id" : nil])
                let c30 = CellBody.init(cellAttributes:[ "value1" : Sections.InfomrationForFuture ], type: [ "type" : CellType.label ], fType: [ "fValue1" : "Information for Future Follow-up" ], dType: [ "Date" :Date()],bType:[ "fValue" : false ], objID: [ "id" : nil])
                let c31 = CellBody.init(cellAttributes:[ "value1" : Sections.ContactInfo ], type: [ "type" : CellType.questionSwitch ], fType: [ "fValue1" : "Did the client provide contact info?", "fValue2" : "" ], dType: [ "Date" :Date()],bType:[ "fValue3" : arc.residentContactInfo ], objID: [ "id" : nil])
                let c32 = CellBody.init(cellAttributes:[ "value1" : Sections.ResidentCellNum ], type: [ "type" : CellType.textField ], fType: [ "fValue1" : "Cell Phone Number:", "fValue2" : arc.residentCellNum ], dType: [ "Date" :Date()],bType:[ "fValue3" : false ], objID: [ "id" : nil])
                let c33 = CellBody.init(cellAttributes:[ "value1" : Sections.ResidentEmail ], type: [ "type" : CellType.textField ], fType: [ "fValue1" : "Email Address:", "fValue2" : arc.residentEmail ], dType: [ "Date" :Date()],bType:[ "fValue3" : false ], objID: [ "id" : nil])
                let c34 = CellBody.init(cellAttributes:[ "value1" : Sections.ResidentOtherPhone ], type: [ "type" : CellType.textField ], fType: [ "fValue1" : "Other Phone Number:", "fValue2" : arc.residentOtherPhone ], dType: [ "Date" :Date()],bType:[ "fValue3" : false ], objID: [ "id" : nil])
                let c15 = CellBody.init(cellAttributes:[ "value1" : Sections.Signatures ], type: [ "type" : CellType.label ], fType: [ "fValue1" : "Signatures" ], dType: [ "Date" :Date()],bType:[ "fValue" : false ], objID: [ "id" : nil])
                let c13 = CellBody.init(cellAttributes:[ "value1" : Sections.SignaturesTextArea ], type: [ "type" : CellType.textArea ], fType: [ "fValue1" : "I am a resident of the home at the address above. Today, I received the services Indicated on this form. I also received Instructions about how to use and maintain smoke alarms. It Is my responslblllty to maintain the smoke alarm(s) per the manufacturer's recommendations and to test the alarm(s) monthly. It Is also my responsibility to make sure I have the appropriate type of smoke alarms In my home. Different types of alarms, Ionization and photoelectric, detect fires differently and experts recommend having both types. It Is additionally my responsibility to make sure that I have the appropriate number of smoke alarms and that the alarms are In appropriate locations. Furthermore, the American Red Cross and Its partners are not responsible for determining the appropriate type, number or location of smoke alarms.\r\rYour signature Indicates that you have read the Information above and that you agree with Its content." ], dType: [ "Date" :Date()],bType:[ "fValue3" : false ], objID: [ "id" : nil])
                var cellDate3:Date = Date()
                if arc.installerHasSigned() {
                    cellDate3 = arc.installerDate
                }
                var cellDate4:Date = Date()
                if arc.residentHasSigned() {
                    cellDate4 = arc.residentSigDate
                }
                let c35 = CellBody.init(cellAttributes:[ "value1" : Sections.SignatureCell ], type: [ "type" : CellType.signature ], fType: [ "fValue1" : "Resident's Printed Name", "fValue2" : arc.residentName ,"fValue3" : "Resident's Date", "fValue4" : "Installer's Printed Name", "fValue5" : arc.installerName, "fValue6" : "Installer's Date" ], dType:[ "Date" : cellDate4 ,"Date2" :cellDate3 ],bType:[ "signature" : arc.residentSigned ], objID: [ "id" : nil])
                if (arc.installerSigend) {
                    //                TODO: SIGNATURE
                    if arc.installerSignature != nil {
                        outputImageI = UIImage(data:(arc.installerSignature)!,scale:1.0)
                        installerData = arc.installerSignature
                    }
                }
                if (arc.residentSigned) {
                    //                TODO: SIGNATURE
                    if arc.residentSignature != nil {
                        outputImageR = UIImage(data:(arc.residentSignature)!,scale:1.0)
                        residentData = arc.residentSignature
                    }
                }
                let c39 = CellBody.init(cellAttributes:[ "value1" : Sections.AdministrativeSection ], type: [ "type" : CellType.label ], fType: [ "fValue1" : "Administrative Section: Complete Section Below After Record is Entered into the Online Reporting Portal" ], dType: [ "Date" :Date()],bType:[ "fValue" : false ], objID: [ "id" : nil])
                let c40 = CellBody.init(cellAttributes:[ "value1" : Sections.AdminName ], type: [ "type" : CellType.textField ], fType: [ "fValue1" : "Who entered the record into the online reporting portal?:", "fValue2" : arc.adminName ], dType: [ "Date" :Date()],bType:[ "fValue3" : false ], objID: [ "id" : nil])
                if arc.isThereAnAdminDate() {
                    cellDate4 = arc.adminDate
                }
                let c41 = CellBody.init(cellAttributes:[ "value1" : Sections.AdminDate ], type: [ "type" : CellType.textFieldWDate ], fType: [ "fValue1" : "What date was record submitted into the online reporting portal?:", "fValue2" : "" ], dType: [ "Date" : cellDate4 ],bType:[ "fValue3" : false ], objID: [ "id" : nil])
                let c42 = CellBody.init(cellAttributes:[ "value1" : Sections.DatePicker ], type: [ "type" : CellType.datePicker ], fType: [ "fValue1" : "" ], dType: [ "Date" :Date()],bType:[ "fValue" : false ], objID: [ "id" : nil])
                
                cells = [c0,c5,c1,c4,c2,c3,c6,c7,c8,c9,c10,c11,c12,c14,c16,c17,c18,c19,c20,c21,c22,c23,c24,c25,c26,c27,c28,c29,c30,c31,c32,c33,c34,c15,c13,c35,c39,c40,c41,c42]
                tableView.reloadData()
                scrollToTop()
            } else {
                print("lets go fetch")
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ARCrossForm")
                let sectionSortDescriptor = NSSortDescriptor(key: "cStartDate", ascending: true)
                let sortDescriptors = [sectionSortDescriptor]
                fetchRequest.sortDescriptors = sortDescriptors
                do {
                    theCells()
                    let fetchedForm = try context.fetch(fetchRequest) as! [ARCrossForm]
    //                print("here is fetchform \(fetchedForm) and count \(fetchedForm.count)")
                    if fetchedForm.count == 0 {
                        print("hey we have zero")
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: notificationKeyNOARCAVAIL), object: nil, userInfo:nil)
                        }
                    } else {
                        arcForm = fetchedForm.last
                        objectID = arcForm.objectID
                        buildTheCells()
                    }
                }  catch {
                    let nserror = error as NSError
                    let errorMessage = "ARCFormDetailTVC buildTheCells() Unresolved error \(nserror), \(nserror.userInfo)"
                    print(errorMessage)
                }
            }
        }
    
    func registerTheCells() {
        tableView.register(UINib(nibName: "FormHeaderCell", bundle: nil), forCellReuseIdentifier: "FormHeaderCell")
        tableView.register(UINib(nibName: "FormQuestionTFCell", bundle: nil), forCellReuseIdentifier: "FormQuestionTFCell")
        tableView.register(UINib(nibName: "QuestionWSwitch", bundle: nil), forCellReuseIdentifier: "QuestionWSwitch")
        tableView.register(UINib(nibName: "FormDatePickerCell", bundle: nil), forCellReuseIdentifier: "FormDatePickerCell")
        tableView.register(UINib(nibName: "IncidentLocationButtonCell", bundle: nil), forCellReuseIdentifier: "IncidentLocationButtonCell")
        tableView.register(UINib(nibName: "SectionLabelCell", bundle: nil), forCellReuseIdentifier: "SectionLabelCell")
        tableView.register(UINib(nibName: "CampaignCell", bundle: nil), forCellReuseIdentifier: "CampaignCell")
        tableView.register(UINib(nibName: "DoubleSignatureCell", bundle: nil), forCellReuseIdentifier: "DoubleSignatureCell")
        tableView.register(UINib(nibName: "ARCTextViewCell", bundle: nil), forCellReuseIdentifier: "ARCTextViewCell")
        tableView.register(UINib(nibName: "QuestionWSwitch", bundle: nil), forCellReuseIdentifier: "QuestionWSwitch")
        tableView.register(UINib(nibName: "LocationCell", bundle: nil), forCellReuseIdentifier: "LocationCell")
        tableView.register(UINib(nibName: "AdminDateCell", bundle: nil), forCellReuseIdentifier: "AdminDateCell")
        tableView.register(UINib(nibName: "StepperTFCell", bundle: nil), forCellReuseIdentifier: "StepperTFCell")
    }
    
    func saveToCD() {
        syncTheData()
        arc.arcModDate = Date()
        arc.arcBackup = false;
        do {
            try context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"ARCFormDetailTVC merge that"])
            }
            DispatchQueue.main.async {
                self.nc.post(name: Notification.Name(rawValue: FJkRELOADTHELIST),
                             object: nil, userInfo: ["shift":MenuItems.arcForm])
            }
        } catch let error as NSError {
            
            let nserror = error
            let errorMessage = "ARCFormDetailTVC saveARCForm(_ sender:Any) Unresolved error \(nserror), \(nserror.userInfo)"
            print(errorMessage)
        }

        
        DispatchQueue.main.async {
            self.nc.post(name:Notification.Name(rawValue:fjkMODIFIEDARCFORM_GOTOCLOUDKIT),
                    object: nil,
                    userInfo: ["objectID":self.searchARCForm.objectID, "date":self.arc.cStartDate ,"arcFormGuid":self.arc.arcFormGuid ])
        }
    }
    
}

extension ARCFormDetailTVC: FormQuestionTFCellDelegate {
    func singleTextFieldInput(type: ValueType, input: String ) {}
    func singleTextFieldInputWithForm(type: CellType, input: String, section:Sections ) {
        let tfForm:CellType = type
        let tfSection:Sections = section
        let tfString = input
        switch tfForm {
        case .textField:
            switch tfSection {
            case .DescHazard:
                arc.hazard = tfString
            case .NationalPartner:
                arc.nationalPartner = tfString
            case .LocalPartner:
                arc.localPartner = tfString
            case .Option1:
                arc.option1 = tfString
            case .Option2:
                arc.option2 = tfString
            case .ResidentCellNum:
                arc.residentCellNum = tfString
            case .ResidentEmail:
                arc.residentEmail = tfString
            case .ResidentOtherPhone:
                arc.residentOtherPhone = tfString
            case .AdminName:
                arc.adminName = tfString
            default:
                print("")
            }
        default:
            print("")
        }
        tableView.reloadData()
    }
    
    func singleTextFieldCompleted(complete: Bool) {
        presentAlert()
    }
    
}

extension ARCFormDetailTVC: FormDatePickerCellDelegate {
    
    func chosenToDate(date: Date) {
        arc.adminDate = date
        buildTheCells()
        showPicker = false
        tableView.reloadData()
        scrollToBottom()
    }
    
}

extension ARCFormDetailTVC: AdminDataCellDelegate {
    
    func dateBTap() {
        if(showPicker) {
            showPicker = false
        } else {
            showPicker = true
        }
        tableView.reloadData()
        scrollToBottom()
    }

}

extension ARCFormDetailTVC: DoubleSignatureCellDelegate,T1AutographDelegate {
    
        func theTextFieldOnSignatureComplete(complete: Bool ) {
            presentAlert()
            }
    
        func residentSigTapped() {
            residentSignatureButtonTapped()
        }
        
        func installerSigTapped() {
            installerSignatureButtonTapped()
        }
    
        func residentSignatureButtonTapped() {
            autographR = T1Autograph.autograph(withDelegate: self, modalDisplay: "Resident Signature") as! T1Autograph

            // Enter license code here to remove the watermark
            autographR.licenseCode = "9186d2059ae047426bd0c571a0cf637ef569a6c4"

            // any optional configuration done here
            autographR.showDate = false
            autographR.strokeColor = UIColor.darkGray
            NSLog("Autograph SDK build number %d", autographR.buildNumber)
            signatureType = "Resident"
        }
    
        func installerSignatureButtonTapped() {
            autographI = T1Autograph.autograph(withDelegate: self, modalDisplay: "Resident Signature") as! T1Autograph

            // Enter license code here to remove the watermark
            autographI.licenseCode = "9186d2059ae047426bd0c571a0cf637ef569a6c4"

            // any optional configuration done here
            autographI.showDate = false
            autographI.strokeColor = UIColor.darkGray
            NSLog("Autograph SDK build number %d", autographI.buildNumber)
            signatureType = "Installer"
        }
        
        func theTextFieldOnSignatureTyped(textNames:[ String : String ]) {
            arc.residentName = textNames["Resident"]!
            arc.installerName = textNames["Installer"]!
        }
       
        func autograph(_ autograph: T1Autograph!, didCompleteWith signature: T1Signature!) {
            NSLog("-- Autograph signature completed. --")
            if signatureType == "Installer" {
                installerDate = Date()
                outputImageI = UIImage(data:signature.imageData,scale:1.0)
                arc.installerSignature = signature.imageData
                arc.installerDate = installerDate
                arc.installerSigend = true
                let count = 35
                let indexPath = IndexPath(row: count, section: 0)
                let cell = tableView.cellForRow(at: indexPath) as! DoubleSignatureCell
                _ = cell.textFieldShouldEndEditing(cell.installerNameTF)
                installerSig = true
            } else if signatureType == "Resident" {
                residentDate = Date()
                outputImageR = UIImage(data:signature.imageData,scale:1.0)
                arc.residentSignature = signature.imageData
                arc.residentSigDate = residentDate
                arc.residentSigned = true
                residentSig = true
                let count = 35
                let indexPath = IndexPath(row: count, section: 0)
                let cell = tableView.cellForRow(at: indexPath) as! DoubleSignatureCell
                _ = cell.textFieldShouldEndEditing(cell.residentNameTF)
            }
            saveToCD()
            let count = 35
            let indexPath = IndexPath(row: count, section: 0)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        func autographDidCancelModalView(_ autograph: T1Autograph!) {
            NSLog("Autograph modal signature has been cancelled")
            if signatureType == "Installer" {
                installerDate = Date()
                outputImageI = nil
                installerSig = false
                arc.installerSigend = false
            } else if signatureType == "Resident" {
                residentDate = Date()
                outputImageR = nil
                residentSig = false
                arc.residentSigned = false
            }
            tableView.reloadData()
        }
        
        func autographDidCompleteWithNoSignature(_ autograph: T1Autograph!) {
            NSLog("User pressed the done button without signing")
            if signatureType == "Installer" {
                installerDate = Date()
                outputImageI = nil
                installerSig = false
                arc.installerSigend = false
            } else if signatureType == "Resident" {
                residentDate = Date()
                outputImageR = nil
                residentSig = false
                arc.residentSigned = false
            }
            tableView.reloadData()
        }
        
        func autograph(_ autograph: T1Autograph!, didEndLineWithSignaturePointCount count: UInt) {
            NSLog("Line ended with total signature point count of %d", count)
            // Note: You can use the 'count' parameter to determine if the line is substantial enough to enable the done or clear button.
        }
        
        func autograph(_ autograph: T1Autograph!, willCompleteWith signature: T1Signature!) {
            NSLog("Autograph will complete with signature")
        }
}

extension ARCFormDetailTVC: LocationCellDelegate, NewIncidentMapDelegate, CLLocationManagerDelegate {
    
    func theTextFieldOnLocationComplete(complete: Bool) {
        presentAlert()
    }
    
    func theTextFieldOnLocationCTyped(textLocation:[ String : String ]) {
            arc.arcLocationAddress = textLocation["Address"] ?? ""
            arc.arcLocationCity = textLocation["City"] ?? ""
            arc.arcLocaitonState = textLocation["State"] ?? ""
            arc.arcLocationZip = textLocation["Zip"] ?? ""
            arc.arcLocationAptMobile = textLocation["AptSuite"] ?? ""
            tableView.reloadData()
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
                    self.arc.arcLocationAvailable = false
                    return
                }
                
                if placemarks?.count != 0 {
                    let pm = placemarks![0]
                    print(pm.locality!)
                    self.arc.arcLocationCity = "\(pm.locality!)"
                    self.streetNum = "\(pm.subThoroughfare!)"
                    self.streetName = "\(pm.thoroughfare!)"
                    self.arc.arcLocationAddress = "\(self.streetNum) \(self.streetName)"
                    self.state = "\(pm.administrativeArea!)"
                    self.arc.arcLocaitonState = self.state
                    self.zip = "\(pm.postalCode!)"
                    self.arc.arcLocationZip = self.zip
                    self.arc.arcLocationAvailable = true
                    self.arc.arcLocation = userLocation
                    self.buildTheCells()
                    self.tableView.reloadData()
                }
                else {
                    print("Problem with the data received from geocoder")
                    self.arc.arcLocationAvailable = false
                }
            })
        }
    
        func theMapButtonTapped() {
            let storyBoard : UIStoryboard = UIStoryboard(name: "ICS214Form", bundle:nil)
            let modalTVC = storyBoard.instantiateViewController(withIdentifier: "NewIncidentMapVC") as! NewIncidentMapVC
            modalTVC.delegate = self
            modalTVC.mapType = "ARCForm"
            let modalNavigationController:UINavigationController = UINavigationController(rootViewController: modalTVC)
            modalNavigationController.modalPresentationStyle = .formSheet
            self.present(modalNavigationController, animated: true, completion: nil)
        }
        
        func theMapCancelButtonTapped() {
            self.dismiss(animated: true, completion: nil)
        }
        
        func theMapLocationHasBeenChosen(location: CLLocation) {
            self.dismiss(animated: true, completion: nil)
            arc.arcLocation = location
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
                
                if error != nil {
                    print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                    self.arc.arcLocationAvailable = false
                    return
                }
                
                if placemarks?.count != 0 {
                    let pm = placemarks![0]
                    print(pm.locality!)
                    self.arc.arcLocationCity = "\(pm.locality!)"
                    self.streetNum = "\(pm.subThoroughfare!)"
                    self.streetName = "\(pm.thoroughfare!)"
                    self.arc.arcLocationAddress = "\(self.streetNum) \(self.streetName)"
                    self.state = "\(pm.administrativeArea!)"
                    self.arc.arcLocaitonState = self.state
                    self.zip = "\(pm.postalCode!)"
                    self.arc.arcLocationZip = self.zip
                    self.arc.arcLocationAvailable = true
                    self.tableView.reloadData()
                }
                else {
                    print("Problem with the data received from geocoder")
                    self.arc.arcLocationAvailable = false
                }
            })
        }
    
}

extension ARCFormDetailTVC: QuestionSwitchDelegate {
    
    func theSwitchIsTapped(switchState:Bool,section:Sections) {
        let tfSection:Sections = section
        switch tfSection {
        case .CreateFEP:
            arc.createFEPlan = switchState
        case .ReviewChecklist:
            arc.reviewFEPlan = switchState
        case .LocalHazard:
            arc.localHazard = switchState
        case .ContactInfo:
            arc.residentContactInfo = switchState
        default: break
        }
    }
    
    func theCompleteIsMarkedTrue(complete: Bool) {
        presentAlert()
    }
    
}

extension ARCFormDetailTVC: NewARCFormDelegate {
    func theARCFormCancelled() {}
}

extension ARCFormDetailTVC: ARCTextViewCellDelegate {
    
    func theTextInTextViewChanged(text:String,section: Sections) {
        switch section {
        case .IANotes:
            arc.iaNotes = text
        default: break
        }
        tableView.reloadData()
    }
    
    func theTextViewCompleted(complete: Bool) {
        presentAlert()
    }
    
}

extension ARCFormDetailTVC: CampaignCellDelegate {
    
    func campaignSwitchWasTapped(tapped: Bool, date: Date) {
        campaignOnOff.toggle()
        
        if campaignOnOff {
            arc.cStartDate = date
            arc.cComplete = campaignOnOff
        } else {
            arc.cEndDate = date
            arc.cComplete = campaignOnOff
        }
        syncTheData()
        do {
            try context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"ARCFormDetailTVC merge that"])
            }
            DispatchQueue.main.async {
                self.nc.post(name: Notification.Name(rawValue: FJkRELOADTHELIST),
                             object: nil, userInfo: ["shift":MenuItems.arcForm])
            }
        }  catch let error as NSError {
            let nserror = error
            let errorMessage = "ARCFormDetailTVC markAllComplete(tapped: Bool) Unresolved error \(nserror), \(nserror.userInfo)"
                print(errorMessage)
        }
        
//        let indexPath = IndexPath(row: 2, section: 0)
//        tableView.reloadRows(at: [indexPath], with: .automatic)
        
        if !campaignOnOff {
            markAllComplete()
        }
    }
    
    func campaignTitleChanged(campaignName: String) {
        arc.campaignName = campaignName
        saveToCD()
    }
    
    func markAllComplete() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ARCrossForm")
        var predicate = NSPredicate.init()
        var predicate2 = NSPredicate.init()
        predicate = NSPredicate(format: "arcFormCampaignGuid == %@",arc.arcFormCampaignGuid)
        predicate2 = NSPredicate(format: "cComplete == %@", NSNumber(value:true))
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate, predicate2])
        fetchRequest.predicate = predicateCan
        do {
            let arcFormFetched = try context.fetch(fetchRequest) as! [ARCrossForm]
            if arcFormFetched.count != 0 {
                for arcMultiple:ARCrossForm in arcFormFetched {
                    if campaignOnOff {
                        arcMultiple.cComplete = false
                        arcMultiple.cStartDate = arc.cStartDate
                    } else {
                        arcMultiple.cComplete = true
                        arcMultiple.cEndDate = arc.cEndDate
                    }
                }
                do {
                    try context.save()
                    DispatchQueue.main.async {
                        self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"ARCFormDetailTVC merge that"])
                    }
                    DispatchQueue.main.async {
                        self.nc.post(name: Notification.Name(rawValue: FJkRELOADTHELIST),
                                     object: nil, userInfo: ["shift":MenuItems.arcForm])
                    }
                }  catch let error as NSError {
                    let nserror = error
                    let errorMessage = "ARCFormDetailTVC markAllComplete(tapped: Bool) Unresolved error \(nserror), \(nserror.userInfo)"
                        print(errorMessage)
                }
            }
        }  catch {
        }
        
        tableView.reloadData()

    }
    
}

extension ARCFormDetailTVC: StepperTFCellDelegate {
    
    func stepperTapped(count: String, section: Sections, indexPath: IndexPath) {
        switch section {
        case .NumNewSA:
            arc.numNewSA = count
        case .NumBellShaker:
            arc.numBedShaker = count
        case .NumBatteriesReplaced:
            arc.numBatteries = count
        case .IANumPeople:
            arc.iaNumPeople = count
        case .IA17Under:
            arc.ia17Under = count
        case .IA65Over:
            arc.ia65Over = count
        case .IADisability:
            arc.iaDisability = count
        case .IAVets:
            arc.iaVets = count
        case .IAPrexistingSA:
            arc.iaPrexistingSA = count
        case .IAWorkingSA:
            arc.iaWorkingSA = count
        default: break
        }
        tableView.reloadData()
    }
    
    func stepperCompleted(complete: Bool) {
        presentAlert()
    }
    
}
