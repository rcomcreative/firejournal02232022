//
//  SettingMyFDResourcesTVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 7/25/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class SettingMyFDResourcesTVC: UITableViewController {

    let nc = NotificationCenter.default
    var titleName: String = ""
    private let vcLaunch = VCLaunch()
    private var launchNC: LaunchNotifications!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var bkgrdContext:NSManagedObjectContext!
    var fetched:Array<Any>!
    var entity:String = ""
    var attribute:String = ""
    var sortAttribute:String = ""
    var settingType:FJSettings!
    var fdResources: UserFDResources!
    var fdResourcesA = [String]()
    var subject:String = ""
    var descriptionText:String = ""
    var newEntry:String = ""
    
    var compact:SizeTrait = .regular
    var collapsed:Bool = false
    var selected: Array<String> = []
    var alertUp: Bool = false
    var theResources: Array<String>!
    var customResource: Bool = false
    var theResourceName: String = ""
    var fju: FireJournalUser!
    var count: Int = 0
    var closed: Bool = false
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        vcLaunch.splitVC = self.splitViewController
        launchNC = LaunchNotifications.init(launchVC: vcLaunch)
        launchNC.callNotifications()
        bkgrdContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        bkgrdContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: bkgrdContext)
        
        nc.addObserver(self, selector: #selector(compactOrRegular(ns:)), name:NSNotification.Name(rawValue: FJkCOMPACTORREGULAR), object: nil)
        
        tableView.register(UINib(nibName: "UserFDResourcesCell", bundle: nil), forCellReuseIdentifier: "UserFDResourcesCell")
        
        switch compact {
        case .compact:
            let button1 = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(goBackToSettings(_:)))
            let button2 = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(updateTheData(_:)))
            
            navigationItem.setLeftBarButtonItems([button1], animated: true)
            
            navigationItem.setRightBarButtonItems([button2], animated: true)
        case .regular:
            let button1 = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(goBackToSettings(_:)))
            let button2 = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(updateTheData(_:)))
            
            navigationItem.leftItemsSupplementBackButton = true
            let button3 = self.splitViewController?.displayModeButtonItem
            navigationItem.setLeftBarButtonItems([button3!, button1], animated: true)
            
            navigationItem.setRightBarButtonItems([button2], animated: true)
        }
        
        if (Device.IS_IPHONE){
            self.navigationController?.navigationBar.backgroundColor = UIColor.white
            let navigationBarAppearace = UINavigationBar.appearance()
            navigationBarAppearace.tintColor = UIColor.black
        } else {
            let navigationBarAppearace = UINavigationBar.appearance()
            navigationBarAppearace.tintColor = UIColor.black
            navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        }
    }
    
    @IBAction func updateTheData(_ sender: Any) {
        //     TODO:
    }
    
    @IBAction func goBackToSettings(_ sender: Any) {
        if collapsed {
            //            TODO:
//            delegate?.userFDResourcesBackToSettings()
        } else {
            nc.post(name:Notification.Name(rawValue:FJkSETTINGS_FROM_MASTER),object: nil, userInfo: ["sizeTrait":compact])
        }
    }
    
    @objc func compactOrRegular(ns: Notification) {
        if let userInfo = ns.userInfo as! [String: Any]?
        {
            compact = userInfo["compact"] as? SizeTrait ?? .regular
            switch compact {
            case .compact:
                print("compact SETTING DATA")
            case .regular:
                print("regular SETTING DATA")
            }
        }
        
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
