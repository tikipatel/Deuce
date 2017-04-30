//
//  ScoreManager.swift
//  Deuce
//
//  Created by Austin Conlon on 3/25/17.
//  Copyright © 2017 Austin Conlon. All rights reserved.
//

import Foundation
import WatchConnectivity

let firstPlayer = ScoreManager(player: .first)
let secondPlayer = ScoreManager(player: .second)

class ScoreManager: NSObject, WCSessionDelegate {
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(iOS 9.3, *)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) { }
    
    // MARK: Properties
    
    var session: WCSession!
    
    enum SetTypes {
        case tiebreak, advantage
    }
    
    enum Player {
        case first, second
    }
    
    var matchLength = 1
    var setType = SetTypes.advantage
    
    static var server: Player?
    static var isInDeuceSituation = false
    static var isInTiebreakGame = false
    static var advantage: Player?
    
    var particularPlayer: Player
    var gameScore = 0
    var setScore = 0
    var matchScore = 0
    var playerWonMatch = false
    
    // MARK: Initialization
    
    init(player particularPlayer: Player) {
        self.particularPlayer = particularPlayer
        
        super.init()
        
        if (WCSession.isSupported()) {
            session = WCSession.default()
            session.delegate = self // conforms to WCSessionDelegate
            session.activate()
        }
    }
    
    // MARK: ScoreManager
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
//        if let server = message["Server"] {
//            ScoreManager.server = server as? ScoreManager.Player
//        }
//        DispatchQueue.main.sync {
//        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // Begin the activation process for the new Apple Watch.
        session.activate()
    }
    
    class func determineWhoServes() {
        if ((arc4random_uniform(2)) == 0) {
            ScoreManager.server = .first
        } else {
            ScoreManager.server = .second
        }
    }
    
    func incrementGameScore() {
        switch gameScore {
        case 0, 15:
            gameScore += 15
        case 30:
            switch particularPlayer {
            case .first:
                gameScore += 10
                if secondPlayer.gameScore == 40 {
                    ScoreManager.isInDeuceSituation = true
                }
            case .second:
                gameScore += 10
                if firstPlayer.gameScore == 40 {
                    ScoreManager.isInDeuceSituation = true
                }
            }
        case 40:
            switch particularPlayer {
            case .first:
                switch ScoreManager.isInDeuceSituation {
                case true:
                    ScoreManager.advantage = .first
                    ScoreManager.isInDeuceSituation = false
                case false:
                    ScoreManager.advantage = nil
                    ScoreManager.isInDeuceSituation = true
                }
            case .second:
                if ScoreManager.isInDeuceSituation {
                    ScoreManager.advantage = .second
                    ScoreManager.isInDeuceSituation = false
                } else {
                    ScoreManager.advantage = nil
                    ScoreManager.isInDeuceSituation = true
                }
            }
        default: // Advantage situation or further deuce situation
            if firstPlayer.gameScore == secondPlayer.gameScore { // Deuce
                switch particularPlayer { // Advantage situation
                case .first:
                    ScoreManager.advantage = .first
                case .second:
                    ScoreManager.advantage = .second
                }
            } else {
                switch particularPlayer {
                case .first:
                    if firstPlayer.gameScore == (secondPlayer.gameScore + 1) {
                        wonGame()
                    }
                case .second:
                    if secondPlayer.gameScore == (firstPlayer.gameScore + 1) {
                        wonGame()
                    }
                }
            }
        }
    }
    
    func wonGame() {
        firstPlayer.gameScore = 0
        secondPlayer.gameScore = 0
        incrementSetScore()
    }
    
    func wonSet() {
        setScore = 0
        incrementMatchScore()
    }
    
    func incrementSetScore() {
        switch setScore {
        case 0...4:
            setScore += 1
        case 5:
            if setScore <= 4 {
                wonSet()
            } else if (setScore >= 5) || (setScore >= setScore + 2) {
                if setType == .tiebreak && setScore == 6 {
                    wonSet()
                } else {
                    wonGame()
                }
            }
        default:
            if setScore >= setScore + 2 {
                wonSet()
            }
        }
    }
    
    func resetSetScore() {
        setScore = 0
    }
    
    func incrementMatchScore() {
        switch matchLength {
        case 3:
            matchScore += 1
            if matchScore == 2 {
                playerWonMatch = true
            }
        case 5:
            matchScore += 1
            if matchScore == 3 {
                playerWonMatch = true
            }
        case 7:
            matchScore += 1
            if matchScore == 4 {
                playerWonMatch = true
            }
        default:
            matchScore += 1
            playerWonMatch = true
        }
    }
}
