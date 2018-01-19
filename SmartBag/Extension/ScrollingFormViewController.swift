//
//  ScrollViewController.swift
//  SmartBag
//
//  Created by admin on 11/01/18.
//  Copyright © 2018 indosystem. All rights reserved.
//
import UIKit

class ScrollingFormViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    var headerHeightLayoutConstraint: NSLayoutConstraint?
    var keyboardHeightLayoutConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerForKeyboardNotifications()
        
        setupView()
    }
    
    func setupView(){
        
    }
    
    deinit {
        self.deregisterFromKeyboardNotifications()
    }
    
    func registerForKeyboardNotifications()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    
    @objc func deregisterFromKeyboardNotifications()
    {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                self.headerHeightLayoutConstraint?.constant = 120.0
                self.keyboardHeightLayoutConstraint?.constant = 100.0
            } else {
                self.headerHeightLayoutConstraint?.constant = 0.0
                self.keyboardHeightLayoutConstraint?.constant = ( endFrame?.size.height ?? 0.0 ) + 75.0
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    
}
