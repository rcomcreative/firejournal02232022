//
//  PersonalJournalTVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 5/20/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData

protocol PersonalJournalDelegate: AnyObject {
    func thePersonalJournalEntrySaved()
    func thePersonalJournalCancel()
}

class PersonalJournalTVC: UITableViewController,NSFetchedResultsControllerDelegate{
    
    //    PROPERTIES:
    weak var delegate:PersonalJournalDelegate? = nil
    var titleName:String = ""
    let vcLaunch = VCLaunch()
    private var launchNC: LaunchNotifications!
    var sizeTrait: SizeTrait = .regular
    var journalType: JournalTypes = .personal
    var journalStructure: JournalData!
    let nc = NotificationCenter.default
    var compact:SizeTrait = .regular
    var theTags = [String]()
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var id = NSManagedObjectID()
    var journal:Journal!
    var fju:FireJournalUser!
    var theUser: UserEntryInfo!
    var theUserCrew: UserCrews!
    var theCrew: TheCrew!
    var fetched:Array<Any>!
    var showSaved:Bool = false
    var objectID: NSManagedObjectID!
    var myShift:MenuItems = .personal
    var incidentPOV: Bool = false
    var overViewHeight: CGFloat = 150
    var discussionHeight: CGFloat = 200
    var tagsA = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vcLaunch.splitVC = self.splitViewController
        launchNC = LaunchNotifications.init(launchVC: vcLaunch)
        launchNC.callNotifications()
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(savePersonalJournal(_:)))
        navigationItem.rightBarButtonItem = saveButton
        registerTheCells()
        
        
        nc.addObserver(self, selector: #selector(compactOrRegular(ns:)), name:NSNotification.Name(rawValue: FJkCOMPACTORREGULAR), object: nil)
        
        journalStructure = JournalData.init()
        
        builtTheJournal(id: id)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
    }
    
    // MARK: - Table view data source
    private func getOverViewSize()->CGFloat {
        if journalStructure.journalOverview != "" {
            let textView = UITextView()
            textView.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: overViewHeight)
            let size = CGSize(width: textView.frame.width, height: .infinity)
            textView.text = journalStructure.journalOverview
            let estimatedSize = textView.sizeThatFits(size)
            
            overViewHeight = estimatedSize.height + 150
        }
        return overViewHeight
    }
    
    private func getDiscussionHeight() ->CGFloat {
        if journalStructure.journalDiscussion != "" || journalStructure.journalSummary != "" {
            let textView = UITextView()
            textView.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: discussionHeight)
            let size = CGSize(width: textView.frame.width, height: .infinity)
            if incidentPOV {
                textView.text = journalStructure.journalDiscussion
            } else {
                textView.text = journalStructure.journalSummary
            }
            let estimatedSize = textView.sizeThatFits(size)
            
            discussionHeight = estimatedSize.height + 200
        }
        return discussionHeight
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        
        switch row {
        case 0:
            return  105
        case 1:
            if overViewHeight == 150 {
                overViewHeight = getOverViewSize()
            }
            return overViewHeight
        case 2:
            if discussionHeight == 200 {
                discussionHeight = getDiscussionHeight()
            }
            return discussionHeight
        case 3:
            return 140
        default:
            return 44
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        
        switch row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ControllerLabelCell", for: indexPath) as! ControllerLabelCell
            
            cell.dateL.text =  journalStructure.journalCreationDate
            cell.addressL.text = journalStructure.journalStreetNum+" "+journalStructure.journalStreetName+" "+journalStructure.journalCity
            switch myShift {
            case .personal:
                cell.controllerL.text = journalStructure.journalTitle
                let image = UIImage(named: "ICONS_BBLUELOCK")
                cell.typeIV.image = image
            default:
                cell.controllerL.text = journalStructure.journalTitle
            }
            cell.incidentEditB.isHidden = true
            cell.incidentEditB.alpha = 0.0
            cell.incidentEditB.isEnabled = false
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextViewCell", for: indexPath) as! LabelTextViewCell
            cell.delegate = self
            cell.journalType = .overview
            cell.myShift = myShift
            cell.subjectL.text = "Overview"
            cell.journalType = .overview
            cell.descriptionTV.text = journalStructure.journalOverview
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextViewTimeStampCell", for: indexPath) as! LabelTextViewTimeStampCell
            cell.delegate = self
            cell.subjectL.text = "My Journal"
            cell.myShift = myShift
            if incidentPOV {
                cell.journalType = JournalTypes.discussion
                cell.descriptionTV.text = journalStructure.journalDiscussion
            } else {
                cell.journalType = .summary
                cell.descriptionTV.text = journalStructure.journalSummary
            }
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextViewDirectionalCell", for: indexPath) as! LabelTextViewDirectionalCell
            cell.delegate = self
            cell.subjectL.text = "Tags"
            cell.descriptionTV.text = ""
            if journalStructure.journalTags != "" {
                cell.descriptionTV.textColor =  UIColor.black
                cell.descriptionTV.text = journalStructure.journalTags
            }
            cell.journalType = .tags
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            return cell
        }
        
    }
    
}
