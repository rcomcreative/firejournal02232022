    //
    //  CKErrorAlert.swift
    //  CKErrorAlert
    //
    //  Created by DuRand Jones on 9/14/21.
    //

    import Foundation
    import UIKit
    import CloudKit

    class CKErrorAlert: NSObject {
        
        //      MARK: -CLOUDKIT Error Messages-
        let FJkNETWORKFailure = "There was a CloudKit network failure. Try again later."
        let FJkSERVICEUNAVAILABLE = "The CloudKit Service is unavailable. Try again later."
        let FJkPARTIALFAILURE = "There was a CloudKit Partial Failure. Try again later."
        let FJkQuotaExceeded = "You have exceeded your iCloud storage, go into settings and manage your storage capacity. Try again later."
        let FJkFAILURENORECOVERY = "CloudKit failed acess. Try again later."
        let FJkRateLimited = "CloudKit rate limited."
        let FJkAlreadyShared = "This record has alredy been shared."
        let FJkRecordMayHaveBeenChanged = "This record may have been changed before this save."
        let FJkZoneNotFound = "The shared zone requested was not found."
        let FJkUSERNOTLOGGEDIN = "You need to be logged in with you AppleID on this device for this app to function correctly."
        let FJkNotPartOfShare = "This save was not part of the share document. Share needs to be verified."
        let FJkTooManyParticipants = "This Fire Station has too many participants, notify the admin of this Fire Station."
        
        override init() {
            super .init()
        }
        
        func buildTheError(errorCode: Int )->String? {
            var errorText: String = ""
            switch errorCode {
            case 1:
                errorText = FJkFAILURENORECOVERY
            case 2:
                errorText = FJkPARTIALFAILURE
            case 3, 4, 6, 34:
                errorText = FJkNETWORKFailure
            case 5, 11, 20, 24, 32:
                errorText = FJkFAILURENORECOVERY
            case 9:
                errorText = FJkUSERNOTLOGGEDIN
            case 17:
                errorText = FJkRecordMayHaveBeenChanged
            case 25:
                errorText = FJkQuotaExceeded
            case 26:
                errorText = FJkZoneNotFound
            case 29:
                errorText = FJkTooManyParticipants
            case 30:
                errorText = FJkAlreadyShared
            case 33:
                errorText = FJkNotPartOfShare
            default:
                errorText = FJkNETWORKFailure
            }
            return errorText
        }
        
        func errorAlert(errorMessage: String) -> UIAlertController {
            let alert = UIAlertController.init(title: "Error", message: errorMessage, preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
                
            })
            alert.addAction(okAction)
            return alert
        }
        
    }
