//
//  IncidentVC+PhotoExtentions.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/18/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//


import UIKit
import Foundation
import CoreData
import MapKit
import CoreLocation
import PhotosUI

extension IncidentVC: CameraTVCellDelegate, PHPickerViewControllerDelegate {
    
    
    func galleryChosen(tag: Int) {
        usePHGallery()
    }
    
    func cameraChosen(tag: Int) {
        useTheCamera()
    }
    
        //    MARK:- Use Camera chosen serve up UIImagePickerController
    func useTheCamera() {
        self.dismiss(animated: true, completion: nil)
        if (UIImagePickerController .isSourceTypeAvailable(.camera)) {
            let vc = UIImagePickerController()
            cameraType = true
            vc.sourceType = .camera
            vc.allowsEditing = true
            vc.delegate = self
            present(vc, animated: true)
        } else {
            if !self.alertUp {
                let error: String = "Your camera is not available. Try again later."
                self.errorAlert(errorMessage: error)
            }
        }
    }
    
    func usePHGallery() {
        self.dismiss(animated: true, completion: nil)
        var configuration  = PHPickerConfiguration()
        configuration.selectionLimit = 0
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true, completion: nil)
        guard !results.isEmpty else { return }
        itemProvider = results.map(\.itemProvider)
        iterator = itemProvider.makeIterator()
        DispatchQueue.main.async {
            self.createSpinnerView()
        }
        processTheImages() {
            DispatchQueue.main.async {
                print("we're all done here")
                
                DispatchQueue.main.async {
                    self.removeSpinnerUpdate()
                }

                print("saved")
                
                
                self.validPhotos =  self.theIncident.photo?.allObjects as! [Photo]
                print("here is validPhotos \(self.validPhotos.count)")
                self.photosAvailable = true
                DispatchQueue.main.async {
                    self.savePhotoIncident(self) {
                        guard let attachments = self.theIncident.photo?.allObjects as? [Photo] else { return }
                        self.validPhotos = attachments.filter { return !($0.imageData == nil) }
                        
                        
                        self.incidentTableView.reloadRows(at: [IndexPath.init(row: 30, section: 0)], with: .automatic)
                            // print out the image size as a test
//                        print(image.size)
                    }
                }
            }
        }
    }
    
    func processTheImages(completionHandler: (() -> Void)? = nil)  {
        let counter = itemProvider.count
        var count = 0
        for item in itemProvider {
            count += 1
            if item.canLoadObject(ofClass: UIImage.self )
            {
                item.loadObject(ofClass: UIImage.self) { (image, error) in
                    DispatchQueue.global(qos: .background).async {
                        if let image = image as? UIImage {
                            let _ = image.jpegData(compressionQuality: 1)
                            let guid = UUID()
                            let fileName = guid.uuidString + ".jpg"
                            let url = CloudKitManager.attachmentFolder.appendingPathComponent(fileName)
                            if let data = image.jpegData(compressionQuality: 1.0),!FileManager.default.fileExists(atPath: url.path)
                            {
                                do {
                                    try data.write(to: url)
                                    print("file saved")
                                    self.taskContext = self.photoProvider.persistentContainer.newBackgroundContext()
                                    let objectID = self.theIncident.objectID
                                    self.photoProvider.addPhotoIncident(imageData: data, imageURL: url, incidentid: objectID, taskContext: self.photoProvider.persistentContainer.viewContext) { incidentid in                                        print(image.size)
                                        self.theIncident = self.context.object(with: incidentid) as? Incident
                                        if count == counter {
                                            completionHandler?()
                                        }
                                    }
                                } catch {
                                    print("error saving file:", error)
                                    var theErrorMessage = ""
                                    let errorMessage = error.localizedDescription
                                    theErrorMessage = "There was an error trying to save your photo." + errorMessage
                                    print(theErrorMessage)
                                    DispatchQueue.main.async {
                                        self.nc.post(name: .fireJournalPhotoErrorCalled ,object: nil ,userInfo: ["errorMessage": theErrorMessage] )
                                    }
                                    
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
        //    MARK:- UIImagePickerControllerDelegate didFinish
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: {

            if self.cameraType {
                guard let image = info[.editedImage] as? UIImage, let _ = image.jpegData(compressionQuality: 1 ) else {
                    print("No image found")
                    self.photosAvailable = false
                    fatalError("###\(#function): Failed to get JPG data and URL of the picked image!")
                }
                DispatchQueue.global(qos: .background).async {
                let guid = UUID()
                let fileName = guid.uuidString + ".jpg"
                let url = CloudKitManager.attachmentFolder.appendingPathComponent(fileName)
                if let data = image.jpegData(compressionQuality: 1.0),!FileManager.default.fileExists(atPath: url.path){
                    
                    do {
                        try data.write(to: url)
                        print("file saved")
                        self.taskContext = self.photoProvider.persistentContainer.newBackgroundContext()
                        let objectID = self.theIncident.objectID
                        self.photoProvider.addPhotoIncident(imageData: data, imageURL: url, incidentid: objectID, taskContext: self.photoProvider.persistentContainer.viewContext) { incidentid in
                            
                            self.photosAvailable = true
                            
                            DispatchQueue.main.async {
                                self.savePhotoIncident(self) {
                                    guard let attachments = self.theIncident.photo?.allObjects as? [Photo] else { return }
                                    self.validPhotos = attachments.filter { return !($0.imageData == nil) }
                                    
                                    
                                    self.incidentTableView.reloadRows(at: [IndexPath.init(row: 30, section: 0)], with: .automatic)
                                        // print out the image size as a test
                                    print(image.size)
                                }
                            }
                        }
                    } catch {
                        print("error saving file:", error)
                    }
                }
                }
            } else {
                DispatchQueue.global(qos: .background).async {
                guard let image = info[.editedImage] as? UIImage, let data = image.jpegData(compressionQuality: 1),
                      let url = info[.imageURL] as? URL else {
                          print("No image found")
                          self.photosAvailable = false
                          fatalError("###\(#function): Failed to get JPG data and URL of the picked image!")
                              //                return
                      }
                self.taskContext = self.photoProvider.persistentContainer.newBackgroundContext()
                let objectID = self.theIncident.objectID
                self.photoProvider.addPhotoIncident(imageData: data, imageURL: url, incidentid: objectID, taskContext: self.photoProvider.persistentContainer.viewContext) { incidentid in
                    DispatchQueue.main.async {
                    self.savePhotoIncident(self) {
                        
                        self.photosAvailable = true
                        guard let attachments = self.theIncident.photo?.allObjects as? [Photo] else { return }
                        self.validPhotos = attachments.filter { return !($0.imageData == nil) }
                        
                        self.incidentTableView.reloadRows(at: [IndexPath.init(row: 30, section: 0)], with: .automatic)
                    }
                    }
                }
            }
        }
                       
        
        }
     )
    }
    
        /// creates a spinner view to hold the scene while data is downloaded from cloudkit
        /// posts to master to lock all the buttons down
    func createSpinnerView() {
        child = SpinnerViewController()
        childAdded = true
            // add the spinner view controller
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
        nc.post(name:Notification.Name(rawValue: FJkLOCKMASTERDOWNFORDOWNLOAD),
                object: nil,
                userInfo: nil)
    }
    
        /// observer on FJkLocationsAllUpdatedToSC
        /// - Parameter ns: no user info
    func removeSpinnerUpdate() {
        if childAdded {
            DispatchQueue.main.async {
                    // then remove the spinner view controller
                self.child.willMove(toParent: nil)
                self.child.view.removeFromSuperview()
                self.child.removeFromParent()
                self.nc.post(name:Notification.Name(rawValue: FJkLOCKMASTERDOWNFORDOWNLOAD),
                             object: nil,
                             userInfo: nil)
                self.nc.post(name:Notification.Name(rawValue: FJkLETSCHECKTHEVERSION),
                             object: nil,
                             userInfo: nil)
            }
            childAdded = false
        }
    }
    
}

    
     
