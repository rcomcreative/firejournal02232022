//
//  TheJournalNoteVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/28/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import CloudKit
import CoreData

protocol TheJournalNoteVCDelegate: AnyObject {
    func theJournalNoteHasBeenUpdated(text: String, index: IndexPath, type: IncidentTypes)
}

class TheJournalNoteVC: UIViewController {
    
    weak var delegate: TheJournalNoteVCDelegate? = nil
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
       
       var journalObID: NSManagedObjectID!
       var theJournal: Journal!
       var theUserTime: UserTime!
       var theUser: FireJournalUser!
       var index: IndexPath!
       var newModalHeaderV: NewModalHeaderV!
       var theType: IncidentTypes!
       var alertUp: Bool = false
       var notesTitleL = UILabel()
       var notesTitleTF = UITextField()
       var notesTV = UITextView()
       var noteTitle: String = ""
       var notes: String = ""
       var timeStampB = UIButton(primaryAction: nil)
       var theDateStamped: Bool = false
       var subject: String = ""
       var newOrUpdate: Bool = false
       var timeStampTapped: Bool = false
       
       var theSubject: String = ""
       var theMessage: String = ""
       
       let dateFormatter = DateFormatter()
       var theRankedOfficer: String = ""
       var isIncidentNote: Bool = false
       
       let nc = NotificationCenter.default

    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "EEE MMM dd,YYYY HH:mm"
        
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        
        guard let objectID = journalObID  else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        theJournal = context.object(with: objectID) as? Journal
        
        if theJournal.userTime != nil {
            theUserTime = theJournal.userTime
        }
        
        if theJournal.fireJournalUserInfo != nil {
            theUser = theJournal.fireJournalUserInfo
            if let rank = theUser.rank {
                theRankedOfficer = rank
            }
            if let last = theUser.lastName {
                theRankedOfficer = theRankedOfficer + " " + last
            }
        }
        
        if theType != nil {
            switch theType {
            case .overview:
                noteTitle = "Overview"
                if let note = theJournal.journalOverviewSC {
                    notes = note as! String
                }
            case .discussion:
                noteTitle = "Discussion"
                if let note = theJournal.journalDiscussionSC {
                    notes = note as! String
                }
            case .controlled:
                noteTitle = "Next Steps"
                if let note = theJournal.journalNextStepsSC {
                    notes = note as! String
                }
            case .summary:
                noteTitle = "Summary"
                if let note = theJournal.journalSummarySC {
                    notes = note as! String
                }
            default: break
            }
        }
        
        if Device.IS_IPHONE {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
            view.addGestureRecognizer(tapGesture)
        }
        
        
        configureNewModalHeaderV()
        configureLabel()
        configureTV()
        configureButton()
        configureNSLayouts()
        
    }
    

    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
        // MARK: -context notification
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    
    
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
        let alert = UIAlertController.init(title: theSubject, message: theMessage, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(okAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    

 

}

extension TheJournalNoteVC {
    
    func configureNewModalHeaderV() {
        newModalHeaderV = Bundle.main.loadNibNamed("NewModalHeaderV", owner: self, options: nil)?.first as? NewModalHeaderV
        newModalHeaderV.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 60)
        newModalHeaderV.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(newModalHeaderV)
        newModalHeaderV.theTitle = ""
        newModalHeaderV.contentView.backgroundColor = .systemGray2
        newModalHeaderV.closeB.setTitleColor(.black, for: .normal)
        newModalHeaderV.saveB.setTitleColor(.black, for: .normal)
        newModalHeaderV.theView = .journal
        newModalHeaderV.delegate = self
        NSLayoutConstraint.activate([
            newModalHeaderV.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            newModalHeaderV.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            newModalHeaderV.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            newModalHeaderV.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    func configureLabel() {
        notesTitleL.textAlignment = .left
        notesTitleL.font = .systemFont(ofSize: 18, weight: UIFont.Weight(rawValue: 200))
        notesTitleL.textColor = .label
        switch theType {
        case .overview:
            notesTitleL.text = "Overview Notes"
        case .discussion:
            notesTitleL.text = "Discussion Notes"
        case .nextSteps:
            notesTitleL.text = "Next Steps Notes"
        case .summary:
            notesTitleL.text = "Summary Notes"
        default: break
        }
    }
    
    func configureTV() {
        notesTV.textAlignment = .left
        notesTV.font = UIFont.preferredFont(forTextStyle: .caption1)
        notesTV.textColor = .label
        notesTV.adjustsFontForContentSizeCategory = true
        notesTV.layer.borderColor = UIColor(named: "FJBlueColor" )?.cgColor
        notesTV.layer.borderWidth = 1
        notesTV.layer.cornerRadius = 8
        notesTV.isUserInteractionEnabled = true
        notesTV.delegate = self
        notesTV.isScrollEnabled = true
        if theJournal != nil {
            switch theType {
            case .overview:
                if let notes = theJournal.journalOverviewSC as? String {
                    notesTV.text = notes
                }
            case .arrivalNote:
                    if let notes = theJournal.journalDiscussionSC as? String {
                        notesTV.text = notes
                    }
            case .controlledNote:
                if let notes = theJournal.journalNextStepsSC as? String {
                    notesTV.text = notes
                }
            case .lastUnitStandingNote:
                if let notes = theJournal.journalSummarySC as? String {
                    notesTV.text = notes
                }
            default: break
            }
            notesTV.setNeedsDisplay()
        }
    }
    
    func configureButton() {
        
        let image = UIImage(systemName:  "clock.badge.checkmark.fill")
        timeStampB.setImage(image, for: .normal)
        timeStampB.addTarget(self, action: #selector(timeStampBWasTapped(_:)), for: .touchUpInside)
        
    }
    
    func configureNSLayouts() {
        notesTitleL.translatesAutoresizingMaskIntoConstraints = false
        notesTV.translatesAutoresizingMaskIntoConstraints = false
        timeStampB.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(notesTitleL)
        self.view.addSubview(notesTV)
        self.view.addSubview(timeStampB)
        
        NSLayoutConstraint.activate([
            
            notesTitleL.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30),
            notesTitleL.topAnchor.constraint(equalTo: newModalHeaderV.bottomAnchor, constant: 20),
            notesTitleL.heightAnchor.constraint(equalToConstant: 30),
            notesTitleL.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant:  -35),
            
            notesTV.leadingAnchor.constraint(equalTo: notesTitleL.leadingAnchor),
            notesTV.topAnchor.constraint(equalTo: notesTitleL.bottomAnchor, constant: 20),
            notesTV.trailingAnchor.constraint(equalTo: notesTitleL.trailingAnchor),
            notesTV.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -95),
            
            timeStampB.trailingAnchor.constraint(equalTo: notesTitleL.trailingAnchor),
            timeStampB.topAnchor.constraint(equalTo: notesTV.bottomAnchor, constant: 10),
            timeStampB.heightAnchor.constraint(equalToConstant: 50),
            timeStampB.widthAnchor.constraint(equalToConstant: 50),
            
        ])
    }
    
    
    @objc func timeStampBWasTapped(_ sender: UIButton ) {
        if notes != "" {
            timeStampTapped = true
            let theDate = dateFormatter.string(from: Date() )
            var theTimeStamp: String = ""
            if theRankedOfficer == "" {
                if theUser != nil {
                    if let rank = theUser.rank {
                        theRankedOfficer = rank
                    }
                    if let last = theUser.lastName {
                        theRankedOfficer = theRankedOfficer + " " + last
                    }
                }
            }
            theTimeStamp = "\n\n" + theRankedOfficer + "\n" + theDate + "\n"
            notes = notes + theTimeStamp
            switch theType {
            case .overview:
                if theJournal != nil {
                    theJournal.journalOverviewSC = notes as NSObject
                }
            case .discussion:
                if theJournal != nil {
                    theJournal.journalDiscussionSC = notes as NSObject
                }
            case .nextSteps:
                if theJournal != nil {
                    theJournal.journalNextStepsSC = notes as NSObject
                }
            case .summary:
                if theJournal != nil {
                    theJournal.journalSummarySC = notes as NSObject
                }
            default: break
            }
            self.notesTV.text = notes
            self.notesTV.setNeedsDisplay()
            if context.hasChanges {
                do {
                    try context.save()
                    DispatchQueue.main.async {
                        self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"The journal;NoteVC merge that"])
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

extension TheJournalNoteVC: NewModalHeaderVDelegate {
    
    func modalSaveBTapped(_ theView: TheViews) {
        if timeStampTapped {
            if notes != "" {
                switch theType {
                case .overview:
                    theJournal.journalOverviewSC = notes as NSObject
                case .discussion:
                    theJournal.journalDiscussionSC = notes as NSObject
                case .nextSteps:
                    theJournal.journalNextStepsSC = notes as NSObject
                case .summary:
                    theJournal.journalSummarySC = notes as NSObject
                default: break
                }
                if context.hasChanges {
                    do {
                        try context.save()
                        DispatchQueue.main.async {
                            self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"The JournalNoteVC merge that"])
                        }
                    } catch let error as NSError {
                        let theError: String = error.localizedDescription
                        let error = "There was an error in saving " + theError
                        errorAlert(errorMessage: error)
                    }
                }
                delegate?.theJournalNoteHasBeenUpdated(text: notes, index: index, type: theType )
                self.dismiss(animated: true, completion: nil)
            } else {
                textViewDidEndEditing(notesTV)
                if notes == "" {
                    errorAlert(errorMessage: "The doesn't seem to be any text in the text view to save.")
                } else {
                    switch theType {
                    case .overview:
                        theJournal.journalOverviewSC = notes as NSObject
                    case .discussion:
                        theJournal.journalDiscussionSC = notes as NSObject
                    case .nextSteps:
                        theJournal.journalNextStepsSC = notes as NSObject
                    case .summary:
                        theJournal.journalSummarySC = notes as NSObject
                    default: break
                    }
                    if context.hasChanges {
                        if context.hasChanges {
                            do {
                                try context.save()
                                DispatchQueue.main.async {
                                    self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"The JournalNoteVC merge that"])
                                }
                            } catch let error as NSError {
                                let theError: String = error.localizedDescription
                                let error = "There was an error in saving " + theError
                                errorAlert(errorMessage: error)
                            }
                        }
                    }
                    delegate?.theJournalNoteHasBeenUpdated(text: notes, index: index, type: theType )
                    self.dismiss(animated: true, completion: nil)
                }
                    
            }
        } else {
            errorAlert(errorMessage: "The time stamp needs to be tapped before you can save this note.")
        }
    }
    
    func modalCloseBTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    func theInfoBTapped() {
        switch theType {
        case .overview:
            theSubject = InfoBodyText.journalOverviewSubject.rawValue
            theMessage = InfoBodyText.journalOverviewDescription.rawValue
        case .discussion:
            theSubject = InfoBodyText.journalDiscussionSubject.rawValue
            theMessage = InfoBodyText.journalDiscussionDescription.rawValue
        case .nextSteps:
            theSubject = InfoBodyText.journalNextStepSubject.rawValue
            theMessage = InfoBodyText.journalNextStepDescription.rawValue
        case .summary:
            theSubject = InfoBodyText.journalSummarySubject.rawValue
            theMessage = InfoBodyText.journalSummaryDescription.rawValue
        default: break
        }
        infoAlert()
    }
    
    
}

extension TheJournalNoteVC: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if let text = textView.text {
            notes = text
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if let text = textView.text {
            notes = text
            switch theType {
            case .overview:
                theJournal.journalOverviewSC = notes as NSObject
            case .discussion:
                theJournal.journalDiscussionSC = notes as NSObject
            case .nextSteps:
                theJournal.journalNextStepsSC = notes as NSObject
            case .summary:
                theJournal.journalSummarySC = notes as NSObject
            default: break
            }
        }
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if let text = textView.text {
            notes = text
            switch theType {
            case .overview:
                theJournal.journalOverviewSC = notes as NSObject
            case .discussion:
                theJournal.journalDiscussionSC = notes as NSObject
            case .nextSteps:
                theJournal.journalNextStepsSC = notes as NSObject
            case .summary:
                theJournal.journalSummarySC = notes as NSObject
            default: break
            }
        }
        return true
    }
    
}

