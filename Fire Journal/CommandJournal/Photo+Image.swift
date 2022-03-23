//
//  Photo+Image.swift
//  StationCommand
//
//  Created by DuRand Jones on 7/8/21.
//

import UIKit
import CoreData

extension Photo {
    
    /**
     Create the thumbnail image from image data.
     */
    static func thumbnail(from imageData: Data, thumbnailPixelSize: Int) -> UIImage? {
        let options = [kCGImageSourceCreateThumbnailWithTransform: true,
                       kCGImageSourceCreateThumbnailFromImageAlways: true,
                       kCGImageSourceThumbnailMaxPixelSize: thumbnailPixelSize] as CFDictionary
        let imageSource = CGImageSourceCreateWithData(imageData as CFData, nil)!
        let imageReference = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options)!
        return UIImage(cgImage: imageReference)
    }
    
    
    
    /**
     Create the image file URL for the current attachment.
     */
    func imageURL() -> URL {
        let fileName = guid!.uuidString + ".jpg"
        return CloudKitManager.attachmentFolder.appendingPathComponent(fileName)
    }
    
    /**
     Create the thumbnail URL for the current attachment.
     */
    private func thumbnailURL() -> URL {
        let fileName = guid!.uuidString + ".thumbnail"
        return CloudKitManager.attachmentFolder.appendingPathComponent(fileName)
    }
    
    func getThumbnail() -> UIImage? {
        // Return the thumbnail image if it is already loaded.
        guard image == nil else { return image }
        
        var nsError: NSError?
        NSFileCoordinator().coordinate(
            readingItemAt: thumbnailURL(), options: .withoutChanges, error: &nsError,
            byAccessor: { (newURL: URL) -> Void in
                image = UIImage(contentsOfFile: newURL.path)
            }
        )
        if let nsError = nsError {
            print("###\(#function): \(nsError.localizedDescription)")
        }

        // Return the thumbnail image if it is ready.
        guard image == nil else { return image }

        // If the thumbnail doesn’t exist yet, try to create it from the full image data.
        // For attachments created by Core Data with CloudKit, imageData can be nil.
        guard let fullImageData = imageData?.data else {
            print("###\(#function): Full image data is not there yet.")
            return nil
        }
        
        image = Photo.thumbnail(from: fullImageData, thumbnailPixelSize: 80)
        return image
    }
    
    /**
     Load the image from the cached file if it exists, otherwise from the attachment’s imageData.
     
     Attachments created by Core Data with CloudKit don’t have cached files.
     Provide a new task context to load the image data, and release it after the image finishes loading.
     */
    func getImage(with taskContext: NSManagedObjectContext) -> UIImage? {
        // Load the image from the cached file if the file exists.
        var image: UIImage?
        
        var nsError: NSError?
        NSFileCoordinator().coordinate(
            readingItemAt: imageURL(), options: .withoutChanges, error: &nsError,
            byAccessor: { (newURL: URL) -> Void in
                if let data = try? Data(contentsOf: newURL) {
                    image = UIImage(data: data, scale: UIScreen.main.scale)
                }
            }
        )
        if let nsError = nsError {
            print("###\(#function): \(nsError.localizedDescription)")
        }

        // Return the image if it was read from the cached file.
        guard image == nil else { return image }

        // If the cache file doesn’t exist, load the image data from the store.
        let attachmentObjectID = objectID
        taskContext.performAndWait {
            if let photo = taskContext.object(with: attachmentObjectID) as? Photo,
                let data = photo.imageData?.data {
                image = UIImage(data: data, scale: UIScreen.main.scale)
            }
        }
        return image
    }
    
    
    
}
