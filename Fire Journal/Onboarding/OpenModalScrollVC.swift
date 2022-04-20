//
//  OpenModalScrollVC.swift
//  dashboard
//
//  Created by DuRand Jones on 10/9/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData


protocol OpenModalScrollVCDelegate: AnyObject {
    func agreementAndFormCompleted(objectID: NSManagedObjectID, userTimeObjectID: NSManagedObjectID)
    func allCompleted( yesNo: Bool )
    func errorOnFormLoad(errorInCD: String)
}

class OpenModalScrollVC: UIViewController, UIScrollViewDelegate, OpenModalAgreementVCDelegate, OpenModalFormTVCDelegate {
    
    @IBOutlet weak var backgroundIV: UIImageView!
    @IBOutlet weak var onboardingSV: UIScrollView!
    @IBOutlet weak var pageController: UIPageControl!
    @IBOutlet weak var letsGoB: UIButton!
    @IBOutlet weak var skipB: UIButton!
    
    var context:NSManagedObjectContext!
    
    var modal1: NewOnboardOneVC!
    var modal2: NewOnboardTwoVC!
    var modal25: NewOnboardThreeVC!
    var modal3: NewOnboardFourVC!
    var modal4: NewOnboardFiveVC!
    var modal5: NewOnboardSixVC!
    var modal6:OnboardSevenVC!
    var modal7: NewOnboardSevenVC!
    var modal8: NewOnboardEightVC!
    var modal9: OnboardTenVC!
    var modal10: NewOnboardNineVC!
    
    var body:BodyText!
    var fromMaster:Bool = false
    
    private let vcLaunch = VCLaunch()
    private var launchNC: LaunchNotifications!
    var segue:String = ""
    weak var delegate:OpenModalScrollVCDelegate? = nil

    //    MARK: - presentation Delegate
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
//        launchNC.removeNC()
    }
    
    func roundViews() {
        self.view.layer.cornerRadius = 20
        self.view.clipsToBounds = true
    }
    
    override func viewWillLayoutSubviews() {
        if !fromMaster {
            roundViews()
        }
        var frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: 1025.0)
        let storyBoard : UIStoryboard = UIStoryboard(name: "Onboarding", bundle:nil)
        let storyBoard1: UIStoryboard = UIStoryboard(name: "NewOnboarding", bundle: nil )
        modal1 = storyBoard1.instantiateViewController(withIdentifier: "NewOnboardOneVC") as? NewOnboardOneVC
        self.addChild(modal1)
        modal1.view.autoresizingMask = []
        modal1.view.frame = frame
        modal1.view.setNeedsLayout()
        onboardingSV.addSubview(modal1.view)
        modal1.didMove(toParent: self)
        frame = CGRect(x: self.view.frame.size.width, y: 0.0, width: self.view.frame.size.width, height: 1025.0)
        modal2 = storyBoard1.instantiateViewController(withIdentifier: "NewOnboardTwoVC") as? NewOnboardTwoVC
        self.addChild(modal2)
        modal2.view.autoresizingMask = []
        modal2.view.frame = frame
        onboardingSV.addSubview(modal2.view)
        modal2.didMove(toParent: self)
        frame = CGRect(x: self.view.frame.size.width*2, y: 0.0, width: self.view.frame.size.width, height: 1025.0)
        modal25 = storyBoard1.instantiateViewController(withIdentifier: "NewOnboardThreeVC") as? NewOnboardThreeVC
        self.addChild(modal25)
        modal25.view.autoresizingMask = []
        modal25.view.frame = frame
        onboardingSV.addSubview(modal25.view)
        modal25.didMove(toParent: self)
        frame = CGRect(x: self.view.frame.size.width*3, y: 0.0, width: self.view.frame.size.width, height: 1025.0)
        modal3 = storyBoard1.instantiateViewController(withIdentifier: "NewOnboardFourVC") as? NewOnboardFourVC
        self.addChild(modal3)
        modal3.view.autoresizingMask = []
        modal3.view.frame = frame
        onboardingSV.addSubview(modal3.view)
        modal3.didMove(toParent: self)
        frame = CGRect(x: self.view.frame.size.width*4, y: 0.0, width: self.view.frame.size.width, height: 1025.0)
        modal4 = storyBoard1.instantiateViewController(withIdentifier: "NewOnboardFiveVC") as? NewOnboardFiveVC
        self.addChild(modal4)
        modal4.view.autoresizingMask = []
        modal4.view.frame = frame
        onboardingSV.addSubview(modal4.view)
        modal4.didMove(toParent: self)
        frame = CGRect(x: self.view.frame.size.width*5, y: 0.0, width: self.view.frame.size.width, height: 1025.0)
        modal5 = storyBoard1.instantiateViewController(withIdentifier: "NewOnboardSixVC") as? NewOnboardSixVC
        self.addChild(modal5)
        modal5.view.autoresizingMask = []
        modal5.view.frame = frame
        onboardingSV.addSubview(modal5.view)
        modal5.didMove(toParent: self)
        frame = CGRect(x: self.view.frame.size.width*6, y: 0.0, width: self.view.frame.size.width, height: 1025.0)
//        modal6 = storyBoard.instantiateViewController(withIdentifier: "OnboardSevenVC") as? OnboardSevenVC
//        self.addChild(modal6)
//        modal6.view.autoresizingMask = []
//        modal6.view.frame = frame
//        onboardingSV.addSubview(modal6.view)
//        modal6.didMove(toParent: self)
        modal7 = storyBoard1.instantiateViewController(withIdentifier: "NewOnboardSevenVC") as? NewOnboardSevenVC
        self.addChild(modal7)
        modal7.view.autoresizingMask = []
        modal7.view.frame = frame
        onboardingSV.addSubview(modal7.view)
        modal7.didMove(toParent: self)
        frame = CGRect(x: self.view.frame.size.width*7, y: 0.0, width: self.view.frame.size.width, height: 1025.0)
        modal8 = storyBoard1.instantiateViewController(withIdentifier: "NewOnboardEightVC") as? NewOnboardEightVC
        self.addChild(modal8)
        modal8.view.autoresizingMask = []
        modal8.view.frame = frame
        onboardingSV.addSubview(modal8.view)
        modal8.didMove(toParent: self)
        frame = CGRect(x: self.view.frame.size.width*8, y: 0.0, width: self.view.frame.size.width, height: 1025.0)
        modal9 = storyBoard.instantiateViewController(withIdentifier: "OnboardTenVC") as? OnboardTenVC
        self.addChild(modal9)
        modal9.view.autoresizingMask = []
        modal9.view.frame = frame
        onboardingSV.addSubview(modal9.view)
        modal9.didMove(toParent: self)
//        frame = CGRect(x: self.view.frame.size.width*9, y: 0.0, width: self.view.frame.size.width, height: 1025.0)
        onboardingSV.contentSize = CGSize(width: self.view.frame.size.width*9, height: onboardingSV.frame.size.height)
        
        let swipeLeft = UISwipeGestureRecognizer.init(target: self, action: #selector(swipe(_:)))
        swipeLeft.direction = .left
        onboardingSV.canCancelContentTouches = true
        onboardingSV.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer.init(target: self, action: #selector(swipe(_ :)))
        swipeRight.direction = .right
        onboardingSV.addGestureRecognizer(swipeRight)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Welcome"
        vcLaunch.splitVC = self.splitViewController
        launchNC = LaunchNotifications.init(launchVC: vcLaunch)
        launchNC.callNotifications()
    }
    
    @objc func swipe(_ recognizer: UISwipeGestureRecognizer) {
        if recognizer.direction == .left {
            pageController.currentPage = pageController.currentPage+1
            let width = Int(self.view.frame.size.width)
            let x = CGFloat(pageController.currentPage * width)
            onboardingSV.setContentOffset(CGPoint(x: x, y: 0), animated: true)
            switch pageController.currentPage {
            case 7:
                UIView.animate(withDuration: 0.5, animations: {
                    self.skipB.isHidden = false
                    self.skipB.alpha = 1.0
                    self.letsGoB.isHidden = true
                    self.letsGoB.alpha = 0.0
                    })
            case 8:
                UIView.animate(withDuration: 0.5, animations: {
                    self.skipB.isHidden = true
                    self.skipB.alpha = 0.0
                    self.letsGoB.isHidden = false
                    self.letsGoB.alpha = 1.0
                })
            default:
                print("do nothing")
            }
        } else if recognizer.direction == .right {
            pageController.currentPage = pageController.currentPage-1
            let width = Int(self.view.frame.size.width)
            let x = CGFloat(pageController.currentPage * width)
            onboardingSV.setContentOffset(CGPoint(x: x, y: 0), animated: true)
            switch pageController.currentPage {
            case 7:
                UIView.animate(withDuration: 0.5, animations: {
                    self.skipB.isHidden = false
                    self.skipB.alpha = 1.0
                    self.letsGoB.isHidden = true
                    self.letsGoB.alpha = 0.0
                })
            case 8:
                UIView.animate(withDuration: 0.5, animations: {
                    self.skipB.isHidden = true
                    self.skipB.alpha = 0.0
                    self.letsGoB.isHidden = false
                    self.letsGoB.alpha = 1.0
                })
            default:
                print("do nothing")
            }
        }
    }
    
    @IBAction func movePages(_ sender: Any) {
        let width = Int(self.view.frame.size.width)
        let x = CGFloat(pageController.currentPage * width)
        onboardingSV.setContentOffset(CGPoint(x: x, y: 0), animated: true)
        switch pageController.currentPage {
        case 7:
            UIView.animate(withDuration: 0.5, animations: {
                self.skipB.isHidden = false
                self.skipB.alpha = 1.0
                self.letsGoB.isHidden = true
                self.letsGoB.alpha = 0.0
            })
        case 8:
            UIView.animate(withDuration: 0.5, animations: {
                self.skipB.isHidden = true
                self.skipB.alpha = 0.0
                self.letsGoB.isHidden = false
                self.letsGoB.alpha = 1.0
            })
        default:
            print("do nothing")
        }
    }
    @IBAction func letsGoTapped(_ sender: Any) {
        loadUpAgreement()
    }
    
    @IBAction func skipBTapped(_ sender: Any) {
        loadUpAgreement()
    }
    
    func loadUpAgreement() {
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let agreementVC = storyBoard.instantiateViewController(withIdentifier: "OpenModalAgreementVC") as! OpenModalAgreementVC
        agreementVC.delegate = self
        agreementVC.transitioningDelegate = slideInTransitioningDelgate
        agreementVC.modalPresentationStyle = .custom
        self.present(agreementVC, animated: true, completion: nil)
    }
    
    func loadUpUserForm() {
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyboard : UIStoryboard = UIStoryboard(name: "OnboardProfileForm", bundle: nil)
        let userForm = storyboard.instantiateViewController(withIdentifier: "OnboardProfileFormVC") as! OnboardProfileFormVC
        userForm.delegate = self
        userForm.transitioningDelegate = slideInTransitioningDelgate
        userForm.modalPresentationStyle = .custom
        
//            newJournalFormVC.modalPresentationStyle = .formSheet
//            newJournalFormVC.isModalInPresentation = true
        self.present(userForm, animated: true, completion: nil)
    }
    
    //    MARK: -OpenModalFormTVCDelegate
    func theFormIsComplete(yesNo: Bool) {
        self.dismiss(animated: true, completion: nil)
        delegate?.allCompleted(yesNo: true)
    }
    
    func theFormHasAnError(errorInCD: String) {
        self.dismiss(animated: true, completion: nil)
        delegate?.errorOnFormLoad(errorInCD: errorInCD)
    }
    
    //    MARK: -OpenModalAgreementVCDelegate
    func theAgreementAgreedTo(yesNo: Bool) {
        if yesNo {
            loadUpUserForm()
        } else {
        }
    }
    
}

extension OpenModalScrollVC: OnboardProfileFormVCDelegate {
    
    func theOnboardFormIsComplete(objectID: NSManagedObjectID, userTimeObjectID: NSManagedObjectID) {
        delegate?.agreementAndFormCompleted(objectID: objectID, userTimeObjectID: userTimeObjectID)
        self.dismiss(animated: true, completion: nil)
    }
    
}
