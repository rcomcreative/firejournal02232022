  //
//  SettimgsMyFireEMSResourcesEditVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 1/23/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class MyFireEMSResourcesList {
    let myFireEMSResource:String //fdResource
    var myFireEMSGuid:String // fdResourceGuid
    var myObjectID: NSManagedObjectID // UserFDResource.objectID
    var myFireEMSCustom: Bool //customResource
    var myFireEMSResourceType = 0002 // 0001,0003,0004  fdResourceType
    var myFireEMSManufacturer = "" //fdManufacturer
    var myFireEMSApparatus = "" //  fdResourceApparatus
    var myFireEMSDescription = "" //fdResourceDescription
    var myFireEMSImageName = "" //fdResourceImageName
    var myPersonnelCount: Int
    var myFireEMSPersonnelCount: String  // fdResourcesPersonnelCount
    var myFireEMSSpecialties = "" //fdResourcesSpecialties
    var myFireEMSShopNumber = "" //fdShopNumber
    init(resource: String,guid: String, objectID: NSManagedObjectID, custom: Bool, count: Int? = nil ) {
        self.myFireEMSResource = resource
        self.myFireEMSGuid = guid
        self.myObjectID = objectID
        self.myFireEMSCustom = custom
        self.myPersonnelCount = count ?? 0
        self.myFireEMSPersonnelCount = String(self.myPersonnelCount)
    }
  }

class SettimgsMyFireEMSResourcesEditVC: UIViewController {
    @IBOutlet weak var fireEMSResourcesEditTV: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
