//
//  PlatoonsVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 10/12/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol PlatoonsVCDelegate: AnyObject {
    func platoonsCancelTapped()
    func platoonsVCChosen(platoon: UserPlatoon)
}

class PlatoonsVC: UIViewController {

    //    MARK: -Objects-
    @IBOutlet weak var platooonV: UIView!
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var platoonTV: UITableView!
    @IBOutlet weak var cancelB: UIButton!
    
    //    MARK: -Properties-
    var platoons = [UserPlatoon]()
    weak var delegate: PlatoonsVCDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        platoonTV.delegate = self
        platoonTV.dataSource = self
        registerCells()
        roundViews()
    }
    
    func roundViews() {
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        platooonV.layer.cornerRadius = 20
        platooonV.clipsToBounds = true
    }
    
    @IBAction func platoonCancelBTapped(_ sender: Any) {
        delegate?.platoonsCancelTapped()
    }
    
    fileprivate func registerCells() {
        platoonTV.register(UINib(nibName: "PlatoonsCell", bundle: nil), forCellReuseIdentifier: "PlatoonsCell")
    }

}

extension PlatoonsVC: UITableViewDataSource, UITableViewDelegate {

   func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if platoons.count == 0 {
            return 0
        } else {
            return platoons.count
        }
    }
    
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let platoon = platoons[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlatoonsCell", for: indexPath) as! PlatoonsCell
            cell.subjectL.text = platoon.platoon
            return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userPlatoon = platoons[indexPath.row]
        delegate?.platoonsVCChosen(platoon: userPlatoon)
    }
    
}
