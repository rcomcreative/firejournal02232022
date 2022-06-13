//
//  MasterViewController+TVCExtensions.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/23/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import StoreKit

extension MasterViewController {
    
    //    MARK: -REGISTERTABLECELLS-
    func registerCells() {
        tableView.register(UINib(nibName: "MyShiftCell", bundle: nil), forCellReuseIdentifier: "MyShiftCell")
        tableView.register(UINib(nibName: "FlameLogoCell", bundle: nil), forCellReuseIdentifier: "FlameLogoCell")
    }
    
        // MARK: - Table View

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        switch row {
        case 0,1,2,3,4,5,6,7,8,9:
            return 110
        default:
            return 200
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 11
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        print("here is the row \(row)")
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        switch row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyShiftCell", for: indexPath) as! MyShiftCell
            configureCell(cell, withMyShift: .myShift)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyShiftCell", for: indexPath) as! MyShiftCell
            configureCell(cell, withMyShift: .journal)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyShiftCell", for: indexPath) as! MyShiftCell
            configureCell(cell, withMyShift: .incidents)
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyShiftCell", for: indexPath) as! MyShiftCell
            configureCell(cell, withMyShift: .projects)
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyShiftCell", for: indexPath) as! MyShiftCell
            configureCell(cell, withMyShift: .maps)
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyShiftCell", for: indexPath) as! MyShiftCell
            configureCell(cell, withMyShift: .forms)
            return cell
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyShiftCell", for: indexPath) as! MyShiftCell
            configureCell(cell, withMyShift: .cloud)
            return cell
        case 7:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyShiftCell", for: indexPath) as! MyShiftCell
            configureCell(cell, withMyShift: .store)
            return cell
        case 8:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyShiftCell", for: indexPath) as! MyShiftCell
            configureCell(cell, withMyShift: .settings)
            return cell
        case 9:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyShiftCell", for: indexPath) as! MyShiftCell
            configureCell(cell, withMyShift: .support)
            return cell
        case 10:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FlameLogoCell", for: indexPath) as! FlameLogoCell
            cell.delegate = self
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            return cell
        }
    }

    func configureCellLogo(_ cell: MyShiftCell) {
        
    }
        ///
        ///    CONFIGURE THE CELLS FOR TABLE
        /// - Parameters:
        ///        - cell: MyShiftCell
        ///        - withMyShift: MenuItems
        ///
        /// - Note
        ///    menu bar with image and template icon both tinted
        ///
    func configureCell(_ cell: MyShiftCell, withMyShift shift: MenuItems ) {
        switch horizontalClass {
        case 1:
            compact = .compact
        case 2 :
            compact = .regular
        default : break
        }
        switch verticalClass {
        case 1:
            compact = .compact
        case 2 :
            compact = .regular
        default :break
        }
        
            //        let tintColor = UIColor(red:0.04, green:0.32, blue:0.68, alpha:1.00)
        let tintColor = UIColor.label
        let imageTintColor = UIColor(named: "FJBlueColor")
        
        let backgroundBar = UIImage(named: "MenuBar-White")
        backgroundBar?.withTintColor(tintColor)
        cell.delegate = self
        cell.myShift = shift
        switch shift {
        case .myShift:
            let backgroundI = UIImage(named: "ICONS_Dashboard White")
            
            if let image = backgroundI {
                cell.myShiftIV.image = image
                cell.myShiftIV.tintColor = imageTintColor
            }
            
            backgroundI?.withTintColor(tintColor)
            cell.myShiftIV.image = backgroundI
            
            cell.myShiftL.textColor = tintColor
            cell.myShiftL.text = "Home"
        case .journal:
            let backgroundI = UIImage(named: "ICONS_stationboard white")
            
            if let image = backgroundI {
                cell.myShiftIV.image = image
                cell.myShiftIV.tintColor = imageTintColor
            }
            
            backgroundI?.withTintColor(tintColor)
            cell.myShiftIV.image = backgroundI
            
            cell.myShiftL.textColor = tintColor
            cell.myShiftL.text = "Journal"
        case .incidents:
            let backgroundI = UIImage(named: "ICONS_06092022_IncidentForm_white")
            
            if let image = backgroundI {
                cell.myShiftIV.image = image
                cell.myShiftIV.tintColor = imageTintColor
            }
            
            backgroundI?.withTintColor(tintColor)
            cell.myShiftIV.image = backgroundI
            
            cell.myShiftL.textColor = tintColor
            cell.myShiftL.text = "Incidents"
        case .projects:
            let backgroundI = UIImage(named: "ICONS_04202022_traing_white")
            
            if let image = backgroundI {
                cell.myShiftIV.image = image
                cell.myShiftIV.tintColor = imageTintColor
            }
            
            backgroundI?.withTintColor(tintColor)
            cell.myShiftIV.image = backgroundI
            
            cell.myShiftL.textColor = tintColor
            cell.myShiftL.text = "Projects"
        case .maps:
            let backgroundI = UIImage(named: "ICONS_map white")
            
            if let image = backgroundI {
                cell.myShiftIV.image = image
                cell.myShiftIV.tintColor = imageTintColor
            }
            
            backgroundI?.withTintColor(tintColor)
            cell.myShiftIV.image = backgroundI
            
            cell.myShiftL.textColor = tintColor
            cell.myShiftL.text = "Maps"
        case .forms:
            let backgroundI = UIImage(named: "ICONS_Forms white")
            
            if let image = backgroundI {
                cell.myShiftIV.image = image
                cell.myShiftIV.tintColor = imageTintColor
            }
            
            backgroundI?.withTintColor(tintColor)
            cell.myShiftIV.image = backgroundI
            
            cell.myShiftL.textColor = tintColor
            cell.myShiftL.text = "Forms"
        case .settings:
            let backgroundI = UIImage(named: "ICONS_Settings white")
            
            if let image = backgroundI {
                cell.myShiftIV.image = image
                cell.myShiftIV.tintColor = imageTintColor
            }
            
            backgroundI?.withTintColor(tintColor)
            cell.myShiftIV.image = backgroundI
            
            cell.myShiftL.textColor = tintColor
            cell.myShiftL.text = "Settings"
        case .store:
            let backgroundI = UIImage(named: "ICONS_store-white")
            
            if let image = backgroundI {
                cell.myShiftIV.image = image
                cell.myShiftIV.tintColor = imageTintColor
            }
            
            backgroundI?.withTintColor(tintColor)
            cell.myShiftIV.image = backgroundI
            
            cell.myShiftL.textColor = tintColor
            cell.myShiftL.text = "Store"
        case .cloud:
            let backgroundI = UIImage(named: "ICONS_cloud white")
            
            if let image = backgroundI {
                cell.myShiftIV.image = image
                cell.myShiftIV.tintColor = imageTintColor
            }
            
            backgroundI?.withTintColor(tintColor)
            cell.myShiftIV.image = backgroundI
            
            cell.myShiftL.textColor = tintColor
            cell.myShiftL.text = "Membership"
        case .support:
            let backgroundI = UIImage(named: "ICONS_support-white")
            
            if let image = backgroundI {
                cell.myShiftIV.image = image
                cell.myShiftIV.tintColor = imageTintColor
            }
            
            backgroundI?.withTintColor(tintColor)
            cell.myShiftIV.image = backgroundI
            
            cell.myShiftL.textColor = tintColor
            cell.myShiftL.text = "Support"
        default:
            print("default")
        }
        cell.myShiftBarIV.image = backgroundBar
        cell.myShiftBarIV.tintColor = .label
    }
    
}
