    //
    //  DetailViewController+Extensions.swift
    //  Fire Journal
    //
    //  Created by DuRand Jones on 2/23/22.
    //  Copyright © 2022 PureCommand, LLC. All rights reserved.
    //

import UIKit
import AVFoundation
import Foundation
import CoreData
import CoreLocation
import StoreKit

extension DetailViewController {
    
    
        /// get the stored guid for the shift
        /// - Parameter guid: String guid for the last shift issued
    func getTheUserTime(_ guid: String) {
        userTimeContext = userTimeProvider.persistentContainer.newBackgroundContext()
        guard let userTime = userTimeProvider.getTheShift(userTimeContext, guid) else {
            let errorMessage = "A start shift is needed to retrieve the incidents of the day"
            errorAlert(errorMessage: errorMessage)
            return
        }
        theUserTime = userTime.last
    }
    
    func getTheLastUserTime() {
        userTimeContext = userTimeProvider.persistentContainer.newBackgroundContext()
        guard let userTime = userTimeProvider.getLastShiftNotCompleted(userTimeContext) else {
            let errorMessage = "A start shift is needed to retrieve the incidents of the day"
            errorAlert(errorMessage: errorMessage)
            return
        }
        let uTime = userTime.last
        if let id = uTime?.objectID {
            theUserTime  = context.object(with: id) as? UserTime
        }
    }
    
    func getTheCompletedShift() {
        userTimeContext = userTimeProvider.persistentContainer.newBackgroundContext()
        guard let userTime = userTimeProvider.getTheLastCompletedShift(userTimeContext) else {
            let errorMessage = "A start shift is needed to retrieve the incidents of the day"
            errorAlert(errorMessage: errorMessage)
            return
        }
        let uTime = userTime.last
        if let id = uTime?.objectID {
            theExpiredUserTime  = context.object(with: id) as? UserTime
        } 
    }
    
    func getTheUser() {
        theUserContext = theUserProvider.persistentContainer.newBackgroundContext()
        guard let users = theUserProvider.getTheUser(theUserContext) else {
            let errorMessage = "There is no user associated with this end shift"
            errorAlert(errorMessage: errorMessage)
            return
        }
        let aUser = users.last
        if let id = aUser?.objectID {
            theFireJournalUser = context.object(with: id) as? FireJournalUser
        }
    }
    
    func getTheStatus() {
        statusContext = statusProvider.persistentContainer.newBackgroundContext()
        if let status = statusProvider.getTheStatus(context: statusContext) {
            if !status.isEmpty {
                let aStatus = status.last
                if let id = aStatus?.objectID {
                    theStatus = context.object(with: id) as? Status
                }
            } else {
                if theStatus == nil {
                    theStatus = Status(context: context)
                    getTheLastUserTime()
                    if theUserTime != nil {
                        theStatus.agreement = true
                        theStatus.agreementDate = Date()
                        if let guid = theUserTime.userTimeGuid {
                            theStatus.guidString = guid
                        }
                        do {
                            try context.save()
                            DispatchQueue.main.async {
                                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"status  merge that"])
                            }
                        } catch let error as NSError {
                            let theError: String = error.localizedDescription
                            let error = "There was an error in saving " + theError
                            errorAlert(errorMessage: error)
                        }
                    } else {
                        let guidDate = GuidFormatter.init(date: Date())
                        let guid = guidDate.formatGuid()
                        let theUserGuid = "78."+guid
                        theUserTime = UserTime.init(context: context)
                        theUserTime.userTimeGuid = theUserGuid
                        theUserTime.userStartShiftTime = Date()
                        theStatus.guidString = theUserGuid
                        
                            theStatus.agreement = true
                            theStatus.agreementDate = Date()
                        getTheUser()
                        if theFireJournalUser != nil {
                            var userName: String = ""
                            if let user = theFireJournalUser.userName {
                                userName = user
                            }
                            if userName == "" {
                                if let first = theFireJournalUser.firstName {
                                    userName = first
                                }
                                if let last = theFireJournalUser.lastName {
                                    userName = userName + " " + last
                                }
                                if userName != "" {
                                    theFireJournalUser.userName = userName
                                }
                            }
                            theUserTime.fireJournalUser = theFireJournalUser
                            self.userDefaults.set(theUserGuid, forKey: FJkUSERTIMEGUID)
                            let objectID = theUserTime.objectID
                            DispatchQueue.main.async {
                                self.nc.post(name:Notification.Name(rawValue: FJkCKNewStartEndCreated),
                                        object: nil,
                                        userInfo: ["objectID": objectID as NSManagedObjectID])
                            }
                            do {
                                try context.save()
                                DispatchQueue.main.async {
                                    self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"EndShiftModal TVC merge that"])
                                }
                            } catch let error as NSError {
                                let theError: String = error.localizedDescription
                                let error = "There was an error in saving " + theError
                                errorAlert(errorMessage: error)
                            }
                        }
                    }
                }
            }
        } else {
            if theStatus == nil {
                theStatus = Status(context: context)
                getTheLastUserTime()
                if theUserTime != nil {
                    theStatus.agreement = true
                    theStatus.agreementDate = Date()
                    if let guid = theUserTime.userTimeGuid {
                        theStatus.guidString = guid
                    }
                    do {
                        try context.save()
                        DispatchQueue.main.async {
                            self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"status  merge that"])
                        }
                    } catch let error as NSError {
                        let theError: String = error.localizedDescription
                        let error = "There was an error in saving " + theError
                        errorAlert(errorMessage: error)
                    }
                } else {
                    let guidDate = GuidFormatter.init(date: Date())
                    let guid = guidDate.formatGuid()
                    let theUserGuid = "78."+guid
                    theUserTime = UserTime.init(context: context)
                    theUserTime.userTimeGuid = theUserGuid
                    theUserTime.userStartShiftTime = Date()
                    theStatus.guidString = theUserGuid
                    
                        theStatus.agreement = true
                        theStatus.agreementDate = Date()
                    getTheUser()
                    if theFireJournalUser != nil {
                        var userName: String = ""
                        if let user = theFireJournalUser.userName {
                            userName = user
                        }
                        if userName == "" {
                            if let first = theFireJournalUser.firstName {
                                userName = first
                            }
                            if let last = theFireJournalUser.lastName {
                                userName = userName + " " + last
                            }
                            if userName != "" {
                                theFireJournalUser.userName = userName
                            }
                        }
                        theUserTime.fireJournalUser = theFireJournalUser
                        self.userDefaults.set(theUserGuid, forKey: FJkUSERTIMEGUID)
                        let objectID = theUserTime.objectID
                        DispatchQueue.main.async {
                            self.nc.post(name:Notification.Name(rawValue: FJkCKNewStartEndCreated),
                                    object: nil,
                                    userInfo: ["objectID": objectID as NSManagedObjectID])
                        }
                        do {
                            try context.save()
                            DispatchQueue.main.async {
                                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"EndShiftModal TVC merge that"])
                            }
                        } catch let error as NSError {
                            let theError: String = error.localizedDescription
                            let error = "There was an error in saving " + theError
                            errorAlert(errorMessage: error)
                        }
                    }
                }
            }
        }
        
        
        
    }
    
    
        /// get the incidents that have been created since the shift started
        /// - Parameter userTime: startShift information to collect incidents
    func getThisShiftsIncidents(_ userTime: UserTime) {
        taskContext = incidentProvider.persistentContainer.newBackgroundContext()
        guard let incidents = incidentProvider.getTodaysIncidents(context: taskContext, userTime: userTime) else {
            return }
        theTodayIncidents = incidents
        theNewestIncident = theTodayIncidents.last
        if !theTodayIncidents.isEmpty {
            let theFire = theTodayIncidents.filter { $0.situationIncidentImage == "Fire" }
            fireCount = theFire.count
            let theEMS = theTodayIncidents.filter { $0.situationIncidentImage == "EMS" }
            emsCount = theEMS.count
            let theRescue = theTodayIncidents.filter { $0.situationIncidentImage == "Rescue"}
            rescueCount = theRescue.count
            incidentCount = theTodayIncidents.count
        }
    }
    
    func getIncidentMonthTotals() {
        incidentMonthTotalsContext = incidentMonthTotalsProvider.persistentContainer.newBackgroundContext()
        yearCounts = incidentMonthTotalsProvider.buidTheIncidentTotals(context: incidentMonthTotalsContext)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func presentAgreement() {
        DispatchQueue.main.async {
            self.plistContext = self.plistProvider.persistentContainer.newBackgroundContext()
            let loadTheUserFromCloud = LoadTheUserFromCloud(context: self.plistContext)
            loadTheUserFromCloud.getCloudUser()
        }
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let openingScrollVC = storyBoard.instantiateViewController(withIdentifier: "OpenModalScrollVC") as! OpenModalScrollVC
        openingScrollVC.delegate = self
        openingScrollVC.fromMaster = false
        openingScrollVC.transitioningDelegate = slideInTransitioningDelgate
        openingScrollVC.modalPresentationStyle = .custom
        self.present(openingScrollVC, animated: true, completion: nil)
    }
    
}

extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func configuredashboardCollectionView() {
        dashboardCollectionView = UICollectionView(frame: .zero , collectionViewLayout: createLayout())
        dashboardCollectionView.translatesAutoresizingMaskIntoConstraints = false
        dashboardCollectionView.backgroundColor = .systemBackground
        dashboardCollectionView.tag = 1
        dashboardCollectionView.delegate = self
        registerCell()
        dashboardCollectionView.dataSource = self
            view.addSubview(dashboardCollectionView)
            NSLayoutConstraint.activate([
                dashboardCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                dashboardCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -25),
                dashboardCollectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 25),
                dashboardCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25)
            ])
    }
    
    func registerCell() {
        dashboardCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "default")
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let sections = DashboardSections(rawValue: indexPath.section) else { fatalError("Unknown section") }
        switch sections {
        case .shift:
            if startEndShift {
                return collectionView.dequeueConfiguredReusableCell(using: configureShiftStartCVCellRegistration, for: indexPath, item: theUserTime )
            } else {
                return collectionView.dequeueConfiguredReusableCell(using: configureShiftEndCVCellRegistration, for: indexPath, item: theUserTime )
            }
        case .forms:
            return collectionView.dequeueConfiguredReusableCell(using: configureShiftFormCVCellRegistration, for: indexPath, item: theUserTime )
        case .status:
            if startEndShift {
                return collectionView.dequeueConfiguredReusableCell(using: configureShiftEndStatusCVCellRegistration, for: indexPath, item: theExpiredUserTime )
            } else {
                return collectionView.dequeueConfiguredReusableCell(using: configureShiftStartStatusCVCellRegistration, for: indexPath, item: theUserTime )
            }
        case .incidents:
            return collectionView.dequeueConfiguredReusableCell(using: configureShiftIncidentsCVCellRegistration, for: indexPath, item: theUserTime )
        case .totalIncidents:
            return collectionView.dequeueConfiguredReusableCell(using: configureStationIncidentCVCellRegistration, for: indexPath, item: theUserTime )
        case .weather:
            return collectionView.dequeueConfiguredReusableCell(using: configureShiftWeatherCVCellRegistration, for: indexPath, item: theUserTime )
        }
        
    }
    
    func createLayout() -> UICollectionViewLayout {
        
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            print(sectionIndex)
            guard let sections = DashboardSections(rawValue: sectionIndex ) else { fatalError("Unknown section") }
            
            let section: NSCollectionLayoutSection
            
            switch sections {
            case .shift:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(115))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            case .forms:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(335))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            case .status:
                if self.startEndShift {
                    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                    let item = NSCollectionLayoutItem(layoutSize: itemSize)
                    item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
                    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(265))
                    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                    section = NSCollectionLayoutSection(group: group)
                    section.interGroupSpacing = 10
                    section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
                } else {
                    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                    let item = NSCollectionLayoutItem(layoutSize: itemSize)
                    item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
                    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(445))
                    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                    section = NSCollectionLayoutSection(group: group)
                    section.interGroupSpacing = 10
                    section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
                }
            case .incidents:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(510))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            case .totalIncidents:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(345))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            case .weather:
               let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(225))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            }
            
            return section
            
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
    
    func endShiftTapped() {
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyboard = UIStoryboard(name: "ShiftEnd", bundle: nil)
        let shiftEndModalVC  = storyboard.instantiateViewController(identifier: "ShiftEndModalVC") as! ShiftEndModalVC
        shiftEndModalVC.delegate = self
        shiftEndModalVC.transitioningDelegate = slideInTransitioningDelgate
        if theStatus != nil {
            shiftEndModalVC.theStatusObj = theStatus.objectID
        }
        if Device.IS_IPHONE {
            shiftEndModalVC.modalPresentationStyle = .formSheet
        } else {
            shiftEndModalVC.modalPresentationStyle = .custom
        }
        
        if theUserTime == nil {
            let error = "There was a error creating the userTime"
            errorAlert(errorMessage: error)
        } else {
            shiftEndModalVC.theUserTimeOID = theUserTime.objectID
            self.present(shiftEndModalVC, animated: true, completion: nil)
        }
    }
    
    func startShiftTapped() {
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyboard = UIStoryboard(name: "ShiftNew", bundle: nil)
        let startShiftModalTVC  = storyboard.instantiateViewController(identifier: "ShiftNewModalVC") as! ShiftNewModalVC
        startShiftModalTVC.delegate = self
        startShiftModalTVC.transitioningDelegate = slideInTransitioningDelgate
        if theStatus != nil {
            startShiftModalTVC.theStatusOID = theStatus.objectID
        } else {
            let error = "There was a error creating the userTime"
            errorAlert(errorMessage: error)
        }
        if Device.IS_IPHONE {
            startShiftModalTVC.modalPresentationStyle = .formSheet
        } else {
            startShiftModalTVC.modalPresentationStyle = .custom
        }
        if theUserTime == nil {
            let error = "There was a error creating the userTime"
            errorAlert(errorMessage: error)
        } else {
            startShiftModalTVC.userTimeObjID = theUserTime.objectID
            self.present(startShiftModalTVC, animated: true, completion: nil)
        }
    }
    
}

extension DetailViewController: ShiftNewModalVCDelegate {
    
    func dismissShiftStartModal() {
        startEndShift = false
        userDefaults.set(startEndShift, forKey: FJkSTARTSHIFTENDSHIFTBOOL)
        self.dashboardCollectionView.reloadSections(IndexSet(integer: DashboardSections.shift.rawValue))
        self.dashboardCollectionView.reloadSections(IndexSet(integer: DashboardSections.status.rawValue))
        dismiss(animated: true, completion: nil)
    }
    
    func noUserFound() {
        dismiss(animated: true, completion: nil)
        let errorMessage = "There was a failure to provide the user profile."
        errorAlert(errorMessage: errorMessage)
    }
}

extension DetailViewController: ShiftEndModalVCDelegate {
    
    func dismissShiftEndModal() {
        startEndShift = true
        userDefaults.set(startEndShift, forKey: FJkSTARTSHIFTENDSHIFTBOOL)
        self.dashboardCollectionView.reloadSections(IndexSet(integer: DashboardSections.shift.rawValue))
        self.dashboardCollectionView.reloadSections(IndexSet(integer: DashboardSections.status.rawValue))
        dismiss(animated: true, completion: nil)
    }
    
    func endShiftNOUserFound() {
        dismiss(animated: true, completion: nil)
        let errorMessage = "There was a failure to provide the shift."
        errorAlert(errorMessage: errorMessage)
    }
    
}

extension DetailViewController: ShiftFormCVCellDelegate {
    
    func incidentTapped() {
        presentNewIncidentFormModal()
    }
    
    func journalTapped() {
        presentJournalFormModal()
    }
    
    func formsTapped() {
        presentFormsModal()
    }
    
    func presentNewIncidentFormModal() {
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyBoard : UIStoryboard = UIStoryboard(name: "IncidentNew", bundle:nil)
        let incidentNewModalVC = storyBoard.instantiateViewController(withIdentifier: "IncidentNewModalVC") as! IncidentNewModalVC
        incidentNewModalVC.transitioningDelegate = slideInTransitioningDelgate
        if theUserTime != nil {
            incidentNewModalVC.userTimeObjectID = theUserTime.objectID
            if Device.IS_IPHONE {
                incidentNewModalVC.modalPresentationStyle = .formSheet
            } else {
                incidentNewModalVC.modalPresentationStyle = .custom
            }
            incidentNewModalVC.delegate = self
            self.present(incidentNewModalVC, animated: true, completion: nil)
        } else {
            let errorMessage = "A shift needs to be started to create incident entries."
            errorAlert(errorMessage: errorMessage)
        }
    }
    
    func presentJournalFormModal() {
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyBoard : UIStoryboard = UIStoryboard(name: "JournalNewModal", bundle:nil)
        let journalNewModalVC = storyBoard.instantiateInitialViewController() as! JournalNewModalVC
        journalNewModalVC.transitioningDelegate = slideInTransitioningDelgate
        if theUserTime != nil {
            journalNewModalVC.userTimeObjectID = theUserTime.objectID
        if Device.IS_IPHONE {
            journalNewModalVC.modalPresentationStyle = .formSheet
        } else {
            journalNewModalVC.modalPresentationStyle = .custom
        }
        journalNewModalVC.delegate = self
        self.present(journalNewModalVC,animated: true)
        } else {
            let errorMessage = "A shift needs to be started to create journal entries."
            errorAlert(errorMessage: errorMessage)
        }
    }
    
    func presentFormsModal() {
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let modalTVC = storyBoard.instantiateViewController(withIdentifier: "ModalTVC") as! ModalTVC
        modalTVC.delegate = self
        modalTVC.transitioningDelegate = slideInTransitioningDelgate
        modalTVC.title = ""
        modalTVC.myShift = MenuItems.forms
        if Device.IS_IPHONE {
            modalTVC.modalPresentationStyle = .formSheet
        } else {
            modalTVC.modalPresentationStyle = .custom
        }
        modalTVC.context = context
        self.present(modalTVC, animated: true, completion: nil)
    }
    
}

extension DetailViewController: JournalNewModalVCDelegate {
    
    func journalNewCancelled() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func journalNewSaved(objectID: NSManagedObjectID) {
        self.dismiss(animated: true, completion: {
            self.nc.post(name:Notification.Name(rawValue: FJkJOURNAL_FROM_MASTER),object: nil, userInfo: ["sizeTrait":SizeTrait.regular,"objectID": objectID])
        })
    }
    
    
}

extension DetailViewController: IncidentNewModalVCDelegate {
   
    func incidentNewCancelled() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func incidentNewSaved(objectID: NSManagedObjectID) {
        self.dismiss(animated: true, completion: {
            self.dashboardCollectionView.reloadSections(IndexSet(integer: DashboardSections.incidents.rawValue))
            
            self.dashboardCollectionView.reloadSections(IndexSet(integer: DashboardSections.totalIncidents.rawValue))
            self.nc.post(name:Notification.Name(rawValue:FJkINCIDENT_FROM_MASTER), object: nil, userInfo:["sizeTrait":SizeTrait.regular,"objectID":objectID])
        })
    }
    
    
}

extension DetailViewController: NewerIncidentModalTVCDelegate {
    
    func theNewIncidentCancelled() {
            self.dismiss(animated: true, completion: nil)
    }
    
    func theNewIncidentModalSaved(ojectID: NSManagedObjectID, shift: MenuItems) {
        self.dismiss(animated: true, completion: {
            self.theTodayIncidents.removeAll()
            self.yearCounts.removeAll()
            self.theNewestIncident = nil
            self.fireCount = 0
            self.emsCount = 0
            self.rescueCount = 0
            self.incidentCount = 0
            self.getThisShiftsIncidents(self.theUserTime)
            self.dashboardCollectionView.reloadSections(IndexSet(integer: DashboardSections.incidents.rawValue))
            self.getIncidentMonthTotals()
            self.dashboardCollectionView.reloadSections(IndexSet(integer: DashboardSections.totalIncidents.rawValue))
            self.nc.post(name:Notification.Name(rawValue:FJkINCIDENT_FROM_MASTER), object: nil, userInfo:["sizeTrait":SizeTrait.regular,"objectID":ojectID])
        })
    }
    
    
}

extension DetailViewController: StartShiftDashbaordModalTVCDelegate {
    
    func startShiftCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func startShiftSave(shift: MenuItems, startShift: StartShiftData) {
        dismiss(animated: true, completion: nil)
        startEndShift.toggle()
        userDefaults.set(startEndShift, forKey: FJkSTARTSHIFTENDSHIFTBOOL)
    }
    
    
}

extension DetailViewController: EndShiftDashboardModalTVCDelegate {
    
    func endShiftSave(shift: MenuItems, EndShift: EndShiftData) {
        dismiss(animated: true, completion: nil)
    }
    
    func endShiftCancel() {
        dismiss(animated: true, completion: nil)
    }
    
}

extension DetailViewController: OpenModalScrollVCDelegate {
    
    func allCompleted(yesNo: Bool) {
        dismiss(animated: true, completion: {
            self.userDefaults.set(true, forKey: FJkFIRSTRUNFORDATAFROMCLOUDKIT)
            self.theAgreementsAccepted()
            self.freshDeskRequest()
            self.appDelegate.fetchAnyChangesWeMissed(firstRun: true)
            DispatchQueue.main.async {
                self.nc.post(name:Notification.Name(rawValue: FJkOPENWEATHER_UPDATENow),object: nil)
            }
            self.buildUserTime()
            self.dashboardCollectionView.reloadSections(IndexSet(integer: DashboardSections.shift.rawValue))
            self.dashboardCollectionView.reloadSections(IndexSet(integer: DashboardSections.status.rawValue))
            self.dashboardCollectionView.reloadSections(IndexSet(integer: DashboardSections.weather.rawValue))
        })
    }
    
    func buildUserTime() {
        startEndShift = true
        userDefaults.set(startEndShift, forKey: FJkSTARTSHIFTENDSHIFTBOOL)
        let agreementDate = Date()
        let guidDate = GuidFormatter.init(date: agreementDate)
        let guid = guidDate.formatGuid()
        let theUserGuid = "78."+guid
        theUserTime = UserTime.init(context: context)
        theUserTime.userTimeGuid = theUserGuid
        theStatus = Status.init(context: context)
        theStatus.guidString = theUserGuid
        theStatus.agreement = true
        theStatus.agreementDate = agreementDate
        theUserTime.userStartShiftTime = agreementDate
        theUserTime.shiftCompleted = false
        self.userDefaults.set(theUserGuid, forKey: FJkUSERTIMEGUID)
        let objectID = theUserTime.objectID
        DispatchQueue.main.async {
            self.nc.post(name:Notification.Name(rawValue: FJkCKNewStartEndCreated),
                    object: nil,
                    userInfo: ["objectID": objectID as NSManagedObjectID])
        }
        do {
            try context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"User Time Start Shift Created for use merge that"])
            }
            self.configuredashboardCollectionView()
        } catch let error as NSError {
            let theError: String = error.localizedDescription
            let error = "There was an error in saving " + theError
            errorAlert(errorMessage: error)
        }
    }
    
    func theAgreementsAccepted() {
        agreementAccepted = userDefaults.bool(forKey: FJkUserAgreementAgreed)
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
                            print("no longer using resources")
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
                            print("no longer using resources")
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

extension DetailViewController {
    
        // download all data from cloudkit if it exists
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
    
}
