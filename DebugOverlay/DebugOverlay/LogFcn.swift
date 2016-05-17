//
//  LogFcn.swift
//  Debug Overlay
//
//  Created by Joshua Kelley on 5/17/16.
//  Copyright © 2016 Joshua Kelley. All rights reserved.
//

import Foundation

func Log(logText: String, copyToNS: Bool = true) {
    Logger.sharedInstance.log(logText)
    if copyToNS {
        NSLog(logText)
    }
}
