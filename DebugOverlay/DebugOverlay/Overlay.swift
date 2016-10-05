//
//  Overlay.swift
//  Debug Overlay
//
//  Created by Joshua Kelley on 5/17/16.
//  Copyright © 2016 Joshua Kelley. All rights reserved.
//

import UIKit

class OverLay : NSObject {
    
    fileprivate var owner: UIViewController!
    
    fileprivate var logger: Logger!
    fileprivate var defaultLoggerDependencies: LoggerDI!
    
    fileprivate enum EditMode { case none, inspect }
    
    fileprivate var currentEditMode: EditMode = .none
    fileprivate var inEditMode: Bool = false
    fileprivate var hidden = false
    fileprivate var loggerOpen: Bool = false
    
    // MARK: - Views
    
    fileprivate var hamburgerButton: UIButton!
    
    fileprivate var toggleInspectButton: UIButton!
    fileprivate var clearLogButton: UIButton!
    fileprivate var shareButton: UIButton!
    
    fileprivate var hideAllButton: UIButton!
    
    fileprivate var addDismissLogButton: UIButton!
    
    fileprivate var overlayView: UIView!
    fileprivate var logView: UITextView!
    
    // MARK: - Theme and Dimensions
    fileprivate let padding: CGFloat = 10.0
    
    fileprivate var initialHeight: CGFloat = 0.0
    fileprivate var initialWidth: CGFloat = 0.0
    fileprivate var initialPosition: CGPoint = CGPoint.zero
    fileprivate var overlayBGColor: UIColor = UIColor.white
    fileprivate var textColor: UIColor = UIColor.black
    
    fileprivate var initialButtonX: CGFloat = (UIScreen.main.bounds.width / 2) - 25
    fileprivate var initialButtonY: CGFloat = 50.0
    fileprivate var buttonSize = CGSize(width: 50, height: 50)
    
    // MARK: - Initializers
    
    convenience init(vc: UIViewController) {
        self.init(vc: vc, overlayBGColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0.3), textColor: UIColor.white)
    }
    
    convenience init(vc: UIViewController, textMode: PresentingScreenIs) {
        self.init(vc: vc, overlayBGColor: textMode.overlayBGColorForMode(), textColor: textMode.textColorForMode())
    }
    
    init(vc: UIViewController, overlayBGColor: UIColor, textColor: UIColor, initialPosition: CGPoint = CGPoint.zero, initialHeight: CGFloat = 0, initialWidth: CGFloat = 0) {
        super.init()
        
        self.owner = vc
        
        self.initialWidth = (initialWidth == 0.0) ? owner.view.frame.width - (padding * 2) :initialWidth
        self.initialHeight = (initialHeight == 0.0) ? owner.view.frame.height / 2 : initialHeight
        self.initialPosition = (initialPosition == CGPoint.zero) ? CGPoint(x: 10.0, y: owner.view.frame.height / 4) : initialPosition
        self.overlayBGColor = overlayBGColor
        self.textColor = textColor
        
        initialButtonX = (owner.view.frame.width / 2) - 25
        
        setupAddLoggerButton()
    }
    
    // MARK: - UI
    
    fileprivate func newLog() {
        setUpLogger()
        overlayView = UIView(frame: CGRect(origin: initialPosition, size: CGSize(width: initialWidth, height: initialHeight)))
        overlayView.backgroundColor = overlayBGColor
        overlayView.layer.cornerRadius = 10.0
        overlayView.clipsToBounds = true
        overlayView.isUserInteractionEnabled = false
        
        // textview
        logView = UITextView(frame: CGRect(origin: CGPoint.zero, size: overlayView.frame.size))
        logView.backgroundColor = UIColor.clear
        logView.textColor = textColor
        overlayView.addSubview(logView)
        overlayView.alpha = 0.0
        overlayView.transform = CGAffineTransform(translationX: 0, y: owner.view.frame.height)
        
        owner.view.addSubview(overlayView)
    }
    
    fileprivate func setupAddLoggerButton() {
        addDismissLogButton = UIButton(frame: CGRect(origin: CGPoint(x: initialButtonX, y: initialButtonY), size: buttonSize))
        addDismissLogButton.layer.cornerRadius = addDismissLogButton.frame.height / 2
        addDismissLogButton.clipsToBounds = true
        addDismissLogButton.setImage(UIImage.OverlayUI.Add, for: UIControlState())
        addDismissLogButton.addTarget(self, action: #selector(addCloseTapped(_:)), for: .touchUpInside)
        loggerOpen = false
        addDismissLogButton.alpha = 0.0
        
        
        owner.view.addSubview(addDismissLogButton)
        
        UIView.animate(withDuration: 0.25, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0.6, options: UIViewAnimationOptions(), animations:  {self.addDismissLogButton.transform = CGAffineTransform(scaleX: 1.15, y: 1.15); self.addDismissLogButton.alpha = 1.0}, completion: { (succeeded) in
            UIView.animate(withDuration: 0.40, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0.6, options: UIViewAnimationOptions(), animations:  {self.addDismissLogButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)}, completion: nil)
        })
    }
    
    // MARK: - Button Setup
    
    fileprivate func setupHamburger() {
        hamburgerButton = UIButton(frame: CGRect(origin: CGPoint(x: initialButtonX, y: initialButtonY), size: buttonSize))
        hamburgerButton.layer.cornerRadius = hamburgerButton.frame.height / 2
        hamburgerButton.clipsToBounds = true
        hamburgerButton.setImage(UIImage.OverlayUI.Hamburger, for: UIControlState())
        hamburgerButton.addTarget(self, action: #selector(hamburgerTapped(_:)), for: .touchUpInside)
        hamburgerButton.alpha = 0.0
        
        owner.view.addSubview(hamburgerButton)
        hamburgerButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    
    fileprivate func setupRefreshButton() {
        clearLogButton = UIButton(frame: CGRect(origin: CGPoint(x: initialButtonX - 75.0 - (3 * padding / 2), y: 2 * initialButtonY + padding), size: buttonSize))
        clearLogButton.layer.cornerRadius = clearLogButton.frame.height / 2
        clearLogButton.clipsToBounds = true
        clearLogButton.setImage(UIImage.OverlayUI.Refresh, for: UIControlState())
        clearLogButton.addTarget(self, action: #selector(clearLogTapped(_:)), for: .touchUpInside)
        clearLogButton.alpha = 0.0
        
        owner.view.addSubview(clearLogButton)
        clearLogButton.transform = CGAffineTransform(translationX: 75.0 + (3 * padding / 2), y: -(initialButtonY + padding))
    }

    fileprivate func setupHideButton() {
        hideAllButton = UIButton(frame: CGRect(origin: CGPoint(x: initialButtonX - 25.0 - (padding / 2), y: 2 * initialButtonY + padding), size: buttonSize))
        hideAllButton.layer.cornerRadius = hideAllButton.frame.height / 2
        hideAllButton.clipsToBounds = true
        hideAllButton.setImage(UIImage.OverlayUI.Hide, for: UIControlState())
        hideAllButton.addTarget(self, action: #selector(hideAllTapped(_:)), for: .touchUpInside)
        hideAllButton.alpha = 0.0
        
        owner.view.addSubview(hideAllButton)
        
        hideAllButton.transform = CGAffineTransform(translationX: 25.0 + (padding / 2), y: -(initialButtonY + padding))
    }
    
    fileprivate func setupInspectButton() {
        toggleInspectButton = UIButton(frame: CGRect(origin: CGPoint(x: initialButtonX + 25.0 + (padding / 2), y: 2 * initialButtonY + padding), size: buttonSize))
        toggleInspectButton.layer.cornerRadius = toggleInspectButton.frame.height / 2
        toggleInspectButton.clipsToBounds = true
        toggleInspectButton.setImage(UIImage.OverlayUI.Inspect, for: UIControlState())
        toggleInspectButton.addTarget(self, action: #selector(inspectLogTapped(_:)), for: .touchUpInside)
        toggleInspectButton.alpha = 0.0
        
        owner.view.addSubview(toggleInspectButton)
        toggleInspectButton.transform = CGAffineTransform(translationX: -(25.0 + (padding / 2)), y: -(initialButtonY + padding))
    }
    
    fileprivate func setupShareButton() {
        shareButton = UIButton(frame: CGRect(origin: CGPoint(x: initialButtonX + 75.0 + (3 * padding / 2), y: 2 * initialButtonY + padding), size: buttonSize))
        shareButton.layer.cornerRadius = shareButton.frame.height / 2
        shareButton.clipsToBounds = true
        shareButton.setImage(UIImage.OverlayUI.Share, for: UIControlState())
        shareButton.addTarget(self, action: #selector(shareLogTapped(_:)), for: .touchUpInside)
        shareButton.alpha = 0.0
        hidden = false
        
        owner.view.addSubview(shareButton)
    }
    
    // MARK: - Actions
    
    func addCloseTapped(_ sender: UIButton) {
        if !loggerOpen {
            animateAddButtonToCloseButton(0.0)
        } else {
            animateCloseButtonToAddButton(0.0)
        }
    }
    
    func hideAllTapped(_ sender: UIButton) {
        
        UIView.animate(withDuration: 0.25, animations: {
            self.hideAllButton.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
            self.overlayView.alpha = 0.0
            self.hideAllButton.alpha = 0.0
            }, completion: { (_) in
                self.hidden = true
                self.hamburgerTapped(sender)
        }) 
    }

    func inspectLogTapped(_ sender: UIButton) {
        buttonPressedAnimation(sender)
        if currentEditMode == .none {
            currentEditMode = .inspect
            overlayView.isUserInteractionEnabled = true
        } else {
            currentEditMode = .none
            overlayView.isUserInteractionEnabled = false
        }
        Log("Inspect Log Tapped")
    }
    
    func clearLogTapped(_ sender: UIButton) {
        
        buttonPressedAnimation(sender)
        Log("Clear Log Tapped")
        logger.reset()
    }
    
    func shareLogTapped(_ sender: UIButton) {
        buttonPressedAnimation(sender)
        
        shareLog()
        
        Log("Share Log Tapped")
    }
    
    func hamburgerTapped(_ sender: UIButton) {
        Log("Hamburger Tapped")
        if !hidden {
            buttonPressedAnimation(sender)
            overlayView.alpha = 1.0
        }
        hidden = false
        
        if !inEditMode {
            setupRefreshButton()
            setupHideButton()
            setupShareButton()
            setupInspectButton()
            
            animateToEditMode()
            
        } else {
            animateCloseEditMode()
        }
        inEditMode = !inEditMode
    }
    
    // MARK: Animations
    
    fileprivate  func animateAddButtonToCloseButton(_ delayToExpect: TimeInterval) {
        setupHamburger()
        newLog()
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions(), animations: {
            let transform = self.addDismissLogButton.transform.translatedBy(x: (2 * self.padding) - self.addDismissLogButton.frame.origin.x, y: 0.0)
            self.addDismissLogButton.transform = transform.rotated(by: CGFloat(M_PI_4))
            
            }, completion: nil)
        UIView.animate(withDuration: 0.25, delay: 0.15, usingSpringWithDamping: 1, initialSpringVelocity: 0.6, options: UIViewAnimationOptions(), animations:  {self.hamburgerButton.transform = CGAffineTransform(scaleX: 1.15, y: 1.15); self.hamburgerButton.alpha = 1.0}, completion: { (succeeded) in
            UIView.animate(withDuration: 0.40, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0.6, options: UIViewAnimationOptions(), animations:  {self.hamburgerButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)}, completion: nil)
        })
        UIView.animate(withDuration: 0.25, delay: 0.3, options: UIViewAnimationOptions(), animations: {
            self.overlayView.transform = CGAffineTransform(translationX: 0, y: 0)
            self.overlayView.alpha = 1.0
            }, completion: nil)
        
        loggerOpen = true
    }
    
    fileprivate func animateCloseButtonToAddButton(_ delayToExpect: TimeInterval) {
        
        if inEditMode {
            animateCloseEditMode(0.25)
            inEditMode = false
        }
        
        // Rotate dismiss button to add button and move to middle
        UIView.animate(withDuration: 0.35, delay: 0.0, options: UIViewAnimationOptions(), animations: {
            self.addDismissLogButton.transform = CGAffineTransform(rotationAngle: 0)
            self.addDismissLogButton.transform = CGAffineTransform(translationX: 0.0, y: 0.0)
            }, completion: nil)
        
        // Wink out hamburger button and unload button
        UIView.animate(withDuration: 0.22, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0.6, options: UIViewAnimationOptions(), animations:  {self.hamburgerButton.transform = CGAffineTransform(scaleX: 0.3, y: 0.3);self.hamburgerButton.alpha = 0.0}, completion: { _ in self.unloadButton(self.hamburgerButton)} )
        
        // push log overlay off bottom of screen and unload overlay
        UIView.animate(withDuration: 0.20, delay: 0.10, options: UIViewAnimationOptions(), animations: {
            self.overlayView.transform = CGAffineTransform(translationX: 0, y: self.owner.view.frame.height)
            self.overlayView.alpha = 0.0
            }, completion: { _ in self.unloadLog()})
        
        loggerOpen = false
    }

    
    fileprivate func buttonPressedAnimation(_ btn: UIButton) {
        btn.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        UIView.animate(withDuration: 0.25, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1, options: [], animations:  {
            btn.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: nil)
    }
    
    fileprivate func animateToEditMode() {
        UIView.animate(withDuration: 0.35, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0.6, options: UIViewAnimationOptions(), animations:  {
            self.clearLogButton.alpha = 1.0
            self.clearLogButton.transform = CGAffineTransform(translationX: 0.0, y: 0.0)
            }, completion: nil)
        UIView.animate(withDuration: 0.35, delay: 0.10, usingSpringWithDamping: 1, initialSpringVelocity: 0.6, options: UIViewAnimationOptions(), animations:  {
            self.hideAllButton.alpha = 1.0
            self.hideAllButton.transform = CGAffineTransform(translationX: 0.0, y: 0.0)
            }, completion: nil)
        UIView.animate(withDuration: 0.35, delay: 0.20, usingSpringWithDamping: 1, initialSpringVelocity: 0.6, options: UIViewAnimationOptions(), animations:  {
            self.toggleInspectButton.alpha = 1.0
            self.toggleInspectButton.transform = CGAffineTransform(translationX: 0.0, y: 0.0)
            }, completion: nil)
        UIView.animate(withDuration: 0.35, delay: 0.30, usingSpringWithDamping: 1, initialSpringVelocity: 0.6, options: UIViewAnimationOptions(), animations:  {
            self.shareButton.alpha = 1.0
            self.shareButton.transform = CGAffineTransform(translationX: 0.0, y: 0.0)
            }, completion: nil)
        
    }
    
    fileprivate func animateCloseEditMode(_ duration: TimeInterval = 0.35) {
        UIView.animate(withDuration: 0.35, delay: 0.30, usingSpringWithDamping: 1, initialSpringVelocity: 0.6, options: UIViewAnimationOptions(), animations:  {
            self.clearLogButton.alpha = 0.0
            self.clearLogButton.transform = CGAffineTransform(translationX: 75.0 + (3 * self.padding / 2), y: -(self.initialButtonY + self.padding))
            }, completion: { _ in self.unloadButton(self.clearLogButton) } )
        UIView.animate(withDuration: 0.35, delay: 0.20, usingSpringWithDamping: 1, initialSpringVelocity: 0.6, options: UIViewAnimationOptions(), animations:  {
            self.hideAllButton.alpha = 0.0
            self.hideAllButton.transform = CGAffineTransform(translationX: 25.0 + (self.padding / 2), y: -(self.initialButtonY + self.padding))
            }, completion: { _ in self.unloadButton(self.hideAllButton) })
        UIView.animate(withDuration: 0.35, delay: 0.10, usingSpringWithDamping: 1, initialSpringVelocity: 0.6, options: UIViewAnimationOptions(), animations:  {
            self.toggleInspectButton.alpha = 0.0
            self.toggleInspectButton.transform = CGAffineTransform(translationX: -(25.0 + (self.padding / 2)), y: -(self.initialButtonY + self.padding))
            }, completion: { _ in self.unloadButton(self.toggleInspectButton) })
        UIView.animate(withDuration: 0.35, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0.6, options: UIViewAnimationOptions(), animations:  {
            self.shareButton.alpha = 0.0
            self.shareButton.transform = CGAffineTransform(translationX: -(75.0 + (3 * self.padding / 2)), y: -(self.initialButtonY + self.padding))
            }, completion: { _ in self.unloadButton(self.shareButton) })
    }
    
    // MARK: - Custom Functions
    
    fileprivate func shareLog() {
        let activityVC = UIActivityViewController(activityItems: [logger.getLog()], applicationActivities: nil)
        owner.present(activityVC, animated: true, completion: nil)
    }
    
    // MARK: Cleanup
    
    fileprivate func unloadButton(_ btn: UIButton) {
        var btn: UIButton! = btn
        btn.removeFromSuperview()
        btn = nil
    }
    
    fileprivate func unloadLog() {
        logger = nil
        logView.removeFromSuperview()
        overlayView.removeFromSuperview()
        logView = nil
        overlayView = nil
    }
    
    fileprivate func setUpLogger() {
        logger = Logger.sharedInstance
        logger.reset()
        
        defaultLoggerDependencies = LoggerDI(updateClosure: updater, promptString: "# ")
        logger.setDependencies(defaultLoggerDependencies)
    }
    
    fileprivate func updater(_ updatedLog: String) {
        guard logView != nil else {
            return
        }
        logView.text = updatedLog
        if logView.text.characters.count > 0 {
            logView.scrollRangeToVisible(NSMakeRange(logView.text.characters.count - 1, 0))
        }
    }
    
    // MARK: - Public API
    
    func tearDown() {
        owner = nil
        logger = nil
        defaultLoggerDependencies = nil
        
        if logView != nil {
            logView.removeFromSuperview()
            logView = nil
        }
        
        if overlayView != nil {
            overlayView.removeFromSuperview()
            overlayView = nil
        }
        
        if addDismissLogButton != nil {
            addDismissLogButton.removeFromSuperview()
            addDismissLogButton = nil
        }
        
        if hamburgerButton != nil {
            hamburgerButton.removeFromSuperview()
            hamburgerButton = nil
        }
        
        if toggleInspectButton != nil {
            toggleInspectButton.removeFromSuperview()
            toggleInspectButton = nil
        }
        
        if clearLogButton != nil {
            clearLogButton.removeFromSuperview()
            clearLogButton = nil
        }
        
        if shareButton != nil {
            shareButton.removeFromSuperview()
            shareButton = nil
        }
        
        if hideAllButton != nil {
            hideAllButton.removeFromSuperview()
            hideAllButton = nil
        }
    }
}
