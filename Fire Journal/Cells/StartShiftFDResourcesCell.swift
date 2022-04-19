//
//  StartShiftFDResourcesCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 8/12/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol StartShiftFDResourcesCellDelegate: AnyObject {
    func aResourceHasBeenTappedForEditing(resource: UserFDResources)
}

class StartShiftFDResourcesCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var startShiftCV: UICollectionView!
    var fdResources  = [UserFDResources]()
    var fdResourcesCount: Int!
    weak var delegate: StartShiftFDResourcesCellDelegate? = nil
    var device: Device!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        device = Device.init()
        self.startShiftCV.dataSource = self
        self.startShiftCV.delegate = self
        self.startShiftCV.register(UINib.init(nibName: "UserFDResourceCustomEditCVCell", bundle: nil), forCellWithReuseIdentifier: "UserFDResourceCustomEditCVCell")
        self.startShiftCV.register(UINib.init(nibName: "UserFDResouceEditCVCell", bundle: nil), forCellWithReuseIdentifier: "UserFDResouceEditCVCell")
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fdResources.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let row = indexPath.row
        let resource = fdResources[row]
        let custom = resource.customResource
        if custom {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserFDResourceCustomEditCVCell", for: indexPath as IndexPath) as! UserFDResourceCustomEditCVCell
            cell.userFDResource = fdResources[row]
            cell.delegate = self
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserFDResouceEditCVCell", for: indexPath as IndexPath) as! UserFDResouceEditCVCell
            cell.delegate = self
            cell.fdResource = fdResources[row]
//            print(cell)
            return cell
        }
    }
    
    
}

extension StartShiftFDResourcesCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Number of cells
        let collectionViewWidth: CGFloat!
        let collectionViewHeight: CGFloat!
        if Device.IS_IPAD {
           collectionViewWidth = collectionView.bounds.width/5.0
           collectionViewHeight = collectionViewWidth+10
        } else {
           collectionViewWidth = collectionView.bounds.width/4.0
           collectionViewHeight = collectionViewWidth+20
        }
        return CGSize(width: collectionViewWidth, height: collectionViewHeight)
    }
}

extension StartShiftFDResourcesCell: UserFDResouceEditCVCellDelegate {
    func editBTapped(resource: UserFDResources) {
        let resourced = resource.fdResource ?? ""
        print("not custom tapped \(resourced)")
        delegate?.aResourceHasBeenTappedForEditing(resource: resource)
    }
}

extension StartShiftFDResourcesCell: UserFDResourceCustomEditCVCellDelegate {
    func editBWasTapped(tag: Int, resource: UserFDResources) {
        let resourced = resource.fdResource ?? ""
        print("custom tapped \(resourced)")
        delegate?.aResourceHasBeenTappedForEditing(resource: resource)
    }
}
