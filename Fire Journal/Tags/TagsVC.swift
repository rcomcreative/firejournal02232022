//
//  TagsVC.swift
//  StationCommand
//
//  Created by DuRand Jones on 11/23/21.
//

import UIKit
import CoreData
import CloudKit

protocol TagsVCDelegate: AnyObject {
    func tagsSubmitted(tags: [Tag])
}

class TagsVC: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var currentNewShiftStationPrioritiesSnapshot: NSDiffableDataSourceSnapshot<Section, Tag>! = nil
    var newAdded: Bool = false
    var tagDataSource: UICollectionViewDiffableDataSource<Section, Tag>!
    var currentTagSnapshot: NSDiffableDataSourceSnapshot<Section, Tag>! = nil
    var thePlatoonColor: String = "FJIconRed"
    var thePlatoon: String = ""
    let nc = NotificationCenter.default
    
        //    MARK: -NSFETCHRESULTS-
    var fetchedResultsController: NSFetchedResultsController<Tag>? = nil
    var _fetchedResultsController: NSFetchedResultsController<Tag> {
        if fetchedResultsController != nil {
            fetchedResultsController?.delegate = self
            return fetchedResultsController!
        }
        return fetchedResultsController!
    }
    
    var fetchedObjects: [Tag] {
        return fetchedResultsController?.fetchedObjects ?? []
    }
    
    weak var delegate: TagsVCDelegate? = nil

    var multiListTableView: UITableView! = nil
    var tagsHeaderV: TagsHeaderV! = nil
    var newModalHeaderV: NewModalHeaderV!
    var alertUp: Bool = false
    var tagsSelected = [Tag]()
    
    private var headerTitle: String = ""
    var theTitle: String = "" {
        didSet {
            self.headerTitle = self.theTitle
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        
        _ = getTags()
        configureNewModalHeaderV()
        configureTagsHeaderV()
        configureMultListTableView()
    }
    

}

extension TagsVC {
    
    
    
        // MARK: -context notification
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    func configureNewModalHeaderV() {
        newModalHeaderV = Bundle.main.loadNibNamed("NewModalHeaderV", owner: self, options: nil)?.first as? NewModalHeaderV
        newModalHeaderV.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 60)
        newModalHeaderV.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(newModalHeaderV)
        newModalHeaderV.theTitle = headerTitle
        newModalHeaderV.contentView.backgroundColor = .systemGray2
        newModalHeaderV.closeB.setTitleColor(.black, for: .normal)
        newModalHeaderV.saveB.setTitleColor(.black, for: .normal)
        newModalHeaderV.theView = .tags
        newModalHeaderV.delegate = self
        NSLayoutConstraint.activate([
            newModalHeaderV.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            newModalHeaderV.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            newModalHeaderV.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            newModalHeaderV.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    func configureTagsHeaderV() {
        tagsHeaderV = Bundle.main.loadNibNamed("TagsHeaderV", owner: self, options: nil)?.first as? TagsHeaderV
        tagsHeaderV.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 0)
        tagsHeaderV.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tagsHeaderV)
        tagsHeaderV.contentView.backgroundColor = .systemGray6
        tagsHeaderV.subject = "Tags"
        tagsHeaderV.delegate = self
        NSLayoutConstraint.activate([
            tagsHeaderV.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tagsHeaderV.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tagsHeaderV.topAnchor.constraint(equalTo: self.newModalHeaderV.bottomAnchor, constant: 2),
            tagsHeaderV.heightAnchor.constraint(equalToConstant: 150),
        ])
        tagsHeaderV.configure()
    }
    
    func configureMultListTableView() {
        multiListTableView  = UITableView(frame: .zero)
        registerCells()
        multiListTableView.translatesAutoresizingMaskIntoConstraints = false
        multiListTableView.backgroundColor = .systemBackground
        view.addSubview(multiListTableView)
        multiListTableView.delegate = self
        multiListTableView.dataSource = self
        multiListTableView.separatorStyle = .none
        multiListTableView.rowHeight = UITableView.automaticDimension
        multiListTableView.estimatedRowHeight = 55
        multiListTableView.allowsMultipleSelection = true
        
        NSLayoutConstraint.activate([
            multiListTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            multiListTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            multiListTableView.topAnchor.constraint(equalTo: tagsHeaderV.bottomAnchor, constant: 5),
            multiListTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10)
        ])
        
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
        let subject = InfoBodyText.tagsSubject.rawValue
        let message = InfoBodyText.tagsDescription.rawValue
        let alert = UIAlertController.init(title: subject, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(okAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension TagsVC: TagsHeaderVDelegate {
    
    func theTagAddBTapped(tag: String) {
        let result = fetchedObjects.filter { $0.name == tag}
        if result.isEmpty {
            let theTag = Tag(context: context)
            theTag.guid = UUID()
            theTag.name = tag
            do {
                try context.save()
                DispatchQueue.main.async {
                    self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"TagVC Tag merge that"])
                }
            } catch let error as NSError {
                let theError: String = error.localizedDescription
                let error = "There was an error in saving " + theError
                errorAlert(errorMessage: error)
            }
            newAdded = true
            viewDidLoad()
        }
    }
    
    func theTagsError(error: String) {
        errorAlert(errorMessage: error)
    }
    
    
}

extension TagsVC: NewModalHeaderVDelegate {
    
    func modalSaveBTapped(_ theView: TheViews) {
        delegate?.tagsSubmitted(tags: tagsSelected )
        self.dismiss(animated: true, completion: nil )
    }
    
    func modalCloseBTapped() {
        self.dismiss(animated: true, completion: nil )
    }
    
    func theInfoBTapped() {
        infoAlert()
    }
    
    
}

extension TagsVC: UITableViewDelegate {
    
    func registerCells() {
        multiListTableView.register(UINib(nibName: "LabelTextFieldCell", bundle: nil), forCellReuseIdentifier: "LabelTextFieldCell")
        multiListTableView.register(TagsTVCell.self, forCellReuseIdentifier: "TagsTVCell")
    }
    
}

extension TagsVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedObjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        guard let tag = fetchedObjects[row] as Tag? else  {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
            return cell
        }
        var cell = tableView.dequeueReusableCell(withIdentifier: "TagsTVCell", for: indexPath) as! TagsTVCell
        cell = configureTagsTVCell(cell, index: indexPath, tag: tag)
        var name: String = ""
        if let tagName = tag.name {
            name = tagName
        }
        cell.configure(objectID: tag.objectID, tag: name)
        return cell
    }
    
    func configureTagsTVCell(_ cell: TagsTVCell, index: IndexPath, tag: Tag) -> TagsTVCell {
        cell.tag = index.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as! TagsTVCell
        let objectID: NSManagedObjectID!
        if let oID = cell.objectID {
            objectID = oID
            let result = tagsSelected.filter { $0.objectID == objectID }
            if result.isEmpty {
                let tag = context.object(with: objectID) as! Tag
                tagsSelected.append(tag)
                cell.isSelected = true
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as! TagsTVCell
        let objectID: NSManagedObjectID!
        if let oID = cell.objectID {
            objectID = oID
            tagsSelected = tagsSelected.filter { $0.objectID != objectID }
        }
        
    }
    
    
}

extension TagsVC: NSFetchedResultsControllerDelegate {
    
    func getTags() -> NSFetchedResultsController<Tag> {
        
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        fetchRequest.fetchBatchSize = 20
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "name != %@", "")
        fetchRequest.predicate = predicate
        
        let sectionSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        fetchedResultsController = aFetchedResultsController
        
        do {
            try fetchedResultsController!.performFetch()
        } catch let error as NSError {
            print("Tags Fetch Error: \(error.localizedDescription)")
            if !self.alertUp {
                let errorred: String =  "Data Error: \(error.localizedDescription) Try again later."
                self.errorAlert(errorMessage: errorred)
            }
        }
        
        return fetchedResultsController!
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        let tagA = fetchedObjects
        if currentTagSnapshot != nil && newAdded {
            tagA.forEach { tag in
                currentTagSnapshot.appendItems([tag], toSection: .main)
            }
        }
    }
    
}
