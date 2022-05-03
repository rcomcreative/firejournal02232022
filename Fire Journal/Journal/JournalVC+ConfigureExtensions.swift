//
//  JournalVC+ConfigureExtensions.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/30/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//


import UIKit
import Foundation
import CoreData
import MapKit
import CoreLocation
import PhotosUI

extension JournalVC {
    
        //    MARK: -CONFIGUREHEIGHT-
    
        /// find the height for text area using the string associated with input
        /// - Parameter text: text entered in modals for form
        /// - Returns: returns the height for the label cell
    func configureLabelHeight(text: String ) -> CGFloat {
        var theFloat: CGFloat = 0.0
        let frame = self.view.frame
        let width = frame.width - 70
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: 44))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = .systemFont(ofSize: 15)
        label.text = text
        label.sizeToFit()
        let labelFrame = label.frame
        theFloat = labelFrame.height
        label.removeFromSuperview()
        theFloat = theFloat - 400
        if theFloat < 44 {
            theFloat = 88
        }
        return theFloat
    }
    
        // MARK: -USER USERTIME-
    
        /// lazy var theUserProvider will get the user to be used for relationships - as it is
        /// pulled from a background context - theUser needs to be pulled by the objectID in this
        /// context.
    func getTheUser() {
        theUserContext = theUserProvider.persistentContainer.newBackgroundContext()
        guard let users = theUserProvider.getTheUser(theUserContext) else {
            let errorMessage = "There is no user associated with this end shift"
            errorAlert(errorMessage: errorMessage)
            return
        }
        let aUser = users.last
        if let id = aUser?.objectID {
            theUser = context.object(with: id) as? FireJournalUser
        }
    }
    
        /// lazy var userTimeProvider will get the userTime to be used for relationships - as it is
        /// pulled from a background context - theUser needs to be pulled by the objectID in this
        /// context.
    func getTheLastUserTime() {
        userTimeContext = userTimeProvider.persistentContainer.newBackgroundContext()
        guard let userTime = userTimeProvider.getLastShiftNotCompleted(userTimeContext) else {
            let errorMessage = "A start shift is needed to retrieve the incidents of the day"
            errorAlert(errorMessage: errorMessage)
            return
        }
        let aUserTime = userTime.last
        if let id = aUserTime?.objectID {
            theUserTime = context.object(with: id) as? UserTime
        }
        
        
    }
    
    func getTheTags() {
        theTagContext = tagProvider.persistentContainer.newBackgroundContext()
        theTags = tagProvider.getAllTags(context: theTagContext)
        if theTags.isEmpty {
            DispatchQueue.main.async {
                self.theTags = self.tagProvider.buildTheTags(bkgrndContext: self.theTagContext)
            }
        }
    }
    
        // MARK: -LAYOUT CONFIGURATIONS-
    
        /// build the table view for the form - called in viewdidload
    func configureJournalTableView() {
        journalTableView = UITableView(frame: .zero)
        registerCellsForTable()
        journalTableView.translatesAutoresizingMaskIntoConstraints = false
        journalTableView.backgroundColor = .systemBackground
        view.addSubview(journalTableView)
        journalTableView.delegate = self
        journalTableView.dataSource = self
        journalTableView.separatorStyle = .none
        
        journalTableView.rowHeight = UITableView.automaticDimension
        journalTableView.estimatedRowHeight = 300
        
        if Device.IS_IPHONE {
            NSLayoutConstraint.activate([
                journalTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
                journalTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
                journalTableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
                journalTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10),
            ])
        } else {
        NSLayoutConstraint.activate([
            journalTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            journalTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            journalTableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 15),
            journalTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10),
        ])
        }
    }
    
        //    MARK: -ALERTS-
    
    func errorAlert(errorMessage: String) {
        let alert = UIAlertController.init(title: "Error", message: errorMessage, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(okAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    
    func theAlert(message: String) {
        let alert = UIAlertController.init(title: "Update", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(okAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentAlert() {
        let message: InfoBodyText = .newIncidentSubject
        let title: InfoBodyText = .newIncident
        let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(okAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    
    func mapAlert() {
        let subject = InfoBodyText.mapErrorSubject.rawValue
        let message = InfoBodyText.mapErrorDescription.rawValue
        let alert = UIAlertController.init(title: subject, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(okAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    
    
}

extension JournalVC: MultipleAddButtonTVCellDelegate {
    
    func multiAddBTapped(type: IncidentTypes, index: IndexPath) {
        let row = index.row
        switch row {
        case 2:
            let storyboard = UIStoryboard(name: "TheJournalNote", bundle: nil)
            if let theJournalNoteVC = storyboard.instantiateViewController(withIdentifier: "TheJournalNoteVC") as? TheJournalNoteVC {
                theJournalNoteVC.modalPresentationStyle = .formSheet
                theJournalNoteVC.isModalInPresentation = true
                theJournalNoteVC.theType = IncidentTypes.overview
                theJournalNoteVC.isIncidentNote = true
                if theJournal != nil {
                    theJournalNoteVC.journalObID = theJournal.objectID
                    theJournalNoteVC.delegate = self
                    theJournalNoteVC.index = index
                    self.present(theJournalNoteVC , animated: true, completion: nil)
                }
            }
        case 4:
            let storyboard = UIStoryboard(name: "TheJournalNote", bundle: nil)
            if let theJournalNoteVC = storyboard.instantiateViewController(withIdentifier: "TheJournalNoteVC") as? TheJournalNoteVC {
                theJournalNoteVC.modalPresentationStyle = .formSheet
                theJournalNoteVC.isModalInPresentation = true
                theJournalNoteVC.theType = IncidentTypes.discussion
                theJournalNoteVC.isIncidentNote = true
                if theJournal != nil {
                    theJournalNoteVC.journalObID = theJournal.objectID
                    theJournalNoteVC.delegate = self
                    theJournalNoteVC.index = index
                    self.present(theJournalNoteVC , animated: true, completion: nil)
                }
            }
        case 9:
            let storyBoard : UIStoryboard = UIStoryboard(name: "Tags", bundle:nil)
            if let tagsVC = storyBoard.instantiateViewController(withIdentifier: "TagsVC") as? TagsVC {
                tagsVC.modalPresentationStyle = .formSheet
                tagsVC.isModalInPresentation = true
                tagsVC.delegate = self
                self.present(tagsVC, animated: true, completion: nil)
            }
        default: break
        }
    }
    
    func multiTitleChosen(type: IncidentTypes, title: String, index: IndexPath) {
    }
    
}

extension JournalVC: TagsVCDelegate {
    
    func tagsSubmitted(tags: [Tag]) {
        if !tags.isEmpty {
            theTagsAvailable = true
            for tag in tags {
                if !theJournalTags.isEmpty {
                    let result = theJournalTags.filter { $0 == tag }
                    if result.isEmpty {
                        let journalTag = JournalTags(context: context)
                        journalTag.journalTag = tag.name
                        if let guid = theJournal.fjpJGuidForReference {
                            journalTag.fjpJournalReference = guid
                        }
                        if let journalModDate = theJournal.journalModDate {
                            let jGuidDate = GuidFormatter.init(date: journalModDate)
                            let jGuid:String = jGuidDate.formatGuid()
                            let guid = "71." + jGuid
                            journalTag.journalGuid = guid
                        }
                        theJournal.addToJournalTags(journalTag)
                        theJournalTags.append(journalTag)
                    }
                } else {
                    let journalTag = JournalTags(context: context)
                    journalTag.journalTag = tag.name
                    if let guid = theJournal.fjpJGuidForReference {
                        journalTag.fjpJournalReference = guid
                    }
                    if let journalModDate = theJournal.journalModDate {
                        let jGuidDate = GuidFormatter.init(date: journalModDate)
                        let jGuid:String = jGuidDate.formatGuid()
                        let guid = "71." + jGuid
                        journalTag.journalGuid = guid
                    }
                    theJournal.addToJournalTags(journalTag)
                    theJournalTags.append(journalTag)
                }
            }
            if context.hasChanges {
                do {
                    try context.save()
                    DispatchQueue.main.async {
                        self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"Updated Incident merge that"])
                    }
                    let objectID = theJournal.objectID
                    DispatchQueue.main.async {
                        self.nc.post(name:Notification.Name(rawValue :FJkCKModifyJournalToCloud),
                                     object: nil,
                                     userInfo: ["objectID": objectID as NSManagedObjectID])
                    }
//                    TODO: - JournalTag to cloud-
                    theAlert(message: "The journal data has been saved.")
                } catch let error as NSError {
                    let nserror = error
                    
                    let errorMessage = "journalEdit saveToCD The context was unable to save due to \(nserror), \(nserror.userInfo)"
                    print(errorMessage)
                }
            }

            let count = theJournalTags.count
            let counted = count / 6
            theTagsHeight = CGFloat(counted * 44)
            if theTagsHeight < 100 {
                theTagsHeight = 88
            }
            journalTableView.reloadRows(at: [IndexPath(row: 10, section: 0)], with: .automatic)
        }
    }
    
}

extension JournalVC: JournalPhotoCollectionCellDelegate {
    
    func thePhotoCellObjectID(objectID: NSManagedObjectID) {
        
        let photo = context.object(with: objectID) as? Photo
        let storyboard = UIStoryboard(name: "FullImage", bundle: nil)
        
        guard let navController = storyboard.instantiateViewController(withIdentifier: "FullNC") as? UINavigationController,
              let fullImageVC = navController.topViewController as? FullImageVC else {
            return
        }
        spinner.startAnimating()
        
        taskContext = photoProvider.persistentContainer.newBackgroundContext()
        guard let theGuid = photo?.guid else { return }
        fullImageVC.fullImage = photo?.getImage(with: taskContext, guid: theGuid)
        
        present(navController, animated: true) {
            self.spinner.stopAnimating()
        }
        
    }
    
    
    func theJournalCellHasBeenTapped(photo: Photo) {
        
        let storyboard = UIStoryboard(name: "FullImage", bundle: nil)
        
        guard let navController = storyboard.instantiateViewController(withIdentifier: "FullNC") as? UINavigationController,
              let fullImageVC = navController.topViewController as? FullImageVC else {
            return
        }
        
        let taskContext = photoProvider.persistentContainer.newBackgroundContext()
        
        spinner.startAnimating()
        
        guard let theGuid = photo.guid else { return }
        fullImageVC.fullImage = photo.getImage(with: taskContext, guid: theGuid)
        
        present(navController, animated: true) {
            self.spinner.stopAnimating()
        }
        
    }
    
}

extension JournalVC: NewAddressFieldsButtonsCellDelegate {
    
        //    MARK: -AddressFieldsButtonsCellDelegate-
    
    func worldBTapped(tag: Int) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "OnBoard", bundle:nil)
        let onBoardAddressSearchlVC = storyBoard.instantiateViewController(withIdentifier: "OnBoardAddressSearch") as! OnBoardAddressSearch
        guard let region = getUserLocation.cameraBoundary else {
            mapAlert()
            return
        }
        theUserRegion = region
        onBoardAddressSearchlVC.type = IncidentTypes.journal
        onBoardAddressSearchlVC.boundarys = theUserRegion
        onBoardAddressSearchlVC.searches = getUserLocation.searchBoundary
        onBoardAddressSearchlVC.stationBoundary = getUserLocation.mapBoundary
        onBoardAddressSearchlVC.theMapTag = tag
        onBoardAddressSearchlVC.delegate = self
        self.present(onBoardAddressSearchlVC, animated: true, completion: nil)
    }
    
    func worldB2Tapped(tag: Int) {
        
    }
    
    func locationBTapped(tag: Int) {
        guard let location = getUserLocation.currentLocation else {
            mapAlert()
            return
        }
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            if error != nil {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            
            switch tag {
            case 6:
                self.theJournalLocation.location = location
                self.theJournalLocation.latitude = location.coordinate.latitude
                self.theJournalLocation.longitude = location.coordinate.longitude
                guard let count = placemarks?.count else {
                    self.errorAlert(errorMessage: "There were no placemarks in this location-  failed with error" + (error?.localizedDescription ?? ""))
                    return
                }
                if count != 0 {
                    guard let pm = placemarks?[0] else { return }
                    if pm.thoroughfare != nil {
                        if let pmCity = pm.locality {
                            self.theJournalLocation.city = "\(pmCity)"
                        } else {
                            self.theJournalLocation.city = ""
                        }
                        if let pmSubThroughfare = pm.subThoroughfare {
                            self.theJournalLocation.streetNumber = "\(pmSubThroughfare)"
                        } else {
                            self.theJournalLocation.streetNumber = ""
                        }
                        if let pmThoroughfare = pm.thoroughfare {
                            self.theJournalLocation.streetName = "\(pmThoroughfare)"
                        } else {
                            self.theJournalLocation.streetName = ""
                        }
                        if let pmState = pm.administrativeArea {
                            self.theJournalLocation.state = "\(pmState)"
                        } else {
                            self.theJournalLocation.state = ""
                        }
                        if let pmZip = pm.postalCode {
                            self.theJournalLocation.zip = "\(pmZip)"
                        } else {
                            self.theJournalLocation.zip = ""
                        }
                        
                        self.theJournal.locationAvailable = true
                        let index = IndexPath(row: 6, section: 0)
                        self.journalTableView.reloadRows(at: [index], with: .automatic)
                        
                    }
                }
            default: break
            }
            
        })
    }
    
    
}

extension JournalVC: OnBoardAddressSearchDelegate {
    
    func addressHasBeenChosen(location: CLLocationCoordinate2D, address: String, tag: Int) {
        self.dismiss(animated: true, completion: nil )
        let theLocation = CLLocation.init(latitude: location.latitude, longitude: location.longitude)
        
        CLGeocoder().reverseGeocodeLocation(theLocation, completionHandler: { (placemarks, error) -> Void in
            
            if error != nil {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                self.errorAlert(errorMessage: "Reverse geocoder failed with error" + (error?.localizedDescription ?? ""))
                return
            }
            
            guard let count = placemarks?.count else {
                self.errorAlert(errorMessage: "There were no placemarks in this location-  failed with error" + (error?.localizedDescription ?? ""))
                return
            }
            if count != 0 {
                switch tag {
                case 6:
                    self.theJournalLocation.location = theLocation
                    self.theJournalLocation.latitude = location.latitude
                    self.theJournalLocation.longitude = location.longitude
                    guard let pm = placemarks?[0] else { return }
                    if pm.thoroughfare != nil {
                        if let pmCity = pm.locality {
                            self.theJournalLocation.city = "\(pmCity)"
                        } else {
                            self.theJournalLocation.city = ""
                        }
                        if let pmSubThroughfare = pm.subThoroughfare {
                            self.theJournalLocation.streetNumber = "\(pmSubThroughfare)"
                        } else {
                            self.theJournalLocation.streetNumber = ""
                        }
                        if let pmThoroughfare = pm.thoroughfare {
                            self.theJournalLocation.streetName = "\(pmThoroughfare)"
                        } else {
                            self.theJournalLocation.streetName = ""
                        }
                        if let pmState = pm.administrativeArea {
                            self.theJournalLocation.state = "\(pmState)"
                        } else {
                            self.theJournalLocation.state = ""
                        }
                        if let pmZip = pm.postalCode {
                            self.theJournalLocation.zip = "\(pmZip)"
                        } else {
                            self.theJournalLocation.zip = ""
                        }
                        
                        self.theJournal.locationAvailable = true
                        let index = IndexPath(row: 6, section: 0)
                        self.journalTableView.reloadRows(at: [index], with: .automatic)
                    }
                default: break
                }
            }
            
        })
    }
    
}

extension JournalVC: TheJournalNoteVCDelegate {
    
    func theJournalNoteHasBeenUpdated(text: String, index: IndexPath, type: IncidentTypes) {
        let row = index.row
        let indexPath = IndexPath(row: row + 1, section: 0)
        switch type {
        case .overview:
            theOverviewNotesAvailable = true
            theOverviewNotes = text
            theOverviewNotesHeight = configureLabelHeight(text: theOverviewNotes)
            if theJournal != nil {
                theJournal.journalOverviewSC = theOverviewNotes as NSObject
            }
        case .discussion:
            theDiscussionNotesAvailable = true
            theDiscussionNotes = text
            theDiscussionNotesHeight = configureLabelHeight(text: theDiscussionNotes)
            if theJournal != nil {
                theJournal.journalDiscussionSC = theDiscussionNotes as NSObject
            }
        case .nextSteps:
            theNextStepsNotesAvailable = true
            theNextStepsNotes = text
            theNextStepsNotesHeight = configureLabelHeight(text: theNextStepsNotes)
            if theJournal != nil {
                theJournal.journalNextStepsSC = theNextStepsNotes as NSObject
            }
        case .lastUnitStandingNote:
            theSummaryNotesAvailable = true
            theSummaryNotes = text
            theSummaryNotesHeight = configureLabelHeight(text: theSummaryNotes)
            if theJournal != nil {
                theJournal.journalSummarySC = theSummaryNotes as NSObject
            }
        default: break
        }
        journalTableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    
}


extension JournalVC: JournalInfoCellDelegate {
    
    func theInfoBTapped() {
        let errorMessage = "This is not available yet."
        errorAlert(errorMessage: errorMessage)
    }
    
}

extension JournalVC: JournalEditTVCellDelegate {
    
    func editBTapped() {
        let errorMessage = "This is not available yet."
        errorAlert(errorMessage: errorMessage)

    }
    
    
}
