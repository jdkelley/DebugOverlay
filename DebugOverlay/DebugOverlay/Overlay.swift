//
//  Overlay.swift
//  Debug Overlay
//
//  Created by Joshua Kelley on 5/17/16.
//  Copyright © 2016 Joshua Kelley. All rights reserved.
//

import UIKit

class OverLay : NSObject {
    
    private var owner: UIViewController!
    
    private var logger: Logger!
    private var defaultLoggerDependencies: LoggerDI!
    
    enum EditMode { case None, Inspect }
    
    private var currentEditMode: EditMode = .None
    private var inEditMode: Bool = false
    private var hidden = false
    
    // MARK: - Views
    
    var hamburgerButton: UIButton!
    
    var toggleInspectButton: UIButton!
    var clearLogButton: UIButton!
    var shareButton: UIButton!
    
    var hideAllButton: UIButton!
    
    var addDismissLogButton: UIButton!
    
    var overlayView: UIView!
    var logView: UITextView!
    
    // MARK: - Theme and Dimensions
    let padding: CGFloat = 10.0
    
    var initialHeight: CGFloat = 0.0
    var initialWidth: CGFloat = 0.0
    var initialPosition: CGPoint = CGPointZero
    var overlayBGColor: UIColor = UIColor.whiteColor()
    var textColor: UIColor = UIColor.blackColor()
    
    var initialButtonX: CGFloat = (UIScreen.mainScreen().bounds.width / 2) - 25
    var initialButtonY: CGFloat = 50.0
    var buttonSize = CGSize(width: 50, height: 50)
    
    convenience init(vc: UIViewController) {
        self.init(vc: vc, overlayBGColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0.3), textColor: UIColor.whiteColor())
    }
    
    convenience init(vc: UIViewController, textMode: PresentingScreenIs) {
        self.init(vc: vc, overlayBGColor: textMode.overlayBGColorForMode(), textColor: textMode.textColorForMode())
    }
    
    init(vc: UIViewController, overlayBGColor: UIColor, textColor: UIColor, initialPosition: CGPoint = CGPointZero, initialHeight: CGFloat = 0, initialWidth: CGFloat = 0) {
        super.init()
        
        self.owner = vc
        
        self.initialWidth = (initialWidth == 0.0) ? owner.view.frame.width - (padding * 2) :initialWidth
        self.initialHeight = (initialHeight == 0.0) ? owner.view.frame.height / 2 : initialHeight
        self.initialPosition = (initialPosition == CGPointZero) ? CGPointMake(10.0, owner.view.frame.height / 4) : initialPosition
        self.overlayBGColor = overlayBGColor
        self.textColor = textColor
        
        initialButtonX = (owner.view.frame.width / 2) - 25
        
        setupAddLoggerButton()
    }
    
    func newLog() {
        setUpLogger()
        overlayView = UIView(frame: CGRect(origin: initialPosition, size: CGSize(width: initialWidth, height: initialHeight)))
        overlayView.backgroundColor = overlayBGColor
        overlayView.layer.cornerRadius = 10.0
        overlayView.clipsToBounds = true
        overlayView.userInteractionEnabled = false
        
        // textview
        logView = UITextView(frame: CGRect(origin: CGPointZero, size: overlayView.frame.size))
        logView.backgroundColor = UIColor.clearColor()
        logView.textColor = textColor
        overlayView.addSubview(logView)
        overlayView.alpha = 0.0
        overlayView.transform = CGAffineTransformMakeTranslation(0, owner.view.frame.height)
        
        owner.view.addSubview(overlayView)
    }
    
    // MARK: - UI
    
    var loggerOpen: Bool = false
    
    func setupAddLoggerButton() {
        addDismissLogButton = UIButton(frame: CGRect(origin: CGPointMake(initialButtonX, initialButtonY), size: buttonSize))
        addDismissLogButton.layer.cornerRadius = addDismissLogButton.frame.height / 2
        addDismissLogButton.clipsToBounds = true
        addDismissLogButton.setImage(UIImage.OverlayUI.Add, forState: .Normal)
        addDismissLogButton.addTarget(self, action: #selector(addCloseTapped(_:)), forControlEvents: .TouchUpInside)
        loggerOpen = false
        addDismissLogButton.alpha = 0.0
        
        
        owner.view.addSubview(addDismissLogButton)
        
        UIView.animateWithDuration(0.25, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0.6, options: .CurveEaseInOut, animations:  {self.addDismissLogButton.transform = CGAffineTransformMakeScale(1.15, 1.15); self.addDismissLogButton.alpha = 1.0}, completion: { (succeeded) in
            UIView.animateWithDuration(0.40, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0.6, options: .CurveEaseInOut, animations:  {self.addDismissLogButton.transform = CGAffineTransformMakeScale(1.0, 1.0)}, completion: nil)
        })
    }
    
    func addCloseTapped(sender: UIButton) {
        if !loggerOpen {
            animateAddButtonToCloseButton(0.0)
        } else {
            animateCloseButtonToAddButton(0.0)
        }
    }
    
    func animateAddButtonToCloseButton(delayToExpect: NSTimeInterval) {
        setupHamburger()
        newLog()
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseInOut, animations: {
            let transform = CGAffineTransformTranslate(self.addDismissLogButton.transform, (2 * self.padding) - self.addDismissLogButton.frame.origin.x, 0.0)
            self.addDismissLogButton.transform = CGAffineTransformRotate(transform, CGFloat(M_PI_4))
            
            }, completion: nil)
        UIView.animateWithDuration(0.25, delay: 0.15, usingSpringWithDamping: 1, initialSpringVelocity: 0.6, options: .CurveEaseInOut, animations:  {self.hamburgerButton.transform = CGAffineTransformMakeScale(1.15, 1.15); self.hamburgerButton.alpha = 1.0}, completion: { (succeeded) in
            UIView.animateWithDuration(0.40, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0.6, options: .CurveEaseInOut, animations:  {self.hamburgerButton.transform = CGAffineTransformMakeScale(1.0, 1.0)}, completion: nil)
        })
        UIView.animateWithDuration(0.25, delay: 0.3, options: .CurveEaseInOut, animations: {
            self.overlayView.transform = CGAffineTransformMakeTranslation(0, 0)
            self.overlayView.alpha = 1.0
            }, completion: nil)
        
        loggerOpen = true
    }
    
    func animateCloseButtonToAddButton(delayToExpect: NSTimeInterval) {
        
        if inEditMode {
            animateCloseEditMode(0.25)
            inEditMode = false
        }
        
        // Rotate dismiss button to add button and move to middle
        UIView.animateWithDuration(0.35, delay: 0.0, options: .CurveEaseInOut, animations: {
            self.addDismissLogButton.transform = CGAffineTransformMakeRotation(0)
            self.addDismissLogButton.transform = CGAffineTransformMakeTranslation(0.0, 0.0)
            }, completion: nil)
        
        // Wink out hamburger button and unload button
        UIView.animateWithDuration(0.22, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0.6, options: .CurveEaseInOut, animations:  {self.hamburgerButton.transform = CGAffineTransformMakeScale(0.3, 0.3);self.hamburgerButton.alpha = 0.0}, completion: { _ in self.unloadButton(self.hamburgerButton)} )
        
        // push log overlay off bottom of screen and unload overlay
        UIView.animateWithDuration(0.20, delay: 0.10, options: .CurveEaseInOut, animations: {
            self.overlayView.transform = CGAffineTransformMakeTranslation(0, self.owner.view.frame.height)
            self.overlayView.alpha = 0.0
            }, completion: { _ in self.unloadLog()})
        
        loggerOpen = false
    }
    
    func setupHamburger() {
        hamburgerButton = UIButton(frame: CGRect(origin: CGPointMake(initialButtonX, initialButtonY), size: buttonSize))
        hamburgerButton.layer.cornerRadius = hamburgerButton.frame.height / 2
        hamburgerButton.clipsToBounds = true
        hamburgerButton.setImage(UIImage.OverlayUI.Hamburger, forState: .Normal)
        hamburgerButton.addTarget(self, action: #selector(hamburgerTapped(_:)), forControlEvents: .TouchUpInside)
        hamburgerButton.alpha = 0.0
        
        owner.view.addSubview(hamburgerButton)
        hamburgerButton.transform = CGAffineTransformMakeScale(0.7, 0.7)
    }
    
    func setupRefreshButton() {
        clearLogButton = UIButton(frame: CGRect(origin: CGPointMake(initialButtonX - 75.0 - (3 * padding / 2), 2 * initialButtonY + padding), size: buttonSize))
        clearLogButton.layer.cornerRadius = clearLogButton.frame.height / 2
        clearLogButton.clipsToBounds = true
        clearLogButton.setImage(UIImage.OverlayUI.Refresh, forState: .Normal)
        clearLogButton.addTarget(self, action: #selector(clearLogTapped(_:)), forControlEvents: .TouchUpInside)
        clearLogButton.alpha = 0.0
        
        owner.view.addSubview(clearLogButton)
        clearLogButton.transform = CGAffineTransformMakeTranslation(75.0 + (3 * padding / 2), -(initialButtonY + padding))
    }

    func setupHideButton() {
        hideAllButton = UIButton(frame: CGRect(origin: CGPointMake(initialButtonX - 25.0 - (padding / 2), 2 * initialButtonY + padding), size: buttonSize))
        hideAllButton.layer.cornerRadius = hideAllButton.frame.height / 2
        hideAllButton.clipsToBounds = true
        hideAllButton.setImage(UIImage.OverlayUI.Hide, forState: .Normal)
        hideAllButton.addTarget(self, action: #selector(hideAllTapped(_:)), forControlEvents: .TouchUpInside)
        hideAllButton.alpha = 0.0
        
        owner.view.addSubview(hideAllButton)
        
        hideAllButton.transform = CGAffineTransformMakeTranslation(25.0 + (padding / 2), -(initialButtonY + padding))
    }
    
    func setupInspectButton() {
        toggleInspectButton = UIButton(frame: CGRect(origin: CGPointMake(initialButtonX + 25.0 + (padding / 2), 2 * initialButtonY + padding), size: buttonSize))
        toggleInspectButton.layer.cornerRadius = toggleInspectButton.frame.height / 2
        toggleInspectButton.clipsToBounds = true
        toggleInspectButton.setImage(UIImage.OverlayUI.Inspect, forState: .Normal)
        toggleInspectButton.addTarget(self, action: #selector(inspectLogTapped(_:)), forControlEvents: .TouchUpInside)
        toggleInspectButton.alpha = 0.0
        
        owner.view.addSubview(toggleInspectButton)
        toggleInspectButton.transform = CGAffineTransformMakeTranslation(-(25.0 + (padding / 2)), -(initialButtonY + padding))
    }
    
    func setupShareButton() {
        shareButton = UIButton(frame: CGRect(origin: CGPointMake(initialButtonX + 75.0 + (3 * padding / 2), 2 * initialButtonY + padding), size: buttonSize))
        shareButton.layer.cornerRadius = shareButton.frame.height / 2
        shareButton.clipsToBounds = true
        shareButton.setImage(UIImage.OverlayUI.Share, forState: .Normal)
        shareButton.addTarget(self, action: #selector(shareLogTapped(_:)), forControlEvents: .TouchUpInside)
        shareButton.alpha = 0.0
        hidden = false
        
        owner.view.addSubview(shareButton)
    }
    
    // MARK: - Actions
    
    func hideAllTapped(sender: UIButton) {
        
        UIView.animateWithDuration(0.25, animations: {
            self.hideAllButton.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
            self.overlayView.alpha = 0.0
            self.hideAllButton.alpha = 0.0
            }) { (_) in
                self.hidden = true
                self.hamburgerTapped(sender)
        }
    }

    func inspectLogTapped(sender: UIButton) {
        buttonPressedAnimation(sender)
        if currentEditMode == .None {
            currentEditMode = .Inspect
            overlayView.userInteractionEnabled = true
        } else {
            currentEditMode = .None
            overlayView.userInteractionEnabled = false
        }
        Log("Inspect Log Tapped")
    }
    
    func clearLogTapped(sender: UIButton) {
        
        buttonPressedAnimation(sender)
        Log("Clear Log Tapped")
        logger.reset()
    }
    
    func shareLogTapped(sender: UIButton) {
        buttonPressedAnimation(sender)
        
        shareLog()
        
        Log("Share Log Tapped")
    }
    
    func shareLog() {
        let activityVC = UIActivityViewController(activityItems: [logger.getLog()], applicationActivities: nil)
        owner.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    func hamburgerTapped(sender: UIButton) {
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
    
    // was 0.15, .20
    func buttonPressedAnimation(btn: UIButton) -> (NSTimeInterval) {
        btn.transform = CGAffineTransformMakeScale(1.2, 1.2)
        UIView.animateWithDuration(0.25, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1, options: [], animations:  {
            btn.transform = CGAffineTransformMakeScale(1.0, 1.0)
            }, completion: nil)
        
        //        UIView.animateWithDuration(0.10, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0.7, options: .CurveEaseInOut, animations:  {btn.transform = CGAffineTransformMakeScale(1.2, 1.2)}, completion: { (succeeded) in
        //            UIView.animateWithDuration(0.10, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0.6, options: .CurveEaseInOut, animations:  {btn.transform = CGAffineTransformMakeScale(1.0, 1.0)}, completion: nil)
        //        })
        return 0.35
    }
    
    func animateToEditMode() {
        UIView.animateWithDuration(0.35, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0.6, options: .CurveEaseInOut, animations:  {
            self.clearLogButton.alpha = 1.0
            self.clearLogButton.transform = CGAffineTransformMakeTranslation(0.0, 0.0)
            }, completion: nil)
        UIView.animateWithDuration(0.35, delay: 0.10, usingSpringWithDamping: 1, initialSpringVelocity: 0.6, options: .CurveEaseInOut, animations:  {
            self.hideAllButton.alpha = 1.0
            self.hideAllButton.transform = CGAffineTransformMakeTranslation(0.0, 0.0)
            }, completion: nil)
        UIView.animateWithDuration(0.35, delay: 0.20, usingSpringWithDamping: 1, initialSpringVelocity: 0.6, options: .CurveEaseInOut, animations:  {
            self.toggleInspectButton.alpha = 1.0
            self.toggleInspectButton.transform = CGAffineTransformMakeTranslation(0.0, 0.0)
            }, completion: nil)
        UIView.animateWithDuration(0.35, delay: 0.30, usingSpringWithDamping: 1, initialSpringVelocity: 0.6, options: .CurveEaseInOut, animations:  {
            self.shareButton.alpha = 1.0
            self.shareButton.transform = CGAffineTransformMakeTranslation(0.0, 0.0)
            }, completion: nil)
        
    }
    
    func animateCloseEditMode(duration: NSTimeInterval = 0.35) {
        UIView.animateWithDuration(0.35, delay: 0.30, usingSpringWithDamping: 1, initialSpringVelocity: 0.6, options: .CurveEaseInOut, animations:  {
            self.clearLogButton.alpha = 0.0
            self.clearLogButton.transform = CGAffineTransformMakeTranslation(75.0 + (3 * self.padding / 2), -(self.initialButtonY + self.padding))
            }, completion: { _ in self.unloadButton(self.clearLogButton) } )
        UIView.animateWithDuration(0.35, delay: 0.20, usingSpringWithDamping: 1, initialSpringVelocity: 0.6, options: .CurveEaseInOut, animations:  {
            self.hideAllButton.alpha = 0.0
            self.hideAllButton.transform = CGAffineTransformMakeTranslation(25.0 + (self.padding / 2), -(self.initialButtonY + self.padding))
            }, completion: { _ in self.unloadButton(self.hideAllButton) })
        UIView.animateWithDuration(0.35, delay: 0.10, usingSpringWithDamping: 1, initialSpringVelocity: 0.6, options: .CurveEaseInOut, animations:  {
            self.toggleInspectButton.alpha = 0.0
            self.toggleInspectButton.transform = CGAffineTransformMakeTranslation(-(25.0 + (self.padding / 2)), -(self.initialButtonY + self.padding))
            }, completion: { _ in self.unloadButton(self.toggleInspectButton) })
        UIView.animateWithDuration(0.35, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0.6, options: .CurveEaseInOut, animations:  {
            self.shareButton.alpha = 0.0
            self.shareButton.transform = CGAffineTransformMakeTranslation(-(75.0 + (3 * self.padding / 2)), -(self.initialButtonY + self.padding))
            }, completion: { _ in self.unloadButton(self.shareButton) })
    }
    
    func unloadButton(btn: UIButton) {
        var btn: UIButton! = btn
        btn.removeFromSuperview()
        btn = nil
    }
    
    func unloadLog() {
        logger = nil
        logView.removeFromSuperview()
        overlayView.removeFromSuperview()
        logView = nil
        overlayView = nil
    }
    
    func tearDown() {
        owner = nil
        logger = nil
        logView.removeFromSuperview()
        overlayView.removeFromSuperview()
        addDismissLogButton.removeFromSuperview()
        logView = nil
        overlayView = nil
        addDismissLogButton = nil
    }
    
    private func setUpLogger() {
        logger = Logger.sharedInstance
        logger.reset()
        
        defaultLoggerDependencies = LoggerDI(updateClosure: updater, promptString: "# ")
        logger.setDependencies(defaultLoggerDependencies)
    }
    
    private func updater(updatedLog: String) {
        guard logView != nil else {
            return
        }
        logView.text = updatedLog
        if logView.text.characters.count > 0 {
            logView.scrollRangeToVisible(NSMakeRange(logView.text.characters.count - 1, 0))
        }
    }
}
