//
//  NotificationStrings.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/25/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let fireJournalPhotoErrorCalled = Notification.Name("fireJournalPhotoErrorCalled")
    static let fireJournalCameraPhotoSaved = Notification.Name("fireJournalCameraPhotoSaved")
    static let fireJournalUserFDIDComplete = Notification.Name("fireJournalUserFDIDComplete")
    static let fireJournalUserNFIRSIncidentTypeComplete = Notification.Name("fireJournalUserNFIRSIncidentTypeComplete")
    static let fireJournalUserLocalIncidentComplete = Notification.Name("fireJournalUserLocalIncidentComplete")
    static let fireJournalNFIRSActionTakenComplete = Notification.Name("fireJournalNFIRSActionTakenComplete")
    static let fireJournalUserModifiedSendToCloud = Notification.Name("fireJournalUserModifiedSendToCloud")
    static let fireJournalPresentNewJournal = Notification.Name("fireJournalPresentNewJournal")
    static let fireJournalProjectListCalled = Notification.Name("fireJournalProjectListCalled")
    static let fireJournalNewProjectCreatedSendToCloud = Notification.Name("fireJournalNewProjectCreatedSendToCloud")
    static let fireJournalProjectModifiedSendToCloud = Notification.Name("fireJournalProjectModifiedSendToCloud")
    static let fireJournalProjectCrewSendToCloud = Notification.Name("fireJournalProjectCrewSendToCloud")
    static let fireJournalProjectTagSendToCloud = Notification.Name("fireJournalProjectTagSendToCloud")
    static let fireJournalProjectFromMaster = Notification.Name("fireJournalProjectFromMaster")
    static let fireJournalStatusNewToCloud = Notification.Name("fireJournalStatusNewToCloud")
    static let fireJournalModifyJournalToCloud = Notification.Name("fireJournalModifyJournalToCloud")
    static let fireJournalModifyFCLocationToCloud = Notification.Name("fireJournalModifyFCLocationToCloud")
    static let fireJournalJournalTagsToCloud = Notification.Name("fireJournalJournalTagsToCloud")
    static let fireJournalIncidentTagsToCloud = Notification.Name("fireJournalIncidentTagsToCloud")
    static let fireJournalUpdateIncidentLocationToFCLocation = Notification.Name("fireJournalUpdateIncidentLocationToFCLocation")
    static let fireJournalUpdateJournalLocationToFCLocation = Notification.Name("fireJournalUpdateJournalLocationToFCLocation")
    static let fireJournalFCLocationsUpdated = Notification.Name("fireJournalFCLocationsUpdated")
    static let fireJournalRemoveAllDataFromCloudKit = Notification.Name("fireJournalRemoveAllDataFromCloudKit")
    static let fireJournalRemoveAllDataFromCD = Notification.Name("fireJournalRemoveAllDataFromCD")
    static let fConCheckTheCKZone = Notification.Name("fConCheckTheCKZone")
    static let fConCheckTheCKZoneFinished = Notification.Name("fConCheckTheCKZoneFinished")
    static let fConCKZoneFailure = Notification.Name("fConCKZoneFailure")
    static let fConCKZoneSuccess = Notification.Name("fConCKZoneSuccess")
    static let fConCDSuccess = Notification.Name("fConCDSuccess")
    static let fConCDFailure = Notification.Name("fConCDFailure")
    static let fConCKSubscriptionSuccess = Notification.Name("fConCKSubscriptionSuccess")
    static let fConCKSubscriptionFailure = Notification.Name("fConCKSubscriptionFailure")
    static let fConCKCDDeletionCompleted = Notification.Name("fConCKCDDeletionCompleted")
    static let fConDeletedRebuildMaster = Notification.Name("fConDeletedRebuildMaster")
    static let fConDeletedRebuildDetail = Notification.Name("fConDeletedRebuildDetail")
    static let fConDeletionNotificationSentFromCloud = Notification.Name("fConDeletionNotificationSentFromCloud")
    static let fConDeletionChangedInternally = Notification.Name("fConDeletionChangedInternally")
}

let FConnectName = "FireJournal"
let FJkCLOUDKITCONTAINERNAME = "iCloud.com.purecommand.FireJournal2017"
let FJkSTATUSCONTAINERNAME = "iCloud.com.purecommand.FireJournal2017"
let FJkRECIEVEDRemoteNotification = "FJkRECIEVEDRemoteNotification"
let FJkFCLocationUpdateToIncidentRan = "FJkFCLocationUpdateToIncidentRan"
let FJkDELETIONCKCD = "FJkDELETIONCKCD"
let FJkFJUSERCKRECORDNAME = "FJkFJUSERCKRECORDNAME"
let FJkSTATUSCKRECORDNAME = "FJkSTATUSCKRECORDNAME"
let FJkREMOVEALLDATA = "FJkREMOVEALLDATA"
let FJkMASTERRELOADDETAIL = "FJkMASTERRELOADDETAIL"
let FJkJOURNAL_FROM_MASTER = "FJkJOURNAL_FROM_MASTER"
let FJkJOURNAL_FROM_DETAIL = "FJkJOURNAL_FROM_DETAIL"
let FJkINCIDENT_FROM_MASTER = "FJkINCIDENT_FROM_MASTER"
let FJkINCIDENT_FROM_DETAIL = "FJkINCIDENT_FROM_DETAIL"
let FJkPERSONAL_FROM_MASTER = "FJkPERSONAL_FROM_MASTER"
let FJkFORMS_FROM_DETAIL = "FJkFORMS_FROM_DETAIL"
let FJkFORMS_FROM_MASTER = "FJkFORMS_FROM_MASTER"
let FJkSTARTSHIFT_FROM_DETAIL = "FJkSTARTSHIFT_FROM_DETAIL"
let FJkENDSHIFT_FROM_DETAIL = "FJkENDSHIFT_FROM_DETAIL"
let FJkMAPS_FROM_MASTER = "FJkMAPS_FROM_MASTER"
let FJkSETTINGS_FROM_MASTER = "FJkSETTINGS_FROM_MASTER"
let FJkSTORE_FROM_MASTER = "FJkSTORE_FROM_MASTER"
let FJkCLOUD_FROM_MASTER = "FJkCLOUD_FROM_MASTER"
let FJkNFIRSBASIC1_FROM_MASTER = "FJkNFIRSBASIC1_FROM_MASTER"
let FJkICS214_FROM_MASTER = "FJkICS214_FROM_MASTER"
let FJkICS214_NEW_TO_LIST = "FJkICS214_NEW_TO_LIST"
let FJkARCFORM_FROM_MASTER = "FJkARCFORM_FROM_MASTER"
let FJkARCFORM_NEW_TO_LIST = "FJkARCFORM_NEW_TO_LIST"
let FJkARCFORM_NEW_TO_CLOUD = "FJkARCFORM_NEW_TO_CLOUD"
let FJkCOMPACTORREGULAR = "FJkCOMPACTORREGULAR"
let FJkJOURNALLISTSEGUE = "FJkJOURNALLISTSEGUE"
let FJkINCIDENTLISTCALLED = "FJkINCIDENTLISTCALLED"
let FJkPERSONALLISTCALLED = "FJkPERSONALLISTCALLED"
let FJkMAPSLISTCALLED = "FJkMAPSLISTCALLED"
let FJkICS214FORMLISTCALLED = "FJkICS214FORMLISTCALLED"
let FJkARCFORMLISTCALLED = "FJkARCFORMLISTCALLED"
let FJkUserAgreementAgreed = "fjkUserAgreementAgreed"
let FJkSUBCRIPTIONBought = "subscriptionBought"
let FJkSUBSCRIPTIONIsLocallyCached = "subscriptionIsLocallyCached"
let FJkUSERFDRESOURCESHAVEBEENSET = "FJkUSERFDRESOURCESHAVEBEENSET"
let FJkPLISTSCALLED = "FJkPLISTSCALLED"
let FJkLOADUSERITMESCALLED = "FJkLOADUSERITMESCALLED"
let FJkMANAGEDContextDidSave = "managedObjectContextDidSave"
let FJkFireJournalUserSaved = "FJkFireJournalUserSaved"
let FJkFireJournalNeedsFirstIncident = "FJkFireJournalNeedsFirstIncident"
let FJkSAVINGTHEFORMANIMATETOEND = "FJkSAVINGTHEFORMANIMATETOEND"
let FJkSTARTSHIFTENDSHIFTBOOL = "FJkSTARTSHIFTENDSHIFTBOOL"
let FJkSTARTSHIFTFORDASH = "FJkSTARTSHIFTFORDASH"
let FJkUPDATESHIFTFORDASH = "FJkUPDATESHIFTFORDASH"
let FJkENDSHIFTFORDASH = "FJkENDSHIFTFORDASH"
let FJkPERSISTENT_STORE_ERROR_REPORTING = "FJkPERSISTENT_STORE_ERROR_REPORTING"
let FJkCLOUDKITDATABASENAME = "iCloud.com.purecommand.FireJournal2017"
let FJkMYProfileHASBeenCalled = "FJkMYProfileHASBeenCalled"
let FJkPROFILE_FROM_MASTER = "FJkPROFILE_FROM_MASTER"
let FJkSETTINGSFJCLOUDCalled = "FJkSETTINGSFJCLOUDCalled"
let FJkSETTINGSCREWCalled = "FJkSETTINGSCREWCalled"
let FJkSETTINGSTAGSCalled = "FJkSETTINGTAGSCalled"
let FJkSETTINGRANKCalled = "FJkSETTINGRANKCalled"
let FJkSETTINGPLATOONCalled = "FJkSETTINGPLATOONCalled"
let FJkSETTINGRESOURCESCalled = "FJkSETTINGRESOURCESCalled"
let FJkSETTINGSTREETTYPECalled = "FJkSETTINGSTREETTYPECalled"
let FJkSETTINGLOCALINCIDENTTYPECalled = "FJkSETTINGLOCALINCIDENTTYPECalled"
let FJkSETTINGTERMSCalled = "FJkSETTINGTERMSCalled"
let FJkSETTINGPRIVACYCalled = "FJkSETTINGPRIVACYCalled"
let FJkSETTINGRESETDATACalled = "FJkSETTINGRESETDATACalled"
let FJkSETTINGSCONTACTSCalled = "FJkSETTINGSCONTACTSCalled"
let FJkSETTINGSPROFILEDATACalled = "FJkSETTINGSPROFILEDATACalled"
let FJkSETTINGSRESETDATACalled = "FJkSETTINGSRESETDATACalled"
let FJkSETTINGSMYFIRESTATIONRESOURCESCalled = "FJkSETTINGSMYFIRESTATIONRESOURCESCalled"
let FJkInternetConnectionAvailable = "internetConnectionAvailable"
let FJkCKServerChangeToken = "FJkCKServerChangeToken"
let FJkCKZondChangeToken = "FJkCKZondChangeToken"
let FJkCKZoneRecordsCALLED = "FJkCKZoneRecordsCALLED"
let FJkCKNewIncidentCreated = "FJkCKNewIncidentCreated"
let FJkCKNewStartEndCreated = "FJkCKNewStartEndCreated"
let FJkCKNewICS214Created = "FJkCKNewICS214Created"
let FJkCKModifiedICS214TOCLOUD = "FJkCKModifiedICS214TOCLOUD"
let FJkCKModifiedSICS214TOCLOUD = "FJkCKModifiedSICS214TOCLOUD"
let FJkCKNewARCrossCreated = "FJkCKNewARCrossCreated"
let FJkCKModifiedARCrossTOCLOUD = "FJkCKModifiedARCrossTOCLOUD"
let FJkCKModifiedSARCrossTOCLOUD = "FJkCKModifiedSARCrossTOCLOUD"
let FJkCKMODIFIEDSTARTENDTOCLOUD = "FJkCKMODIFIEDSTARTENDTOCLOUD"
let FJkCKModifyIncidentToCloud = "FJkCKModifyIncidentToCloud"
let FJkCKModifiedIncidentsToCloud = "FJkCKModifiedIncidentsToCloud"
let FJkCKNewJournalCreated = "FJkCKNewJournalCreated"
let FJkCKModifyJournalToCloud = "FJkCKModifyJournalToCloud"
let FJkCKModifiedJournalsToCloud = "FJkCKModifiedJournalsToCloud"
let FJkFJUSERSavedToCoreDataFromCloud = "FJkFJUSERSavedToCoreDataFromCloud"
let FJkFJUserModifiedSendToCloud = "FJkFJUserModifiedSendToCloud"
let FJkFJUserNEWSendToCloud = "FJkFJUserNEWSendToCloud"
let FJkFJISCOLLAPSED = "FJkFJISCOLLAPSED"
let FJkFJSHOULDRunSYNC = "FJkFJSHOULDRunSYNC"
let METERS_PER_MILE = 4536.344
let ZOOM_METERS_PER_MILE = 2200.50
let FJkUSERTIMEGUID = "FJkUSERTIMEGUID"
let FJkDONTSHOWSTARTSHIFTALERTAGAIN = "FJkDONTSHOWSTARTSHIFTALERTAGAIN"
let FJkSETTINGSHASSTATE = "FJkSETTINGSHASSTATE"
// MARK: -STORENAMES
let FJkSUBSCRIPTIONProductIdentifier = "FJkSUBSCRIPTIONProductIdentifier"
let FJkSUBSCRIPTIONUserName = "FJkSUBSCRIPTIONUserName"
let FJkSUBSCRIPTIONPurchaseDate = "FJkSUBSCRIPTIONPurchaseDate"
let FJkSUBSCRIPTIONTransactionIdentifier = "FJkSUBSCRIPTIONTransactionIdentifier"
// MARK: -SUBSCRIPTION
let kTHEREISA_SUBSCRIPTION = "kTHEREISA_SUBSCRIPTION"
let FJkRELOADTHEDASHBOARD = "FJkRELOADTHEDASHBOARD"
let FJkRELOADTHELIST = "FJkRELOADTHELIST"
// MARK: -ATTENDEES
let FJkNEWUSERATTENDEE_TOCLOUDKIT = "FJkNEWUSERATTENDEE_TOCLOUDKIT"
let FJkMODIFIEDUSERATTENDEE_TOCLOUDKIT = "FJkMODIFIEDUSERATTENDEE_TOCLOUDKIT"
let FJkDELETEUSERATTENDEE_TOCLOUDKIT = "FJkDELETEUSERATTENDEE_TOCLOUDKIT"
// MARK: -ICS214
let FJkNEWICS214FormCreated = "FJkNEWICS214FormCreated"
let FJkMODIFIEDICS214FORM_TOCLOUDKIT = "FJkMODIFIEDICS214FORM_TOCLOUDKIT"
let FJkNEWICS214ACTIVITYLOG_TOCLOUDKIT = "FJkNEWICS214ACTIVITYLOG_TOCLOUDKIT"
let FJkNEWICS214PERSONNEL_TOCLOUDKIT = "FJkNEWICS214PERSONNEL_TOCLOUDKIT"
let FJkMODIFIEDICS214ACTIVITYLOG_TOCLOUDKIT = "FJkMODIFIEDICS214ACTIVITYLOG_TOCLOUDKIT"
let FJkMODIFIEDICS214PERSONNEL_TOCLOUDKIT = "FJkMODIFIEDICS214PERSONNEL_TOCLOUDKIT"
let FJkDELETEMODIFIEDICS214PERSONNEL_TOCLOUDKIT = "FJkDELETEMODIFIEDICS214PERSONNEL_TOCLOUDKIT"
let FJkDELETEMODIFIEDICS214ACTIVITYLOG_TOCLOUDKIT = "FJkDELETEMODIFIEDICS214ACTIVITYLOG_TOCLOUDKIT"
// MARK: -SHARE LINKS-
let FJkLINKFROMCLOUDFORARCROSSFORMTOSHARE = "FJkLINKFROMCLOUDFORARCROSSFORMTOSHARE"
let FJkLINKFROMCLOUDFORICS214TOSHARE = "FJkLINKFROMCLOUDFORICS214TOSHARE"
// MARK: -BACKED UP-
let FJkCHECKINCIDENTBACKEDUP = "FJkCHECKINCIDENTBACKEDUP"
let FJkCHECKICS214BACKEDUP = "FJkCHECKICS214BACKEDUP"
let FJkCHECKARCFORMBACKEDUP = "FJkCHECKARCFORMBACKEDUP"
let FJkCHECKUSERTIMEBACKEDUP = "FJkCHECKUSERTIMEBACKEDUP"
let FJkCHECKUSERTAGSBACKEDUP = "FJkCHECKUSERTAGSBACKEDUP"
let FJkCHECKUSERRANKBACKEDUP = "FJkCHECKUSERRANKSBACKEDUP"
let FJkCHECKSTREETTYPEBACKEDUP = "FJkCHECKSTREETTYPEBACKEDUP"
let FJkCHECKINCIDENTTYPEBACKEDUP = "FJkCHECKINCIDENTTYPEBACKEDUP"
let FJkCHECKICS214ACTIVITYLOGBACKEDUP = "FJkCHECKICS214ACTIVITYLOGBACKEDUP"
let FJkCHECKICS214PERSONNELBACKEDUP = "FJkCHECKICS214PERSONNELBACKEDUP"
let FJkCHECKRESIDENCEBACKEDUP = "FJkCHECKRESIDENCEBACKEDUP"
let FJkCHECKLOCALPARTNERSBACKEDUP = "FJkCHECKLOCALPARTNERSBACKEDUP"
let FJkCHECKNATIONALPARTNERSBACKEDUP = "FJkCHECKNATIONALPARTNERSBACKEDUP"
let FJkCHECKFIREJOURNALUSERBACKEDUP = "FJkCHECKFIREJOURNALUSERBACKEDUP"
let FJkCHECKJOURNALBACKEDUP = "FJkCHECKJOURNALBACKEDUP"
// MARK: -FRESHDESK
let FJkFRESHDESK_UPDATED = "FJkFRESHDESK_UPDATED"
let FJkFRESHDESK_UPDATENow = "FJkFRESHDESK_UPDATENow"
// MARK: -STARTSHIFT
let FJkSTARTUPDATEENDSHIFT = "FJkSTARTUPDATEENDSHIFT"
// MARK: -PRODUCTS
let FJkSUBSCRIPTION1 = "FJkSUBSCRIPTION1"
let FJkSUBSCRIPTION2 = "FJkSUBSCRIPTION2"
let FJkSUBSCRIPTION3 = "FJkSUBSCRIPTION3"
//MARK: -ALERTS
let FJkALERTBACKUPCOMPLETED = "FJkALERTBACKUPCOMPLETED"
let FJkALERTICS214INCOMPLETEENTRY = "FJkALERTICS214INCOMPLETEENTRY"
//MARK: -CLEANDATA
let FJkCLEANUSERATTENDEES = "FJkCLEANUSERATTENDEES"
let FJkDELETEFROMLIST = "FJkDELETEFROMLIST"
let FJkCHANGESINFROMCLOUD = "FJkCHANGESINFROMCLOUD"
let FJkSTOREINALERTTAPPED = "FJkSTOREINALERTTAPPED"
//MARK: -MAPCHANGES
let FJkTHEMAPTYPECHANGED = "FJkTHEMAPTYPECHANGED"
let FJkINCIDENTCHOSENFORMAP = "FJkINCIDENTCHOSENFORMAP"
let FJkICS214CHOSENFORMAP = "FJkICS214CHOSENFORMAP"
let FJkARCFORMCHOSENFORMAP = "FJkARCFORMCHOSENFORMAP"
//MARK: -FDRESOURCES
let FJkUSERRESOURCENEWTOCLOUD = "FJkUSERRESOURCENEWTOCLOUD"
let FJkFDRESOURCESNEWTOCLOUD = "FJkFDRESOURCESNEWTOCLOUD"
let FJkFDRESOURCESMODIFIEDTOCLOUD = "FJkFDRESOURCESMODIFIEDTOCLOUD"
let FJkFDRESOURCESDELETETOCLOUD = "FJkFDRESOURCESDELETETOCLOUD"
let FJkFDRESOURCESSYNCFROMCLOUD = "FJkFDRESOURCESSYNCFROMCLOUD"
let FJkSETTINGSUSERRESOURCESCUSTOMCOMMITTED = "FJkSETTINGSUSERRESOURCESCUSTOMCOMMITTED"
let FJkSETTINGSUSERRESOURCESCUSTOMRUN = "FJkSETTINGSUSERRESOURCESCUSTOMRUN"
let FJkUSERFDRESOURCESPOINTOFTRUTH = "FJkUSERFDRESOURCESPOINTOFTRUTH"
let FJkUserFDResourcesPointOfTruthOperationHasRun = "FJkUserFDResourcesPointOfTruthOperationHasRun"
//MARK: -ORIENTATION-
let FJkORIENTATIONDIDCHANGE = "FJkORIENTATIONDIDCHANGE"
//MARK: -DONTSHOWAGAIN-
let FJkStartShiftDontShowAgain = "FJkStartShiftDontShowAgain"
let FJkUpdateShiftDontShowAgain = "FJkUpdateShiftDontShowAgain"
let FJkEndShiftDontShowAgain = "FJkEndShiftDontShowAgain"
//MARK: -VERSIONCONTROL-
let FJkVERSIONCONTROL = "FJkVERSIONCONTROL"
let FJkCALLVERSIONCONTROL = "FJkCALLVERSIONCONTROL"

//MARK: -ARCFORM-
let notificationKeyARCMap = "FJkCOREDATA_INCIDENTSMAPSCALLED"
let notificationKeyNOARCAVAIL = "FJkNO_ARCFORMS_AVAILABLE"
let notificationKeyARCLAST = "FJkCOREDATA_ARCFORMLASTOBJECT"
let fjKNEW_ARCFORM_CREATED = "FJkNEW_ARCFORM_CREATED"
let fjkMODIFIEDARCFORM_GOTOCLOUDKIT = "FJkMODIFIEDARCFORM_GOTOCLOUDKIT"
let fjkCOREDATA_DASHBOARDCALLEDFROMARC = "FJkCOREDATA_DASHBOARDCALLEDFROMARC"
let fjkCOREDATA_INCIDENTCALLEDFROMARC = "FJkCOREDATA_INCIDENTCALLEDFROMARC"
let fjkCOREDATA_MAPCALLEDFROMARC = "FJkCOREDATA_MAPCALLEDFROMARC"
let fjkCOREDATA_JOURNALCALLEDFROMARC = "FJkCOREDATA_JOURNALCALLEDFROMARC"
let fjkCOREDATA_PERSONALCALLEDFROMARC = "FJkCOREDATA_PERSONALCALLEDFROMARC"
let FJkDASHBOARD_FROMNFIRSBASIC1 = "FJkDASHBOARD_FROMNFIRSBASIC1"
let FJkCOREDATA_RELOADLIST = "kCOREDATA_RELOADLIST"
let FJkLOCATIONSINLOCATION = "FJkLOCATIONSINLOCATION"
let FJkChangeTheLocationsTOLOCATIONSSC = "FJkChangeTheLocationsTOLOCATIONSSC"
let FJkLETSCHECKTHEVERSION = "FJkLETSCHECKTHEVERSION"
let FJkMoveTheLocationsToLocationsSC = "FJkMoveTheLocationsToLocationsSC"

//MARK: -RELOAD SETTINGS-
let FJkReloadUserTagsCalled = "FJkReloadUserTagsCalled"
let FJkReloadUserTagsFinished = "FJkReloadUserTagsFinished"
let FJkReloadUserResourcesCalled = "FJkReloadUserResourcesCalled"
let FJkReloadUserResourcesFinished = "FJkReloadUserResourcesFinished"
let FJkReloadUserRankCalled = "FJkReloadUserRankCalled"
let FJkReloadUserRankFinished = "FJkReloadUserRankFinished"
let FJkReloadUserPlatoonCalled = "FJkReloadUserPlatoonCalled"
let FJkReloadUserPlatoonFinished = "FJkReloadUserPlatoonFinished"
let FJkReloadStreetTypeCalled = "FJkReloadStreetTypeCalled"
let FJkReloadStreetTypeFinished = "FJkReloadStreetTypeFinished"
let FJkReloadLocalIncidentTypesCalled = "FJkReloadLocalIncidentTypesCalled"
let FJkReloadLocalIncidentTypesFinished = "FJkReloadLocalIncidentTypesFinished"


let FJkFDRESOURCESINSTRUCTIONS = "Establish the fire and EMS apparatus in your fire station using the Fire/EMS option in Settings. Once saved, those resources will appear with each new incident.\n\nTap on the resource assigned to any incident. You’ll see a checkmark appear that indicates the apparatus is assigned and is part of the incident assignment.\n\nIf you need additional resources beyond what’s in your fire station, tap on the arrow button and a list of apparatus (as you have defined in Settings) will appear. Tap on the ones you want and they’ll be added. Note that any additional resources used will be saved to the incident, but will not change the apparatus you’ve assigned to your fire station."


// MARK: -FROM DASHBOARD TEST-
// MARK: -USERDEFAULTS FOR WEATHER-
let FJkOPENWEATHER_UPDATENow = "FJkOPENWEATHER_UPDATENow"  //BOOL
let FJkOPENWEATHER_LASTUPDATED = "FJkOPENWEATHER_LASTUPDATED"  //DATE
let FJkOPENWEATHER_DATETIME = "FJkOPENWEATHER_DATETIME"  //DATE
let FJkTEMPERATURE = "FJkTEMPERATURE" //STRING
let FJkHUMIDITY = "FJkHUMIDITY" //STRING
let FJkWINDSPEEDDIRECTION = "FJkWINDSPEEDDIRECTION" //STRING
let FJkLATITUDE = "FJkLATITUDE" //DOUBLE
let FJkLONGITUDE = "FJkLONGITUDE" //DOUBLE
let FJkLOCATION = "FJkLOCATION" //BOOL
let FJkWEATHERHASBEENUPDATED = "FJkWEATHERHASBEENUPDATED"

// MARK: -STATIC STRINGS FOR SCENE DELEGATE-
// MARK: -CELL IDENTIFIERS-
let newFormsCVCellIdentifier = "NewFormsCVCellIdentifier"
let endShiftCVCellIdentifier = "EndShiftCVCellIdentifier"
let startShiftCVCellIdentifier = "StartShiftCVCell"
let todaysIncidentsCVCellIdentifer = "TodaysIncidentsCVCellIdentifer"
let todaysShiftCVCellIdentifier = "TodaysShiftCVCellIdentifier"
let updateAndEndShiftCVCellIdentifier = "UpdateAndEndShiftCVCellIdentifier"
let updateShiftCVCellIdentifier = "UpdateShiftCVCellIdentifier"
let weatherCVCellIdentifier = "WeatherCVCellIdentifier"
let settingsTVCellIdentifier = "SettingsTVCellIdentifier"
let incidentMonthTotalsCVCellIdentifer = "IncidentMonthTotalsCVCellIdentifer"
let stationResourcesStatusCVCellIdentifier = "StationResourcesStatusCVCellIdentifier"
let displayModeOfApp = "displayModeOfApp"
let FJkSHIFTBUTTONINSETFRAME = "FJkSHIFTBUTTONINSETFRAME"
let FJkWEATHERINSETFRAME = "FJkWEATHERINSETFRAME"
let FJkINCIDENTTOTALSINSETFRAME = "FJkINCIDENTTOTALSINSETFRAME"
let FJkSTATIONRESOURCEINSETFRAME = "FJkSTATIONRESOURCEINSETFRAME"
let FJkTODAYSINCIDENTINSETFRAME = "FJkTODAYSINCIDENTINSETFRAME"
let FJkNEWFORMSINSETFRAME = "FJkNEWFORMSINSETFRAME"
let FJkSHIFTCELLSINSETFRAME = "FJkSHIFTCELLSINSETFRAME"

// MARK: -API KEY-
let openWeatherAPIKey = "8670cbdb9ee738cc2388a6dbc4cec79f"
let openWeatherAPIKeyTime = "openWeatherAPIKeyTime"

// MARK: -LOCKDOWN FOR LOADING-
let FJkLOCKMASTERDOWNFORDOWNLOAD = "FJkLOCKMASTERDOWNFORDOWNLOAD"
let FJkLOADFORMMODAL = "FJkLOADFORMMODAL"
let FJkFIRSTRUNFORDATAFROMCLOUDKIT = "FJkFIRSTRUNFORDATAFROMCLOUDKIT"
let FJkLOADPERSONALMODAL = "FJkLOADPERSONALMODAL"

// MARK: -DISPLAY-
//let FJkCOMPACTORREGULAR = "FJkCOMPACTORREGULAR"
let FJkSPVDISPLAYMODEDIDCHANGE = "FJkSPVDISPLAYMODEDIDCHANGE"
//let FJkORIENTATIONDIDCHANGE = "FJkORIENTATIONDIDCHANGE"

//  MARK: -SEGUES-
let MapVCToMapIncidentSegue = "MapVCToMapIncidentSegue"
let MapVCToMapICS214Segue = "MapVCToMapICS214Segue"
let MapVCToMapARCSegue = "MapVCToMapARCSegue"
let MAPRELEASETheSEGUE = "MAPRELEASETheSEGUE"

public enum PlistsToLoad: String {
    case fjkPLISTNFIRSIncidentLoader = "fjkPLISTNFIRSIncidentLoader"
    case fJkPLISTNFIRSLocationLoader = "fjkPLISTNFIRSLocationLoader"
    case fjkPLISTUserLocalIncidentTypeLoader = "fjkPLISTUserLocalIncidentTypeLoader"
    case fjkPLISTNFIRSStreetPrefixLoader = "fjkPLISTNFIRSStreetPrefixLoader"
    case fjkPLISTNFIRSStreetTypeLoader = "fjkPLISTNFIRSStreetTypeLoader"
    case fjkPLISTActionTakenLoader = "fjkPLISTActionTakenLoader"
    case fjkPLISTAidGivenLoader = "fjkPLISTAidGivenLoader"
    case fjkPLISTBattalionLoader = "fjkPLISTBattalionLoader"
    case fjkPLISTBuildingTypeLoader = "fjkPLISTBuildingTypeLoader"
    case fjkPLISTCompletedModulesLoader = "fjkPLISTCompletedModulesLoader"
    case fjkPLISTCouncilWardLoader = "fjkPLISTCouncilWardLoader"
    case fjkPLISTaDivisionsLoader = "fjkPLISTaDivisionsLoader"
    case fjkPLISTFireDistrictsLoader = "fjkPLISTFireDistrictsLoader"
    case fjkPLISTHazardousMaterialsLoader = "fjkPLISTHazardousMaterialsLoader"
    case fjkPLISTInstallersLoader = "fjkPLISTInstallersLoader"
    case fjkPLISTNFIRSMixedUsePropertiesLoader = "fjkPLISTNFIRSMixedUsePropertiesLoader"
    case fjkPLISTNFIRSFormLoader = "fjkPLISTNFIRSFormLoader"
    case fjkPLISTNFIRSFormTOCLoader = "fjkPLISTNFIRSFormTOCLoader"
    case fjkPLISTPlatoonLoader = "fjkPLISTPlatoonLoader"
    case fjkPLISTPropertyUseLoader = "fjkPLISTPropertyUseLoader"
    case fjkPLISTRadioChannelsLoader = "fjkPLISTRadioChannelsLoader"
    case fjkPLISTRankLoader = "fjkPLISTRankLoader"
    case fjkPLISTRequiredModulesLoader = "fjkPLISTRequiredModulesLoader"
    case fjkPLISTUserResourcesLoader = "fjkPLISTUserResourcesLoader"
    case fjkPLISTUserStateLoader = "fjkPLISTUserStateLoader"
    case fjkPLISTUserTagsLoader = "fjkPLISTUserTagsLoader"
    case fjkPLISTUserApparatusLoader = "fjkPLISTUserApparatusLoader"
    case fjkPLISTUserAssignementLoader = "fjkPLISTUserAssignementLoader"
    case fjlPLISTUserSpecialitiesLoader = "fjlPLISTUserSpecialitiesLoader"
    case fjkPLISTUserFDIDLoader = "fjkPLISTUserFDIDLoader"
}
