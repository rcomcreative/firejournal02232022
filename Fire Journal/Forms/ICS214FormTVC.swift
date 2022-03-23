//
//  ICS214FormTVC.swift
//  dashboard
//
//  Created by DuRand Jones on 9/4/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit

protocol ICS214FormTVCDelegate: AnyObject {
    func ics214Tapped()
}

class ICS214FormTVC: UITableViewController {
    weak var delegate:ICS214FormTVCDelegate? = nil
    var titleName:String = ""
    private let vcLaunch = VCLaunch()
    private var launchNC: LaunchNotifications!
    var controllerName:String = ""
    var myShift:MenuItems! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = titleName
        vcLaunch.splitVC = self.splitViewController
        launchNC = LaunchNotifications.init(launchVC: vcLaunch)
        launchNC.callNotifications()
        
        tableView.register(UINib(nibName: "ControllerLabelCell", bundle: nil), forCellReuseIdentifier: "ControllerLabelCell")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        launchNC.removeNC()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        
        switch row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ControllerLabelCell", for: indexPath) as! ControllerLabelCell
            cell.controllerL.text = "NIMS ICS 214"
            cell.incidentEditB.isHidden = true
            cell.incidentEditB.alpha = 0.0
            cell.incidentEditB.isEnabled = false
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! startShiftOvertimeSwitchCell
            return cell
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
