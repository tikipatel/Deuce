//
//  ScoreManager.swift
//  Deuce
//
//  Created by Austin Conlon on 4/22/17.
//  Copyright © 2017 Austin Conlon. All rights reserved.
//

import Foundation
import WatchConnectivity

class ScoreManager: NSObject, WCSessionDelegate {
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(watchOS 2.2, *)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) { }
    
    // MARK: Properties
    
    enum MatchLength {
        case oneSet, bestOfThreeSets, bestOfFiveSets, bestOfSevenSets
    }
    
    enum SetType {
        case tiebreaker, advantage
    }
    
    enum Player {
        case first, second
    }
    
    var session: WCSession!
    static var matchLength: MatchLength?
    static var setType: SetType?
    static var server: Player?
    
    // MARK: Initialization
    
    override init() {
        super.init()
        
        if (WCSession.isSupported()) {
            session = WCSession.default()
            session.delegate = self // conforms to WCSessionDelegate
            session.activate()
        }
        
        if ((arc4random_uniform(2)) == 0) {
            ScoreManager.server = .first
        } else {
            ScoreManager.server = .second
        }
        
        session.sendMessage(["Server": ScoreManager.server as Any], replyHandler: nil) { (Error) in
            print(Error)
        }
    }
    
    // MARK: ScoreManager
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.sync {
        }
    }
}
