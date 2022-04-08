//
//  IncidentTagsCViewTVCell.swift
//  StationCommand
//
//  Created by DuRand Jones on 1/11/22.
//

import Foundation
import UIKit
import CloudKit
import CoreData

class IncidentTagsCViewTVCell: UITableViewCell {
    
    var tagCollectionView:UICollectionView!
    var tagDataSource: UICollectionViewDiffableDataSource<Section, Tag>!
    var currentTagSnapshot: NSDiffableDataSourceSnapshot<Section,Tag>! = nil
    var theTagArray = [Tag]()
    var platoonColor: String = "FJIconRed"
    var theColor: UIColor!
    var theIncident: Incident!
    var theJournal: Journal!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension IncidentTagsCViewTVCell {
    
    func configure(theIncident: Incident ) {
        self.theIncident = theIncident
        buildTheTags()
        if theTagArray.isEmpty {} else {
            configureTagHierarchy()
        }
    }
    
    func buildTheTags() {
        
        if let incidentTags = theIncident.tags?.allObjects as? [Tag] {
            theTagArray = incidentTags
        }
        
        if theIncident.incidentInfo != nil {
            theJournal = theIncident.incidentInfo
            
            let platoon = theJournal.journalTempPlatoon
            if platoon == "A Platoon" {
                if let theColor = UIColor(named: "FJIconRed") {
                    platoonColor = "FJIconRed"
                    self.theColor = theColor
                }
            } else if platoon == "B Platoon" {
                if let theColor = UIColor(named: "FJBlueColor") {
                    platoonColor = "FJBlueColor"
                    self.theColor = theColor
                }
            } else if platoon == "C Platoon" {
                if let theColor = UIColor(named: "FJGreenColor") {
                    platoonColor = "FJGreenColor"
                    self.theColor = theColor
                }
            } else if platoon == "D Platoon" {
                    if let theColor = UIColor(named: "FJGoldColor") {
                        platoonColor = "FJGoldColor"
                        self.theColor = theColor
                    }
            }
        }
    }
    
    func configureTagHierarchy() {
        tagCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        tagCollectionView.translatesAutoresizingMaskIntoConstraints = false
        tagCollectionView.backgroundColor = .systemBackground
        tagCollectionView.tag = 1
        createDataSource()
        contentView.addSubview(tagCollectionView)
        NSLayoutConstraint.activate([
            tagCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            tagCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            tagCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            tagCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            
        ])
    }
    
    func createLayout()  -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.2),
                                                  heightDimension: .fractionalHeight(0.5))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
            
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.50))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 0
            section.contentInsets = NSDirectionalEdgeInsets(top: 0.0, leading: 0.0, bottom: 0, trailing: 0.0)
            return section
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 0
        
        let layout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider, configuration: config)
        
        return layout
    }
    
    func createDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<TagsCVCell,Tag> { (cell, indexPath, tag ) in
                cell.configure(tag: tag, platoonColor: self.platoonColor)
            }
        
        tagDataSource = UICollectionViewDiffableDataSource<Section, Tag>(collectionView:  tagCollectionView) { (collectionView: UICollectionView, indexPath: IndexPath, identifier: Tag) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }
        
        //        let navButtons = navBarController.generateButtons()
        currentTagSnapshot = NSDiffableDataSourceSnapshot < Section, Tag>()
        currentTagSnapshot.appendSections([.main])
        theTagArray.forEach {
            let row = $0
            currentTagSnapshot.appendItems([row])
        }
        tagDataSource.apply(currentTagSnapshot,animatingDifferences: false)
    }
    
}
