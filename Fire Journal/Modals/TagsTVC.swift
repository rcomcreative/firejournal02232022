//
//  TagsTVC.swift
//  dashboard
//
//  Created by DuRand Jones on 10/31/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class TheTag {
    var entryState = EntryState.new
    var tag: String
    var tagGuid: String = ""
    var tagDate: Date = Date()
    init(tag: String) {
        self.tag = tag
    }
    
    func createGuid() {
        self.tagDate = Date()
        let groupDate = GuidFormatter.init(date:tagDate)
        let grGuid:String = groupDate.formatGuid()
        self.tagGuid = "74."+grGuid
    }
    
}

protocol TagsTVCDelegate: AnyObject {
    func theCancelTagsBTapped()
    func theTagsHaveBeenChosen(tags:Array<String>)
}

class TagsTVC: UITableViewController, UITextFieldDelegate, NSFetchedResultsControllerDelegate,ModalHeaderSaveCancelDelegate {

    weak var delegate: TagsTVCDelegate? = nil
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let nc = NotificationCenter.default
    var newTag: TheTag!
    var selected: Array<String> = []
    
    @IBOutlet weak var cancelB: UIButton!
    @IBOutlet weak var saveB: UIButton!
    @IBOutlet weak var newTagTF: UITextField!
    @IBOutlet weak var addNewTagB: UIButton!
    var shift: MenuItems = .journal
    
    
    @IBAction func cancelBTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        delegate?.theCancelTagsBTapped()
    }
    
    @IBAction func saveBTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        delegate?.theTagsHaveBeenChosen(tags: selected )
    }
    
    @IBAction func addTagBTapped(_ sender: Any) {
        if let tag = newTagTF.text {
            let tagNew = TheTag.init(tag: tag )
            tagNew.createGuid()
            let fjUserTags = UserTags.init(entity: NSEntityDescription.entity(forEntityName: "UserTags", in: context)!, insertInto: context)
            fjUserTags.userTag = tagNew.tag
            selected.append(tagNew.tag)
            fjUserTags.entryState = tagNew.entryState.rawValue
            fjUserTags.userTagGuid = tagNew.tagGuid
            fjUserTags.userTagModDate = tagNew.tagDate
            fjUserTags.userTagBackup = false
            saveToCD()
        }
        newTagTF.text = ""
        tableView.reloadData()
    }
    
    //    MARK: -CELL CrewCell
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Device.IS_IPHONE {
            let frame = self.view.frame
            let height = frame.height - 44
            self.view.frame = CGRect(x: 0, y: 44, width: frame.width, height: height)
            self.tableView = UITableView.init(frame: self.view.frame, style: .grouped)
        }
        _ = getTheTagsData()
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        
        
        tableView.register(UINib(nibName: "TagsCell", bundle: nil), forCellReuseIdentifier: "TagsCell")
        
        tableView.allowsMultipleSelection = true
    
        roundViews()
    }
    
    func roundViews() {
        self.view.layer.cornerRadius = 20
        self.view.clipsToBounds = true
    }
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    //    MARK: -SAVE
    fileprivate func saveToCD() {
        do {
            try context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"Tags TVC merge that"])
            }
        } catch let error as NSError {
            print("TagsTVC line 103 Fetch Error: \(error.localizedDescription)")
        }
    }
    
    //    MARK: -ModalHeaderSaveCancelHeaderDelegate
    func modalHeaderSaveBTapped() {
        self.dismiss(animated: true, completion: nil)
        delegate?.theTagsHaveBeenChosen(tags: selected )
    }
    func modalHeaderCancelBTapped(){
        self.dismiss(animated: true, completion: nil)
        delegate?.theCancelTagsBTapped()
    }
    func modalHeaderAddNewTag(tag:String) {
        
        let tagNew = TheTag.init(tag: tag )
        tagNew.createGuid()
        let fjUserTags = UserTags.init(entity: NSEntityDescription.entity(forEntityName: "UserTags", in: context)!, insertInto: context)
        fjUserTags.userTag = tagNew.tag
        selected.append(tagNew.tag)
        fjUserTags.entryState = tagNew.entryState.rawValue
        fjUserTags.userTagGuid = tagNew.tagGuid
        fjUserTags.userTagModDate = tagNew.tagDate
        fjUserTags.userTagBackup = false
        saveToCD()
        
        tableView.reloadData()
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cellHeader = Bundle.main.loadNibNamed("ModalHeaderSaveCancelBkgrndColorView", owner: self, options: nil)?.first as! ModalHeaderSaveCancelBkgrndColorView
        cellHeader.modalHTitle.text = "Tags"
        cellHeader.delegate = self
        if shift == .incidents {
            cellHeader.backgroundV.backgroundColor = ButtonsForFJ092018.fillColor38
        } else {
            cellHeader.backgroundV.backgroundColor = UIColor(named: "FJJournalBlueColor")
        }
        
//        let color = ButtonsForFJ092018.gradient1Blue
        cellHeader.tagTF.placeholder = "New Tag"
//        cellHeader.backgroundV.backgroundColor = color
        return cellHeader
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 112
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = _fetchedResultsController?.sections
        {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TagsCell", for: indexPath) as! TagsCell
        configureCell(cell, at: indexPath)
        return cell
    }
    
    func configureCell(_ cell: TagsCell, at indexPath: IndexPath) {
        cell.tags =  _fetchedResultsController?.object(at: indexPath)
        
        //        MARK: if multiple selects already exist check against resource and mark as checked
        let tag = cell.tags?.userTag ?? ""
        let result = selected.filter { $0 == tag}
        if !result.isEmpty {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as! TagsCell
        cell.isSelected = true
        let name = cell.tags?.userTag ?? ""
        
        let result = selected.filter { $0 == name}
        if result.isEmpty {
            selected.append(name)
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as! TagsCell
        cell.isSelected = false
        let resource = cell.tags?.userTag ?? ""
        selected = selected.filter { $0 != resource }
    }

    
    
    var fetchedResultsController: NSFetchedResultsController<UserTags> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        return _fetchedResultsController!
    }
    
    var _fetchedResultsController: NSFetchedResultsController<UserTags>? = nil
    
    private func getTheTagsData() -> NSFetchedResultsController<UserTags> {
        
        let fetchRequest: NSFetchRequest<UserTags> = UserTags.fetchRequest()
        
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != %@","userTag","")
        
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 20
        
        let sectionSortDescriptor = NSSortDescriptor(key: "userTag", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch let error as NSError {
            print("TagsTVC line 193 Fetch Error: \(error.localizedDescription)")
        }
        return _fetchedResultsController!
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?)
    {
        switch type
        {
        case NSFetchedResultsChangeType.delete:
            print("NSFetchedResultsChangeType.Delete detected")
            if let deleteIndexPath = indexPath
            {
                tableView.deleteRows(at: [deleteIndexPath], with: UITableView.RowAnimation.fade)
            }
        case NSFetchedResultsChangeType.insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
        case NSFetchedResultsChangeType.move:
            print("NSFetchedResultsChangeType.Move detected")
        case NSFetchedResultsChangeType.update:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            tableView.reloadRows(at: [indexPath!], with: UITableView.RowAnimation.fade)
        default: break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        tableView.endUpdates()
    }
}
