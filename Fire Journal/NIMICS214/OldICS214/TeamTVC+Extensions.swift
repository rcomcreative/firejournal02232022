//
//  TeamTVC+Extensions.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/29/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import CoreData
import Contacts
import ContactsUI

//      MARK: -ARRAY EXTENSION-
extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        guard let index = firstIndex(of: object) else {return}
        remove(at: index)
    }
    
}

//      MARK: -ContactsCellDelegate -
extension TeamTVC: ContactsCellDelegate {
    func contactTapped() {
        
        let segue = "ToContactsListSegue"
        performSegue(withIdentifier: segue, sender: self)
        
    }
    func resourceTapped() {
        
    }
    func saveTapped(array: Array<Array<String>>) {
        
    }
    func cancelTapped() {
        
    }
    func newEntryHasBegun() {
        
        if !(buttonAdded) {
            let header = "Tap the button next to Name to add contacts from your contacts or add a name, ICS\nPosition and Home Agency"
            let date = Date()
            let obID = NSManagedObjectID()
            let cell00 = ICS214TeamCell2.init(header: header, date: date, id:obID)
            
            let i:Int = theCells.firstIndex(where: { $0.tag == 1 })!
            let d:Int = i+1
            theCells.insert(cell00, at: d)
            buttonAdded = true
            self.tableView.reloadData()
        }
        
    }
    
}

extension TeamTVC: AddButtonCellDelegate {
    
    func theAddContactButtonTapped(indexPath: IndexPath) {
        let cellChecked = tableView.cellForRow(at: indexPath) as! ContactsCell
        var name = ""
        var icsPosition = ""
        var homeAgency = ""
        if (cellChecked.inputOneTF.text) != nil {
            name = cellChecked.inputOneTF.text!
        }
        if (cellChecked.inputTwoTF.text) != nil {
            icsPosition = cellChecked.inputTwoTF.text!
        }
        if (cellChecked.inputThreeTF.text) != nil {
            homeAgency = cellChecked.inputThreeTF.text!
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserAttendees")
        fetchRequest.predicate = NSPredicate(format: "attendee == %@", name)
        do {
            let fetchedAttendee = try context.fetch(fetchRequest) as! [UserAttendees]
            
            
            if fetchedAttendee.count == 0 {
                let icsDate = Date()
                var uuidUA:String = NSUUID().uuidString.lowercased()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "YYYYDDDHHmmAAAAAAAA"
                let dateFrom = dateFormatter.string(from: icsDate)
                uuidUA = uuidUA+dateFrom
                let userAttendee = UserAttendees.init(entity: NSEntityDescription.entity(forEntityName: "UserAttendees", in: context)!, insertInto: context)
                userAttendee.attendee = name
                userAttendee.attendeeEmail = ""
                userAttendee.attendeePhone = ""
                userAttendee.attendeeICSPosition = icsPosition
                userAttendee.attendeeHomeAgency = homeAgency
                userAttendee.attendeeModDate = icsDate
                userAttendee.attendeeBackUp = false
                userAttendee.attendeeGuid = uuidUA
                userAttendee.attendeeBackUp = false
                
                var members3 = [userAttendee]
                for user in members2 {
                    members3.append(user)
                }
                members2.removeAll()
                members2 = members3.sorted(by: {$0.attendee! > $1.attendee!})
                
                do {
                    try context.save()
                    DispatchQueue.main.async {
                        self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"Team TVC merge that"])
                    }
                } catch {
                    
                    let nserror = error as NSError
                    
                    let errorMessage = "TeamTVC theAddContactButtonTapped() fetchRequest \(fetchRequest) Unresolved error \(nserror)"
                    print(errorMessage)
                    
                }
            }
            
        }catch {
            
            let nserror = error as NSError
            
            let errorMessage = "TeamTVC theAddContactButtonTapped() fetchRequest \(fetchRequest) Unresolved error \(nserror)"
            print(errorMessage)
            
        }
        theCells.removeAll()
        theCells = cellsFromData.teamCells
        
        for user in members2 {
            var name = ""
            var email = ""
            var phone = ""
            var agency = ""
            var position = ""
            var guid = ""
            if user.attendee != nil {
                name = user.attendee!
            }
            if user.attendeeEmail != nil {
                email = user.attendeeEmail!
            }
            if user.attendeeICSPosition != nil {
                position = user.attendeeICSPosition!
            }
            if user.attendeePhone != nil {
                phone = user.attendeePhone!
            }
            if user.attendeeHomeAgency != nil {
                agency = user.attendeeHomeAgency!
            }
            if user.attendeeGuid != nil {
                guid = user.attendeeGuid!
            }
            
            
            let attendee1 = ICS214Resources.init(resource: [ "name":name ], icsPosition: [ "icsPosition": position ], agency: [ "agency":agency ], email: [ "email":email ], phone: [ "phone":phone ], resourceGuid: [ "guid":guid ])
            ics214resources.append(attendee1)
            
            let header = ""
            let date = Date()
            let obID = NSManagedObjectID()
            let cell00 = ICS214TeamCell3.init(header: header, date: date, id:obID)
            cell00.field1 = name
            cell00.field2 = email
            cell00.field3 = phone
            let i:Int = theCells.firstIndex(where: { $0.tag == 1 })!
            let d:Int = i+1
            theCells.insert(cell00, at: d)
        }
        self.tableView.reloadData()
        
    }
    
}

//      MARK: -CONTACTSTVCDelegate-
extension TeamTVC: ContactsTVCDelegate {
    
    func contactsCancelBTapped(){
        navigationController?.popViewController(animated: true)
    }
    
    func contactsSaveBTapped(team: [Resource]) {
        navigationController?.popViewController(animated: true)
        for resource in team {
            let type:Resource = resource
            var name:String = type.contact["name"]!
            let email:String = type.contact["email"]!
            let phone:String = type.contact["phone"]!
            name = name.trimmingCharacters(in: .whitespaces)
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserAttendees")
            let predicate1 = NSPredicate(format: "attendee == %@", name)
            let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate1])
            fetchRequest.predicate = predicateCan
            do {
                let fetchedAttendee = try context.fetch(fetchRequest) as! [UserAttendees]
                if fetchedAttendee.count == 0 {
                    let icsDate = Date()
                    var uuidUA:String = NSUUID().uuidString.lowercased()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "YYYYDDDHHmmAAAAAAAA"
                    let dateFrom = dateFormatter.string(from: icsDate)
                    uuidUA = uuidUA+dateFrom
                    let userAttendee = UserAttendees.init(entity: NSEntityDescription.entity(forEntityName: "UserAttendees", in: context)!, insertInto: context)
                    userAttendee.attendee = name
                    userAttendee.attendeeEmail = email
                    userAttendee.attendeePhone = phone
                    userAttendee.attendeeModDate = icsDate
                    userAttendee.attendeeBackUp = false
                    userAttendee.attendeeGuid = uuidUA
                    userAttendee.attendeeBackUp = false
                    
                    do {
                        try context.save()
                        DispatchQueue.main.async {
                            self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"Team TVC merge that"])
                        }
                    } catch {
                        
                        let nserror = error as NSError
                        
                        let errorMessage = "TeamTVC contactsSaveBTapped() fetchRequest \(fetchRequest) Unresolved error \(nserror)"
                        print(errorMessage)
                        
                    }
                    
                    chosenMembers.append(userAttendee)
                    print(chosenMembers)
                    
                    if userAttendee.attendee != nil {
                        
                        
                        let header = ""
                        let date = Date()
                        let obID = NSManagedObjectID()
                        let cell00 = ICS214TeamCell3.init(header: header, date: date, id:obID)
                        cell00.field1 = userAttendee.attendee ?? ""
                        cell00.field2 = userAttendee.attendeeICSPosition ?? ""
                        cell00.field3 = userAttendee.attendeeHomeAgency ?? ""
                        cell00.field4 = userAttendee.attendeeEmail ?? ""
                        cell00.cellValue1 = userAttendee.attendeePhone ?? ""
                        cell00.cellValue2 = userAttendee.attendeeGuid ?? ""
                        let i:Int = theCells.firstIndex(where: { $0.tag == 1 })!
                        let d:Int = i+1
                        theCells.insert(cell00, at: d)
                        
                    }
                } else {
                    print("fetched 1 too many")
                }
                
            }catch {
                
                let nserror = error as NSError
                
                let errorMessage = "TeamTVC contactsSaveBTapped()2 fetchRequest \(fetchRequest) Unresolved error \(nserror)"
                print(errorMessage)
                
            }
            
        }
        
        
        var theGathered = [CellStorage]()
        var theStationary = [CellStorage]()
        for cells in theCells {
            if cells.tag == 3 {
                theGathered.append(cells)
            } else {
                theStationary.append(cells)
            }
        }
        theCells.removeAll()
        theCells = theStationary
        theGathered = theGathered.sorted(by: { $0.field1 > $1.field1 })
        for cell in theGathered {
            let i:Int = theCells.firstIndex(where: { $0.tag == 1 })!
            let d:Int = i+1
            theCells.insert(cell, at: d)
        }
        self.tableView.reloadData()
    }
    
}

extension TeamTVC: CompletedThreeFieldExpandedCellDelegate {
    
    func nameFieldEdited(string:String, indexPath:IndexPath) {
        
    }
    
    func positionFieldEdited(position:String, indexPath:IndexPath) {
        
        let icsPosition = position
        let cellChecked = tableView.cellForRow(at: indexPath) as! CompletedThreeFieldExpandedCell
        let name = cellChecked.inputTestFieldOne.text
        
        let filteredName = members2.filter({ $0.attendee == name })
        let filteredChosen = chosenMembers.filter({ $0.attendee == name })
        //        print(filteredName)
        if !members2.isEmpty {
            //        members2.remove(at: indexPath.row)
        }
        for user in filteredName {
            let userAttendee:UserAttendees = user
            userAttendee.attendeeICSPosition = position
            userAttendee.attendeeHasPosition = true
            userAttendee.attendeeBackUp = false
            do {
                try context.save()
                DispatchQueue.main.async {
                    self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"Team TVC merge that"])
                }
            } catch {
                
                let nserror = error as NSError
                
                let errorMessage = "TeamTVC positionFieldEdited() fetchRequest  Unresolved error \(nserror)"
                
                print(errorMessage)
                
            }
            var members3 = [userAttendee]
            for user in members2 {
                members3.append(user)
            }
            members2.removeAll()
            members2 = members3.sorted(by: {$0.attendee! > $1.attendee!})
            
        }
        for user in filteredChosen {
            chosenMembers = chosenMembers.filter({ $0 != user })
            user.attendeeICSPosition = icsPosition
            user.attendeeHasPosition = true
            do {
                try context.save()
                DispatchQueue.main.async {
                    self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"Team TVC merge that"])
                }
            } catch {
                
                let nserror = error as NSError
                
                let errorMessage = "TeamTVC positionFieldEdited()  user in filteredChosen Unresolved error \(nserror)"
                
                print(errorMessage)
                
            }
            var chosen = [user]
            for user in chosenMembers {
                chosen.append(user)
            }
            chosenMembers.removeAll()
            chosenMembers = chosen.sorted(by: { $0.attendee! > $1.attendee! })
        }
        
    }
    
    func agencyFieldEdited(agency:String, indexPath:IndexPath) {
        
        let icsAgency = agency
        let cellChecked = tableView.cellForRow(at: indexPath) as! CompletedThreeFieldExpandedCell
        let name = cellChecked.inputTestFieldOne.text
        
        let filteredChosen = chosenMembers.filter({ $0.attendee == name })
        
        for user in filteredChosen {
            chosenMembers = chosenMembers.filter({ $0 != user })
            user.attendeeHomeAgency = icsAgency
            do {
                try context.save()
                
                DispatchQueue.main.async {
                    self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"Team TVC merge that"])
                }
            } catch {
                
                let nserror = error as NSError
                
                let errorMessage = "TeamTVC agencyFieldEdited() fetchRequest user in filteredChosen Unresolved error \(nserror)"
                
                print(errorMessage)
                
            }
            var chosen = [user]
            for user in chosenMembers {
                chosen.append(user)
            }
            chosenMembers.removeAll()
            chosenMembers = chosen.sorted(by: { $0.attendee! > $1.attendee! })
        }
        
    }
    
}

extension TeamTVC {
    
    func registerCells() {
        tableView.register(UINib(nibName: "ModalHeaderCell", bundle: nil), forCellReuseIdentifier: "ModalHeaderCell")
        tableView.register(UINib(nibName: "ContactsCell", bundle: nil), forCellReuseIdentifier: "ContactsCell")
        tableView.register(UINib(nibName: "CompletedThreeFieldExpandedCell", bundle: nil), forCellReuseIdentifier: "CompletedThreeFieldExpandedCell")
        tableView.register(UINib(nibName: "AddButtonCell", bundle: nil), forCellReuseIdentifier: "AddButtonCell")
    }
    
    func fetchUsersForTable() {
        
        var names = [String]()
        var cells = [ICS214TeamCell3]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserAttendees")
        fetchRequest.fetchBatchSize = 20
        fetchRequest.returnsObjectsAsFaults = false
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != %@", "attendeeHomeAgency", "")
        let sortDescriptor1 = NSSortDescriptor(key: "attendee", ascending: false)
        let sortDescriptors = [sortDescriptor1]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        do {
            teams = try context.fetch(fetchRequest) as! [UserAttendees]
            for user:UserAttendees in teams  as! [UserAttendees] {
//                let use = context.object(with: user.objectID) as! UserAttendees
                var name:String!
                if user.attendee != nil {
                    name = user.attendee!.trimmingCharacters(in: .whitespaces)
                }
                if names.contains(name) {} else {
                    names.append(name)
                    var attendeePosition:String = ""
                    if user.attendeeICSPosition != nil {
                        attendeePosition = user.attendeeICSPosition!
                    }
                    var attendeeAgency:String = ""
                    if user.attendeeHomeAgency != nil {
                        attendeeAgency = user.attendeeHomeAgency!
                    }
                    var phone:String = ""
                    if user.attendeePhone != nil {
                        phone = user.attendeePhone!
                    }
                    var email:String = ""
                    if user.attendeeEmail != nil {
                        email = user.attendeeEmail!
                    }
                    var guid:String = ""
                    if user.attendeeGuid != nil {
                        guid = user.attendeeGuid!
                    }
                    if name != nil {
                        
                        
                        let header = ""
                        let date = Date()
                        let obID = NSManagedObjectID()
                        let cell00 = ICS214TeamCell3.init(header: header, date: date, id:obID)
                        cell00.field1 = name
                        cell00.field2 = attendeePosition
                        cell00.field3 = attendeeAgency
                        cell00.field4 = email
                        cell00.cellValue1 = phone
                        cell00.cellValue2 = guid
                        cells.append(cell00)
                    }
                }
            }
        } catch {
            
            let nserror = error as NSError
            
            let errorMessage = "TeamTVC viewDidLoad() fetchRequest \(fetchRequest) Unresolved error \(nserror)"
            print(errorMessage)
            
        }
        cells = cells.sorted(by: { $0.field1 > $1.field1})
        for cell00 in cells {
            let i:Int = theCells.firstIndex(where: { $0.tag == 1 })!
            let d:Int = i+1
            theCells.insert(cell00, at: d)
        }
    }
}
