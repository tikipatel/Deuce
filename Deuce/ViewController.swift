//
//  ViewController.swift
//  Deuce
//
//  Created by Austin Conlon on 11/27/16.
//  Copyright © 2016 Austin Conlon. All rights reserved.
//

import UIKit
import WatchConnectivity

class ViewController: UIViewController, WCSessionDelegate {
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(iOS 9.3, *)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) { }


    // MARK: Properties
    var session: WCSession!
    @IBOutlet weak var firstPlayerGameScoreLabel: UIButton!
    @IBOutlet weak var secondPlayerGameScoreLabel: UIButton!
    @IBOutlet weak var firstPlayerServingLabel: UILabel!
    @IBOutlet weak var secondPlayerServingLabel: UILabel!
    
    var matchLength: Int
    var setType: Int
    var settingsData: [String: Int]
    
    var isServing: server
    
    enum server {
        case opponent, you
    }
    
    var setScore: (Int, Int)
    var matchScore: (Int, Int)
    
    var opponentSetScore: Int
    var opponentGameScore: Int
    var opponentMatchScore: Int
    
    var yourSetScore: Int
    var yourGameScore: Int
    var yourMatchScore: Int
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        switch (WCSession.isSupported()) {
            case true:
                session = WCSession.`default`()
                session.delegate = self;
                session.activate()
            default:
                break
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        // Initialize properties here.
        matchLength = 1
        setType = 1
        settingsData = ["match length": matchLength, "set type": setType]
        isServing = server.you
        opponentSetScore = 0
        opponentGameScore = 0
        opponentMatchScore = 0
        yourSetScore = 0
        yourGameScore = 0
        yourMatchScore = 0
        setScore = (yourSetScore, opponentSetScore)
        matchScore = (yourMatchScore, opponentMatchScore)

        super.init(coder: aDecoder)!
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        // Initialize properties here.
        matchLength = 1
        setType = 1
        settingsData = ["match length": matchLength, "set type": setType]
        isServing = server.you
        opponentSetScore = 0
        opponentGameScore = 0
        opponentMatchScore = 0
        yourSetScore = 0
        yourGameScore = 0
        yourMatchScore = 0
        setScore = (yourSetScore, opponentSetScore)
        matchScore = (yourMatchScore, opponentMatchScore)

        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Mark: Actions
    
    @IBAction func incrementFirstPlayerScore(_ sender: Any) {
        let playerThatScored = ["Player that scored": "opponent"]
        session.sendMessage(playerThatScored, replyHandler: nil, errorHandler: {error in
            print(error)
        })
    }
    
    @IBAction func incrementSecondPlayerScore(_ sender: Any) {
        let playerThatScored = ["Player that scored": "you"]
        session.sendMessage(playerThatScored, replyHandler: nil, errorHandler: {error in
            print(error)
        })
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // Handle received message.
        var gameScoreValue: String
        var particularPlayerIsOpponentForUpdatingGameScore: Bool
        
        if let particularPlayerScore = message["Opponent's game score"] as? String {
            particularPlayerIsOpponentForUpdatingGameScore = true
            gameScoreValue = particularPlayerScore
        } else {
            particularPlayerIsOpponentForUpdatingGameScore = false
            gameScoreValue = (message["Your game score"] as? String)!
        }
        
        DispatchQueue.main.sync {
            if particularPlayerIsOpponentForUpdatingGameScore == true {
                self.firstPlayerGameScoreLabel.setTitle(gameScoreValue, for: .normal)
            } else {
                self.secondPlayerGameScoreLabel.setTitle(gameScoreValue, for: .normal)
            }
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // Begin the activation process for the new Apple Watch.
        session.activate()
    }
    
}
