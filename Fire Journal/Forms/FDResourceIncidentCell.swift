//
//  FDResourceIncidentCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 8/23/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

struct IncidentUserResource: Equatable {
    var customOrNot: Bool = false
    var imageName: String
    var type: Int64 = 0002
    var assetName: String = "GreenAvailable"
    var incidentGuid: String = ""
    init(imageName: String) {
        self.imageName = imageName
    }
}

protocol FDResourceIncidentCellDelegate: AnyObject {
    func aFDResourceHasBeenTappedForSelection(resource: IncidentUserResource)
    func aFDResourceDirectionalTapped()
    func aFDResourceInfoBTapped()
    func additionalStationApparatusCalled()
}

class FDResourceIncidentCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource  {

    @IBOutlet weak var incidentFDResourceCV: UICollectionView!
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var directionalB: UIButton!
    @IBOutlet weak var infoB: UIButton!
    var incidentOrNew: Bool = false
    @IBOutlet weak var additionalL: UILabel!
    @IBOutlet weak var addB: UIButton!
    
    
    weak var delegate: FDResourceIncidentCellDelegate? = nil
    private var incidentResources = [IncidentUserResource]()
    var fdResourcesCount: Int!
    var device: Device!
    var instantResources: [IncidentUserResource]? {
        didSet {
            self.incidentResources = self.instantResources!
        }
        willSet {
            self.incidentResources = self.instantResources ?? [IncidentUserResource]()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        device = Device.init()
        self.incidentFDResourceCV.dataSource = self
        self.incidentFDResourceCV.delegate = self
        registerCVCells()
    }
    
    @IBAction func infoBTapped(_ sender: Any) {
        delegate?.aFDResourceInfoBTapped()
    }
    
    func registerCVCells() {
        self.incidentFDResourceCV.register(UINib.init(nibName: "IncidentUserResourceCVCell", bundle: nil), forCellWithReuseIdentifier: "IncidentUserResourceCVCell")
        self.incidentFDResourceCV.register(UINib.init(nibName: "IncidentUserResourceCustomCVCell", bundle: nil), forCellWithReuseIdentifier: "IncidentUserResourceCustomCVCell")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return incidentResources.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let row = indexPath.row
        let resource = incidentResources[row]
        let custom = resource.customOrNot
        if custom {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IncidentUserResourceCustomCVCell", for: indexPath as IndexPath) as! IncidentUserResourceCustomCVCell
            if #available(iOS 13.0, *) {
                cell.backgroundColor = UIColor.clear
            } else {
                cell.backgroundColor = UIColor.clear
            }
            cell.incidentOrNew = incidentOrNew
            cell.userResource = resource
            cell.delegate = self
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IncidentUserResourceCVCell", for: indexPath as IndexPath) as! IncidentUserResourceCVCell
            if #available(iOS 13.0, *) {
                cell.backgroundColor = UIColor.clear
            } else {
                cell.backgroundColor = UIColor.clear
            }
            cell.incidentOrNew = incidentOrNew
            cell.userResource = resource
            cell.delegate = self
            return cell
        }
    }
    
    @IBAction func directionalBTapped(_ sender: Any) {
        delegate?.aFDResourceDirectionalTapped()
    }
    
    @IBAction func additionalStationApparatusBTapped(_ sender: Any) {
        delegate?.additionalStationApparatusCalled()
    }
    
    
}

extension FDResourceIncidentCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Number of cells
        let collectionViewWidth: CGFloat!
        let collectionViewHeight: CGFloat!
        if Device.IS_IPAD {
            collectionViewWidth = collectionView.bounds.width/6.0
            collectionViewHeight = collectionViewWidth+30
        } else {
            collectionViewWidth = collectionView.bounds.width/5.0
            collectionViewHeight = collectionViewWidth+30
        }
        return CGSize(width: collectionViewWidth, height: collectionViewHeight)
    }
}

extension FDResourceIncidentCell:  IncidentUserResourceCVCellDelegate {
    func incidentUserResourceCVTapped(resource: IncidentUserResource) {
        delegate?.aFDResourceHasBeenTappedForSelection(resource: resource)
    }
}

extension FDResourceIncidentCell: IncidentUserResourceCustomCVCellDelegate {
    func incidentUserResourceCustomCVTapped(resource: IncidentUserResource) {
        delegate?.aFDResourceHasBeenTappedForSelection(resource: resource)
    }
}
