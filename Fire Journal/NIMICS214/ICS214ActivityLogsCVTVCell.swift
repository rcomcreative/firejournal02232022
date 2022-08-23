//
//  ICS214ActivityLogsCVTVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 8/13/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import CoreData

class ICS214ActivityLogsCVTVCell: UITableViewCell {
    
    var context: NSManagedObjectContext!
    var ics214FormOID: NSManagedObjectID!
    var ics214Form: ICS214Form!
    var activityLogs = [ICS214ActivityLog]()
    var activityHeight: CGFloat = 1.0
    var theHeight: CGFloat = 44
    let nc = NotificationCenter.default
    
    lazy var theUserAttendeeProvider: UserAttendeesProvider = {
        let provider = UserAttendeesProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var theUserAttendeeContext: NSManagedObjectContext!
    
    enum Section: CaseIterable {
        case main
    }
    
    var activityLogCollectionView: UICollectionView! = nil
    let theBackgroundView = UIView()
    var indexPath: IndexPath!
    
    var alogDataSource: UICollectionViewDiffableDataSource<Section, ICS214ActivityLog>!
    var currentALogSnapshot: NSDiffableDataSourceSnapshot<Section,ICS214ActivityLog>! = nil
    

    override func awakeFromNib() {
        super.awakeFromNib()
            // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
            // Configure the view for the selected state
    }
    
        // MARK: -
        // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    func saveToCoreData(completion: () -> Void) {
        do {
            try context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"ICS214ActivityLogVC merge that"])
            }
            completion()
        } catch let error as NSError {
            print("ICS214ActivityLogVC line 140 Fetch Error: \(error.localizedDescription)")
        }
    }

}


extension ICS214ActivityLogsCVTVCell {
    
    func configure(_ ics214FormID: NSManagedObjectID, _ backgroundContext: NSManagedObjectContext, index: IndexPath, _ ics214ActivityLogs: [ICS214ActivityLog]) {
        
        self.nc.addObserver(self, selector: #selector(self.deleteTheActivityLog(nc:)), name: .fConDelteICS214ActivityLog, object: nil)
        
        self.nc.addObserver(self, selector: #selector(self.editTheActivityLog(nc:)), name: .fConEditICS214ActivityLog, object: nil)
        
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        
        self.activityLogs = ics214ActivityLogs
        self.selectionStyle = .none
        self.indexPath = index
        self.tag = indexPath.row
        
        self.ics214FormOID = ics214FormID
        self.context = backgroundContext
        self.ics214Form = context.object(with: self.ics214FormOID) as? ICS214Form
        if ics214ActivityLogs.isEmpty {
            if self.ics214Form.ics214ActivityDetail != nil {
                let result = self.ics214Form.ics214ActivityDetail?.allObjects as! [ICS214ActivityLog]
                if !result.isEmpty {
                        activityLogs = result
                }
            }
        }
        
        if activityLogs.count > 1 {
            let standardHeight = 1
            let height = standardHeight/activityLogs.count
            activityHeight = CGFloat(height)
            var heightCount: CGFloat = 0
            for activityLog in activityLogs {
                if let log = activityLog.ics214ActivityLog {
                    let height = configureLabelHeight(text: log)
                    heightCount = heightCount + height
                }
            }
            theHeight = heightCount * CGFloat(activityLogs.count)
        }
        
        theBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(theBackgroundView)
        
        NSLayoutConstraint.activate([
            
            theBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            theBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            theBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
            theBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
        ])
        
        configureActivityLogHierarchy()
        
    }
    
    @objc func editTheActivityLog(nc: Notification) {
        if let userInfo = nc.userInfo as! [String: Any]? {
            if let id = userInfo["activityLogID"] as? NSManagedObjectID {
                    DispatchQueue.main.async {
                        self.nc.post(name: .fConLaunchEditICS214ActivityLog, object: nil, userInfo:  ["activityLogID": id])
                    }
            }
        }
    }
    
    @objc func deleteTheActivityLog(nc: Notification) {
        if let userInfo = nc.userInfo as! [String: Any]? {
            if let id = userInfo["activityLogID"] as? NSManagedObjectID {
                DispatchQueue.main.async {
                    self.nc.post(name: .fConLaunchDeleteICS214ActivityLog, object: nil, userInfo:  ["activityLogID": id])
                }
//                let activityLogID = id
//                let activityLogModel = context.object(with: activityLogID)
//                let theICS214ActivityLog = context.object(with: activityLogID) as! ICS214ActivityLog
//                    context.delete(activityLogModel)
//                    currentALogSnapshot.deleteItems([theICS214ActivityLog])
//                    alogDataSource.apply(currentALogSnapshot, animatingDifferences: true)
//                if ics214Form != nil {
//                    ics214Form.removeFromIcs214ActivityDetail(theICS214ActivityLog)
//                    saveToCoreData() {
//
//                    }
//                }
                }
            }
        }
    
        //    MARK: -CONFIGUREHEIGHT-
    
        /// find the height for text area using the string associated with input
        /// - Parameter text: text entered in modals for form
        /// - Returns: returns the height for the label cell
    func configureLabelHeight(text: String ) -> CGFloat {
        var theFloat: CGFloat = 0.0
        let frame = self.contentView.frame
        let width = frame.width - 150
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
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
    
    func configureActivityLogHierarchy() {
        
        activityLogCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createActivityLogLayout())
        activityLogCollectionView.translatesAutoresizingMaskIntoConstraints = false
        activityLogCollectionView.backgroundColor = .systemBackground
        activityLogCollectionView.tag = 1
        activityLogCollectionView.delegate = self
        configureActivityLogsDataSource()
       contentView.addSubview(activityLogCollectionView)
       NSLayoutConstraint.activate([
        activityLogCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
        activityLogCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        activityLogCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        activityLogCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
//        activityLogCollectionView.heightAnchor.constraint(equalToConstant: theHeight),
           
       ])
        
    }
    
    func createActivityLogLayout() -> UICollectionViewLayout  {
        let estimatedHeight = CGFloat(100)
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(70.0))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
//            section.orthogonalScrollingBehavior = .continuous
            section.interGroupSpacing = 5
            section.contentInsets = NSDirectionalEdgeInsets(top: 0.0, leading: 5.0, bottom: 0, trailing: 20.0)
            return section
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        
        let layout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider, configuration: config)
        
        return layout
    }
    
    func configureActivityLogsDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<ICS214ActivityLogsCVCell, ICS214ActivityLog> { (cell, indexPath, activityLog ) in
            cell.configure(activityLog)
        }
        
        alogDataSource = UICollectionViewDiffableDataSource<Section, ICS214ActivityLog>(collectionView: activityLogCollectionView) { (collectionView: UICollectionView, indexPath: IndexPath, identifier: ICS214ActivityLog) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }
        
        //        let navButtons = navBarController.generateButtons()
        currentALogSnapshot = NSDiffableDataSourceSnapshot < Section, ICS214ActivityLog>()
        currentALogSnapshot.appendSections([.main])
        activityLogs = activityLogs.sorted(by: { return $0.ics214ActivityDate! < $1.ics214ActivityDate! })
        activityLogs.forEach {
            let log = $0
            currentALogSnapshot.appendItems([log])
        }
        alogDataSource.apply(currentALogSnapshot,animatingDifferences: false)
        
    }
    
}

extension ICS214ActivityLogsCVTVCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        guard let objectID = self.alogDataSource.itemIdentifier(for: indexPath)?.objectID else {
            collectionView.deselectItem(at: indexPath, animated: true)
            return UIContextMenuConfiguration(identifier: nil,
                                              previewProvider: nil,
                                              actionProvider: nil)
        }
        
        let actionProvider: ([UIMenuElement]) -> UIMenu? = { _ in
            let edit = UIAction(title: "Review and Edit Activity Log", image: UIImage(systemName: "pencil.circle"), identifier: UIAction.Identifier(rawValue: "edit")) { _ in
                DispatchQueue.main.async {
                         self.nc.post(name: .fConEditICS214ActivityLog, object: nil, userInfo: ["activityLogID": objectID as Any])
                     }
            }
            let delete = UIAction(title: "Delete Activity Log", image: UIImage(systemName: "xmark.circle"), identifier: UIAction.Identifier(rawValue: "delete")) { _ in
                DispatchQueue.main.async {
                         self.nc.post(name: .fConDelteICS214ActivityLog, object: nil, userInfo: ["activityLogID": objectID as Any])
                     }
            }
            
            return UIMenu(title: "", image: nil, identifier: nil, children: [edit, delete])
        }

        return UIContextMenuConfiguration(identifier: nil,
                                          previewProvider: nil,
                                          actionProvider: actionProvider)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
}

