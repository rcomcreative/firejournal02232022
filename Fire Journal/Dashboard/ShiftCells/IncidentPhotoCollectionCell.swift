//
//  PhotoCollectionCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/1/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit

protocol IncidentPhotoCollectionCellDelegate: AnyObject {
    func theIncidentCellHasBeenTapped(photo: Photo)
}


class IncidentPhotoCollectionCell: UITableViewCell {
    
    enum Section: CaseIterable {
        case main
    }
    
    var photoCollectionView: InteractiveCollectionView! = nil
    let backgroundGView = UIView()
    var indexPath: IndexPath!
    
    var pDataSource: UICollectionViewDiffableDataSource<Section, Photo>!
    var currentPhotoSnapshot: NSDiffableDataSourceSnapshot<Section,Photo>! = nil
    var photosA: [Photo]!
    
    weak var delegate: IncidentPhotoCollectionCellDelegate? = nil
    
    private var thePhotos = [Photo]()
    var photos = [Photo]() {
        didSet {
            self.thePhotos = self.photos
            self.photosA = self.thePhotos
        }
    }
    
    private var theIncident: Incident? = nil
    var incident: Incident? = nil {
        didSet {
            self.theIncident = self.incident
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

extension IncidentPhotoCollectionCell {
    
    func configure(index: IndexPath) {
        
        self.selectionStyle = .none
        self.indexPath = index
        self.tag = indexPath.row
     
        backgroundGView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(backgroundGView)
        
        NSLayoutConstraint.activate([
            
            backgroundGView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundGView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundGView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundGView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
        ])
        
        configureIconsHierarchy()
        
    }
    
    func configureIconsHierarchy() {
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(photoCollectionViewTapped(gr:)))
     
         tapGR.numberOfTapsRequired = 1
         photoCollectionView = InteractiveCollectionView(frame: .zero, collectionViewLayout: createIconsLayout())
         photoCollectionView.addGestureRecognizer(tapGR)
        photoCollectionView.translatesAutoresizingMaskIntoConstraints = false
        photoCollectionView.backgroundColor = .systemBackground
        photoCollectionView.tag = 1
        photoCollectionView.delegate = self
        configurePhotosDataSource()
        contentView.addSubview(photoCollectionView)
        NSLayoutConstraint.activate([
            photoCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            photoCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            photoCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
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
            delegate?.theIncidentCellHasBeenTapped(photo: photo)
        }
    }
    
}

extension IncidentPhotoCollectionCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        MARK InteractiveCollectionView works with the gesture recognizer instead
    }
    
}
