//
//  TheShiftNoteVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/29/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import CloudKit
import CoreData

protocol TheShiftNoteVCDelegate: AnyObject {
    func theShiftNoteHasBeenUpdated(text: String, index: IndexPath, type: IncidentTypes)
}

class TheShiftNoteVC: UIViewController {
    
    weak var delegate: TheShiftNoteVCDelegate? = nil

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
       
       var shiftObID: NSManagedObjectID!
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
       
       let nc = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.dateFormat = "EEE MMM dd,YYYY HH:mm"
        
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        
        guard let objectID = shiftObID  else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        theUserTime = context.object(with: objectID) as? UserTime
        
        if theUserTime.fireJournalUser != nil {
            theUser = theUserTime.fireJournalUser
            if let rank = theUser.rank {
                theRankedOfficer = rank
            }
            if let last = theUser.lastName {
                theRankedOfficer = theRankedOfficer + " " + last
            }
        }
        
        if theType != nil {
            switch theType {
            case .startShiftNotes:
                noteTitle = "Start Shift"
                if let note = theUserTime.startShiftDiscussion {
                    notes = note
                }
            case .endShiftNotes:
                noteTitle = "End Shift"
                if let note = theUserTime.startShiftDiscussion {
                    notes = note
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

extension TheShiftNoteVC {
    
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
        case .startShiftNotes:
            notesTitleL.text = "Start Shift Notes"
        case .endShiftNotes:
            notesTitleL.text = "End Shift Notes"
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
        notesTV.text = ""
        if theUserTime != nil {
            switch theType {
            case .startShiftNotes:
                if let notes = theUserTime.startShiftDiscussion {
                    notesTV.text = notes
                }
            case .endShiftNotes:
                if let notes = theUserTime.endShiftDiscussion {
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
        
        if Device.IS_IPHONE {
        
            NSLayoutConstraint.activate([
                
                notesTitleL.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30),
                notesTitleL.topAnchor.constraint(equalTo: newModalHeaderV.bottomAnchor, constant: 20),
                notesTitleL.heightAnchor.constraint(equalToConstant: 30),
                notesTitleL.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant:  -35),
                
                notesTV.leadingAnchor.constraint(equalTo: notesTitleL.leadingAnchor),
                notesTV.topAnchor.constraint(equalTo: notesTitleL.bottomAnchor, constant: 20),
                notesTV.trailingAnchor.constraint(equalTo: notesTitleL.trailingAnchor),
                notesTV.heightAnchor.constraint(equalToConstant: 300),
                
                timeStampB.trailingAnchor.constraint(equalTo: notesTitleL.trailingAnchor),
                timeStampB.topAnchor.constraint(equalTo: notesTitleL.topAnchor),
                timeStampB.heightAnchor.constraint(equalToConstant: 50),
                timeStampB.widthAnchor.constraint(equalToConstant: 50),
                
            ])
            
        } else {
        
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
            case .startShiftNotes:
                if theUserTime != nil {
                    theUserTime.startShiftDiscussion = notes
                }
            case .endShiftNotes:
                if theUserTime != nil {
                    theUserTime.endShiftDiscussion = notes
                }
            default: break
            }
            self.notesTV.text = notes
            self.notesTV.setNeedsDisplay()
            if context.hasChanges {
                do {
                    try context.save()
                    DispatchQueue.main.async {
                        self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"The Shift NoteVC merge that"])
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

extension TheShiftNoteVC: NewModalHeaderVDelegate {
    
    func modalSaveBTapped(_ theView: TheViews) {
        if timeStampTapped {
            if notes != "" {
                switch theType {
                case .startShiftNotes:
                    theUserTime.startShiftDiscussion = notes
                case .endShiftNotes:
                    theUserTime.endShiftDiscussion = notes
                default: break
                }
                if context.hasChanges {
                    do {
                        try context.save()
                        DispatchQueue.main.async {
                            self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"The ShiftNoteVC merge that"])
                        }
                    } catch let error as NSError {
                        let theError: String = error.localizedDescription
                        let error = "There was an error in saving " + theError
                        errorAlert(errorMessage: error)
                    }
                }
                delegate?.theShiftNoteHasBeenUpdated(text: notes, index: index, type: theType )
                self.dismiss(animated: true, completion: nil)
            } else {
                textViewDidEndEditing(notesTV)
                if notes == "" {
                    errorAlert(errorMessage: "The doesn't seem to be any text in the text view to save.")
                } else {
                    switch theType {
                    case .startShiftNotes:
                        theUserTime.startShiftDiscussion = notes
                    case .endShiftNotes:
                        theUserTime.endShiftDiscussion = notes
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
                    delegate?.theShiftNoteHasBeenUpdated(text: notes, index: index, type: theType)
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
        case .startShiftNotes:
            theSubject = InfoBodyText.journalOverviewSubject.rawValue
            theMessage = InfoBodyText.journalOverviewDescription.rawValue
        case .endShiftNotes:
            theSubject = InfoBodyText.journalDiscussionSubject.rawValue
            theMessage = InfoBodyText.journalDiscussionDescription.rawValue
        default: break
        }
        infoAlert()
    }
    
    
}

extension TheShiftNoteVC: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if let text = textView.text {
            notes = text
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if let text = textView.text {
            notes = text
            switch theType {
            case .startShiftNotes:
                theUserTime.startShiftDiscussion = notes
            case .endShiftNotes:
                theUserTime.endShiftDiscussion = notes
            default: break
            }
        }
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if let text = textView.text {
            notes = text
            switch theType {
            case .startShiftNotes:
                theUserTime.startShiftDiscussion = notes
            case .endShiftNotes:
                theUserTime.endShiftDiscussion = notes
            default: break
            }
        }
        return true
    }
    
}
