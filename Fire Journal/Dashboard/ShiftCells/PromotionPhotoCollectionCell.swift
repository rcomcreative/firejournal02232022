//
//  PromotionPhotoCollectionCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/22/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//


import Foundation
import UIKit
import CoreData

protocol PromotionPhotoCollectionCellDelegate: AnyObject {
    func thePromotionCellHasBeenTapped(photo: Photo)
    func thePromotionPhotoCellObjectID(objectID: NSManagedObjectID)
}

class PromotionPhotoCollectionCell: UITableViewCell {
    
    weak var delegate: PromotionPhotoCollectionCellDelegate? = nil
    
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
    
    private var thePhotos = [Photo]()
    var photos = [Photo]() {
        didSet {
            self.thePhotos = self.photos
            self.photosA = self.thePhotos
        }
    }
    
    private var theProject: PromotionJournal? = nil
    var project: PromotionJournal? = nil {
        didSet {
            self.theProject = self.project
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
