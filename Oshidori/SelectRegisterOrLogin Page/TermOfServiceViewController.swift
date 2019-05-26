//
//  TermOfServiceViewController.swift
//  Oshidori
//
//  Created by Tatsuya Yamamoto on 2019/5/26.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit

protocol TermOfServiceViewControllerDelegate: class {
    func confirmBackButton()
}

final class TermOfServiceViewController: UIViewController {
    
    @IBOutlet weak var baseView: UITextView!
    @IBOutlet weak var confirmBackButton: UIButton!
    
    weak var delegate: TermOfServiceViewControllerDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        baseView.delegate = self
        baseView.layer.cornerRadius = 8
        confirmBackButton.backgroundColor = OshidoriColor.primary
        confirmBackButton.layer.cornerRadius = 8
        confirmBackButton.setTitle("戻る", for: .normal)
        confirmBackButton.alpha = 0.5
        confirmBackButton.isEnabled = false
    }
    
    @IBAction private func confirmButtonTapped(_ sender: UIButton) {
        dismiss(animated: true) {
            self.delegate?.confirmBackButton()
        }
    }
}

extension TermOfServiceViewController: UITextViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 一番下にきたらボタンを明るくする！
        if scrollView.contentOffset.y >= baseView.contentSize.height - baseView.frame.height {
            confirmBackButton.isEnabled = true
            confirmBackButton.alpha = 1.0
        }
    }
}

extension TermOfServiceViewController: UIViewControllerTransitioningDelegate {
    
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


