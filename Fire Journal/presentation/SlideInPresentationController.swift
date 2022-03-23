//
//  SlideInPresentationController.swift
//  dashboard
//
//  Created by DuRand Jones on 8/8/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit

class SlideInPresentationController: UIPresentationController {
    
    //    MARK: -Properties
    fileprivate var dimmingView: UIView!
    private var direction: PresentationDirection
    
    //    MARK: -Init
    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, direction: PresentationDirection) {
        self.direction = direction
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        setupDimmingView()
    }
    
    //    MARK: -UIPresentationController methods
    override func presentationTransitionWillBegin() {
        containerView?.insertSubview(dimmingView, at: 0)
        
        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "V:|[dimmingView]|", options: [], metrics: nil, views: ["dimmingView": dimmingView!]))
        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[dimmingView]|", options: [], metrics: nil, views: ["dimmingView": dimmingView!]))
        
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 1.0
            return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1.0
        })
    }
    
    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 0.0
            return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0.0
        })
    }
    
    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        switch direction {
        case .left, .right:
            return CGSize(width: parentSize.width*(2.0/3.0), height: parentSize.height)
        case .bottom, .top:
            return CGSize(width: parentSize.width*(2.0/3.0), height: parentSize.height-70)
//            return CGSize(width: parentSize.width*(2.0/3.0), height: parentSize.height*(7.0/8.0))
        }
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        
        var frame: CGRect = .zero
        frame.size = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerView!.bounds.size)
        let theCenter = frame.midX
        print(theCenter)
        switch direction {
        case .left:
//            frame.origin.x = containerView!.frame.width*(1.0/3.0)
            frame.origin.x = (theCenter/2.0)
        case .bottom:
            frame.origin.x = (theCenter/2.0)
            frame.origin.y = 100
//                containerView!.frame.height*(5.0/6.0)
        default:
            frame.origin = .zero
        }
        
        return frame
    }
}

// MARK: Private
private extension SlideInPresentationController {
    func setupDimmingView() {
        dimmingView = UIView()
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        dimmingView.alpha = 0.0
//        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognier:)))
//        dimmingView.addGestureRecognizer(recognizer)
    }
    
    @objc dynamic func handleTap(recognier: UITapGestureRecognizer) {
        presentingViewController.dismiss(animated: true)
    }
}
