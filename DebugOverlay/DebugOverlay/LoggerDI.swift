//
//  LoggerDI.swift
//  Debug Overlay
//
//  Created by Joshua Kelley on 5/17/16.
//  Copyright © 2016 Joshua Kelley. All rights reserved.
//

/// "Dependency Injection" object for the Logger
struct LoggerDI {
    
    /// This closue can be used to update the View.
    let updateClosure: ((_ updatedLog: String) -> Void)
    
    /// The prompt string that will prepend any logged text.
    let promptString: String
}
