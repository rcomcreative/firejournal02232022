//
//  ARCFormData.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/14/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreLocation

class ARCFormData {

    var thread:Thread!
    let nc = NotificationCenter.default
    var arCrossForm: ARCrossForm
    var readingFromCD: Bool = false
    let vcLaunch = VCLaunch()
    
    private var _adminDate: Date? = nil
    var adminDateM: String = ""
    var adminDateD: String = ""
    var adminDateY: String = ""
    var adminDate: Date {
           get {
               let date = _adminDate ?? Date()
               return date
           }
           set (newDate) {
               _adminDate = newDate
            let datesS = vcLaunch.threeComponentsDate(date: newDate)
            adminDateM = datesS[0]
            adminDateD = datesS[1]
            adminDateY = datesS[2]
           }
       }
    var adminName: String = ""
    var arcBackup: Bool = false
    var arcCreationDate: Date = Date()
    var arcFormCampaignGuid: String = ""
    var arcFormGuid: String = ""
    var arcLocaitonState: String = ""
    var arcLocationSC: NSObject? = nil
    var arcLocationAddress: String = ""
    var arcLocationAptMobile: String = ""
    var arcLocationAvailable: Bool = false
    var arcLocationCity: String = ""
    var arcLocationZip: String = ""
    var arcMaster: Bool = false
    var arcModDate: Date = Date()
    var campaign: Bool = false
    var campaignCount: Int64 = 0
    var campaignName: String = ""
    var campaignStartEndText = ""
    var cComplete: Bool = false
    private var _cEndDate: Date? = nil
    var cEndDate: Date {
        get {
            let date = _cEndDate ?? Date()
            return date
        }
        set (newDate) {
            _cEndDate = newDate
        }
    }
    var createFEPlan: Bool = false
    private var _cStartDate: Date? = nil
    var cStartDate: Date {
        get {
            let date = _cStartDate ?? Date()
            return date
        }
        set (newDate) {
            _cStartDate = newDate
        }
    }
    var fjUserGuid: String = ""
    var hazard: String = ""
    var ia17Under: String = "0"
    var ia65Over: String = "0"
    var iaDisability: String = "0"
    var iaNotes: String = ""
    var iaNumPeople: String = "0"
    var iaPrexistingSA: String = "0"
    var iaVets: String = "0"
    var iaWorkingSA: String = "0"
    var installerDateString: String = ""
    private var _installerDate:Date? = nil
    var installerDate:Date {
        get {
            let date = _installerDate ?? Date()
            installerDateString = vcLaunch.fullDateString(date: date)
            return date
        }
        set (newDate) {
            _installerDate = newDate
            installerDateString = vcLaunch.fullDateString(date: newDate)
        }
    }
    var installerName: String = ""
    var installerSigend: Bool = false
    var installerSignature: Data? = nil
    var journalGuid: String = ""
    var localHazard: Bool = false
    var localPartner: String = ""
    var nationalPartner: String = ""
    var numBatteries: String = "0"
    var numBedShaker: String = "0"
    var numNewSA: String = "0"
    var option1: String = ""
    var option2: String = ""
    var residentCellNum: String = ""
    var residentContactInfo: Bool = false
    var residentEmail: String = ""
    var residentName: String = ""
    var residentOtherPhone: String = ""
    var residentSigDateString: String = ""
    private var _residentSigDate: Date? = nil
    var residentSigDate: Date {
        get {
                   let date = _residentSigDate ?? Date()
                   residentSigDateString = vcLaunch.fullDateString(date: date)
                   return date
               }
               set (newDate) {
                   _residentSigDate = newDate
                   residentSigDateString = vcLaunch.fullDateString(date: newDate)
               }
    }
    var residentSignature: Data? = nil
    var residentSigned: Bool = false
    var reviewFEPlan: Bool = false
    
    init(theArcForm: ARCrossForm ) {
        self.arCrossForm = theArcForm
        getTheForm()
    }
    
    func installerHasSigned() -> Bool {
        if _installerDate == nil {
            return false
        }
        return true
    }
    
    func residentHasSigned() -> Bool {
        if _residentSigDate == nil {
            return false
        }
        return true
    }
    
    func isThereAcStartDate() -> Bool {
        if _cStartDate == nil {
            return false
        }
        return true
    }
    
    func isThereAcEndDate() -> Bool {
        if _cEndDate == nil {
            return false
        }
        return true
    }
    
    func isThereAnAdminDate() -> Bool {
        if _adminDate == nil {
            return false
        }
        return true
    }
    
    //    MARK: -get the form from context-
    func getTheForm() {
        adminDate = arCrossForm.adminDate ?? Date()
        adminName = arCrossForm.adminName ?? ""
        arcCreationDate = arCrossForm.arcCreationDate ?? Date()
        arcFormCampaignGuid = arCrossForm.arcFormCampaignGuid ?? ""
        arcFormGuid = arCrossForm.arcFormGuid ?? ""
        arcLocaitonState = arCrossForm.arcLocaitonState ?? ""
        arcLocationSC = arCrossForm.arcLocationSC ?? nil
        arcLocationAddress = arCrossForm.arcLocationAddress ?? ""
        arcLocationAptMobile = arCrossForm.arcLocationAptMobile ?? ""
        arcLocationAvailable = arCrossForm.arcLocationAvailable
        arcLocationCity = arCrossForm.arcLocationCity ?? ""
        arcLocationZip = arCrossForm.arcLocationZip ?? ""
        arcMaster = arCrossForm.arcMaster
        arcModDate = arCrossForm.arcModDate ?? Date()
        campaign = arCrossForm.campaign
        campaignCount = arCrossForm.campaignCount
        campaignName = arCrossForm.campaignName ?? "No Campaign Name Set"
        cComplete = arCrossForm.cComplete
        cEndDate = arCrossForm.cEndDate ?? Date()
        createFEPlan = arCrossForm.createFEPlan
        cStartDate = arCrossForm.cStartDate ?? Date()
        fjUserGuid = arCrossForm.fjUserGuid ?? ""
        hazard = arCrossForm.hazard ?? ""
        if arCrossForm.ia17Under == "" || arCrossForm.ia17Under == nil {
            ia17Under = "0"
        } else {
            ia17Under = arCrossForm.ia17Under!
        }
        if arCrossForm.ia65Over == ""  || arCrossForm.ia65Over == nil {
            ia65Over = "0"
        } else {
            ia65Over = arCrossForm.ia65Over!
        }
        if arCrossForm.iaDisability == ""  || arCrossForm.iaDisability == nil {
            iaDisability = "0"
        } else {
            iaDisability = arCrossForm.iaDisability!
        }
        iaNotes = arCrossForm.iaNotes ?? ""
        if arCrossForm.iaNumPeople == ""  || arCrossForm.iaNumPeople == nil {
            iaNumPeople = "0"
        } else {
            iaNumPeople = arCrossForm.iaNumPeople!
        }
        if arCrossForm.iaPrexistingSA == ""  || arCrossForm.iaPrexistingSA == nil {
            iaPrexistingSA = "0"
        } else {
            iaPrexistingSA = arCrossForm.iaPrexistingSA!
        }
        if arCrossForm.iaVets == ""  || arCrossForm.iaVets == nil {
            iaVets = "0"
        } else {
            iaVets = arCrossForm.iaVets!
        }
        if arCrossForm.iaWorkingSA == "" || arCrossForm.iaWorkingSA == nil  {
            iaWorkingSA = "0"
        } else {
            iaWorkingSA = arCrossForm.iaWorkingSA!
        }
        installerDate = arCrossForm.installerDate ?? Date()
        installerName = arCrossForm.installerName ?? ""
        installerSigend = arCrossForm.installerSigend
        installerSignature = arCrossForm.installerSignature ?? nil
        journalGuid = arCrossForm.journalGuid ?? ""
        localHazard = arCrossForm.localHazard
        localPartner = arCrossForm.localPartner ?? ""
        nationalPartner = arCrossForm.nationalPartner ?? ""
        if arCrossForm.numBatteries == ""  || arCrossForm.numBatteries == nil {
            numBatteries = "0"
        } else {
            numBatteries = arCrossForm.numBatteries!
        }
        if arCrossForm.numBedShaker == ""  || arCrossForm.numBedShaker == nil {
            numBedShaker = "0"
        } else {
            numBedShaker = arCrossForm.numBedShaker!
        }
        if arCrossForm.numNewSA == ""  || arCrossForm.numNewSA == nil {
            numNewSA = "0"
        } else {
            numNewSA = arCrossForm.numNewSA!
        }
        option1 = arCrossForm.option1 ?? ""
        option2 = arCrossForm.option2 ?? ""
        residentCellNum = arCrossForm.residentCellNum ?? ""
        residentContactInfo = arCrossForm.residentContactInfo
        residentEmail = arCrossForm.residentEmail ?? ""
        residentName = arCrossForm.residentName ?? ""
        residentOtherPhone = arCrossForm.residentOtherPhone ?? ""
        residentSigDate = arCrossForm.residentSigDate ?? Date()
        residentSignature = arCrossForm.residentSignature ?? nil
        residentSigned = arCrossForm.residentSigned
        reviewFEPlan = arCrossForm.createFEPlan
    }
    
    func buildEndStartTimeText()-> String {
        var theDate: Date = Date()
        var campaignText: String!
        var dateString: String!
        if cComplete {
            theDate = cStartDate
            dateString = vcLaunch.fullDateString(date: theDate)
            campaignText =  "Campaign started \(dateString ?? "")"
        } else {
            theDate = cEndDate
            dateString = vcLaunch.fullDateString(date: theDate)
            campaignText =  "Campaign closed \(dateString ?? "")"
        }
        print("here is the campaign text \(campaignText ?? "")")
        return campaignText
    }
    
    
}
