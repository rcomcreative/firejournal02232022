//
//  LaunchNotifications.swift
//  dashboard
//
//  Created by DuRand Jones on 9/6/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//


import UIKit
import Foundation
import CoreData

class LaunchNotifications {
    let nc = NotificationCenter.default
    var vcLaunch: VCLaunch
    var compact: SizeTrait!
    
    init(launchVC: VCLaunch){
        vcLaunch = launchVC
    }
    
    func callNotifications() {
        nc.addObserver(self, selector:#selector(incidentCalled(notification:)), name:NSNotification.Name(rawValue: FJkINCIDENT_FROM_MASTER), object: nil)
        nc.addObserver(self, selector:#selector(journalCalled(notification:)), name:NSNotification.Name(rawValue: FJkJOURNAL_FROM_MASTER), object: nil)
        nc.addObserver(self, selector: #selector(projectCalled(nc:)), name: .fireJournalProjectFromMaster, object: nil)
        nc.addObserver(self, selector:#selector(mapsCalled(notification:)), name:NSNotification.Name(rawValue: FJkMAPS_FROM_MASTER), object: nil)
        nc.addObserver(self, selector:#selector(settingsCalled(notification:)), name:NSNotification.Name(rawValue: FJkSETTINGS_FROM_MASTER), object: nil)
        nc.addObserver(self, selector:#selector(storeCalled(notification:)), name:NSNotification.Name(rawValue: FJkSTORE_FROM_MASTER), object: nil)
        nc.addObserver(self, selector:#selector(nfirsB1Called(notification:)), name:NSNotification.Name(rawValue: FJkNFIRSBASIC1_FROM_MASTER), object: nil)
        nc.addObserver(self, selector:#selector(ics214Called(notification:)), name:NSNotification.Name(rawValue: FJkICS214_FROM_MASTER), object: nil)
        nc.addObserver(self, selector:#selector(alarmFormCalled(notification:)), name:NSNotification.Name(rawValue: FJkARCFORM_FROM_MASTER), object: nil)
        nc.addObserver(self, selector:#selector(personalCalled(notification:)), name:NSNotification.Name(rawValue: FJkPERSONAL_FROM_MASTER), object: nil)
        nc.addObserver(self, selector:#selector(fjuSavedCalled(notification:)), name:NSNotification.Name(rawValue: FJkFireJournalUserSaved), object: nil)
        nc.addObserver(self, selector:#selector(myProfileCalled(notification:)),name:NSNotification.Name(rawValue: FJkMYProfileHASBeenCalled), object: nil )
        nc.addObserver(self, selector:#selector(settingFJCloudCalled(notification:)),name:NSNotification.Name(rawValue: FJkSETTINGSFJCLOUDCalled), object: nil)
        nc.addObserver(self, selector:#selector(settingFJCrewCalled(notification:)),name:NSNotification.Name(rawValue: FJkSETTINGSCREWCalled), object: nil)
        nc.addObserver(self, selector:#selector(settingFJTagsCalled(notification:)),name:NSNotification.Name(rawValue: FJkSETTINGSTAGSCalled), object: nil)
        nc.addObserver(self, selector:#selector(settingFJRankCalled(notification:)),name:NSNotification.Name(rawValue: FJkSETTINGRANKCalled), object: nil)
        nc.addObserver(self, selector:#selector(settingFJPlatoonCalled(notification:)),name:NSNotification.Name(rawValue: FJkSETTINGPLATOONCalled), object: nil)
        nc.addObserver(self, selector:#selector(settingFJResourcesCalled(notification:)),name:NSNotification.Name(rawValue: FJkSETTINGRESOURCESCalled), object: nil)
        nc.addObserver(self, selector:#selector(settingMyFireStationResourcesCalled(notification:)),name:NSNotification.Name(rawValue: FJkSETTINGSMYFIRESTATIONRESOURCESCalled), object: nil)
        nc.addObserver(self, selector:#selector(settingFJStreetTypesCalled(notification:)),name:NSNotification.Name(rawValue: FJkSETTINGSTREETTYPECalled), object: nil)
        nc.addObserver(self, selector:#selector(settingFJLocalIncidentTypesCalled(notification:)),name:NSNotification.Name(rawValue: FJkSETTINGLOCALINCIDENTTYPECalled), object: nil)
        nc.addObserver(self, selector:#selector(settingFJTermsCalled(notification:)),name:NSNotification.Name(rawValue: FJkSETTINGTERMSCalled), object: nil)
        nc.addObserver(self, selector:#selector(settingFJPrivacyCalled(notification:)),name:NSNotification.Name(rawValue: FJkSETTINGPRIVACYCalled), object: nil)
        nc.addObserver(self, selector:#selector(settingFJResetDataCalled(notification:)),name:NSNotification.Name(rawValue: FJkSETTINGRESETDATACalled), object: nil)
        nc.addObserver(self, selector:#selector(settingFJContactsCalled(notification:)),name:NSNotification.Name(rawValue: FJkSETTINGSCONTACTSCalled), object: nil)
        nc.addObserver(self, selector:#selector(settingFJProfileDataCalled(notification:)),name:NSNotification.Name(rawValue: FJkSETTINGSPROFILEDATACalled), object: nil)
        nc.addObserver(self, selector:#selector(settingResetDataCalled(notification:)),name:NSNotification.Name(rawValue: FJkSETTINGSRESETDATACalled), object: nil)
    }
    
    @objc func settingResetDataCalled(notification: Notification)->Void {
        if let userInfo = notification.userInfo as! [String: Any]?
        {
            compact = userInfo["sizeTrait"] as? SizeTrait
            vcLaunch.settingsResetDataCalled(compact: compact)
        }
    }
    
    @objc func settingFJProfileDataCalled(notification: Notification)->Void {
        if let userInfo = notification.userInfo as! [String: Any]?
        {
            let type = userInfo["type"] as? FJSettings
            compact = userInfo["sizeTrait"] as? SizeTrait
            vcLaunch.settingsProfileDataCalled(type:type!,compact: compact)
        }
    }
    
    @objc func settingFJContactsCalled(notification: Notification) -> Void {
        if let userInfo = notification.userInfo as! [String: Any]?
        {
            compact = userInfo["sizeTrait"] as? SizeTrait
            vcLaunch.settingsContactsCalled(compact: compact)
        }
    }
    
    @objc func settingFJResetDataCalled(notification: Notification) -> Void {
        if let userInfo = notification.userInfo as! [String: Any]?
        {
            compact = userInfo["sizeTrait"] as? SizeTrait
            vcLaunch.settingsResetDataCalled(compact: compact)
        }
    }
    
    @objc func settingFJPrivacyCalled(notification: Notification) -> Void {
        if let userInfo = notification.userInfo as! [String: Any]?
    {
        compact = userInfo["sizeTrait"] as? SizeTrait
        vcLaunch.settingsPrivacyCalled(compact: compact)
        }
    }
    
    @objc func settingFJTermsCalled(notification: Notification) -> Void {
        if let userInfo = notification.userInfo as! [String: Any]?
    {
        compact = userInfo["sizeTrait"] as? SizeTrait
        vcLaunch.settingsTermsCalled(compact: compact)
        }
    }
    
    @objc func settingFJLocalIncidentTypesCalled(notification: Notification) -> Void {
        if let userInfo = notification.userInfo as! [String: Any]?
    {
        compact = userInfo["sizeTrait"] as? SizeTrait
        vcLaunch.settingsLocalIncidentTypesCalled(compact: compact)
        }
    }
    
    @objc func settingFJStreetTypesCalled(notification: Notification) -> Void {
        if let userInfo = notification.userInfo as! [String: Any]?
    {
        compact = userInfo["sizeTrait"] as? SizeTrait
        vcLaunch.settingsStreetTypeCalled(compact: compact)
        }
    }
    
    @objc func settingFJResourcesCalled(notification: Notification) -> Void {
        if let userInfo = notification.userInfo as! [String: Any]?
    {
        compact = userInfo["sizeTrait"] as? SizeTrait
        vcLaunch.settingsResourcesCalled(compact: compact)
        }
    }
    
    @objc func settingMyFireStationResourcesCalled(notification: Notification) -> Void {
        if let userInfo = notification.userInfo as! [String: Any]?
        {
            compact = userInfo["sizeTrait"] as? SizeTrait
            vcLaunch.settingsMyFireStationResourcesCalled(compact: compact)
        }
    }
    
    @objc func settingFJPlatoonCalled(notification: Notification) -> Void {
        if let userInfo = notification.userInfo as! [String: Any]?
    {
        compact = userInfo["sizeTrait"] as? SizeTrait
        vcLaunch.settingsPlatoonCalled(compact: compact)
        }
    }
    
    @objc func settingFJRankCalled(notification: Notification) -> Void {
        if let userInfo = notification.userInfo as! [String: Any]?
    {
        compact = userInfo["sizeTrait"] as? SizeTrait
        vcLaunch.settingsRankCalled(compact: compact)
        }
    }
    
    @objc func settingFJTagsCalled(notification: Notification) -> Void {
        if let userInfo = notification.userInfo as! [String: Any]?
    {
        compact = userInfo["sizeTrait"] as? SizeTrait
        vcLaunch.settingsTagsCalled(compact: compact)
        }
    }
    
    @objc func settingFJCrewCalled(notification: Notification) -> Void {
        if let userInfo = notification.userInfo as! [String: Any]?
    {
        compact = userInfo["sizeTrait"] as? SizeTrait
        vcLaunch.settingsCrewCalled(compact: compact)
        }
    }
    
    @objc func settingFJCloudCalled(notification: Notification) -> Void {
        if let userInfo = notification.userInfo as! [String: Any]?
        {
            compact = userInfo["sizeTrait"] as? SizeTrait
            vcLaunch.settingsCloudCalled(compact: compact)
        }
    }
    
    @objc func myProfileCalled(notification:Notification) -> Void {
        if let userInfo = notification.userInfo as! [String: Any]?
        {
            compact = userInfo["sizeTrait"] as? SizeTrait
            _ = vcLaunch.myProfileCalled(compact: compact)
        }
    }
    
    @objc func fjuSavedCalled(notification:Notification) -> Void {
        if let userInfo = notification.userInfo as! [String: Any]?
        {
           _ = userInfo["user"] as? FireJournalUserOnboard
        }
    }
    
    @objc func openingNeededOnMaster(notification:Notification) -> Void {
        
    }
    
    @objc func incidentCalled(notification:Notification) -> Void {
        if let userInfo = notification.userInfo as! [String: Any]?
        {
            compact = userInfo["sizeTrait"] as? SizeTrait
            let id = userInfo["objectID"] as? NSManagedObjectID ?? nil
            vcLaunch.incidentCalled(sizeTrait: compact,id:id!)
        }
    }
    
    @objc func projectCalled(nc: Notification) -> Void {
        if let userInfo = nc.userInfo as! [String: Any]?
        {
            compact = userInfo["sizeTrait"] as? SizeTrait
            if let id = userInfo["objectID"] as? NSManagedObjectID {
                vcLaunch.projectCalled(sizeTrait: compact, id: id)
            }
        }
    }
    
    @objc func journalCalled(notification:Notification) -> Void {
        if let userInfo = notification.userInfo as! [String: Any]?
        {
            compact = userInfo["sizeTrait"] as? SizeTrait
            let id = userInfo["objectID"] as? NSManagedObjectID ?? nil
            vcLaunch.journalCalled(sizeTrait: compact,id:id!)
        }
    }
    
    @objc func settingsCalled(notification:Notification)-> Void{
        if let userInfo = notification.userInfo as! [String: Any]?
        {
            compact = userInfo["sizeTrait"] as? SizeTrait
            vcLaunch.settingsCalled(sizeTrait: compact)
        }
    }
    
    /**
     when MasterViewController calls FJkSTORE_FROM_MASTER this selector is use to launch VCLaunch storeCalled() which either calls Beta store with monthly for NewStoreVC with only quarterly and annual
     */
    @objc func storeCalled(notification:Notification)-> Void{
        vcLaunch.storeCalled()
    }
    
    @objc func mapsCalled(notification:Notification)-> Void{
        vcLaunch.mapCalled(type: IncidentTypes.allIncidents )
    }
    
    @objc func nfirsB1Called(notification:Notification)-> Void{
        vcLaunch.nfirsB1Called()
    }
    
    @objc func ics214Called(notification:Notification)-> Void{
        if let userInfo = notification.userInfo as! [String: Any]?
        {
            if let id = userInfo["objectID"] as? NSManagedObjectID {
                vcLaunch.ics214Called(objectID: id)
            }
        }
    }
    
    @objc func alarmFormCalled(notification:Notification)-> Void{
        if let userInfo = notification.userInfo as [AnyHashable : Any]?
        {
            if let id = userInfo["objectID"] as? NSManagedObjectID {
                vcLaunch.alarmFormCalled(object: id)
            }
        }
    }
    
    @objc func personalCalled(notification:Notification) -> Void {
        if let userInfo = notification.userInfo as [AnyHashable : Any]?
        {
            compact = userInfo["sizeTrait"] as? SizeTrait
            let id = userInfo["objectID"] as? NSManagedObjectID ?? nil
            vcLaunch.personalCalled(sizeTrait: compact,id:id!)
        }
    }
    
    func removeNC() {
        nc.removeObserver(self, name: NSNotification.Name(rawValue: FJkINCIDENT_FROM_MASTER), object: nil)
        nc.removeObserver(self, name: NSNotification.Name(rawValue: FJkJOURNAL_FROM_MASTER), object: nil)
        nc.removeObserver(self, name: NSNotification.Name(rawValue: FJkMAPS_FROM_MASTER), object: nil)
        nc.removeObserver(self, name: NSNotification.Name(rawValue: FJkSETTINGS_FROM_MASTER), object: nil)
        nc.removeObserver(self, name: NSNotification.Name(rawValue: FJkSTORE_FROM_MASTER), object: nil)
        nc.removeObserver(self, name: NSNotification.Name(rawValue: FJkNFIRSBASIC1_FROM_MASTER), object: nil)
        nc.removeObserver(self, name: NSNotification.Name(rawValue: FJkICS214_FROM_MASTER), object: nil)
        nc.removeObserver(self, name: NSNotification.Name(rawValue: FJkARCFORM_FROM_MASTER), object: nil)
        nc.removeObserver(self, name: NSNotification.Name(rawValue: FJkPERSONAL_FROM_MASTER), object: nil)
    }
        
}
