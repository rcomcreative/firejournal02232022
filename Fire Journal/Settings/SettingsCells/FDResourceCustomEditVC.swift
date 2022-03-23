//
//  FDResourceCustomEditVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 10/12/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol  FDResourceCustomEditVCDelegate: AnyObject {
    func fdResourceCustomEditCancelTapped()
    func fdResourceCustomEditSaveTapped(resource: UserFDResources)
}

class FDResourceCustomEditVC: UIViewController {

    //    MARK: -Objects-
     @IBOutlet weak var subjectL: UILabel!
     @IBOutlet weak var resourceIV: UIImageView!
     @IBOutlet weak var fdResouceCustomL: UILabel!
     @IBOutlet weak var resourceNameTF: UITextField!
     @IBOutlet weak var accessIV: UIImageView!
     @IBOutlet weak var resourceSegment: UISegmentedControl!
     @IBOutlet weak var cancelB: UIButton!
     @IBOutlet weak var saveB: UIButton!
     @IBOutlet weak var resourceV: UIView!
     
     //    MARK: -Properties-
     weak var delegate: FDResourceCustomEditVCDelegate? = nil
     var customOrNot: Bool = false
     var imageType: theFDResources = .FJkFDRESOURCE_AC1
     var type: Int64 = 0002
     var redSelectedOrNot: Bool = false
     var image: String = ""
     var imageName: String = ""
     var customImage: String = ""
     var name: String = ""
     var labelName: String = ""
     
     override func viewDidLoad() {
         super.viewDidLoad()
                 switch type {
                         case 0001: break
                         case 0002:
                             self.resourceSegment.selectedSegmentIndex = 0
                         case 0003:
                             self.resourceSegment.selectedSegmentIndex = 1
                         case 0004:
                             self.resourceSegment.selectedSegmentIndex = 2
                         default: break
                         }
        if labelName.count > 6 {
            self.fdResouceCustomL.font = fdResouceCustomL.font.withSize(10)
            self.fdResouceCustomL.adjustsFontSizeToFitWidth = true
            self.fdResouceCustomL.lineBreakMode = NSLineBreakMode.byWordWrapping
            self.fdResouceCustomL.numberOfLines = 0
            self.fdResouceCustomL.setNeedsDisplay()
        }
         fdResouceCustomL.text = labelName
         let imaged = UIImage(named:image)
         resourceIV.image = imaged
         let customI = UIImage(named:customImage)
         accessIV.image = customI
//         resourceNameTF.text = name
        
         roundViews()
     }
     
     func roundViews() {
         resourceV.layer.cornerRadius = 10
         resourceV.clipsToBounds = true
     }
     
     var fdResources: UserFDResources? {
         didSet {
                let customImageName:String = "RESOURCEWHITE"
                self.image = customImageName
                 let type:Int64 = self.fdResources!.fdResourceType
                 self.type = type
                 var imageName = ""
                 switch type {
                 case 0001:
                     imageName = "RedSelectedCHECKED"
                 case 0002:
                     imageName = "GreenAvailable"
                     self.imageName = imageName
                 case 0003:
                     imageName = "YellowConditional"
                     self.imageName = imageName
                 case 0004:
                     imageName = "BlackOutOfService"
                     self.imageName = imageName
                 default: break
                 }
                 self.customImage = imageName
                 if let name: String = self.fdResources!.fdResource {
                     self.name = name
                 }
            var labelName = ""
            if let name: String = self.fdResources!.fdResource {
            
                if name.count > 6 {
                    labelName = name.replacingOccurrences(of: " ", with: "\n")
                } else {
                    labelName = name
                }
                self.labelName = labelName
            }
             
         }
     }
     
     @IBAction func segmentTapped(_ sender: UISegmentedControl) {
         var imageName = ""
         switch resourceSegment.selectedSegmentIndex
         {
         case 0:
             type = 0
             imageName = "GreenAvailable"
             fdResources?.fdResourceType = 0002
         case 1:
             type = 1
             imageName = "YellowConditional"
             fdResources?.fdResourceType = 0003
         case 2:
             type = 2
             imageName = "BlackOutOfService"
             fdResources?.fdResourceType = 0004
         default:
             break;
         }
         let customImage = UIImage(named: imageName)
         self.accessIV.image = customImage
     }
     
    
     @IBAction func saveBTapped(_ sender: Any) {
        delegate?.fdResourceCustomEditSaveTapped(resource: fdResources!)
     }
     @IBAction func cancelBTapped(_ sender: Any) {
        delegate?.fdResourceCustomEditCancelTapped()
     }

}
