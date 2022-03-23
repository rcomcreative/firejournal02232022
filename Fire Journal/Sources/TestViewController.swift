//
//  TestViewController.swift
//  Fire Journal
//
//  Created by DuRand Jones on 8/3/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    @IBOutlet weak var collectionVC: UICollectionView!
    
    var testArray: Array<String>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        testArray = ["AC1","AC2","AC3","BC1","bC2","BC3","BIKE1","BIKE2","BOAT1","BOAT2"]
        collectionVC.dataSource = testArray as? UICollectionViewDataSource
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
