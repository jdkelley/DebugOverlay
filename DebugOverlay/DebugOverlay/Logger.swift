//
//  Logger.swift
//  Debug Overlay
//
//  Created by Joshua Kelley on 5/17/16.
//  Copyright © 2016 Joshua Kelley. All rights reserved.
//

import Foundation

/// This logger is a singleton. It holds a log of messages.
class Logger {
    
    // MARK: - Properties
    
    /// This holds the closure that can be used to update the View.
    private var updateClosure: ((updatedLog: String) -> Void)?
    
    /// This holds the prompt string that will prepend any logged message.
    private var promptString: String?
    
    /// The log. Access this use the getter (getLog()) and setter (log()).
    private var log: String = "" {
        didSet {
            updateClosure?(updatedLog: log)
        }
    }
    
    // MARK: Singleton
    
    /// Shared instance. Is threadsafe.
    static let sharedInstance = Logger()
    
    private init() { }
    
    // MARK: - Public API
    
    /// Append to log property
    func log(message: String) {
        log += ("\n\(promptString ?? "# ")" + message)
    }
    
    /// Returns the entire log property
    func getLog() -> String {
        return log
    }
    
    /// Sets the dependencies for the log. Combining this with 
    /// reset will effectively new up a new log.
    func setDependencies(dependencies: LoggerDI) {
        updateClosure = dependencies.updateClosure
        promptString = dependencies.promptString
    }
    
    /// Clears the log.
    func reset() {
        log = ""
    }
}
