//
//  ICS214ResourcesCVTVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 8/12/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import CoreData

class ICS214ResourcesCVTVCell: UITableViewCell {
    
    var context: NSManagedObjectContext!
    var ics214FormOID: NSManagedObjectID!
    var ics214Form: ICS214Form!
    var userAttendees = [UserAttendees]()
    var userHeight: CGFloat = 1.0
    var theHeight: CGFloat = 44
    var ics214CrewEditVC: ICS214CrewEditVC!
    
    lazy var theUserAttendeeProvider: UserAttendeesProvider = {
        let provider = UserAttendeesProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var theUserAttendeeContext: NSManagedObjectContext!
    
    enum Section: CaseIterable {
        case main
    }
    
    var attendeesCollectionView: UICollectionView! = nil
    let theBackgroundView = UIView()
    var indexPath: IndexPath!
    
    var uaDataSource: UICollectionViewDiffableDataSource<Section, UserAttendees>!
    var currentUASnapshot: NSDiffableDataSourceSnapshot<Section,UserAttendees>! = nil
    
    let nc = NotificationCenter.default

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

}

extension ICS214ResourcesCVTVCell {
    
    func configure(_ ics214FormID: NSManagedObjectID, _ backgroundContext: NSManagedObjectContext, index: IndexPath) {
        
        self.nc.addObserver(self, selector: #selector(self.deleteThePersonnel(nc:)), name: .fConDeletionICS214Personnel, object: nil)
        
        self.nc.addObserver(self, selector: #selector(self.editThePersonnel(nc:)), name: .fConEditICS214Personnel, object: nil)
        
        self.selectionStyle = .none
        self.indexPath = index
        self.tag = indexPath.row
        
        self.ics214FormOID = ics214FormID
        self.context = backgroundContext
        self.ics214Form = context.object(with: self.ics214FormOID) as? ICS214Form
        self.userAttendees.removeAll()
        if self.ics214Form.ics214PersonneDetail != nil {
            let result = self.ics214Form?.ics214PersonneDetail?.allObjects as! [ICS214Personnel]
            if !result.isEmpty {
                theUserAttendeeContext = theUserAttendeeProvider.persistentContainer.newBackgroundContext()
                for personnel in result {
                    if let attendeeGuid = personnel.userAttendeeGuid {
                        if let result = theUserAttendeeProvider.isUserAttendeePartOfCD(attendeeGuid, theUserAttendeeContext) {
                            let attendee = result.last
                            if let id = attendee?.objectID {
                                if let userAttendee = context.object(with: id) as? UserAttendees {
                                    userAttendees.append(userAttendee)
                                }
                                
                            }
                        }
                    }
                }
            }
        }
        
        if userAttendees.count > 1 {
            let standardHeight = 1
            let height = standardHeight/userAttendees.count
            userHeight = CGFloat(height)
            let aHeight = 44 * userAttendees.count
            theHeight = CGFloat(aHeight)
        }
        
        theBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(theBackgroundView)
        
        NSLayoutConstraint.activate([
            
            theBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            theBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            theBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
            theBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
        ])
        
        configureUserAttendeesHierarchy()
        
    }
    
}

extension ICS214ResourcesCVTVCell {
    
    @objc func editThePersonnel(nc: Notification) {
        if let userInfo = nc.userInfo as! [String: Any]? {
            if let id = userInfo["userAttendeeID"] as? NSManagedObjectID {
                    DispatchQueue.main.async {
                        self.nc.post(name: .fConEditICS214UserAttendee, object: nil, userInfo:  ["userAttendeeID": id])
                    }
            }
        }
    }
    
    @objc func deleteThePersonnel(nc: Notification) {
        if let userInfo = nc.userInfo as! [String: Any]? {
            if let id = userInfo["userAttendeeID"] as? NSManagedObjectID {
                let userAttendeeID = id
                let userAttendeeModel = context.object(with: userAttendeeID) as! UserAttendees
                if let theGuid = userAttendeeModel.attendeeGuid {
                    if self.ics214Form.ics214PersonneDetail != nil {
                        let result = self.ics214Form.ics214PersonneDetail?.allObjects as! [ICS214Personnel]
                        if !result.isEmpty {
                            let theResult = result.filter { $0.userAttendeeGuid == theGuid }
                            if !theResult.isEmpty {
                                let ics214Personnel = theResult.last
                                if let objectID = ics214Personnel?.objectID {
                                    let personnelModel = context.object(with: objectID)
                                    context.delete(personnelModel)
                                    currentUASnapshot.deleteItems([userAttendeeModel])
                                    uaDataSource.apply(currentUASnapshot, animatingDifferences: true)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func configureUserAttendeesHierarchy() {
        
        attendeesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createUserAttendeesLayout())
       attendeesCollectionView.translatesAutoresizingMaskIntoConstraints = false
       attendeesCollectionView.backgroundColor = .systemBackground
       attendeesCollectionView.tag = 1
       attendeesCollectionView.delegate = self
        configureUserAttendeesDataSource()
       contentView.addSubview(attendeesCollectionView)
       NSLayoutConstraint.activate([
           attendeesCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
           attendeesCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
           attendeesCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
           attendeesCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
           
       ])
        
    }
    
    func createUserAttendeesLayout() -> UICollectionViewLayout  {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50.0))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
//            section.orthogonalScrollingBehavior = .continuous
            section.interGroupSpacing = 5
            section.contentInsets = NSDirectionalEdgeInsets(top: 0.0, leading: 5.0, bottom: 0, trailing: 20.0)
            return section
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 10
        
        let layout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider, configuration: config)
        
        return layout
    }
    
    func configureUserAttendeesDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<ICS214ResourcesCVCell, UserAttendees> { (cell, indexPath, attendees ) in
            cell.configure(attendees)
        }
        
        uaDataSource = UICollectionViewDiffableDataSource<Section, UserAttendees>(collectionView: attendeesCollectionView) { (collectionView: UICollectionView, indexPath: IndexPath, identifier: UserAttendees) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }
        
        //        let navButtons = navBarController.generateButtons()
        currentUASnapshot = NSDiffableDataSourceSnapshot < Section, UserAttendees>()
        currentUASnapshot.appendSections([.main])
        userAttendees.forEach {
            let personnel = $0
            currentUASnapshot.appendItems([personnel])
        }
        uaDataSource.apply(currentUASnapshot,animatingDifferences: false)
        
    }
    
    
}

extension ICS214ResourcesCVTVCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {

        guard let objectID = self.uaDataSource.itemIdentifier(for: indexPath)?.objectID else {
            collectionView.deselectItem(at: indexPath, animated: true)
            return UIContextMenuConfiguration(identifier: nil,
                                              previewProvider: nil,
                                              actionProvider: nil)
        }
        
        
        let previewProvider: () -> ICS214CrewEditVC? = {
            self.ics214CrewEditVC = ICS214CrewEditVC()
            let userAttendee = self.context.object(with: objectID) as! UserAttendees
            self.ics214CrewEditVC.configure(userAttendee)
            return self.ics214CrewEditVC
        }
        
        let actionProvider: ([UIMenuElement]) -> UIMenu? = { _ in
            let edit = UIAction(title: "Review Resource Crew", image: UIImage(systemName: "pencil.circle"), identifier: UIAction.Identifier(rawValue: "edit")) { _ in
                DispatchQueue.main.async {
                         self.nc.post(name: .fConEditICS214Personnel, object: nil, userInfo: ["userAttendeeID": objectID as Any])
                     }
            }
            let delete = UIAction(title: "Delete Resource Crew", image: UIImage(systemName: "xmark.circle"), identifier: UIAction.Identifier(rawValue: "delete")) { _ in
                DispatchQueue.main.async {
                         self.nc.post(name: .fConDeletionICS214Personnel, object: nil, userInfo: ["userAttendeeID": objectID as Any])
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
