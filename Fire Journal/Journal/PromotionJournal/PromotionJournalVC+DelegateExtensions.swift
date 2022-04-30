//
//  PromotionJournalVC+DelegateExtensions.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/21/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import MapKit
import CoreLocation
import PhotosUI

extension PromotionJournalVC {
    
        //    MARK: -CONFIGUREHEIGHT-
    
        /// find the height for text area using the string associated with input
        /// - Parameter text: text entered in modals for form
        /// - Returns: returns the height for the label cell
    func configureLabelHeight(text: String ) -> CGFloat {
        var theFloat: CGFloat = 0.0
        let frame = self.view.frame
        let width = frame.width - 70
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = .systemFont(ofSize: 18)
        label.text = text
        label.sizeToFit()
        let labelFrame = label.frame
        theFloat = labelFrame.height
        label.removeFromSuperview()
        if Device.IS_IPHONE {
            theFloat = theFloat - 600
        } else {
        theFloat = theFloat - 400
        }
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
    
    func configureTheProjectTableView() {
        projectTableView = UITableView(frame: .zero)
        registerCellsForTable()
        projectTableView.translatesAutoresizingMaskIntoConstraints = false
        projectTableView.backgroundColor = .systemBackground
        view.addSubview(projectTableView)
        projectTableView.delegate = self
        projectTableView.dataSource = self
        projectTableView.separatorStyle = .none
        
        projectTableView.rowHeight = UITableView.automaticDimension
        projectTableView.estimatedRowHeight = 300
        
        if Device.IS_IPHONE {
            NSLayoutConstraint.activate([
                projectTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
                projectTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
                projectTableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
                projectTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10),
            ])
        } else {
        NSLayoutConstraint.activate([
            projectTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            projectTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            projectTableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 15),
            projectTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10),
        ])
        }
    }
    
}

extension PromotionJournalVC: LabelTextFieldCellDelegate {
    
    func incidentLabelTFEditing(text: String, myShift: MenuItems, type: IncidentTypes) {}
    
    func incidentLabelTFFinishedEditing(text: String, myShift: MenuItems, type: IncidentTypes) {}
    
    func labelTextFieldEditing(text: String, myShift: MenuItems) {}
    
    func labelTextFieldFinishedEditing(text: String, myShift: MenuItems, tag: Int) {
        let row = tag
        switch row {
        case 0:
            theProject.projectName = text
        case 2:
            theProject.projectType = text
        default: break
        }
    }
    
    func userInfoTextFieldEditing(text: String, myShift: MenuItems, journalType: JournalTypes) {}
    
    func userInfoTextFieldFinishedEditing(text: String, myShift: MenuItems, journalType: JournalTypes) {}
    
    
}

extension PromotionJournalVC: LabelDateiPhoneTVCellDelegate {
    
    func theDatePickerTapped(_ theDate: Date, index: IndexPath) {
        let row = index.row
        switch row {
        case 1:
            theProject.promotionDate = theDate
        default: break
        }
    }
    
}

extension PromotionJournalVC: LabelSingleDateFieldCellDelegate {
    
    func singleDatePickerTapped(index: IndexPath, tag: Int, date: Date) {
        let row = index.row
        switch row {
        case 1:
            theProject.promotionDate = date
        default: break
        }
    }
    
    
}

extension PromotionJournalVC: MultipleAddButtonTVCellDelegate {
    
    func multiAddBTapped(type: IncidentTypes, index: IndexPath) {
        let row = index.row
        switch row {
        case 3:
            let storyboard = UIStoryboard(name: "PromotionNote", bundle: nil)
            if let thePromotionNoteVC = storyboard.instantiateViewController(withIdentifier: "PromotionNoteVC") as? PromotionNoteVC {
                thePromotionNoteVC.modalPresentationStyle = .formSheet
                thePromotionNoteVC.isModalInPresentation = true
                thePromotionNoteVC.theType = IncidentTypes.theProjectOverview
                if theProject != nil {
                    thePromotionNoteVC.promotionObID = theProject.objectID
                    thePromotionNoteVC.delegate = self
                    thePromotionNoteVC.index = index
                    self.present(thePromotionNoteVC , animated: true, completion: nil)
                }
            }
        case 5:
            let storyboard = UIStoryboard(name: "PromotionNote", bundle: nil)
            if let thePromotionNoteVC = storyboard.instantiateViewController(withIdentifier: "PromotionNoteVC") as? PromotionNoteVC {
                thePromotionNoteVC.modalPresentationStyle = .formSheet
                thePromotionNoteVC.isModalInPresentation = true
                thePromotionNoteVC.theType = IncidentTypes.theProjectClassNote
                if theProject != nil {
                    thePromotionNoteVC.promotionObID = theProject.objectID
                    thePromotionNoteVC.delegate = self
                    thePromotionNoteVC.index = index
                    self.present(thePromotionNoteVC , animated: true, completion: nil)
                }
            }
        case 7:
            slideInTransitioningDelgate.direction = .bottom
            slideInTransitioningDelgate.disableCompactHeight = true
            let storyBoard : UIStoryboard = UIStoryboard(name: "RelieveSupervisor", bundle:nil)
            let relieveSupervisorVC = storyBoard.instantiateViewController(withIdentifier: "RelieveSupervisorVC") as! RelieveSupervisorVC
            relieveSupervisorVC.delegate = self
            relieveSupervisorVC.headerTitle = "Crew"
            relieveSupervisorVC.crew = true
            relieveSupervisorVC.transitioningDelegate = slideInTransitioningDelgate
            relieveSupervisorVC.modalPresentationStyle = .custom
            self.present(relieveSupervisorVC, animated: true, completion: nil)
        case 12:
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

extension PromotionJournalVC: RelieveSupervisorVCDelegate {
    
    func relieveSupervisorCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func relieveSupervisorChosen(relieveSupervisor: [UserAttendees], relieveOrSupervisor: Bool) {
        theProjectCrewAvailable = true
        for crew in relieveSupervisor {
            if let name = crew.attendee {
                let result = theProjectCrewA.filter { $0.fullName == name }
                if result.isEmpty {
                    let projectCrew = PromotionCrew(context: context)
                    projectCrew.fullName = name
                    projectCrew.guid = UUID()
                    projectCrew.promotionGuid = theProject.guid
                    theProject.addToCrew(projectCrew)
                    theProjectCrewA.append(projectCrew)
                    theProjectCrew = theProjectCrew + name + ", "
                }
            }
        }
        if context.hasChanges {
            do {
                try context.save()
                DispatchQueue.main.async {
                    self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"Updated Incident merge that"])
                }
                let objectID = theProject.objectID
//                DispatchQueue.main.async {
//                    self.nc.post(name:Notification.Name(rawValue :FJkCKModifyJournalToCloud),
//                                 object: nil,
//                                 userInfo: ["objectID": objectID as NSManagedObjectID])
//                }
//                    TODO: - PromotionJournalCrew to cloud-
                theAlert(message: "The project data has been saved.")
            } catch let error as NSError {
                let nserror = error
                
                let errorMessage = "projectEdit saveToCD The context was unable to save due to \(nserror), \(nserror.userInfo)"
                print(errorMessage)
            }
        }
        
        projectTableView.reloadRows(at: [IndexPath(row: 8, section: 0)], with: .automatic)
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

extension PromotionJournalVC: TagsVCDelegate {
    
    func tagsSubmitted(tags: [Tag]) {
        if !tags.isEmpty {
            theTagsAvailable = true
            for tag in tags {
                if !theProjectTags.isEmpty {
                    let result = theProjectTags.filter { $0 == tag }
                    if result.isEmpty {
                        let projectTag = PromotionJournalTags(context: context)
                        projectTag.tag = tag.name
                        if let guid = theProject.projectGuid {
                            projectTag.promotionGuid = guid
                        }
                        projectTag.guid = UUID.init()
                        theProject.addToPromotionTag(projectTag)
                        theProjectTags.append(projectTag)
                    }
                } else {
                    let projectTag = PromotionJournalTags(context: context)
                    projectTag.tag = tag.name
                    if let guid = theProject.projectGuid {
                        projectTag.promotionGuid = guid
                    }
                    projectTag.guid = UUID.init()
                    theProject.addToPromotionTag(projectTag)
                    theProjectTags.append(projectTag)
                }
            }
            if context.hasChanges {
                do {
                    try context.save()
                    DispatchQueue.main.async {
                        self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"Updated Incident merge that"])
                    }
                    let objectID = theProject.objectID
//                    DispatchQueue.main.async {
//                        self.nc.post(name:Notification.Name(rawValue :FJkCKModifyJournalToCloud),
//                                     object: nil,
//                                     userInfo: ["objectID": objectID as NSManagedObjectID])
//                    }
//                    TODO: - PromotionJournalTag to cloud-
                    theAlert(message: "The project data has been saved.")
                } catch let error as NSError {
                    let nserror = error
                    
                    let errorMessage = "projectEdit saveToCD The context was unable to save due to \(nserror), \(nserror.userInfo)"
                    print(errorMessage)
                }
            }

            let count = theProjectTags.count
            let counted = count / 6
            theTagsHeight = CGFloat(counted * 44)
            if theTagsHeight < 100 {
                theTagsHeight = 88
            }
            projectTableView.reloadRows(at: [IndexPath(row: 13, section: 0)], with: .automatic)
        }
    }
    
    
}

extension PromotionJournalVC: PromotionNoteVCDelegate {
    
    func thePromotionNoteHasBeenUpdated(text: String, index: IndexPath, type: IncidentTypes) {
        var indexPath: IndexPath!
        switch type {
        case .theProjectOverview:
            theOverviewNotesAvailable = true
            theOverviewNotes = text
            theOverviewNotesHeight = configureLabelHeight(text: theOverviewNotes)
            if theProject != nil {
                theProject.overview = theOverviewNotes as NSObject
            }
            indexPath = IndexPath(row: 4, section: 0)
        case .theProjectClassNote:
            theProjectNotesAvailable = true
            theProjectNotes = text
            theProjectNotesHeight = configureLabelHeight(text: theProjectNotes)
            if theProject != nil {
                theProject.studyClassNote = theProjectNotes as NSObject
            }
            indexPath = IndexPath(row: 6, section: 0)
        default: break
        }
        projectTableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    
}

extension PromotionJournalVC: JournalEditTVCellDelegate {
    
    func editBTapped() {
        let errorMessage = "This is not available yet."
        errorAlert(errorMessage: errorMessage)

    }
    
    
}

extension PromotionJournalVC: NewAddressFieldsButtonsCellDelegate {
    
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
            case 9:
                self.theLocation.location = location
                self.theLocation.latitude = location.coordinate.latitude
                self.theLocation.longitude = location.coordinate.longitude
                guard let count = placemarks?.count else {
                    self.errorAlert(errorMessage: "There were no placemarks in this location-  failed with error" + (error?.localizedDescription ?? ""))
                    return
                }
                if count != 0 {
                    guard let pm = placemarks?[0] else { return }
                    if pm.thoroughfare != nil {
                        if let pmCity = pm.locality {
                            self.theLocation.city = "\(pmCity)"
                        } else {
                            self.theLocation.city = ""
                        }
                        if let pmSubThroughfare = pm.subThoroughfare {
                            self.theLocation.streetNumber = "\(pmSubThroughfare)"
                        } else {
                            self.theLocation.streetNumber = ""
                        }
                        if let pmThoroughfare = pm.thoroughfare {
                            self.theLocation.streetName = "\(pmThoroughfare)"
                        } else {
                            self.theLocation.streetName = ""
                        }
                        if let pmState = pm.administrativeArea {
                            self.theLocation.state = "\(pmState)"
                        } else {
                            self.theLocation.state = ""
                        }
                        if let pmZip = pm.postalCode {
                            self.theLocation.zip = "\(pmZip)"
                        } else {
                            self.theLocation.zip = ""
                        }
                        
                        self.locationAvailable = true
                        let index = IndexPath(row: 9, section: 0)
                        self.projectTableView.reloadRows(at: [index], with: .automatic)
                        
                    }
                }
            default: break
            }
            
        })
    }
    
    
}

extension PromotionJournalVC: OnBoardAddressSearchDelegate {
    
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
                case 9:
                    self.theLocation.location = theLocation
                    self.theLocation.latitude = location.latitude
                    self.theLocation.longitude = location.longitude
                    guard let pm = placemarks?[0] else { return }
                    if pm.thoroughfare != nil {
                        if let pmCity = pm.locality {
                            self.theLocation.city = "\(pmCity)"
                        } else {
                            self.theLocation.city = ""
                        }
                        if let pmSubThroughfare = pm.subThoroughfare {
                            self.theLocation.streetNumber = "\(pmSubThroughfare)"
                        } else {
                            self.theLocation.streetNumber = ""
                        }
                        if let pmThoroughfare = pm.thoroughfare {
                            self.theLocation.streetName = "\(pmThoroughfare)"
                        } else {
                            self.theLocation.streetName = ""
                        }
                        if let pmState = pm.administrativeArea {
                            self.theLocation.state = "\(pmState)"
                        } else {
                            self.theLocation.state = ""
                        }
                        if let pmZip = pm.postalCode {
                            self.theLocation.zip = "\(pmZip)"
                        } else {
                            self.theLocation.zip = ""
                        }
                        
                        self.locationAvailable = true
                        let index = IndexPath(row: 9, section: 0)
                        self.projectTableView.reloadRows(at: [index], with: .automatic)
                    }
                default: break
                }
            }
            
        })
    }
    
}

extension PromotionJournalVC: PromotionPhotoCollectionCellDelegate {
    
    func thePromotionCellHasBeenTapped(photo: Photo) {
        
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
    
    func thePromotionPhotoCellObjectID(objectID: NSManagedObjectID) {
        
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
    
    
}



