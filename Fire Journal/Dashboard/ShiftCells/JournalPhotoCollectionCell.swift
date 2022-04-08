//
//  JournalPhotoCollectionCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/1/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData


protocol JournalPhotoCollectionCellDelegate: AnyObject {
    func theJournalCellHasBeenTapped(photo: Photo)
    func thePhotoCellObjectID(objectID: NSManagedObjectID)
}

class JournalPhotoCollectionCell: UITableViewCell {
    
    enum Section: CaseIterable {
        case main
    }
    
    
    lazy var photoProvider: PhotoProvider = {
        let provider = PhotoProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var taskContext: NSManagedObjectContext!
    
    lazy var spinner: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = UIColor(named: "FXROrange")
        indicator.hidesWhenStopped = true
        return indicator
    }()

    
    var photoCollectionView: UICollectionView!
//    let backgroundGView = UIView()
    var indexPath: IndexPath!
    
    var pDataSource: UICollectionViewDiffableDataSource<Section, Photo>!
    var currentPhotoSnapshot: NSDiffableDataSourceSnapshot<Section,Photo>! = nil
    var photosA: [Photo]!
    
    weak var delegate: JournalPhotoCollectionCellDelegate? = nil
    
    private var thePhotos = [Photo]()
    var photos = [Photo]() {
        didSet {
            self.thePhotos = self.photos
            self.photosA = self.thePhotos
        }
    }
    
    private var theJournal: Journal? = nil
    var journal: Journal? = nil {
        didSet {
            self.theJournal = self.journal
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension JournalPhotoCollectionCell {
    
    func configure(index: IndexPath) {
        
        self.selectionStyle = .none
        self.indexPath = index
        self.tag = indexPath.row
    
        
        configureIconsHierarchy()
        
    }
    
    func configureIconsHierarchy() {

        photoCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createIconsLayout())
        photoCollectionView.translatesAutoresizingMaskIntoConstraints = false
        photoCollectionView.backgroundColor = .systemBackground
        photoCollectionView.tag = 1
        photoCollectionView.delegate = self
        configurePhotosDataSource()
        contentView.addSubview(photoCollectionView)
        NSLayoutConstraint.activate([
            photoCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            photoCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 26),
            photoCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -26),
            photoCollectionView.heightAnchor.constraint(equalToConstant: 100),
            
        ])
    }
    
    func createIconsLayout() -> UICollectionViewLayout  {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(70.0), heightDimension: .absolute(70.0))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.interGroupSpacing = 5
            section.contentInsets = NSDirectionalEdgeInsets(top: 0.0, leading: 5.0, bottom: 0, trailing: 20.0)
            return section
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        
        let layout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider, configuration: config)
        
        return layout
    }
    
    func configurePhotosDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<PhotoCCell, Photo> { (cell, indexPath, photo ) in
            cell.configure(thePhotos: photo)
        }
        
        pDataSource = UICollectionViewDiffableDataSource<Section, Photo>(collectionView: photoCollectionView) { (collectionView: UICollectionView, indexPath: IndexPath, identifier: Photo) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }
        
        //        let navButtons = navBarController.generateButtons()
        currentPhotoSnapshot = NSDiffableDataSourceSnapshot < Section, Photo>()
        currentPhotoSnapshot.appendSections([.main])
        photosA.forEach {
            let photo = $0
            currentPhotoSnapshot.appendItems([photo])
        }
        pDataSource.apply(currentPhotoSnapshot,animatingDifferences: false)
        
    }
    
   @objc  func photoCollectionViewTapped(gr: UITapGestureRecognizer) {
        let point = gr.location(in: self.photoCollectionView)
        if let indexPath = self.photoCollectionView.indexPathForItem(at: point) {
            guard let cell = self.photoCollectionView.cellForItem(at: indexPath) as? PhotoCCell else { return }
            guard let photo = cell.thePhoto else { return  }
            delegate?.theJournalCellHasBeenTapped(photo: photo)
        }
    }
    
}

extension JournalPhotoCollectionCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PhotoCCell else { return }
        if cell.objectID != nil {
            guard let id = cell.objectID else { return }
            delegate?.thePhotoCellObjectID(objectID: id)
        }
 
        
    }
    
}
