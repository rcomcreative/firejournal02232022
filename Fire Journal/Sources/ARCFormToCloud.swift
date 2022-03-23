//
//  ARCFormToCloud.swift
//  Fire Journal
//
//  Created by DuRand Jones on 10/12/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class ARCFormToCloud: NSObject {

//    MARK: -PROPERTIES-
    var objectID: NSManagedObjectID!
    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    var arcForm: ARCrossForm!
    var thread:Thread!
    let nc = NotificationCenter.default
    let dayFormat = DateFormatter()
    var formBody = [ String: Any ]()
    let FIRECLOUD_URL = "https://www.firejournalcloud.com/forms/api/arc.php"
    
    //    MARK: -THREAD CHECK-
    @objc func checkTheThread() {
        let testThread:Bool = thread.isMainThread
        print("here is testThread \(testThread) and \(Thread.current)")
    }
    
    // MARK: -Core Data
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    
    init(_ context: NSManagedObjectContext) {
        self.context = context
        super.init()
        self.bkgrdContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        self.bkgrdContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        self.thread = Thread(target:self, selector:#selector(checkTheThread), object:nil)
        self.nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: bkgrdContext)
    }
    
//    MARK: -BUILD THE FORM FOR JSON-
    func arcBuildToShare(_ objectID: NSManagedObjectID) ->[ String : Any ] {
        
        self.arcForm = bkgrdContext.object(with: objectID) as? ARCrossForm
        
        var streetAddress: String = ""
        if let street = arcForm.arcLocationAddress {
            streetAddress = street
        }
        if streetAddress == "" {
            if let num = arcForm.arcLocationStreetNum {
                streetAddress = num
            }
            if let name = arcForm.arcLocationStreetName {
                streetAddress = "\(streetAddress) \(name)"
            }
        }
        
        var aptMobile: String = ""
        if let apt = arcForm.arcLocationAptMobile {
            aptMobile = apt
        }
        
        var city: String = ""
        if let cityName = arcForm.arcLocationCity {
            city = cityName
        }
        
        var state: String = ""
        if let theState = arcForm.arcLocaitonState {
            state = theState
        }
        
        var zip: String = ""
        if let theZip = arcForm.arcLocationZip {
            zip = theZip
        }
        
        var numSA: String = ""
        if let num = arcForm.numNewSA {
            numSA = num
        }
        
        var numBS: String = ""
        if let bed = arcForm.numBedShaker {
            numBS = bed
        }
        
        var numBat: String = ""
        if let bat = arcForm.numBatteries {
            numBat = bat
        }
        
        var numC02: String = ""
        if let c02 = arcForm.numC02detectors {
            numC02 = c02
        }
        
        var spm: String = ""
        if arcForm.receiveSPM {
            spm = "1"
        } else {
            spm = "0"
        }
        
        var ep: String = ""
        if arcForm.recieveEP {
            ep = "1"
        } else {
            ep = "0"
        }
        
        var fep: String = ""
        if arcForm.createFEPlan {
            fep = "1"
        } else {
            fep = "0"
        }
        
        var hfsc: String = ""
        if arcForm.reviewFEPlan {
            hfsc = "1"
        } else {
            hfsc = "0"
        }
        
        var lz: String = ""
        if arcForm.localHazard {
            lz = "1"
        } else {
            lz = "0"
        }
        
        var hazText: String = ""
        if let haz = arcForm.hazard {
            hazText = haz
        }
        
        var countP: String = ""
        if let people = arcForm.iaNumPeople {
            countP = people
        }
        
        var count17: String = ""
        if let c17 = arcForm.ia17Under {
            count17 = c17
        }
        
        var count65: String = ""
        if let c65 = arcForm.ia65Over {
            count65 = c65
        }
        
        var countD: String = ""
        if let cD = arcForm.iaDisability {
            countD = cD
        }
        
        var countV: String = ""
        if let cV = arcForm.iaVets {
            countV = cV
        }
        
        var countPSA: String = ""
        if let cP = arcForm.iaPrexistingSA {
            countPSA = cP
        }
        
        var countFunc: String = ""
        if let cF = arcForm.iaWorkingSA {
            countFunc = cF
        }
        
        var countPE: String = ""
        if let cPE = arcForm.iaHowOldSA {
            countPE = cPE
        }
        
        var aNotes: String = ""
        if let aN = arcForm.iaNotes {
            aNotes = aN
        }
        
        var national: String = ""
        if let nat = arcForm.nationalPartner {
            national = nat
        }
        
        var local: String = ""
        if let loc = arcForm.localPartner {
            local = loc
        }
        
        var option1: String = ""
        if let opt1 = arcForm.option1 {
            option1 = opt1
        }
        
        var option2: String = ""
        if let opt2 = arcForm.option2 {
            option2 = opt2
        }
        
        var rEmail: String = ""
        if let rE = arcForm.residentEmail {
            rEmail = rE
        }
        
        var rCell: String = ""
        if let rC = arcForm.residentCellNum {
            rCell = rC
        }
        
        var rOther: String = ""
        if let rO = arcForm.residentOtherPhone {
            rOther = rO
        }
        
        var rName: String = ""
        if let rN = arcForm.residentName {
            rName = rN
        }
        
        var rSignatureDate: String = ""
        if let date = arcForm.residentSigDate {
            dayFormat.dateFormat = "MM/dd/YYYY"
            rSignatureDate = dayFormat.string(from: date)
        }
        
        var iName: String = ""
        if let iN = arcForm.installerName {
            iName = iN
        }
        
        var iSignatureDate: String = ""
        if let date = arcForm.installerDate {
            dayFormat.dateFormat = "MM/dd/YYYY"
            iSignatureDate = dayFormat.string(from: date)
        }
        
        var adminName: String = ""
        if let aName = arcForm.adminName {
            adminName = aName
        }
        
        var adminDate: String = ""
        if let date = arcForm.adminDate {
            dayFormat.dateFormat = "MM/dd/YYYY"
            adminDate = dayFormat.string(from: date)
        }
        
        var portal: String = ""
        var markerType: String = ""
        if let port = arcForm.arcPortalSystem {
            portal = port
            if portal == "ARC ORP" {
                markerType = "Installation Red Cross"
            } else if portal == "MySmokeAlarm" {
                markerType = "Installation MySmokeAlarm"
            } else if portal == "Other" {
                markerType = "Installation Other"
            }
        }
        
        var residentData: Data = Data()
        if arcForm.residentSigned {
            residentData = imageForCloudKit(signature: "Resident")
        }
        
        var installerData: Data = Data()
        if arcForm.installerSigend {
            installerData = imageForCloudKit(signature: "Installer")
        }
        
        formBody = [
            "arcLocationAddress": streetAddress,
            "APT/mobile": aptMobile,
            "arcLocationCity": city,
            "arcLocationState": state,
            "arcLocationZip": zip,
            "numNewSA": numSA,
            "numBedShaker": numBS,
            "numBatteries": numBat,
            "numC02detectors": numC02,
            "receiveSPM": spm,
            "recieveEP": ep,
            "createFEPlan": fep,
            "reviewFEPlan": hfsc,
            "localHazard": lz,
            "hazard": hazText,
            "iaNumPeople": countP,
            "ia17Under": count17,
            "ia65Over": count65,
            "iaDisability": countD,
            "iaVets": countV,
            "iaPrexistingSA": countPSA,
            "iaWorkingSA": countFunc,
            "iaHowOldSA": countPE,
            "iaNotes": aNotes,
            "nationalPartner": national,
            "localPartner": local,
            "option1": option1,
            "option2": option2,
            "residentEmai": rEmail,
            "residentCellNum": rCell,
            "residentOtherPhone": rOther,
            "residentName": rName,
            "residentSigDate": rSignatureDate,
            "installerName": iName,
            "installerDate": iSignatureDate,
            "adminName": adminName,
            "adminDate": adminDate,
            "arcPortalSystem": portal,
            "markerType": markerType
            ]
        
        if !installerData.isEmpty {
            formBody["installerSignature"] = installerData.base64EncodedString()
        }
        
        if !residentData.isEmpty {
            formBody["residentSignature"] = residentData.base64EncodedString()
        }
        
        guard JSONSerialization.isValidJSONObject(formBody) else {  return ["nothing": "not valid"]  }
        print(formBody)
        
        return formBody
    }
    
    func setTheData(dataCompletionHander: @escaping ( String, Error? ) -> Void ) {
        
    }
    
//    MARK: -PROCESS AND SEND-
    func sendAndRecieve(dataCompletionHander: @escaping ( String, Error? ) -> Void ) {
        
        do {
            
            let bodyData = try JSONSerialization.data(withJSONObject: formBody, options: [] )
            
            let validationURLString = FIRECLOUD_URL
            guard let validationURL = URL(string: validationURLString) else {  return  }
            
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForResource = TimeInterval(180)
            let session = URLSession(configuration: sessionConfig)
            
            var request = URLRequest.init(url: validationURL, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 180)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.httpBody = bodyData
            
            let task = session.uploadTask(with: request, from: bodyData) { (data, response, error) in
                print("here is the data \(String(describing: data)) here is the error \(String(describing: error))")
                if let data = data , error == nil {
                    do {
                        let appReceiptJSON = try JSONSerialization.jsonObject(with: data, options: .allowFragments )  as! [ String:Any ]
//                        let appReceiptJSON = try JSONSerialization.jsonObject(with: data, options: [])  as! [ String:Any ]
                        print("here is appReceiptJSON \(appReceiptJSON)")
                        let pdfLink: String = (appReceiptJSON["pdf"] as! String)
                        DispatchQueue.main.async {
                            self.nc.post(name: Notification.Name(rawValue: FJkLINKFROMCLOUDFORARCROSSFORMTOSHARE),
                                         object: nil, userInfo: ["pdfLink":pdfLink])
                        }
                        dataCompletionHander( pdfLink , nil )
                        
                    } catch {
                        let nserror = error as NSError
                        print("Unresolved error \(nserror), \(nserror.userInfo)")
//                        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                    }
                }
            }
            task.resume()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
    }

//    MARK: -SIGNATURE GATHERING-
    func getDirectoryPath() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory
    }
    
    func imageForCloudKit(signature: String) ->Data {
        var image: UIImage!
        var imageData: Data!
        if signature == "Installer" {
            image = UIImage.init(data: self.arcForm.installerSignature!)!
        } else if signature == "Resident" {
            image = UIImage.init(data: self.arcForm.residentSignature!)!
        }
        imageData = image.pngData()
        return imageData
   }
}
