//
//  OnboardProfileFormVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/13/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import MapKit
import CoreLocation

protocol OnboardProfileFormVCDelegate: AnyObject {
    func theOnboardFormIsComplete(objectID: NSManagedObjectID, userTimeObjectID: NSManagedObjectID)
}

class OnboardProfileFormVC: UIViewController {
    
    weak var delegate: OnboardProfileFormVCDelegate? = nil
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    private let vcLaunch = VCLaunch()
    private var launchNC: LaunchNotifications!
    let nc = NotificationCenter.default
    
    lazy var theUserProvider: FireJournalUserProvider = {
        let provider = FireJournalUserProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var theUserContext: NSManagedObjectContext!
    var theFireJournalUser: FireJournalUser!
    var theJournal: Journal!
    var theUserTime: UserTime!
    var objectID: NSManagedObjectID!
    var theLocation: FCLocation!
    var theStatus: Status!
    var alertUp: Bool = false
    var dateFormatter = DateFormatter()
    
    
    var onboardModalHeaderV: OnboardHeaderV!
    var onboardTableView: UITableView!
    
        var firstNameB = false
        var lastNameB = false
        var fireStationB = false
        var emailB = false
    
        let theDate = Date()

    override func viewDidLoad() {
        super.viewDidLoad()
        getTheUser()
        if theFireJournalUser == nil {
            theFireJournalUser = FireJournalUser(context: context)
            theFireJournalUser.userGuid = theFireJournalUser.guidForFireJournalUser(theDate, dateFormatter: dateFormatter)
            theFireJournalUser.fjpUserModDate = theDate
            theFireJournalUser.firstName = ""
            theFireJournalUser.lastName = ""
            theFireJournalUser.emailAddress = ""
            theFireJournalUser.fireStation = ""
            do {
                try context.save()
                DispatchQueue.main.async {
                    self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"FireJournalUser merge that"])
                }
            } catch let error as NSError {
                let theError: String = error.localizedDescription
                let error = "There was an error in saving " + theError
                errorAlert(errorMessage: error)
            }
            self.objectID = theFireJournalUser.objectID
        }
        configureOnboardHeaderV()
        configureOnboardTableView()
    }
    
        // MARK: -
        // MARK: Notification Handling
        @objc func managedObjectContextDidSave(notification: Notification) {
            DispatchQueue.main.async {
                self.context.mergeChanges(fromContextDidSave: notification)
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
    
    func infoAlert() {
        let subject = InfoBodyText.onboardInfoSubject.rawValue
        let message = InfoBodyText.onboardInfoDescription.rawValue
        let alert = UIAlertController.init(title: subject, message: message, preferredStyle: .alert)
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

extension OnboardProfileFormVC {
    
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
            self.objectID = theFireJournalUser.objectID
        }
    }
    
    func configureOnboardHeaderV() {
        onboardModalHeaderV = Bundle.main.loadNibNamed("OnboardHeaderV", owner: self, options: nil)?.first as? OnboardHeaderV
        onboardModalHeaderV.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(onboardModalHeaderV)
        onboardModalHeaderV.delegate = self
        
        NSLayoutConstraint.activate([
            onboardModalHeaderV.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            onboardModalHeaderV.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            onboardModalHeaderV.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 44),
            onboardModalHeaderV.heightAnchor.constraint(equalToConstant: 170),
        ])
    }
    
    func configureOnboardTableView() {
        onboardTableView = UITableView(frame: .zero)
        registerCellsForTable()
        onboardTableView.translatesAutoresizingMaskIntoConstraints = false
        onboardTableView.backgroundColor = .systemBackground
        view.addSubview(onboardTableView)
        onboardTableView.delegate = self
        onboardTableView.dataSource = self
        onboardTableView.separatorStyle = .none
        
        onboardTableView.rowHeight = UITableView.automaticDimension
        onboardTableView.estimatedRowHeight = 300
        
        NSLayoutConstraint.activate([
            onboardTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            onboardTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            onboardTableView.topAnchor.constraint(equalTo: onboardModalHeaderV.bottomAnchor, constant: 5),
            onboardTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10),
        ])
    }
    
}

extension OnboardProfileFormVC: OnboardHeaderVDelegate {
    
    func theOnboardSaveBTapped() {
        firstNameB = theFireJournalUser.firstName == "" ? true : false
        lastNameB = theFireJournalUser.lastName == "" ? true: false
        emailB = theFireJournalUser.emailAddress == "" ? true: false
        fireStationB = theFireJournalUser.fireStation == "" ? true: false
        if firstNameB, lastNameB, emailB, fireStationB {
//            MARK: - ERROR ALERT
        } else {
            
            var fullName: String = ""
            if theFireJournalUser.userName == "" {
            if let first = theFireJournalUser.firstName {
                fullName = first + " "
            }
            if let last = theFireJournalUser.lastName {
                fullName = fullName + last
            }
                theFireJournalUser.userName = fullName
            }
            
            
            let guidDate = GuidFormatter.init(date: theDate)
            let guid = guidDate.formatGuid()
            let theUserGuid = "78."+guid
            theUserTime = UserTime(context: context)
            theUserTime.userTimeGuid = theUserGuid
            theUserTime.userStartShiftTime = theDate
            theUserTime.shiftCompleted = false
            theUserTime.fireJournalUser = theFireJournalUser
            theUserTime.startShiftPlatoon = theFireJournalUser.platoon
            theUserTime.startShiftAssignment = theFireJournalUser.tempAssignment
            
            
            theStatus = Status(context: context)
            theStatus.guidString = theUserGuid
            theStatus.shiftDate = theDate
            theStatus.agreement = true
            theStatus.agreementDate = theDate
            
            theJournal = Journal(context: context)
            theJournal.journalGuid = UUID()
            theJournal.fjpJGuidForReference = theJournal.guidForJournal(theDate, dateFormatter: dateFormatter)
            theJournal.fireJournalUserInfo = theFireJournalUser
            let searchDate = FormattedDate.init(date: theDate)
            let sDate:String = searchDate.formatTheDate()
            let header:String = "New User created \(sDate)"
            theJournal.journalHeader = header
            theJournal.journalEntryTypeImageName = "100515IconSet_092016_Stationboard c0l0r"
            theJournal.journalEntryType = "Station"
            theJournal.journalCreationDate = theDate
            theJournal.journalModDate = theDate
            theJournal.journalDateSearch = sDate
            theJournal.fjpUserReference = theFireJournalUser.userGuid
            var journalEntry: String = ""
            if let fullName = theFireJournalUser.userName {
                journalEntry = "New User created " + fullName + " on " + sDate
            } else {
                journalEntry = "New User created " + " on " + sDate
            }
            theJournal.journalOverview = journalEntry as NSObject
            theJournal.journalTempPlatoon = theFireJournalUser.platoon
            theJournal.journalTempApparatus = theFireJournalUser.tempApparatus
            theJournal.journalTempAssignment = theFireJournalUser.tempAssignment
            theJournal.journalTempFireStation = theFireJournalUser.fireStation
            theJournal.journalFireStation = theFireJournalUser.fireStation
            theJournal.journalBackedUp = false
            theJournal.journalPhotoTaken = false
            
            do {
                try context.save()
                DispatchQueue.main.async {
                    self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"FireJournalUser merge that"])
                }
                delegate?.theOnboardFormIsComplete(objectID: self.objectID, userTimeObjectID: self.theUserTime.objectID)
                self.nc.post(name: .fireJournalUserModifiedSendToCloud , object: nil, userInfo: ["objectID": self.theFireJournalUser.objectID])
                self.dismiss(animated: true, completion: nil)
            } catch let error as NSError {
                let theError: String = error.localizedDescription
                let error = "There was an error in saving " + theError
                errorAlert(errorMessage: error)
            }
            
                
        }
    }
    
    func theOnboardInfoBTapped() {
        infoAlert()
    }
    
}

extension OnboardProfileFormVC: UITableViewDelegate {
     
    func registerCellsForTable() {
        onboardTableView.register(UINib(nibName: "ProfileLabelTextFieldCell", bundle: nil), forCellReuseIdentifier: "ProfileLabelTextFieldCell")
        
        onboardTableView.register(UINib(nibName: "ProfileLabelCell", bundle: nil), forCellReuseIdentifier: "ProfileLabelCell")
        
        onboardTableView.register(UINib(nibName: "ProfileLabelTextFieldIndicatorCell", bundle: nil), forCellReuseIdentifier: "ProfileLabelTextFieldIndicatorCell")
        
        onboardTableView.register(UINib(nibName: "ProfileLabelWithLocationButtonsCell", bundle: nil), forCellReuseIdentifier: "ProfileLabelWithLocationButtonsCell")
        
        onboardTableView.register(RankTVCell.self, forCellReuseIdentifier: "RankTVCell")
        onboardTableView.register(UINib(nibName: "NewAddressFieldsButtonsCell", bundle: nil), forCellReuseIdentifier: "NewAddressFieldsButtonsCell")
        onboardTableView.register(ProfileLabelTextFieldTVCell.self, forCellReuseIdentifier: "ProfileLabelTextFieldTVCell")
        onboardTableView.register(MultipleAddButtonTVCell.self, forCellReuseIdentifier: "MultipleAddButtonTVCell")
    }
    
}

extension OnboardProfileFormVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 11
    }
    
        //
        /// - Parameters:
        ///   - tableView: self.onboardTableView
        ///   - indexPath: the indexPath for each cell
        /// - Returns: CGFloat
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        switch row {
        case 0, 1, 2, 3, 5:
            if Device.IS_IPHONE {
                return 100
            } else {
                return 50
            }
        case 7, 8, 9, 10:
            if Device.IS_IPHONE {
                return 100
            } else {
                return 55
            }
        default:
            return 44
        }
    }
    
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        switch row {
        case 0:
            var cell = tableView.dequeueReusableCell(withIdentifier: "ProfileLabelTextFieldTVCell", for: indexPath) as! ProfileLabelTextFieldTVCell
            cell = configureProfileLabelTextFieldTVCell(cell, index: indexPath)
            return cell
        case 1:
            var cell = tableView.dequeueReusableCell(withIdentifier: "ProfileLabelTextFieldTVCell", for: indexPath) as! ProfileLabelTextFieldTVCell
            cell = configureProfileLabelTextFieldTVCell(cell, index: indexPath)
            return cell
        case 2:
            var cell = tableView.dequeueReusableCell(withIdentifier: "ProfileLabelTextFieldTVCell", for: indexPath) as! ProfileLabelTextFieldTVCell
            cell = configureProfileLabelTextFieldTVCell(cell, index: indexPath)
            return cell
        case 3:
            var cell = tableView.dequeueReusableCell(withIdentifier: "ProfileLabelTextFieldTVCell", for: indexPath) as! ProfileLabelTextFieldTVCell
            cell = configureProfileLabelTextFieldTVCell(cell, index: indexPath)
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileLabelCell", for: indexPath) as! ProfileLabelCell
            cell.subjectL.text = "My Primary Fire Station"
            return cell
        case 5:
            var cell = tableView.dequeueReusableCell(withIdentifier: "ProfileLabelTextFieldTVCell", for: indexPath) as! ProfileLabelTextFieldTVCell
            cell = configureProfileLabelTextFieldTVCell(cell, index: indexPath)
            return cell
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileLabelCell", for: indexPath) as! ProfileLabelCell
            cell.subjectL.text = "My Assignment"
            return cell
        case 7:
            var cell = tableView.dequeueReusableCell(withIdentifier: "RankTVCell", for: indexPath) as! RankTVCell
            cell = configureRankTVCell(cell, index: indexPath)
            cell.selectionStyle = .none
            cell.configureTheButton()
            return cell
        case 8:
            var cell = tableView.dequeueReusableCell(withIdentifier: "RankTVCell", for: indexPath) as! RankTVCell
            cell = configureRankTVCell(cell, index: indexPath)
            cell.selectionStyle = .none
            cell.configureTheButton()
            return cell
        case 9:
            var cell = tableView.dequeueReusableCell(withIdentifier: "RankTVCell", for: indexPath) as! RankTVCell
            cell = configureRankTVCell(cell, index: indexPath)
            cell.selectionStyle = .none
            cell.configureTheButton()
            return cell
        case 10:
            var cell = tableView.dequeueReusableCell(withIdentifier: "RankTVCell", for: indexPath) as! RankTVCell
            cell = configureRankTVCell(cell, index: indexPath)
            cell.selectionStyle = .none
            cell.configureTheButton()
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileLabelCell", for: indexPath) as! ProfileLabelCell
            return cell
        }
    }
    
//    MARK: -CONFIGURATIONS-
    func configureProfileLabelTextFieldTVCell(_ cell: ProfileLabelTextFieldTVCell, index: IndexPath) -> ProfileLabelTextFieldTVCell {
        let row = index.row
        cell.tag = row
        cell.index = index
        cell.delegate = self
        switch row {
        case 0:
            cell.subject = "First Name"
            if let first = theFireJournalUser.firstName {
                cell.aDescription = first
            }
        case 1:
            cell.subject = "Last Name"
            if let last = theFireJournalUser.lastName {
                cell.aDescription = last
            }
        case 2:
            cell.subject = "Email Address"
            if let email = theFireJournalUser.emailAddress {
                cell.aDescription = email
            }
        case 3:
            cell.subject = "Phone Number"
            if let phone = theFireJournalUser.mobileNumber {
                cell.aDescription = phone
            }
        case 5:
            cell.subject = "Fire Station"
            if let station = theFireJournalUser.fireStation {
                cell.aDescription = station
            }
        default: break
        }
        cell.configure()
        return cell
    }
    
    func configureRankTVCell(_ cell: RankTVCell, index: IndexPath) -> RankTVCell {
        let row = index.row
        cell.tag = row
        cell.delegate = self
        cell.indexPath = index
        cell.theSubjectTF.font = UIFont.preferredFont(forTextStyle: .caption1)
        switch row {
        case 7:
            cell.type = IncidentTypes.platoon
            if theFireJournalUser != nil {
                if let platoon = theFireJournalUser.tempPlatoon {
                    cell.theSubjectTF.text = platoon
                }
            }
        case 8:
            cell.type = IncidentTypes.theRanks
            if theFireJournalUser != nil {
                if let rank = theFireJournalUser.rank {
                    cell.theSubjectTF.text = rank
                }
            }
        case 9:
            cell.type = IncidentTypes.assignment
            if theFireJournalUser != nil {
                if let assignment = theFireJournalUser.tempAssignment {
                    cell.theSubjectTF.text = assignment
                }
            }
        case 10:
            cell.type = IncidentTypes.apparatus
            if theFireJournalUser != nil {
                if let apparatus = theFireJournalUser.tempApparatus {
                    cell.theSubjectTF.text = apparatus
                }
            }
        default: break
        }
        return cell
    }
    
    
}



extension OnboardProfileFormVC: RankTVCellDelegate {
    
    func theButtonChoiceWasMade(_ text: String, index: IndexPath, tag: Int) {
        switch tag {
        case 7:
            theFireJournalUser.platoon = text
            theFireJournalUser.tempPlatoon = text
            onboardTableView.reloadRows(at: [IndexPath(row: 7, section: 0)], with: .automatic)
        case 8:
            theFireJournalUser.rank = text
            onboardTableView.reloadRows(at: [IndexPath(row: 8, section: 0)], with: .automatic)
        case 9:
            theFireJournalUser.tempAssignment = text
            onboardTableView.reloadRows(at: [IndexPath(row: 9, section: 0)], with: .automatic)
        case 10:
            theFireJournalUser.tempApparatus = text
            onboardTableView.reloadRows(at: [IndexPath(row: 10, section: 0)], with: .automatic)
        default: break
        }
    }
    
}

extension OnboardProfileFormVC: ProfileLabelTextFieldTVCellDelegate {
    
    func profileDescriptionChanged(text: String, tag: Int) {
        switch tag {
        case 0:
            theFireJournalUser.firstName = text
        case 1:
            theFireJournalUser.lastName = text
        case 2:
            theFireJournalUser.emailAddress = text
        case 3:
            theFireJournalUser.mobileNumber = text
        case 5:
            theFireJournalUser.fireStation = text
        default: break
        }
    }
    
    
}
