//
//  PhotosTVCell.swift
//  dashboard
//
//  Created by DuRand Jones on 9/11/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit

protocol PhotoTVCellDelegate: AnyObject {
    func cameraButtonTapped()
}

class PhotosTVCell: UITableViewCell {
    //    MARK: -objects
    @IBOutlet weak var iconB: UIButton!
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var photoCV: UICollectionView!
    //    MRRK: -properties
    var myShift:MenuItems!
    var delegate:PhotoTVCellDelegate? = nil
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //    MARK: -button action
    @IBAction func cameraBTapped(_ sender: Any) {
    }
    
}
