//
//  UpdateShiftEditResourceVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 11/5/19.
//  Copyright © 2019 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class UpdateShiftEditResourceVC: UIViewController {

    
        //    MARK: -Objects-
    @IBOutlet weak var updateShiftEditResourceV: UIView!
    @IBOutlet weak var saveB: UIButton!
        @IBOutlet weak var cancelB: UIButton!
        @IBOutlet weak var resourceIconIV: UIImageView!
        @IBOutlet weak var resourceStatusIV: UIImageView!
        @IBOutlet weak var resourceSegment: UISegmentedControl!
        @IBOutlet weak var title1L: UILabel!
        @IBOutlet weak var title1TeamTF: UITextField!
        @IBOutlet weak var title1EditB: UIButton!
        @IBOutlet weak var title2L: UILabel!
        @IBOutlet weak var title2TeamTF: UITextField!
        @IBOutlet weak var title2EditB: UIButton!
        @IBOutlet weak var title3L: UILabel!
        @IBOutlet weak var title3TeamTF: UITextField!
        @IBOutlet weak var tile3EditB: UIButton!
        @IBOutlet weak var title4L: UILabel!
        @IBOutlet weak var title4TeamTF: UITextField!
        @IBOutlet weak var tile4EditB: UIButton!
        @IBOutlet weak var title5L: UILabel!
        @IBOutlet weak var title5TeamTF: UITextField!
        @IBOutlet weak var tile5EditB: UIButton!
        @IBOutlet weak var title6L: UILabel!
        @IBOutlet weak var title6TeamTF: UITextField!
        @IBOutlet weak var tile6EditB: UIButton!
        @IBOutlet weak var title1StackView: UIStackView!
        @IBOutlet weak var title2StackView: UIStackView!
        @IBOutlet weak var title3StackView: UIStackView!
        @IBOutlet weak var title4StackView: UIStackView!
        @IBOutlet weak var title5StackView: UIStackView!
        @IBOutlet weak var title6StackView: UIStackView!
    
        //    MARK: -Properties-
        var count: Int = 0
         let userDefaults = UserDefaults.standard
         var context:NSManagedObjectContext?
         let nc = NotificationCenter.default
        

        override func viewDidLoad() {
            super.viewDidLoad()
            
            nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
            // Do any additional setup after loading the view.
        }
        
    //     MARK: -
    //        MARK: Notification Handling
           @objc func managedObjectContextDidSave(notification: Notification) {
               DispatchQueue.main.async {
                self.context?.mergeChanges(fromContextDidSave: notification)
               }
           }
    
    //    MARK: -ACTIONS-
    @IBAction func cancelBTapped(_ sender: UIButton) {
    }
    @IBAction func saveBTapped(_ sender: UIButton) {
    }
    @IBAction func segmentTapped(_ sender: UISegmentedControl) {
    }
    @IBAction func title1EditBTapped(_ sender: UIButton) {
    }
    @IBAction func title2EditBTapped(_ sender: UIButton) {
    }
    @IBAction func title3EditBTapped(_ sender: UIButton) {
    }
    @IBAction func title4EditBTapped(_ sender: UIButton) {
    }
    @IBAction func title5EditBTapped(_ sender: UIButton) {
    }
    @IBAction func title6EditBTapped(_ sender: UIButton) {
    }
    

}

extension UpdateShiftEditResourceVC: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
//        MARK: -TOD0-
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//        MARK: -TODO-
        return true
    }
}
