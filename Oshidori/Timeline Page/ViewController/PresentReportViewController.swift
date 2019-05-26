//
//  PresentReportViewController.swift
//  Oshidori
//
//  Created by Tatsuya Yamamoto on 2019/5/26.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit

protocol PresentReportViewControllerDelegate: class {
    func cancelButtonTapped()
    func reportButtonTapped(reportMessage: RepresentationMessage)
}

import UIKit


final class PresentReportViewController: UIViewController {
    
    @IBOutlet weak private var baseView: UIView!
    @IBOutlet weak private var cancelButton: UIButton!
    @IBOutlet weak private var reportButton: UIButton!
    
    var reportMessage: RepresentationMessage?
    
    weak var delegate: PresentReportViewControllerDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        baseView.layer.cornerRadius = 8
        baseView.backgroundColor = .lightGray
        cancelButton.backgroundColor = OshidoriColor.dark
        cancelButton.layer.cornerRadius = 8
        reportButton.backgroundColor = OshidoriColor.dark
        reportButton.layer.cornerRadius = 8
    }
    
    @IBAction private func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true) {
            self.delegate?.cancelButtonTapped()
        }
    }
    
    @IBAction func reportButtonTapped(_ sender: Any) {
        dismiss(animated: true) {
            guard let message = self.reportMessage else {
                return
            }
            self.delegate?.reportButtonTapped(reportMessage: message)
        }
    }
    
}



extension PresentReportViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimatedTransition(forPresented: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimatedTransition(forPresented: false)
    }
}


