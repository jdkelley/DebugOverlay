//
//  ViewController.swift
//  Debug Overlay
//
//  Created by Joshua Kelley on 5/12/16.
//  Copyright © 2016 Joshua Kelley. All rights reserved.
//

import UIKit

class ExampleViewController: UIViewController {
    
    var overlay: OverLay?
    
    @IBAction func toggleDevMode(sender: AnyObject) {
        guard overlay == nil else {
            overlay?.tearDown()
            overlay = nil
            return
        }
        
        overlay = OverLay(vc: self, textMode: .Dark)
    }
    
    @IBOutlet weak var log1Button: UIButton!
    @IBOutlet weak var log2Button: UIButton!
    @IBOutlet weak var log3Button: UIButton!
    @IBOutlet weak var log4Button: UIButton!
    
    @IBAction func logButtonPress(sender: UIButton) {
        switch sender.tag {
        case 1:
            Log("Button 1 - This is an error")
        case 2:
            Log("Button 2 - Network errors are very long and contain function names \(#function)")
        case 3:
            Log("Button 3 - This is a Very, VERY, VERY,............., VERY long error.........................")
        case 4:
            Log("Button 4 - Notice: Don't log to NSLog", copyToNS: false)
        default:
            Log("ERROR!")
        }
    }
}
