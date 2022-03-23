//
//  DetailViewController+Extensions.swift
//  Fire Journal
//
//  Created by DuRand Jones on 10/19/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//


import UIKit
import AVFoundation
import Foundation
import CoreData
import CoreLocation
import StoreKit

extension DetailViewController {
    
//    MARK: -THE SPINNER FOR DATA LOAD-
    /// Update Data from Location to LocationSC in Core Data
    func updateLocationDataToSC() {
        if !alertUp {
                let title: InfoBodyText = .updateLocationSubject
                let message: InfoBodyText = .updateLocationMessage
                let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
                let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
                    self.alertUp = false
//                    self.createSpinnerView()
                    
                    //                    FJkLOCKMASTERDOWNFORDOWNLOAD
                })
                alert.addAction(okAction)
                alertUp = true
                self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    /// observer on FJkLocationsAllUpdatedToSC
    /// - Parameter ns: no user info
    @objc func removeSpinnerUpdate(ns: Notification) {
        if childAdded {
            DispatchQueue.main.async {
                // then remove the spinner view controller
                self.child.willMove(toParent: nil)
                self.child.view.removeFromSuperview()
                self.child.removeFromParent()
                self.nc.post(name:Notification.Name(rawValue: FJkLOCKMASTERDOWNFORDOWNLOAD),
                             object: nil,
                             userInfo: nil)
                self.nc.post(name:Notification.Name(rawValue: FJkLETSCHECKTHEVERSION),
                             object: nil,
                             userInfo: nil)
            }
            childAdded = false
        }
    }
    
    /// download all data from cloudkit if it exists
    func goingToStartADownloadFromCloud() {
        if !alertUp {
            let count:Int = self.userDefaults.integer(forKey: FJkALERTBACKUPCOMPLETED)
            if count == 0 {
                let title: InfoBodyText = .cloudDataSubject
                let message: InfoBodyText = .cloudData
                let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
                let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
                    self.alertUp = false
                    self.createSpinnerView()
                    
                    //                    FJkLOCKMASTERDOWNFORDOWNLOAD
                })
                alert.addAction(okAction)
                alertUp = true
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    /// creates a spinner view to hold the scene while data is downloaded from cloudkit
    /// posts to master to lock all the buttons down
    func createSpinnerView() {
        child = SpinnerViewController()
        childAdded = true
        // add the spinner view controller
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
        nc.post(name:Notification.Name(rawValue: FJkLOCKMASTERDOWNFORDOWNLOAD),
                object: nil,
                userInfo: nil)
    }
    
    /// notification from cloudkit download is concluded
    /// FJkRELOADTHEDASHBOARD
    /// - Parameter ns: notification no userinfo included
    /// - Returns: removes spinner and tells Master to remove lock on buttons
    @objc func newContentForDashboard(ns: Notification)->Void {
        if agreementAccepted {
            entity = "FireJournalUser"
            attribute = "userGuid"
            sortAttribute = "lastName"
            startEndShift = userDefaults.bool(forKey: FJkSTARTSHIFTENDSHIFTBOOL)
        }
        // wait two seconds to simulate some work happening
        if childAdded {
            DispatchQueue.main.async {
                // then remove the spinner view controller
                self.child.willMove(toParent: nil)
                self.child.view.removeFromSuperview()
                self.child.removeFromParent()
                self.nc.post(name:Notification.Name(rawValue: FJkLOCKMASTERDOWNFORDOWNLOAD),
                             object: nil,
                             userInfo: nil)
            }
            childAdded = false
        }
        
        
        if !alertUp {
            var count:Int = self.userDefaults.integer(forKey: FJkALERTBACKUPCOMPLETED)
            if count == 0 {
                let title: InfoBodyText = .cloudDataSubject2
                let message: InfoBodyText = .cloudData2
                let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
                let learnMore = UIAlertAction.init(title: "Learn More", style: .default, handler: {_ in
                    self.alertUp = false
                    count = count + 1
                    if count > 20 {
                        count = 0
                    }
                    self.userDefaults.set(count, forKey: FJkALERTBACKUPCOMPLETED)
                    self.userDefaults.synchronize()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.nc.post(name:Notification.Name(rawValue:FJkSTOREINALERTTAPPED),
                                     object: nil,
                                     userInfo: nil)
                    }
                })
                alert.addAction(learnMore)
                let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
                    self.alertUp = false
                    count = count + 1
                    if count > 20 {
                        count = 0
                    }
                    self.userDefaults.set(count, forKey: FJkALERTBACKUPCOMPLETED)
                    self.userDefaults.synchronize()
                    if self.firstRun {
                        self.fdResourcesPointOfTruthFirstTime()
                        self.firstRun = false
                        DispatchQueue.main.async {
                            self.nc.post(name:Notification.Name(rawValue:FJkMASTERRELOADDETAIL), object: nil, userInfo: nil)
                        }
                    }
                })
                alert.addAction(okAction)
                alertUp = true
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    //    MARK: -WEATHER NOTIFICATION
    /// notification to get weather for weather cell on FJkWEATHERHASBEENUPDATED
    /// - Parameter ns: userinfo includes temp, humidity, windspeed and direction
    @objc func updateWeatherInfo(ns: Notification) {
        if let userInfo = ns.userInfo as! [String: Any]? {
            weatherTemperature = userInfo[FJkTEMPERATURE] as? String ?? ""
            weatherHumidity = userInfo[FJkHUMIDITY] as? String ?? ""
            weatherWindSpeed = userInfo[FJkWINDSPEEDDIRECTION] as? String ?? ""
            
            if !menuCall {
                if cellCount == 7 {
                    let indexPath = IndexPath(row: 6, section: 0)
                    detailCollectionView.reloadItems(at: [indexPath])
                }
            }
        }
    }
    
//    MARK: -FD RESOURCES - POINT OF TRUTH-
    func fdResoucesPointOfTruth() {
        let userFDResourcesUpdated = self.userDefaults.bool(forKey: FJkUserFDResourcesPointOfTruthOperationHasRun)
        if !userFDResourcesUpdated {
            DispatchQueue.main.async {
                self.nc.post(name:Notification.Name(rawValue:(FJkUSERFDRESOURCESPOINTOFTRUTH)),
                             object: nil,
                             userInfo: ["firstRun":true,"runOnce":false])
            }
            self.userDefaults.set(true, forKey: FJkUserFDResourcesPointOfTruthOperationHasRun)
            self.userDefaults.synchronize()
        }
    }

    
    func fdResourcesPointOfTruthFirstTime() {
        print("Running fdResourcesPointOfTruthFirstTime")

        DispatchQueue.main.async {
            self.nc.post(name:Notification.Name(rawValue:(FJkUSERFDRESOURCESPOINTOFTRUTH)),
                     object: nil,
                     userInfo: nil )
        }
        self.userDefaults.set(true, forKey: FJkUserFDResourcesPointOfTruthOperationHasRun)
        self.userDefaults.synchronize()
    }
    
//    MARK: -CELLS REGISTER-
    func registerTheCells() {
        detailCollectionView.register(UINib.init(nibName: "UpdateAndEndShiftCVCell", bundle: nil), forCellWithReuseIdentifier: updateAndEndShiftCVCellIdentifier)
        detailCollectionView.register(UINib.init(nibName: "EndShiftCVCell", bundle: nil), forCellWithReuseIdentifier: endShiftCVCellIdentifier)
        detailCollectionView.register(UINib.init(nibName: "NewFormsCVCell", bundle: nil), forCellWithReuseIdentifier: newFormsCVCellIdentifier)
        detailCollectionView.register(UINib.init(nibName: "StartShiftCVCell", bundle: nil), forCellWithReuseIdentifier: startShiftCVCellIdentifier)
        detailCollectionView.register(UINib.init(nibName: "TodaysIncidentsCVCell", bundle: nil), forCellWithReuseIdentifier: todaysIncidentsCVCellIdentifer)
        detailCollectionView.register(UINib.init(nibName: "TodaysShiftCVCell", bundle: nil), forCellWithReuseIdentifier: todaysShiftCVCellIdentifier)
        detailCollectionView.register(UINib.init(nibName: "UpdateAndEndShiftCVCell", bundle: nil), forCellWithReuseIdentifier: updateAndEndShiftCVCellIdentifier)
        detailCollectionView.register(UINib.init(nibName: "UpdateShiftCVCell", bundle: nil), forCellWithReuseIdentifier: updateShiftCVCellIdentifier)
        detailCollectionView.register(UINib.init(nibName: "WeatherCVCell", bundle: nil), forCellWithReuseIdentifier: weatherCVCellIdentifier)
        detailCollectionView.register(UINib.init(nibName: "IncidentMonthTotalsCVCell", bundle: nil), forCellWithReuseIdentifier: incidentMonthTotalsCVCellIdentifer)
        detailCollectionView.register(UINib.init(nibName: "StationResourcesStatusCVCell", bundle: nil), forCellWithReuseIdentifier: stationResourcesStatusCVCellIdentifier)
    }
    
//    MARK: -REGISTER NOTIFICATIONS-
    func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector:#selector(formsWasTapped(notification:)), name:NSNotification.Name(rawValue: FJkFORMS_FROM_MASTER), object: nil)
        NotificationCenter.default.addObserver(self,selector:#selector(newUserCreated(notification:)), name:NSNotification.Name(rawValue:FJkFireJournalUserSaved),object:nil)
        
        NotificationCenter.default.addObserver(self, selector:#selector(noConnectionCalled(ns:)),name:NSNotification.Name(rawValue: kHAVENO_CONNECTIONALERT), object: nil)
        
        NotificationCenter.default.addObserver(self, selector:#selector(startShiftForDash(ns:)),name:NSNotification.Name(rawValue: FJkSTARTSHIFTFORDASH), object: nil)
        
        NotificationCenter.default.addObserver(self, selector:#selector(newContentForDashboard(ns:)),name:NSNotification.Name(rawValue: FJkRELOADTHEDASHBOARD), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        
        nc.addObserver(self, selector:#selector(updateWeatherInfo(ns:)),name:NSNotification.Name(rawValue: FJkWEATHERHASBEENUPDATED), object: nil)
        
        nc.addObserver(self, selector: #selector(loadTheFormModal(ns:)), name: NSNotification.Name(rawValue: FJkLOADFORMMODAL), object: nil)
        
        nc.addObserver(self, selector: #selector(addNewPersonalNewEntryModal(nc:)), name: NSNotification.Name(rawValue: FJkLOADPERSONALMODAL), object: nil)
        
        nc.addObserver(self, selector: #selector(presentTheIncidentModalFirstTime(nc:)), name: NSNotification.Name(rawValue: FJkFireJournalNeedsFirstIncident), object: nil)
        
        nc.addObserver(self, selector: #selector(changeTheLocationsToSC(ns:)), name: NSNotification.Name(rawValue: FJkChangeTheLocationsTOLOCATIONSSC), object: nil)
        
        nc.addObserver(self, selector: #selector(checkOnTheVersion(ns:)), name: NSNotification.Name(rawValue: FJkLETSCHECKTHEVERSION), object: nil)
        
    }
    
//    MARK: -CONFIGURE THE CELLS-
    func configureNewShifts(_ collectionView: UICollectionView, _ indexPath: IndexPath) -> UICollectionViewCell {
        self.shift = Shift(rawValue: userDefaults.integer(forKey: FJkSTARTUPDATEENDSHIFT)) ?? .end
        if !agreementAccepted {
            self.shift = .end
        }
        
        if !incidentCounted {
            self.shift = .end
        }
        
        switch shift {
        case .start:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: updateAndEndShiftCVCellIdentifier, for: indexPath as IndexPath) as! UpdateAndEndShiftCVCell
//            cell.delegate = self
            return cell
        case .update:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: updateAndEndShiftCVCellIdentifier, for: indexPath as IndexPath) as! UpdateAndEndShiftCVCell
//            cell.delegate = self
            return cell
        case .end:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: startShiftCVCellIdentifier, for: indexPath as IndexPath) as! StartShiftCVCell
//            cell.delegate = self
            return cell
        }
    }
    
    func configureShifts(_ collectionView: UICollectionView, _ indexPath: IndexPath) -> UICollectionViewCell {
        if agreementAccepted {
            self.shift = Shift(rawValue: userDefaults.integer(forKey: FJkSTARTUPDATEENDSHIFT)) ?? .end
            switch shift {
            case .start:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: todaysShiftCVCellIdentifier, for: indexPath as IndexPath) as! TodaysShiftCVCell
                cell.agreementAccepted = self.agreementAccepted
                cell.shiftData = self.todayShiftData
                return cell
            case .update:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: updateShiftCVCellIdentifier, for: indexPath as IndexPath) as! UpdateShiftCVCell
                cell.agreementAccepted = self.agreementAccepted
                cell.column = columns
                cell.updateShiftData = self.updateShiftData
                return cell
            case .end:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: endShiftCVCellIdentifier, for: indexPath as IndexPath) as! EndShiftCVCell
                cell.agreementAccepted = self.agreementAccepted
                if endShiftData != nil {
                    cell.endShiftData = self.endShiftData
                }
                return cell
            }
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: todaysShiftCVCellIdentifier, for: indexPath as IndexPath) as! TodaysShiftCVCell
            cell.shiftData = self.todayShiftData
            return cell
        }
    }
    
    func configureNewFormsCell(_ collectionView: UICollectionView, _ indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: newFormsCVCellIdentifier, for: indexPath as IndexPath) as! NewFormsCVCell
        cell.delegate = self
        return cell
    }
    
    func configureTodaysIncidentCell(_ collectionView: UICollectionView, _ indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: todaysIncidentsCVCellIdentifer, for: indexPath as IndexPath) as! TodaysIncidentsCVCell
        if agreementAccepted {
            
            cell.totalCount = todaysCount.totalCount
            cell.fireCount = todaysCount.fireCount
            cell.emsCount = todaysCount.emsCount
            cell.rescueCount = todaysCount.rescueCount
            cell.allOfTodaysIncidents = allOfTodaysIncidents
            
            if fireStationLocation != nil {
                cell.location = fireStationLocation
            }
            if fireStationAddress != "" {
                cell.fsAddress = fireStationAddress
            }
        }
        return cell
    }
    
    func configureStationResourcesStatusCell(_ collectionView: UICollectionView, _ indexPath: IndexPath) ->UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: stationResourcesStatusCVCellIdentifier, for: indexPath) as! StationResourcesStatusCVCell
        return cell
    }
    
    func configureIncidentMonthTotalsCell(_ collectionView: UICollectionView, _ indexPath: IndexPath) ->UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: incidentMonthTotalsCVCellIdentifer, for: indexPath) as! IncidentMonthTotalsCVCell
        cell.primaryYear = thisYear
        cell.years = theYears
        cell.yearOfCounts = totalsForYears
        return cell
    }
    
    func configureWeather(_ collectionView: UICollectionView, _ indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: weatherCVCellIdentifier, for: indexPath as IndexPath) as! WeatherCVCell
        cell.temperatureL.text = weatherTemperature
        cell.humidityL.text = weatherHumidity
        cell.windL.text = weatherWindSpeed
        return cell
    }

    
}

extension DetailViewController: SKStoreProductViewControllerDelegate {
    
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
}

extension DetailViewController: OpenModalScrollVCDelegate {
    func allCompleted(yesNo: Bool) {
        dismiss(animated: true, completion: {
            self.userDefaults.set(true, forKey: FJkFIRSTRUNFORDATAFROMCLOUDKIT)
            self.userDefaults.synchronize()
            self.theAgreementsAccepted()
            self.freshDeskRequest()
            self.appDelegate.fetchAnyChangesWeMissed(firstRun: true)
            DispatchQueue.main.async {
                self.nc.post(name:Notification.Name(rawValue:FJkOPENWEATHER_UPDATENow),object: nil)
            }
        })
    }
    
    func theAgreementsAccepted() {
        agreementAccepted = userDefaults.bool(forKey: FJkUserAgreementAgreed)
        if let guid = userDefaults.string(forKey: FJkUSERTIMEGUID) {
            startEndGuid = guid
        }
    }
    
    func freshDeskRequest() {
        let fresh = self.userDefaults.bool(forKey: FJkFRESHDESK_UPDATED)
        DispatchQueue.main.async {
            if !fresh {
                let title:String = "Sync with CRM"
                let message:String = "We would like add your info to our CRM for customer service."
                let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
                var userIsFromCloud: Bool = false
                let okAction = UIAlertAction.init(title: "Yes Thank you", style: .default, handler: {_ in
                    self.alertUp = false
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: FJkFRESHDESK_UPDATENow), object: nil, userInfo: nil)
                        userIsFromCloud = self.userDefaults.bool(forKey: FJkFJUSERSavedToCoreDataFromCloud)
                        if userIsFromCloud {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                print("Timer fired!")
                                self.goingToStartADownloadFromCloud()
                            }
                        } else {
                            self.buildUsersFDResourcesAfterAgreement()
                        }
                    }
                })
                alert.addAction(okAction)
                let noAction = UIAlertAction.init(title: "No Thanks", style: .default, handler: {_ in
                    self.alertUp = false
                    let fresh = false
                    DispatchQueue.main.async {
                        self.userDefaults.set(fresh, forKey: FJkFRESHDESK_UPDATED)
                        self.userDefaults.synchronize()
                        userIsFromCloud = self.userDefaults.bool(forKey: FJkFJUSERSavedToCoreDataFromCloud)
                        if userIsFromCloud {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                print("Timer fired!")
                                self.goingToStartADownloadFromCloud()
                            }
                        } else {
                            self.buildUsersFDResourcesAfterAgreement()
                        }
                    }
                })
                alert.addAction(noAction)
                self.present(alert, animated: true, completion: nil)
                self.alertUp = true
            }
        }
    }
    
    
    
    
    
    
    func errorOnFormLoad(errorInCD: String) {
        dismiss(animated: true, completion: {
            let title:String = "Error in Core Data"
            let message:String = errorInCD
            let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
                self.alertUp = false
            })
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            self.alertUp = true
        })
    }
}

extension DetailViewController: PinterestLayoutDelegate {
    
    func collectionViewSS(_ collectionView: UICollectionView, heightForStartShiftCVCell indexPath: IndexPath) -> CGFloat {
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = detailCollectionView.dequeueReusableCell(withReuseIdentifier: startShiftCVCellIdentifier, for: indexPath as IndexPath) as! StartShiftCVCell
        var height: CGFloat
        height = cell.contentView.bounds.size.height
        return height
    }
    
    func collectionViewUPandE(_ collectionView: UICollectionView, heightForUpdateAndEndShiftCVCell indexPath: IndexPath) -> CGFloat {
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = detailCollectionView.dequeueReusableCell(withReuseIdentifier: updateAndEndShiftCVCellIdentifier, for: indexPath as IndexPath) as! UpdateAndEndShiftCVCell
        let height = cell.contentView.bounds.size.height
        return height
    }
    
    func collectionViewNForms(_ collectionView: UICollectionView, heightForNewFormsCVCell indexPath: IndexPath) -> CGFloat {
        let indexPath = IndexPath(row: 2, section: 0)
        let cell = detailCollectionView.dequeueReusableCell(withReuseIdentifier: newFormsCVCellIdentifier, for: indexPath as IndexPath) as! NewFormsCVCell
        let height = cell.contentView.bounds.size.height
        return height
    }
    
    func collectionViewTS(_ collectionView: UICollectionView, heightForTodaysShiftCVCell indexPath: IndexPath) -> CGFloat {
        let indexPath = IndexPath(row: 1, section: 0)
        let cell = detailCollectionView.dequeueReusableCell(withReuseIdentifier: todaysShiftCVCellIdentifier, for: indexPath as IndexPath) as! TodaysShiftCVCell
        let height = cell.contentView.bounds.size.height
        return height
    }
    
    func collectionViewUPS(_ collectionView: UICollectionView, heightForUpdateShiftCVCell indexPath: IndexPath) -> CGFloat {
        let indexPath = IndexPath(row: 1, section: 0)
        let cell = detailCollectionView.dequeueReusableCell(withReuseIdentifier: updateShiftCVCellIdentifier, for: indexPath as IndexPath) as! UpdateShiftCVCell
        let height = cell.contentView.bounds.size.height
        return height
    }
    
    func collectionViewES(_ collectionView: UICollectionView, heightForEndShiftCVCell indexPath: IndexPath) -> CGFloat {
        let indexPath = IndexPath(row: 1, section: 0)
        let cell = detailCollectionView.dequeueReusableCell(withReuseIdentifier: endShiftCVCellIdentifier, for: indexPath as IndexPath) as! EndShiftCVCell
        let height = cell.contentView.bounds.size.height
        return height
    }
    
    func collectionViewTI(_ collectionView: UICollectionView, heightForTodaysIncidentsCVCell indexPath: IndexPath) -> CGFloat {
        let indexPath = IndexPath(row: 3, section: 0)
        let cell = detailCollectionView.dequeueReusableCell(withReuseIdentifier: todaysIncidentsCVCellIdentifer, for: indexPath as IndexPath) as! TodaysIncidentsCVCell
        let height = cell.contentView.bounds.size.height
        return height
    }
    
    func collectionViewStationResources(_ collectionView: UICollectionView, heightForStationResourcesCVCell indexPath: IndexPath) ->CGFloat {
        let indexPath = IndexPath(row: 4, section: 0)
        let cell = detailCollectionView.dequeueReusableCell(withReuseIdentifier: stationResourcesStatusCVCellIdentifier, for: indexPath as IndexPath) as! StationResourcesStatusCVCell
        let height = cell.contentView.bounds.size.height
        return height
    }
    
    func collectionViewIncidentMonths(_ collectionView: UICollectionView, heightForIncidentMonthsTotalsCVCell indexPath: IndexPath) ->CGFloat {
        let indexPath = IndexPath(row: 5, section: 0)
        let cell = detailCollectionView.dequeueReusableCell(withReuseIdentifier: incidentMonthTotalsCVCellIdentifer, for: indexPath as IndexPath) as! IncidentMonthTotalsCVCell
        let height = cell.contentView.bounds.size.height
        return height
    }
    
    func collectionViewW(_ collectionView: UICollectionView, heightForWeatherCVCell indexPath: IndexPath) -> CGFloat {
        let indexPath = IndexPath(row: 6, section: 0)
        let cell = detailCollectionView.dequeueReusableCell(withReuseIdentifier: weatherCVCellIdentifier, for: indexPath as IndexPath) as! WeatherCVCell
        let height = cell.contentView.bounds.size.height
        return height
    }
    
    func whatIsTheShift() -> Shift {
        return self.shift
    }
    
}

extension DetailViewController: UpdateShiftDashboardModalTVCDelegate {
    func updateShiftCancel() {
        self.dismiss(animated: true, completion: {
            self.todaysCount = nil
            self.incidentTotalCounts = nil
            self.todayCountsEmpty.toggle()
            self.viewWillLayoutSubviews()
        })
    }
    
    func updateShiftSave(shift: MenuItems, UpdateShift: UpdateShiftData) {
        updateShiftStructure = UpdateShift
        shiftExists = true
        self.shift = .update
        updateShiftForDashboard = TheUpdateShiftForDashboard.init(thisDay: Date())
        updateShiftData = updateShiftForDashboard.buildShiftForDashboard()
        self.userDefaults.set(1, forKey: FJkSTARTUPDATEENDSHIFT)
        self.userDefaults.set(true, forKey: FJkSTARTSHIFTENDSHIFTBOOL)
        self.userDefaults.synchronize()
        startEndShift = true
        processCollectionView()
        let shouldAlert = userDefaults.bool(forKey: FJkUpdateShiftDontShowAgain)
        self.dismiss(animated: true, completion: {
            if !shouldAlert {
                if !self.alertUp {
                    self.presentUpdateAlert()
                }
            }
        })
    }
    
    func presentUpdateAlert() {
        let message: InfoBodyText = .updateShiftSupportNotes2
        let title: InfoBodyText = .updateShiftSupportNotesSubject2
        let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
        })
        let dontShow = UIAlertAction.init(title: "Don't Show Again", style: .default, handler: {_ in
            self.userDefaults.set(true, forKey: FJkUpdateShiftDontShowAgain)
            self.userDefaults.synchronize()
        })
        alert.addAction(okAction)
        alert.addAction(dontShow)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension DetailViewController: UpdateAndEndShiftCVCellDelegate {
    func updateBTapped() {
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyboard = UIStoryboard(name: "UpdateShiftDashboardModal", bundle: nil)
        let updateShiftModalTVC  = storyboard.instantiateViewController(identifier: "UpdateShiftDashboardModalTVC") as! UpdateShiftDashboardModalTVC
        updateShiftModalTVC.delegate = self
        updateShiftModalTVC.transitioningDelegate = slideInTransitioningDelgate
        updateShiftModalTVC.modalPresentationStyle = .custom
        updateShiftModalTVC.context = context
        self.present(updateShiftModalTVC, animated: true, completion: nil)
        //        processCollectionView()
    }
    
    func endBTapped() {
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyboard = UIStoryboard(name: "EndShiftDashboardModal", bundle: nil)
        let endShiftModalTVC  = storyboard.instantiateViewController(identifier: "EndShiftBashboardModalTVC") as! EndShiftBashboardModalTVC
        endShiftModalTVC.delegate = self
        endShiftModalTVC.context = context
        endShiftModalTVC.transitioningDelegate = slideInTransitioningDelgate
        endShiftModalTVC.modalPresentationStyle = .custom
        self.present(endShiftModalTVC, animated: true, completion: nil)
        //        processCollectionView()
    }
}

extension DetailViewController: EndShiftDashboardModalTVCDelegate {
    func endShiftSave(shift: MenuItems, EndShift: EndShiftData) {
        endShiftStructure = EndShift
        shiftExists = true
        self.shift = .end
        
        endShiftForDashboard = EndShiftForDashboard.init(theDate: Date())
        endShiftData = endShiftForDashboard.buildTheEndShift()
        
        self.userDefaults.set(2, forKey: FJkSTARTUPDATEENDSHIFT)
        self.userDefaults.set(false, forKey: FJkSTARTSHIFTENDSHIFTBOOL)
        
        self.userDefaults.synchronize()
        startEndShift = false
        processCollectionView()
        let shouldAlert = userDefaults.bool(forKey: FJkEndShiftDontShowAgain)
        self.dismiss(animated: true, completion: {
            if !shouldAlert {
                if !self.alertUp {
                    self.presentEndAlert()
                }
            }
        })
    }
    
    func endShiftCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func presentEndAlert() {
        let message: InfoBodyText = .endShiftRecorded2
        let title: InfoBodyText = .endShiftRecordedSubject2
        let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
            self.endClass()
        })
        let dontShow = UIAlertAction.init(title: "Don't Show Again", style: .default, handler: {_ in
            self.userDefaults.set(true, forKey: FJkUpdateShiftDontShowAgain)
            self.userDefaults.synchronize()
            self.endClass()
        })
        alert.addAction(okAction)
        alert.addAction(dontShow)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
}

extension DetailViewController: StartShiftCVCellDelegate {
    func startShiftBTapped() {
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyboard = UIStoryboard(name: "StartShiftDashboardModal", bundle: nil)
        let startShiftModalTVC  = storyboard.instantiateViewController(identifier: "StartShiftDashbaordModalTVC") as! StartShiftDashbaordModalTVC
        startShiftModalTVC.delegate = self
        startShiftModalTVC.transitioningDelegate = slideInTransitioningDelgate
        startShiftModalTVC.modalPresentationStyle = .custom
        startShiftModalTVC.context = context
        self.present(startShiftModalTVC, animated: true, completion: nil)
    }
}

extension DetailViewController: StartShiftDashbaordModalTVCDelegate {
    func startShiftSave(shift: MenuItems, startShift: StartShiftData) {
        startShiftStructure = startShift
        shiftExists = true
        self.shift = .start
        todayShiftForDashboard = TodayShiftForDashboard.init(thisDay: Date())
        todayShiftData = todayShiftForDashboard.buildShiftForDashboard()
        self.userDefaults.set(0, forKey: FJkSTARTUPDATEENDSHIFT)
        self.userDefaults.set(true, forKey: FJkSTARTSHIFTENDSHIFTBOOL)
        self.userDefaults.synchronize()
        startEndShift = true
        processCollectionView()
        let shouldAlert = userDefaults.bool(forKey: FJkStartShiftDontShowAgain)
        self.dismiss(animated: true, completion: {
            if !shouldAlert {
                if !self.alertUp {
                    self.presentAlert()
                }
            }
        })
    }
    
    func presentAlert() {
        let title: InfoBodyText = .startShiftSupportSubject
        let message: InfoBodyText = .startShiftSupport
        let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
        })
        let dontShow = UIAlertAction.init(title: "Don't Show Again", style: .default, handler: {_ in
            self.userDefaults.set(true, forKey: FJkStartShiftDontShowAgain)
            self.userDefaults.synchronize()
        })
        alert.addAction(okAction)
        alert.addAction(dontShow)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    
    func startShiftCancel() {
        self.dismiss(animated: true, completion: nil)
        self.shift = .start
        viewWillLayoutSubviews()
    }
    
}

extension DetailViewController: SettingsTVCDelegate {
    func settingsTapped() {}
    func settingsLoadPage(settings:FJSettings) {}
}

extension DetailViewController {
    //    MARK: -FORCE RELOAD OF DATA-
    func endClass() {
        self.todaysCount = nil
        self.incidentTotalCounts = nil
        self.todayCountsEmpty.toggle()
        self.viewWillLayoutSubviews()
    }
    //    MARK: -NOTIFICATION FUNCTIONS-
    @objc func formsWasTapped(notification:Notification)-> Void {
        myShift = .forms
        //        TODO:
        //        presentModal(menuType: myShift, title: "Choose a Form Type")
    }
    
    @objc func newUserCreated(notification:Notification)-> Void {
        if let userInfo = notification.userInfo as! [String: Any]?
        {
            self.fireJournalUser = userInfo["user"] as? FireJournalUserOnboard
        }
    }
    
    @objc func noConnectionCalled(ns: Notification) {
        if vcLaunch.alertI == 0 {
            let alert = vcLaunch.networkUnavailable()
            self.present(alert,animated: true)
        }
    }
    
    @objc func startShiftForDash(ns: Notification)-> Void {
        //           if let userInfo = ns.userInfo as! [String: Any]?
        //           {
        ////               startShiftStructure = userInfo["startShift"] as? StartShiftData
        ////               self.userDefaults.set(0, forKey: FJkSTARTUPDATEENDSHIFT)
        ////               self.userDefaults.set(true, forKey: FJkSTARTSHIFTENDSHIFTBOOL)
        ////               self.userDefaults.synchronize()
        ////               startEndShift = true
        //           }
    }
    
    
    
    func processCollectionViewAfterDownload() {
        buildifAgreementAccepted()
        switch compact {
        case .compact:
            print("compact")
            if self.isViewLoaded {
                detailCollectionView.bounds = frame
                layout.contentWidth = frame.size.width
                layout.numberOfColumns = columns
                layout.cache.removeAll()
                detailCollectionView.setCollectionViewLayout(layout, animated: false)
                detailCollectionView.reloadData()
                detailCollectionView.performBatchUpdates({
                    detailCollectionView.collectionViewLayout.invalidateLayout()
                } , completion: nil )
                detailCollectionView.setContentOffset(CGPoint.zero, animated: true)
            }
        case .regular:
            print("regular")
            if self.isViewLoaded {
                detailCollectionView.bounds = frame
                layout.contentWidth = frame.size.width
                layout.numberOfColumns = columns
                layout.cache.removeAll()
                detailCollectionView.setCollectionViewLayout(layout, animated: false)
                detailCollectionView.reloadData()
                detailCollectionView.performBatchUpdates({
                    detailCollectionView.collectionViewLayout.invalidateLayout()
                } , completion: nil )
                detailCollectionView.setContentOffset(CGPoint.zero, animated: true)
            }
        }
    }
    
    func processCollectionView() {
        switch compact {
        case .compact:
            print("compact")
            if self.isViewLoaded {
                detailCollectionView.bounds = frame
                layout.contentWidth = frame.size.width
                layout.numberOfColumns = columns
                layout.cache.removeAll()
                detailCollectionView.setCollectionViewLayout(layout, animated: false)
                detailCollectionView.reloadData()
                detailCollectionView.performBatchUpdates({
                    detailCollectionView.collectionViewLayout.invalidateLayout()
                } , completion: nil )
                detailCollectionView.setContentOffset(CGPoint.zero, animated: true)
            }
        case .regular:
            print("regular")
            if self.isViewLoaded {
                detailCollectionView.bounds = frame
                layout.contentWidth = frame.size.width
                layout.numberOfColumns = columns
                layout.cache.removeAll()
                detailCollectionView.setCollectionViewLayout(layout, animated: false)
                detailCollectionView.reloadData()
                detailCollectionView.performBatchUpdates({
                    detailCollectionView.collectionViewLayout.invalidateLayout()
                } , completion: nil )
                detailCollectionView.setContentOffset(CGPoint.zero, animated: true)
            }
        }
    }
    
    func getTheUser() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FireJournalUser" )
        fetchRequest.fetchBatchSize = 1
        
        do {
            fetched = try context.fetch(fetchRequest) as! [FireJournalUser]
            if fetched.isEmpty {
            } else {
                fju = fetched.last as? FireJournalUser
            }
        } catch let error as NSError {
            print("DetailViewController line 837 Fetch failed: \(error.localizedDescription)")
        }
    }
    
    //    MARK: -COREDATE-
    func saveToCD() {
        do {
            try context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"DetailVC merge that"])
            }
            DispatchQueue.main.async {
                if let guid = self.userDefaults.string(forKey: FJkUSERTIMEGUID) {
                    self.startEndGuid = guid
                }
                if self.startEndGuid != "" {
                    self.theUserTimeCount(entity: "UserTime", guid: self.startEndGuid)
                    let id = self.fjUserTimeCD.objectID
                    self.nc.post(name:Notification.Name(rawValue:FJkCKNewStartEndCreated),
                                 object: nil,
                                 userInfo: ["objectID":id])
                    
                }
            }
        } catch let error as NSError {
            let nserror = error
            print("Unresolved error \(nserror), \(nserror.userInfo)")
            let error = "\(nserror):\(nserror.localizedDescription)\(nserror.userInfo)"
            print("DetailViewController: \(error)")
        }
    }
    
    //    MARK: -BUILD USERS FDRESOURCES-
    func buildUsersFDResourcesAfterAgreement() {
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyboard = UIStoryboard(name: "OpenFDResources", bundle: nil)
        let openFDREsourcesTVC  = storyboard.instantiateViewController(identifier: "OpenFDResourcesTVC") as! OpenFDResourcesTVC
        openFDREsourcesTVC.titleName = "Fire/EMS Resources"
        openFDREsourcesTVC.settingType = FJSettings.resources
        openFDREsourcesTVC.firstRun = true
        openFDREsourcesTVC.delegate = self
        openFDREsourcesTVC.transitioningDelegate = slideInTransitioningDelgate
        openFDREsourcesTVC.modalPresentationStyle = .custom
        self.present(openFDREsourcesTVC, animated: true, completion: nil)
    }
    
}

extension DetailViewController: OpenFDResourcesTVCDelegate {
    func openFDResourcesTVCCanceled() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func openFDResourcesTVCSave() {
        self.dismiss(animated: true, completion: {
            self.processCollectionView()
        })
    }
    
    func openFDResourcesCloseItUp() {
        self.dismiss(animated: true, completion: {
            self.processCollectionView()
        })
    }
    
    
}

extension DetailViewController: SettingsUserFDResourcesTVCDelegate {
    func userFDResourcesBackToSettings() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension DetailViewController: PersonalNewEntryModalTVCDelegate {
    
    func dismissPJModalTapped(shift: MenuItems) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func personalJournalModalSaved(id: NSManagedObjectID, shift: MenuItems) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @objc func addNewPersonalNewEntryModal(nc: Notification) {
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let personalNewEntrylModalTVC = storyBoard.instantiateViewController(withIdentifier: "PersonalNewEntryModalTVC") as! PersonalNewEntryModalTVC
        personalNewEntrylModalTVC.transitioningDelegate = slideInTransitioningDelgate
        personalNewEntrylModalTVC.modalPresentationStyle = .custom
        personalNewEntrylModalTVC.context = context
        personalNewEntrylModalTVC.delegate = self
        self.present(personalNewEntrylModalTVC,animated: true)
    }
    
}

extension DetailViewController: NewFormsCVCellDelegate {
    
    @objc func presentTheIncidentModalFirstTime(nc:Notification) {
        presentNewerIncidentModal()
    }
    
    func newJournalTapped() {
        myShift = .journal
        newJournalModalCalled()
    }
    
    func newIncidentTapped() {
        myShift = .incidents
        presentNewerIncidentModal()
    }
    
    func newFormTapped() {
        myShift = .forms
        presentModal(menuType: myShift, title: "")
    }
    
    func presentNewerIncidentModal() {
        setUpDataStructure(myShift: MenuItems.incidents)
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let modalTVC = storyBoard.instantiateViewController(withIdentifier: "NewerIncidentModalTVC") as! NewerIncidentModalTVC
        modalTVC.delegate = self
        modalTVC.context = context
        modalTVC.transitioningDelegate = slideInTransitioningDelgate
        modalTVC.modalPresentationStyle = .custom
        self.present(modalTVC, animated: true, completion: nil)
    }
    
    func newJournalModalCalled() {
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyBoard : UIStoryboard = UIStoryboard(name: "JournalSB", bundle:nil)
        let newJournalModalTVC = storyBoard.instantiateInitialViewController() as? JournalModalTVC
        newJournalModalTVC?.transitioningDelegate = slideInTransitioningDelgate
        newJournalModalTVC?.modalPresentationStyle = .custom
        newJournalModalTVC?.context = context
        newJournalModalTVC?.delegate = self
        self.present(newJournalModalTVC!,animated: true)
    }
    
    func presentModal(menuType: MenuItems, title: String) {
        setUpDataStructure(myShift: menuType)
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let modalTVC = storyBoard.instantiateViewController(withIdentifier: "ModalTVC") as! ModalTVC
        modalTVC.delegate = self
        modalTVC.transitioningDelegate = slideInTransitioningDelgate
        modalTVC.title = title
        modalTVC.myShift = menuType
        if personalModalCalled {
            modalTVC.personalJournalEntry = true
        }
        modalTVC.modalPresentationStyle = .custom
        modalTVC.context = context
        self.present(modalTVC, animated: true, completion: nil)
    }
    
    func setUpDataStructure(myShift: MenuItems) {
        switch myShift {
        case .incidents:
            incidentStructure = IncidentData.init()
        case .journal:
            journalStructure = JournalData.init()
        case .nfirsBasic1Search:
            incidentStructure = IncidentData.init()
        case .startShift:
            startShiftStructure = StartShiftData.init()
            if let guid = userDefaults.string(forKey: FJkUSERTIMEGUID) {
                if guid != "" {
                    theUserTimeCount(entity: "UserTime", guid: guid)
                } else {
                    theUserTimeLast(entity: "UserTime")
                }
            }
            startShiftStructure.ssPlatoon = fjUserTimeCD.startShiftPlatoon ?? ""
            startShiftStructure.ssFireStationTF = fjUserTimeCD.startShiftFireStation ?? ""
            startShiftStructure.ssApparatusTF = fjUserTimeCD.startShiftApparatus ?? ""
            startShiftStructure.ssAssignmentTF = fjUserTimeCD.startShiftAssignment ?? ""
            startShiftStructure.ssResourcesTF = fjUserTimeCD.startShiftResources ?? ""
            startShiftStructure.ssCrewsTF = fjUserTimeCD.startShiftCrew ?? ""
            startShiftStructure.ssAMReliefDefault = fjUserTimeCD.startShiftStatus
            if startShiftStructure.ssAMReliefDefault {
                startShiftStructure.ssAMReliefDefaultT = "AM Relief"
            } else {
                startShiftStructure.ssAMReliefDefaultT = "Overtime"
            }
        case .updateShift:
            updateShiftStructure = UpdateShiftData.init()
            if let guid = userDefaults.string(forKey: FJkUSERTIMEGUID) {
                if guid != "" {
                    theUserTimeCount(entity: "UserTime", guid: guid)
                } else {
                    theUserTimeLast(entity: "UserTime")
                }
            }
            updateShiftStructure.upsPlatoon = fjUserTimeCD.updateShiftPlatoon ?? ""
            updateShiftStructure.upsFireStationTF = fjUserTimeCD.updateShiftFireStation ?? ""
            updateShiftStructure.upsAssignmentTF = fjUserTimeCD.startShiftAssignment ?? ""
            updateShiftStructure.upsApparatusTF = fjUserTimeCD.startShiftApparatus ?? ""
            updateShiftStructure.upsResourcesTF = fjUserTimeCD.startShiftResources ?? ""
            updateShiftStructure.upsCrewCombine = fjUserTimeCD.startShiftCrew ?? ""
            updateShiftStructure.upsAMReliefDefaultT = fjUserTimeCD.updateShiftStatus
        case .endShift:
            endShiftStructure = EndShiftData.init()
            if let guid = userDefaults.string(forKey: FJkUSERTIMEGUID) {
                if guid != "" {
                    theUserTimeCount(entity: "UserTime", guid: guid)
                } else {
                    theUserTimeLast(entity: "UserTime")
                }
            }
            endShiftStructure.esPlatoon = fjUserTimeCD.updateShiftPlatoon ?? ""
            endShiftStructure.esFireStationTF = fjUserTimeCD.updateShiftFireStation ?? ""
            endShiftStructure.esApparatusTF = fjUserTimeCD.startShiftApparatus ?? ""
            endShiftStructure.esAssignmentTF = fjUserTimeCD.startShiftAssignment ?? ""
            endShiftStructure.esResourcesTF = fjUserTimeCD.startShiftResources ?? ""
            endShiftStructure.esCrewCombine = fjUserTimeCD.startShiftCrew ?? ""
            endShiftStructure.esAMReliefDefaultT = fjUserTimeCD.endShiftStatus
        default:
            print("none")
        }
    }
    
    func theUserTimeCount(entity: String, guid: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        let predicate = NSPredicate(format: "%K == %@", "userTimeGuid", guid)
        fetchRequest.predicate = predicate
        do {
            let userFetched = try context.fetch(fetchRequest) as! [UserTime]
            if userFetched.isEmpty {
                theUserTimeLast(entity: "UserTime")
            } else {
                timeCount = userFetched.count
                fjUserTimeCD = userFetched.last!
            }
        } catch let error as NSError {
            print("DetailViewController line 959 Error: \(error.localizedDescription)")
        }
    }
    
    func theUserTimeLast(entity: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        let predicate = NSPredicate(format: "%K != %@", "userTimeGuid", "")
        fetchRequest.predicate = predicate
        do {
            let userFetched = try context.fetch(fetchRequest) as! [UserTime]
            timeCount = userFetched.count
            if !userFetched.isEmpty {
                fjUserTimeCD = userFetched.last!
            }
        } catch let error as NSError {
            print("DetailViewController line 1073 Error: \(error.localizedDescription)")
        }
    }
    
    
}

extension DetailViewController: NewerIncidentModalTVCDelegate {
    func theNewIncidentCancelled() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func theNewIncidentModalSaved(ojectID: NSManagedObjectID, shift: MenuItems) {
        self.dismiss(animated: true, completion: {
            self.nc.post(name:Notification.Name(rawValue:FJkINCIDENT_FROM_MASTER), object: nil, userInfo:["sizeTrait":self.compact,"objectID":ojectID])
            self.endClass()
        })
    }
}

extension DetailViewController: JournalModalTVCDelegate {
    func dismissJModalTapped(shift: MenuItems) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func journalModalSaved(id: NSManagedObjectID, shift: MenuItems) {
        self.dismiss(animated: true, completion: {
            self.nc.post(name:Notification.Name(rawValue:FJkJOURNAL_FROM_MASTER),object: nil, userInfo: ["sizeTrait":self.compact,"objectID":id])
        })
    }
}

extension DetailViewController: ModalTVCDelegate {
    func saveBTapped(shift: MenuItems) {}
    func journalSaved(id: NSManagedObjectID, shift: MenuItems) {}
    func incidentSave(id: NSManagedObjectID, shift: MenuItems) {}
    
    func dismissTapped(shift: MenuItems) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func formTypedTapped(shift: MenuItems) {
        self.dismiss(animated: true, completion: nil)
        let nc = NotificationCenter.default
        switch shift {
        case .nfirs:
            nc.post(name:Notification.Name(rawValue:FJkNFIRSBASIC1_FROM_MASTER),
                    object: nil,
                    userInfo: ["objectID":"", "date":"","arcFormGuid":""])
        case .ics214:
            let int = theCount(entity: "ICS214Form")
            if int != 0 {
                let objectID = fetchTheLatest(shift: shift)
                nc.post(name:Notification.Name(rawValue:FJkICS214_FROM_MASTER),
                        object: nil,
                        userInfo: ["objectID": objectID, "shift": shift])
            } else {
                slideInTransitioningDelgate.direction = .bottom
                slideInTransitioningDelgate.disableCompactHeight = true
                let vc:NewICS214ModalTVC = vcLaunch.modalICS214NewCalled()
                vc.title = "New ICS 214"
                vc.delegate = self
                vc.transitioningDelegate = slideInTransitioningDelgate
                vc.modalPresentationStyle = .custom
                self.present(vc, animated: true, completion: nil)
            }
        case .arcForm:
            let int = theCount(entity: "ARCrossForm")
            if int != 0 {
                let objectID = fetchTheLatest(shift: shift)
                nc.post(name:Notification.Name(rawValue:FJkARCFORM_FROM_MASTER),
                        object: nil,
                        userInfo: ["objectID": objectID, "shift": shift])
            } else {
                slideInTransitioningDelgate.direction = .bottom
                slideInTransitioningDelgate.disableCompactHeight = true
                let vc:ARC_ViewController = vcLaunch.modalARCFormNewCalled()
                vc.title = "New ARC Form"
                vc.transitioningDelegate = slideInTransitioningDelgate
                vc.modalPresentationStyle = .custom
                self.present(vc, animated: true, completion: nil)
            }
        default: break
        }
    }
    
    func theCount(entity: String)->Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        do {
            let count = try context.count(for:fetchRequest)
            return count
        } catch let error as NSError {
            print("DetailViewController line 1391 Error: \(error.localizedDescription)")
            return 0
        }
    }
    
    func fetchTheLatest(shift: MenuItems)->NSManagedObjectID {
        var objectID:NSManagedObjectID!
        switch shift {
        case .ics214:
            var ics214 = [ICS214Form]()
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ICS214Form")
            let sort = NSSortDescriptor(key: "ics214FromTime", ascending: true)
            request.sortDescriptors = [sort]
            do {
                ics214 = try context.fetch(request) as! [ICS214Form]
                let form = ics214.last
                objectID = form?.objectID
            }  catch let error as NSError {
                let nserror = error
                let errorMessage = "\(nserror):\(nserror.localizedDescription)\(nserror.userInfo)"
                print("there were zero ICS214 Forms available \(errorMessage)")
            }
        case .arcForm:
            var arcForm = [ARCrossForm]()
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ARCrossForm")
            let sort = NSSortDescriptor(key: "arcCreationDate", ascending: true)
            request.sortDescriptors = [sort]
            do {
                arcForm = try context.fetch(request) as! [ARCrossForm]
                if !arcForm.isEmpty {
                    let form = arcForm.last
                    objectID = form?.objectID
                } else {
                    
                }
            } catch let error as NSError {
                print("DetailViewController line 1475 Error: \(error.localizedDescription)")
            }
        default: break
        }
        return objectID
    }
}

extension DetailViewController: NewICS214ModalTVCDelegate {
    func theCancelCalledOnNewICS214Modal() {
        self.dismiss(animated: true, completion: nil)
    }
}
