//
//  FullImageVC.swift
//  FireJournal
//
//  Created by DuRand Jones on 6/25/21.
//

import UIKit

class FullImageVC: UIViewController {
    
    @IBOutlet weak var fullImageIV: UIImageView!
    
    var fullImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fullImageIV.translatesAutoresizingMaskIntoConstraints = false
        fullImageIV.image = fullImage
    }
    

}

extension FullImageVC {
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
}

