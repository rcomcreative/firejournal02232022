    //
    //  RelieveSupervisorVC+Extensions.swift
    //  Fire Journal
    //
    //  Created by DuRand Jones on 3/16/22.
    //  Copyright © 2022 PureCommand, LLC. All rights reserved.
    //

import UIKit
import Foundation
import CoreData

extension RelieveSupervisorVC {
    
    func configureRelieveSupervisorHeaderV() {
        relieveSupervisorHeaderV = Bundle.main.loadNibNamed("RelieveSupervisorHeaderV", owner: self, options: nil)?.first as? RelieveSupervisorHeaderV
        relieveSupervisorHeaderV.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(relieveSupervisorHeaderV)
        relieveSupervisorHeaderV.delegate = self
        relieveSupervisorHeaderV.relieveSupervisorSubjectL.text = headerTitle
        relieveSupervisorHeaderV.backgroundV.image = UIImage(named: "EDF0F6-D8E7FA_CellBkgrnd4sq")
        NSLayoutConstraint.activate([
            relieveSupervisorHeaderV.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            relieveSupervisorHeaderV.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            relieveSupervisorHeaderV.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            relieveSupervisorHeaderV.heightAnchor.constraint(equalToConstant: 190),
        ])
    }
    
    func configureRelieveSupervisorTableView() {
        relieveSupervisorTableView = UITableView(frame: .zero)
        registerCellsForTable()
        relieveSupervisorTableView.translatesAutoresizingMaskIntoConstraints = false
        relieveSupervisorTableView.backgroundColor = .systemBackground
        view.addSubview(relieveSupervisorTableView)
        relieveSupervisorTableView.delegate = self
        relieveSupervisorTableView.dataSource = self
        relieveSupervisorTableView.separatorStyle = .none
        
        relieveSupervisorTableView.rowHeight = UITableView.automaticDimension
        relieveSupervisorTableView.estimatedRowHeight = 300
        if crew {
            relieveSupervisorTableView.allowsMultipleSelection = true
        }
        
        NSLayoutConstraint.activate([
            relieveSupervisorTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            relieveSupervisorTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            relieveSupervisorTableView.topAnchor.constraint(equalTo: relieveSupervisorHeaderV.bottomAnchor, constant: 5),
            relieveSupervisorTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10),
        ])
    }
    
}

extension RelieveSupervisorVC: UITableViewDelegate {
    
    func registerCellsForTable() {
        relieveSupervisorTableView.register(UINib(nibName: "CrewCell", bundle: nil), forCellReuseIdentifier: "CrewCell")
    }
    
}

extension RelieveSupervisorVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedObjects.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CrewCell", for: indexPath) as! CrewCell
        configureCell(cell, at: indexPath)
        return cell
    }
    
    func configureCell(_ cell: CrewCell, at indexPath: IndexPath) {
        let row = indexPath.row
        cell.contact =  fetchedObjects[row]
        
            //        MARK: if multiple selects already exist check against resource and mark as checked
        let contact = cell.contact?.attendee ?? ""
        let result = selected.filter { $0.attendee == contact}
        if !result.isEmpty {
            relieveSupervisorTableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as! CrewCell
        cell.isSelected = true
        let name = cell.contact?.attendee ?? ""
        
        let result = selected.filter { $0.attendee == name}
        if result.isEmpty {
            selected.append(cell.contact!)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)! as! CrewCell
        cell.isSelected = false
        let name = cell.contact?.attendee ?? ""
        let result = selected.filter { $0.attendee == name }
        if !result.isEmpty {
            if let attendee = cell.contact {
                selected.remove(object: attendee)
            }
        }
        
     }
    
}



extension RelieveSupervisorVC: RelieveSupervisorHeaderVDelegate {
    
    func relieveSupervisorInfoTapped() {
        presentAlert()
    }
    
    func relieveSupervisorAddNewMember(member: String) {
        if member != "" {
            if newOfficer != nil {
                newOfficer = nil
            }
            let group = CrewFromContact.init(name: member, phone: "", email: "", crew: [] )
            group.createGuid()
            newOfficer = UserAttendees.init(context: context)
            newOfficer.attendee = group.name
            newOfficer.attendeeEmail = group.email
            newOfficer.attendeePhone = group.phone
            newOfficer.attendeeModDate = group.attendeeDate
            newOfficer.attendeeGuid = group.attendeeGuid
            newOfficer.defaultCrewMember = group.overtimeB
            newOfficer.staffGuid = UUID()
            newOfficer.supervisor = true
            saveSupervisor()
            _ = getAllAttendees(supervisor: supervisor)
            relieveSupervisorTableView.reloadData()
        }
    }
    
    func relieveSupervisorAddFromContacts() {
        presentContact()
    }
    
    func relieveSupervisorCancelTapped() {
        delegate?.relieveSupervisorCancel()
    }
    
    func relieveSupervisorSaveTapped(member: String) {
        delegate?.relieveSupervisorChosen(relieveSupervisor: selected, relieveOrSupervisor: relievingOrSupervisor)
    }
    
    func relieveSupervisorTextEditing(text: String) {}
    
    func saveSupervisor() {
        do {
            try context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"RelieveSupervisorVC merge that"])
            }
            DispatchQueue.main.async {
                    let objectID = self.newOfficer.objectID
                    self.nc.post(name: NSNotification.Name(rawValue: FJkNEWUSERATTENDEE_TOCLOUDKIT), object: nil, userInfo:["objectID":objectID])
            }
        } catch let error as NSError {
            print("RelieveSupervisorModal line 284 Fetch Error: \(error.localizedDescription)")
        }
    }
    
    func presentContact() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "StaffContact", bundle:nil)
        staffContactsVC = storyBoard.instantiateViewController(withIdentifier: "StaffContactsVC") as? StaffContactsVC
        staffContactsVC.delegate = self
        staffContactsVC.modalPresentationStyle = .formSheet
        self.present(staffContactsVC, animated: true, completion: nil)
    }
    
}

extension RelieveSupervisorVC: StaffContactsVCDelegate {
    
    func staffChosen(_ staff: NewStaff) {
        newOfficer = nil
        var name: String = ""
        var phone: String = ""
        var email: String = ""
        if staff.fullName != "" {
            name = staff.fullName
        }
        if staff.phone != "" {
            phone = staff.phone
        }
        if staff.email != "" {
            email = staff.email
        }
        let group = CrewFromContact.init(name: name, phone: phone, email: email , crew: [] )
        group.createGuid()
        newOfficer = UserAttendees.init(context: context)
        newOfficer.attendee = group.name
        newOfficer.attendeeEmail = group.email
        newOfficer.attendeePhone = group.phone
        newOfficer.attendeeModDate = group.attendeeDate
        newOfficer.attendeeGuid = group.attendeeGuid
        newOfficer.defaultCrewMember = group.overtimeB
        newOfficer.supervisor = true
        if staff.officerImage != nil {
            imageAvailable = true
            contactImage = staff.officerImage
            contactImageToURL()
        }
        saveSupervisor()
        _ = getAllAttendees(supervisor: supervisor)
        relieveSupervisorTableView.reloadData()
    }
    
    func contactImageToURL() {
        guard let image = contactImage, let data = image.jpegData(compressionQuality: 1) else {
            print("No image found")
            self.imageAvailable = false
            fatalError("###\(#function): Failed to get JPG data and URL of the picked image!")
        }
        let guid = UUID()
        let fileName = guid.uuidString + ".jpg"
        let url = CloudKitManager.attachmentFolder.appendingPathComponent(fileName)
        if let data = image.jpegData(compressionQuality: 1.0),!FileManager.default.fileExists(atPath: url.path){
            
            do {
                try data.write(to: url)
                print("file saved")
                self.photoProvider.addPhotoStaff(imageData: data, imageURL: url, staff: self.newOfficer, taskContext: self.photoProvider.persistentContainer.viewContext, shouldSave: true, logo: false)
                self.contactImage = image
                self.imageAvailable = true
                guard let attachment = self.newOfficer.photo else { return }
                self.validPhotos.append(attachment)
                DispatchQueue.main.async {
                    print("we're all done here")
                }
            } catch {
                print("error saving file:", error)
            }
        }
    }
    
}

extension RelieveSupervisorVC: RelieveSupervisorContactsTVCDelegate {
   
    func cancelContactsBTapped() {
        relieveSupervisorContactsTVC.dismiss(animated: true, completion: nil)
    }
    
    func saveContactsBTapped(crew: [CrewFromContact]) {
        relieveSupervisorContactsTVC.dismiss(animated: true, completion: nil)
        for ( _, item ) in crew.enumerated() {
            let group = item
            let name = group.name
            let result = selected.filter { $0.attendee == name}
            if result.isEmpty {
                newOfficer = nil
                let group = CrewFromContact.init(name: name, phone: "", email: "", crew: [] )
                group.createGuid()
                newOfficer = UserAttendees.init(context: context)
                newOfficer.attendee = group.name
                newOfficer.attendeeEmail = group.email
                newOfficer.attendeePhone = group.phone
                newOfficer.attendeeModDate = group.attendeeDate
                newOfficer.attendeeGuid = group.attendeeGuid
                newOfficer.defaultCrewMember = group.overtimeB
                newOfficer.supervisor = true
                saveSupervisor()
                _ = getAllAttendees(supervisor: supervisor)
                relieveSupervisorTableView.reloadData()
            }
        }
    }
    
    
}

extension RelieveSupervisorVC: NSFetchedResultsControllerDelegate {
    
    func getAllAttendees(supervisor: Bool ) -> NSFetchedResultsController<UserAttendees> {
        
        let fetchRequest: NSFetchRequest<UserAttendees> = UserAttendees.fetchRequest()
        fetchRequest.fetchBatchSize = 20
        
        var predicate = NSPredicate.init()
        var predicate2 = NSPredicate.init()
        var predicateCan = NSCompoundPredicate.init()
        if supervisor {
        predicate = NSPredicate(format: "%K != nil", "attendee")
        predicate2 = NSPredicate(format: "supervisor == %@", NSNumber(value:true))
        predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate,predicate2])
        } else {
            predicate = NSPredicate(format: "%K != nil", "attendee")
            
            predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
        }
        fetchRequest.predicate = predicateCan
        
        let sectionSortDescriptor = NSSortDescriptor(key: "attendee", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        fetchedResultsController = aFetchedResultsController
        
        do {
            try fetchedResultsController!.performFetch()
        } catch let error as NSError {
            print("ReportVC Fetch Error: \(error.localizedDescription)")
            if !self.alertUp {
                let errorred: String =  "Data Error: \(error.localizedDescription) Try again later."
                self.errorAlert(errorMessage: errorred)
            }
        }
        
        return fetchedResultsController!
    }
    
}
