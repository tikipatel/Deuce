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

//    required init(coder aDecoder: NSCoder) {
//        // Initialize properties here.
//        matchLength = 1
//        setType = 1
//        settingsData = ["match length": matchLength, "set type": setType]
//        isServing = server.you
//        opponentSetScore = 0
//        opponentGameScore = 0
//        opponentMatchScore = 0
//        yourSetScore = 0
//        yourGameScore = 0
//        yourMatchScore = 0
//        setScore = (yourSetScore, opponentSetScore)
//        matchScore = (yourMatchScore, opponentMatchScore)
//
//        super.init(coder aDecoder: NSCoder)
//    }
    
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
        if opponentGameScore <= 15 {
            opponentGameScore += 15
            
            firstPlayerGameScoreLabel.setTitle(String(opponentGameScore), for: .normal)
            let messageToSend = ["Opponent's game score": String(opponentGameScore)]
            session.sendMessage(messageToSend, replyHandler: nil, errorHandler: {error in
                // catch any errors here
                print(error)
            })
        } else if opponentGameScore == 30 {
            opponentGameScore += 10
            
            if yourGameScore <= 30 {
                firstPlayerGameScoreLabel.setTitle(String(opponentGameScore), for: .normal)
                let messageToSend = ["Opponent's game score": String(opponentGameScore)]
                session.sendMessage(messageToSend, replyHandler: nil, errorHandler: {error in
                    // catch any errors here
                    print(error)
                })
            } else if yourGameScore == 40 {
                firstPlayerGameScoreLabel.setTitle("Deuce", for: .normal)
                secondPlayerGameScoreLabel.setTitle("Deuce", for: .normal)
                let opponentGameScoreToSend = ["Opponent's game score": "Deuce"]
                session.sendMessage(opponentGameScoreToSend, replyHandler: nil, errorHandler: {error in
                    // catch any errors here
                    print(error)
                })
                let yourGameScoreToSend = ["Your game score": "Deuce"]
                session.sendMessage(yourGameScoreToSend, replyHandler: nil, errorHandler: {error in
                    // catch any errors here
                    print(error)
                })
            }
            
        } else if opponentGameScore == 40 && yourGameScore <= 30 {
//            if (opponentSetScore + yourSetScore) % 2 != 0 {
//                WKInterfaceDevice.current().play(WKHapticType.notification)
//            } else {
//                
//            }
            opponentSetScore += 1
//            switch isServing {
//            case server.opponent:
//                isServing = server.you
//                opponentServingIndicatorLabel.setHidden(true)
//                yourServingIndicatorLabel.setHidden(false)
//            case server.you:
//                isServing = server.opponent
//                opponentServingIndicatorLabel.setHidden(false)
//                yourServingIndicatorLabel.setHidden(true)
//            }
            setScore = (yourSetScore, opponentSetScore)
            
            opponentGameScore = 0
            yourGameScore = 0
            firstPlayerGameScoreLabel.setTitle("Love", for: .normal)
            secondPlayerGameScoreLabel.setTitle("Love", for: .normal)
//            opponentSetScoreLabel.setText(String(opponentSetScore))
            
            let opponentGameScoreToSend = ["Opponent's game score": "Love"]
            session.sendMessage(opponentGameScoreToSend, replyHandler: nil, errorHandler: {error in
                // catch any errors here
                print(error)
            })
            
            let opponentSetScoreToSend = ["Opponent's set score": String(opponentSetScore)]
            session.sendMessage(opponentSetScoreToSend, replyHandler: nil, errorHandler: {error in
                // catch any errors here
                print(error)
            })
        } else if opponentGameScore >= 40 {
            if opponentGameScore == yourGameScore {
                opponentGameScore += 1
                
                if isServing == .opponent {
                    firstPlayerGameScoreLabel.setTitle("Ad", for: .normal)
                    let messageToSend = ["Opponent's game score": "Ad in"]
                    session.sendMessage(messageToSend, replyHandler: nil, errorHandler: {error in
                        // catch any errors here
                        print(error)
                    })
                } else {
                    firstPlayerGameScoreLabel.setTitle("Ad", for: .normal)
                    let messageToSend = ["Opponent's game score": "Ad out"]
                    session.sendMessage(messageToSend, replyHandler: nil, errorHandler: {error in
                        // catch any errors here
                        print(error)
                    })
                }
                secondPlayerGameScoreLabel.setTitle("🎾", for: .normal)
                let messageToSend = ["Your game score": ""]
                session.sendMessage(messageToSend, replyHandler: nil, errorHandler: {error in
                    // catch any errors here
                    print(error)
                })
            } else if opponentGameScore < yourGameScore {
                opponentGameScore += 1
                
                firstPlayerGameScoreLabel.setTitle("Deuce", for: .normal)
                secondPlayerGameScoreLabel.setTitle("Deuce", for: .normal)
                let opponentGameScoreToSend = ["Opponent's game score": "Deuce"]
                session.sendMessage(opponentGameScoreToSend, replyHandler: nil, errorHandler: {error in
                    // catch any errors here
                    print(error)
                })
                let yourGameScoreToSend = ["Your game score": "Deuce"]
                session.sendMessage(yourGameScoreToSend, replyHandler: nil, errorHandler: {error in
                    // catch any errors here
                    print(error)
                })
            } else if opponentGameScore > yourGameScore {
//                if (opponentSetScore + yourSetScore) % 2 != 0 {
//                    WKInterfaceDevice.current().play(WKHapticType.notification)
//                } else {
//                    
//                }
                opponentSetScore += 1
//                switch isServing {
//                case server.opponent:
//                    isServing = server.you
//                    opponentServingIndicatorLabel.setHidden(true)
//                    yourServingIndicatorLabel.setHidden(false)
//                    
//                    
//                case server.you:
//                    isServing = server.opponent
//                    opponentServingIndicatorLabel.setHidden(false)
//                    yourServingIndicatorLabel.setHidden(true)
//                    
//                    
//                }
                setScore = (yourSetScore, opponentSetScore)
                
                opponentGameScore = 0
                yourGameScore = 0
                firstPlayerGameScoreLabel.setTitle("Love", for: .normal)
                secondPlayerGameScoreLabel.setTitle("Love", for: .normal)
                let opponentGameScoreToSend = ["Opponent's game score": "Love"]
                session.sendMessage(opponentGameScoreToSend, replyHandler: nil, errorHandler: {error in
                    // catch any errors here
                    print(error)
                })
                let yourGameScoreToSend = ["Your game score": "Love"]
                session.sendMessage(yourGameScoreToSend, replyHandler: nil, errorHandler: {error in
                    // catch any errors here
                    print(error)
                })
                let opponentSetScoreToSend = ["Opponent's set score": String(opponentSetScore)]
                session.sendMessage(opponentSetScoreToSend, replyHandler: nil, errorHandler: {error in
                    // catch any errors here
                    print(error)
                })
            }
        }
        
        switch setType {
        case 0:
            switch setScore {
            case (0...4, 6):
                opponentGameScore = 0
                yourGameScore = 0
                setScore = (0, 0)
                opponentSetScore = 0
                let opponentSetScoreToSend = ["Opponent's set score": String(opponentSetScore)]
                session.sendMessage(opponentSetScoreToSend, replyHandler: nil, errorHandler: {error in
                    print(error)
                })
                yourSetScore = 0
//                yourSetScoreLabel.setText(String(yourSetScore))
                switch matchLength {
                case 3:
                    switch matchScore {
                    case (0...1, 1):
                        opponentMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                        
                        firstPlayerGameScoreLabel.setTitle("🏆", for: .normal)
                        secondPlayerGameScoreLabel.setTitle("", for: .normal)
                        
                        let yourServingIndicatorToSend = ["Your serving indicator": ""]
                        session.sendMessage(yourServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourGameScoreToSend = ["Your game score": ""]
                        session.sendMessage(yourGameScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourSetScoreToSend = ["Your set score": ""]
                        session.sendMessage(yourSetScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourMatchScoreToSend = ["Your match score": String(yourMatchScore)]
                        session.sendMessage(yourMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentServingIndicatorToSend = ["Opponent's serving indicator": ""]
                        session.sendMessage(opponentServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentGameScoreToSend = ["Opponent's game score": "🏆"]
                        session.sendMessage(opponentGameScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentSetScoreToSend = ["Opponent's set score": ""]
                        session.sendMessage(opponentSetScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentMatchScoreToSend = ["Opponent's match score": String(opponentMatchScore)]
                        session.sendMessage(opponentMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                    default:
                        opponentMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                        
                        let opponentMatchScoreToSend = ["Opponent's match score": String(opponentMatchScore)]
                        session.sendMessage(opponentMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                    }
                case 5:
                    switch matchScore {
                    case (0...2, 2):
                        opponentMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                        
                        firstPlayerGameScoreLabel.setTitle("🏆", for: .normal)
                        secondPlayerGameScoreLabel.setTitle("", for: .normal)
                        
                        let yourServingIndicatorToSend = ["Your serving indicator": ""]
                        session.sendMessage(yourServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourGameScoreToSend = ["Your game score": ""]
                        session.sendMessage(yourGameScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourSetScoreToSend = ["Your set score": ""]
                        session.sendMessage(yourSetScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourMatchScoreToSend = ["Your match score": String(yourMatchScore)]
                        session.sendMessage(yourMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentServingIndicatorToSend = ["Opponent's serving indicator": ""]
                        session.sendMessage(opponentServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentGameScoreToSend = ["Opponent's game score": "🏆"]
                        session.sendMessage(opponentGameScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentSetScoreToSend = ["Opponent's set score": ""]
                        session.sendMessage(opponentSetScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentMatchScoreToSend = ["Opponent's match score": String(opponentMatchScore)]
                        session.sendMessage(opponentMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                    default:
                        opponentMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                        
                        let opponentMatchScoreToSend = ["Opponent's match score": String(opponentMatchScore)]
                        session.sendMessage(opponentMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                    }
                case 7:
                    switch matchScore {
                    case (0...3, 3):
                        opponentMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                        
                        firstPlayerGameScoreLabel.setTitle("🏆", for: .normal)
                        secondPlayerGameScoreLabel.setTitle("", for: .normal)
                        
                        let yourServingIndicatorToSend = ["Your serving indicator": ""]
                        session.sendMessage(yourServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourGameScoreToSend = ["Your game score": ""]
                        session.sendMessage(yourGameScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourSetScoreToSend = ["Your set score": ""]
                        session.sendMessage(yourSetScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourMatchScoreToSend = ["Your match score": String(yourMatchScore)]
                        session.sendMessage(yourMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentServingIndicatorToSend = ["Opponent's serving indicator": ""]
                        session.sendMessage(opponentServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })

                        let opponentGameScoreToSend = ["Opponent's game score": "🏆"]
                        session.sendMessage(opponentGameScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentSetScoreToSend = ["Opponent's set score": ""]
                        session.sendMessage(opponentSetScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentMatchScoreToSend = ["Opponent's match score": String(opponentMatchScore)]
                        session.sendMessage(opponentMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                    default:
                        opponentMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                        
                        let opponentMatchScoreToSend = ["Opponent's match score": String(opponentMatchScore)]
                        session.sendMessage(opponentMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                    }
                default:
                    switch matchScore {
                    case (0, 0):
                        opponentMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                        
                        firstPlayerGameScoreLabel.setTitle("🏆", for: .normal)
                        secondPlayerGameScoreLabel.setTitle("", for: .normal)
                        
                        let yourServingIndicatorToSend = ["Your serving indicator": ""]
                        session.sendMessage(yourServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourGameScoreToSend = ["Your game score": ""]
                        session.sendMessage(yourGameScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourSetScoreToSend = ["Your set score": ""]
                        session.sendMessage(yourSetScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourMatchScoreToSend = ["Your match score": String(yourMatchScore)]
                        session.sendMessage(yourMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentServingIndicatorToSend = ["Opponent's serving indicator": ""]
                        session.sendMessage(opponentServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentGameScoreToSend = ["Opponent's game score": "🏆"]
                        session.sendMessage(opponentGameScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentSetScoreToSend = ["Opponent's set score": ""]
                        session.sendMessage(opponentSetScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentMatchScoreToSend = ["Opponent's match score": String(opponentMatchScore)]
                        session.sendMessage(opponentMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                    default:
                        opponentMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                        
                        let opponentMatchScoreToSend = ["Opponent's match score": String(opponentMatchScore)]
                        session.sendMessage(opponentMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                    }
                }
            case (6, 6): break
//                opponentSetScoreLabel.setText("Tiebreaker")
//                yourSetScoreLabel.setText("Tiebreaker")
            case (5...6, 7):
                setScore = (0, 0)
                opponentSetScore = 0
                yourSetScore = 0
                opponentMatchScore += 1
//                opponentSetScoreLabel.setText("0")
//                yourSetScoreLabel.setText("0")
//                opponentMatchScoreLabel.setText(String(opponentMatchScore))
//                yourMatchScoreLabel.setText(String(yourMatchScore))
                switch matchLength {
                case 3:
                    switch matchScore {
                    case (0...1, 1):
                        opponentMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                        
                        firstPlayerGameScoreLabel.setTitle("🏆", for: .normal)
                        secondPlayerGameScoreLabel.setTitle("", for: .normal)
                        
                        let yourServingIndicatorToSend = ["Your serving indicator": ""]
                        session.sendMessage(yourServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourGameScoreToSend = ["Your game score": ""]
                        session.sendMessage(yourGameScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourSetScoreToSend = ["Your set score": ""]
                        session.sendMessage(yourSetScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourMatchScoreToSend = ["Your match score": String(yourMatchScore)]
                        session.sendMessage(yourMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentServingIndicatorToSend = ["Opponent's serving indicator": ""]
                        session.sendMessage(opponentServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentGameScoreToSend = ["Opponent's game score": "🏆"]
                        session.sendMessage(opponentGameScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentSetScoreToSend = ["Opponent's set score": ""]
                        session.sendMessage(opponentSetScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentMatchScoreToSend = ["Opponent's match score": String(opponentMatchScore)]
                        session.sendMessage(opponentMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                    default:
                        opponentMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                        
                        firstPlayerGameScoreLabel.setTitle("🏆", for: .normal)
                        secondPlayerGameScoreLabel.setTitle("", for: .normal)
                        
                        let opponentMatchScoreToSend = ["Opponent's match score": String(opponentMatchScore)]
                        session.sendMessage(opponentMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                    }
                case 5:
                    switch matchScore {
                    case (0...2, 2):
                        opponentMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                        
                        firstPlayerGameScoreLabel.setTitle("🏆", for: .normal)
                        secondPlayerGameScoreLabel.setTitle("", for: .normal)
                        
                        let yourServingIndicatorToSend = ["Your serving indicator": ""]
                        session.sendMessage(yourServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourGameScoreToSend = ["Your game score": ""]
                        session.sendMessage(yourGameScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourSetScoreToSend = ["Your set score": ""]
                        session.sendMessage(yourSetScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourMatchScoreToSend = ["Your match score": String(yourMatchScore)]
                        session.sendMessage(yourMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentServingIndicatorToSend = ["Opponent's serving indicator": ""]
                        session.sendMessage(opponentServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentGameScoreToSend = ["Opponent's game score": "🏆"]
                        session.sendMessage(opponentGameScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentSetScoreToSend = ["Opponent's set score": ""]
                        session.sendMessage(opponentSetScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentMatchScoreToSend = ["Opponent's match score": String(opponentMatchScore)]
                        session.sendMessage(opponentMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                    default:
                        opponentMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                        
                        let opponentMatchScoreToSend = ["Opponent's match score": String(opponentMatchScore)]
                        session.sendMessage(opponentMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                    }
                case 7:
                    switch matchScore {
                    case (0...3, 3):
                        opponentMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                        
                        firstPlayerGameScoreLabel.setTitle("🏆", for: .normal)
                        secondPlayerGameScoreLabel.setTitle("", for: .normal)
                        
                        let yourServingIndicatorToSend = ["Your serving indicator": ""]
                        session.sendMessage(yourServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourGameScoreToSend = ["Your game score": ""]
                        session.sendMessage(yourGameScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourSetScoreToSend = ["Your set score": ""]
                        session.sendMessage(yourSetScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourMatchScoreToSend = ["Your match score": String(yourMatchScore)]
                        session.sendMessage(yourMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentServingIndicatorToSend = ["Opponent's serving indicator": ""]
                        session.sendMessage(opponentServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentGameScoreToSend = ["Opponent's game score": "🏆"]
                        session.sendMessage(opponentGameScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentSetScoreToSend = ["Opponent's set score": ""]
                        session.sendMessage(opponentSetScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentMatchScoreToSend = ["Opponent's match score": String(opponentMatchScore)]
                        session.sendMessage(opponentMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                    default:
                        opponentMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                        
                        let opponentMatchScoreToSend = ["Opponent's match score": String(opponentMatchScore)]
                        session.sendMessage(opponentMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                    }
                default:
                    switch matchScore {
                    case (0, 0):
                        opponentMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                        
                        firstPlayerGameScoreLabel.setTitle("🏆", for: .normal)
                        secondPlayerGameScoreLabel.setTitle("", for: .normal)
                        
                        let yourServingIndicatorToSend = ["Your serving indicator": ""]
                        session.sendMessage(yourServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourGameScoreToSend = ["Your game score": ""]
                        session.sendMessage(yourGameScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourSetScoreToSend = ["Your set score": ""]
                        session.sendMessage(yourSetScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourMatchScoreToSend = ["Your match score": String(yourMatchScore)]
                        session.sendMessage(yourMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentServingIndicatorToSend = ["Opponent's serving indicator": ""]
                        session.sendMessage(opponentServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentGameScoreToSend = ["Opponent's game score": "🏆"]
                        session.sendMessage(opponentGameScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentSetScoreToSend = ["Opponent's set score": ""]
                        session.sendMessage(opponentSetScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentMatchScoreToSend = ["Opponent's match score": String(opponentMatchScore)]
                        session.sendMessage(opponentMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                    default:
                        opponentMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                        
                        let opponentMatchScoreToSend = ["Opponent's match score": String(opponentMatchScore)]
                        session.sendMessage(opponentMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                    }
                }
                let opponentMatchScoreToSend = ["Opponent's match score": String(opponentMatchScore)]
                session.sendMessage(opponentMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                    print(error)
                })
            default:
                break
            }
        // Advantage set
        default:
            switch setScore {
            case (0...4, 6):
                opponentGameScore = 0
                yourGameScore = 0
                setScore = (0, 0)
                opponentSetScore = 0
                let opponentSetScoreToSend = ["Opponent's set score": String(opponentSetScore)]
                session.sendMessage(opponentSetScoreToSend, replyHandler: nil, errorHandler: {error in
                    print(error)
                })
                yourSetScore = 0
//                yourSetScoreLabel.setText(String(yourSetScore))
                switch matchLength {
                case 3:
                    switch matchScore {
                    case (0...1, 1):
                        opponentMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                        
                        firstPlayerGameScoreLabel.setTitle("🏆", for: .normal)
                        secondPlayerGameScoreLabel.setTitle("", for: .normal)
                        
                        let yourServingIndicatorToSend = ["Your serving indicator": ""]
                        session.sendMessage(yourServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourGameScoreToSend = ["Your game score": ""]
                        session.sendMessage(yourGameScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourSetScoreToSend = ["Your set score": ""]
                        session.sendMessage(yourSetScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourMatchScoreToSend = ["Your match score": String(yourMatchScore)]
                        session.sendMessage(yourMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentServingIndicatorToSend = ["Opponent's serving indicator": ""]
                        session.sendMessage(opponentServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentGameScoreToSend = ["Opponent's game score": "🏆"]
                        session.sendMessage(opponentGameScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentSetScoreToSend = ["Opponent's set score": ""]
                        session.sendMessage(opponentSetScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentMatchScoreToSend = ["Opponent's match score": String(opponentMatchScore)]
                        session.sendMessage(opponentMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                    default:
                        opponentMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                        
                        let opponentMatchScoreToSend = ["Opponent's match score": String(opponentMatchScore)]
                        session.sendMessage(opponentMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                    }
                case 5:
                    switch matchScore {
                    case (0...2, 2):
                        opponentMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                        
                        firstPlayerGameScoreLabel.setTitle("🏆", for: .normal)
                        secondPlayerGameScoreLabel.setTitle("", for: .normal)
                        
                        let yourServingIndicatorToSend = ["Your serving indicator": ""]
                        session.sendMessage(yourServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourGameScoreToSend = ["Your game score": ""]
                        session.sendMessage(yourGameScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourSetScoreToSend = ["Your set score": ""]
                        session.sendMessage(yourSetScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourMatchScoreToSend = ["Your match score": String(yourMatchScore)]
                        session.sendMessage(yourMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentServingIndicatorToSend = ["Opponent's serving indicator": ""]
                        session.sendMessage(opponentServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentGameScoreToSend = ["Opponent's game score": "🏆"]
                        session.sendMessage(opponentGameScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentSetScoreToSend = ["Opponent's set score": ""]
                        session.sendMessage(opponentSetScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentMatchScoreToSend = ["Opponent's match score": String(opponentMatchScore)]
                        session.sendMessage(opponentMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                    default:
                        opponentMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                        
                        let opponentMatchScoreToSend = ["Opponent's match score": String(opponentMatchScore)]
                        session.sendMessage(opponentMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                    }
                case 7:
                    switch matchScore {
                    case (0...3, 3):
                        opponentMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                        
                        firstPlayerGameScoreLabel.setTitle("🏆", for: .normal)
                        secondPlayerGameScoreLabel.setTitle("", for: .normal)
                        
                        let yourServingIndicatorToSend = ["Your serving indicator": ""]
                        session.sendMessage(yourServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourGameScoreToSend = ["Your game score": ""]
                        session.sendMessage(yourGameScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourSetScoreToSend = ["Your set score": ""]
                        session.sendMessage(yourSetScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourMatchScoreToSend = ["Your match score": String(yourMatchScore)]
                        session.sendMessage(yourMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentServingIndicatorToSend = ["Opponent's serving indicator": ""]
                        session.sendMessage(opponentServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentGameScoreToSend = ["Opponent's game score": "🏆"]
                        session.sendMessage(opponentGameScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentSetScoreToSend = ["Opponent's set score": ""]
                        session.sendMessage(opponentSetScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentMatchScoreToSend = ["Opponent's match score": String(opponentMatchScore)]
                        session.sendMessage(opponentMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                    default:
                        opponentMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                        
                        let opponentMatchScoreToSend = ["Opponent's match score": String(opponentMatchScore)]
                        session.sendMessage(opponentMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                    }
                default:
                    opponentMatchScore += 1
                    matchScore = (yourMatchScore, opponentMatchScore)
                    
                    firstPlayerGameScoreLabel.setTitle("🏆", for: .normal)
                    secondPlayerGameScoreLabel.setTitle("", for: .normal)
                    
                    let yourServingIndicatorToSend = ["Your serving indicator": ""]
                    session.sendMessage(yourServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                        print(error)
                    })
                    
                    let yourGameScoreToSend = ["Your game score": ""]
                    session.sendMessage(yourGameScoreToSend, replyHandler: nil, errorHandler: {error in
                        print(error)
                    })
                    
                    let yourSetScoreToSend = ["Your set score": ""]
                    session.sendMessage(yourSetScoreToSend, replyHandler: nil, errorHandler: {error in
                        print(error)
                    })
                    
                    let yourMatchScoreToSend = ["Your match score": String(yourMatchScore)]
                    session.sendMessage(yourMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                        print(error)
                    })
                    
                    let opponentServingIndicatorToSend = ["Opponent's serving indicator": ""]
                    session.sendMessage(opponentServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                        print(error)
                    })
                    
                    let opponentGameScoreToSend = ["Opponent's game score": "🏆"]
                    session.sendMessage(opponentGameScoreToSend, replyHandler: nil, errorHandler: {error in
                        print(error)
                    })
                    
                    let opponentSetScoreToSend = ["Opponent's set score": ""]
                    session.sendMessage(opponentSetScoreToSend, replyHandler: nil, errorHandler: {error in
                        print(error)
                    })
                    
                    let opponentMatchScoreToSend = ["Opponent's match score": String(opponentMatchScore)]
                    session.sendMessage(opponentMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                        print(error)
                    })
                }
//                opponentMatchScoreLabel.setText(String(opponentMatchScore))
            default:
                if (opponentSetScore > yourSetScore + 1) && (yourSetScore >= 5) {
                    opponentGameScore = 0
                    yourGameScore = 0
                    setScore = (0, 0)
                    opponentSetScore = 0
//                    opponentSetScoreLabel.setText(String(opponentSetScore))
                    yourSetScore = 0
//                    yourSetScoreLabel.setText(String(yourSetScore))
                    switch matchLength {
                    case 3:
                        switch matchScore {
                        case (0...1, 1):
                            opponentMatchScore += 1
                            matchScore = (yourMatchScore, opponentMatchScore)
                            
                            firstPlayerGameScoreLabel.setTitle("🏆", for: .normal)
                            secondPlayerGameScoreLabel.setTitle("", for: .normal)
                            
                            let yourServingIndicatorToSend = ["Your serving indicator": ""]
                            session.sendMessage(yourServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                            
                            let yourGameScoreToSend = ["Your game score": ""]
                            session.sendMessage(yourGameScoreToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                            
                            let yourSetScoreToSend = ["Your set score": ""]
                            session.sendMessage(yourSetScoreToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                            
                            let yourMatchScoreToSend = ["Your match score": String(yourMatchScore)]
                            session.sendMessage(yourMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                            
                            let opponentServingIndicatorToSend = ["Opponent's serving indicator": ""]
                            session.sendMessage(opponentServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                            
                            let opponentGameScoreToSend = ["Opponent's game score": "🏆"]
                            session.sendMessage(opponentGameScoreToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                            
                            let opponentSetScoreToSend = ["Opponent's set score": ""]
                            session.sendMessage(opponentSetScoreToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                            
                            let opponentMatchScoreToSend = ["Opponent's match score": String(opponentMatchScore)]
                            session.sendMessage(opponentMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                        default:
                            opponentMatchScore += 1
                            matchScore = (yourMatchScore, opponentMatchScore)
                            
                            let opponentMatchScoreToSend = ["Opponent's match score": String(opponentMatchScore)]
                            session.sendMessage(opponentMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                        }
                    case 5:
                        switch matchScore {
                        case (0...2, 2):
                            opponentMatchScore += 1
                            matchScore = (yourMatchScore, opponentMatchScore)
                            
                            firstPlayerGameScoreLabel.setTitle("🏆", for: .normal)
                            secondPlayerGameScoreLabel.setTitle("", for: .normal)
                            
                            let yourServingIndicatorToSend = ["Your serving indicator": ""]
                            session.sendMessage(yourServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                            
                            let yourGameScoreToSend = ["Your game score": ""]
                            session.sendMessage(yourGameScoreToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                            
                            let yourSetScoreToSend = ["Your set score": ""]
                            session.sendMessage(yourSetScoreToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                            
                            let yourMatchScoreToSend = ["Your match score": String(yourMatchScore)]
                            session.sendMessage(yourMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                            
                            let opponentServingIndicatorToSend = ["Opponent's serving indicator": ""]
                            session.sendMessage(opponentServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                            
                            let opponentGameScoreToSend = ["Opponent's game score": "🏆"]
                            session.sendMessage(opponentGameScoreToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                            
                            let opponentSetScoreToSend = ["Opponent's set score": ""]
                            session.sendMessage(opponentSetScoreToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                            
                            let opponentMatchScoreToSend = ["Opponent's match score": String(opponentMatchScore)]
                            session.sendMessage(opponentMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                        default:
                            opponentMatchScore += 1
                            matchScore = (yourMatchScore, opponentMatchScore)
                            
                            let opponentMatchScoreToSend = ["Opponent's match score": String(opponentMatchScore)]
                            session.sendMessage(opponentMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                        }
                    case 7:
                        switch matchScore {
                        case (0...3, 3):
                            opponentMatchScore += 1
                            matchScore = (yourMatchScore, opponentMatchScore)
                            
                            firstPlayerGameScoreLabel.setTitle("🏆", for: .normal)
                            secondPlayerGameScoreLabel.setTitle("", for: .normal)
                            
                            let yourServingIndicatorToSend = ["Your serving indicator": ""]
                            session.sendMessage(yourServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                            
                            let yourGameScoreToSend = ["Your game score": ""]
                            session.sendMessage(yourGameScoreToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                            
                            let yourSetScoreToSend = ["Your set score": ""]
                            session.sendMessage(yourSetScoreToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                            
                            let yourMatchScoreToSend = ["Your match score": String(yourMatchScore)]
                            session.sendMessage(yourMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                            
                            let opponentServingIndicatorToSend = ["Opponent's serving indicator": ""]
                            session.sendMessage(opponentServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                            
                            let opponentGameScoreToSend = ["Opponent's game score": "🏆"]
                            session.sendMessage(opponentGameScoreToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                            
                            let opponentSetScoreToSend = ["Opponent's set score": ""]
                            session.sendMessage(opponentSetScoreToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                            
                            let opponentMatchScoreToSend = ["Opponent's match score": String(opponentMatchScore)]
                            session.sendMessage(opponentMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                        default:
                            opponentMatchScore += 1
                            matchScore = (yourMatchScore, opponentMatchScore)
                            
                            let opponentMatchScoreToSend = ["Opponent's match score": String(opponentMatchScore)]
                            session.sendMessage(opponentMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })                        }
                    default:
                        opponentMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                        
                        let opponentMatchScoreToSend = ["Opponent's match score": String(opponentMatchScore)]
                        session.sendMessage(opponentMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                    }
                }
            }
        }
    }
    
    @IBAction func incrementSecondPlayerScore(_ sender: Any) {
        if yourGameScore <= 15 {
            yourGameScore += 15
            
            secondPlayerGameScoreLabel.setTitle(String(yourGameScore), for: .normal)
            let messageToSend = ["Your game score": String(yourGameScore)]
            session.sendMessage(messageToSend, replyHandler: nil, errorHandler: {error in
                // catch any errors here
                print(error)
            })
        } else if yourGameScore == 30 {
            yourGameScore += 10
            
            if opponentGameScore <= 30 {
                secondPlayerGameScoreLabel.setTitle(String (yourGameScore), for: .normal)
                let messageToSend = ["Your game score": String(yourGameScore)]
                session.sendMessage(messageToSend, replyHandler: nil, errorHandler: {error in
                    // catch any errors here
                    print(error)
                })
            } else if opponentGameScore == 40 {
                firstPlayerGameScoreLabel.setTitle("Deuce", for: .normal)
                secondPlayerGameScoreLabel.setTitle("Deuce", for: .normal)
                let opponentGameScoreToSend = ["Opponent's game score": "Deuce"]
                session.sendMessage(opponentGameScoreToSend, replyHandler: nil, errorHandler: {error in
                    // catch any errors here
                    print(error)
                })
                let yourGameScoreToSend = ["Your game score": "Deuce"]
                session.sendMessage(yourGameScoreToSend, replyHandler: nil, errorHandler: {error in
                    // catch any errors here
                    print(error)
                })
            }
            
        } else if yourGameScore == 40 && opponentGameScore <= 30 {
//            if (opponentSetScore + yourSetScore) % 2 != 0 {
//                WKInterfaceDevice.current().play(WKHapticType.notification)
//            } else {
//                
//            }
            yourSetScore += 1
//            switch isServing {
//            case server.opponent:
//                isServing = server.you
//                opponentServingIndicatorLabel.setHidden(true)
//                yourServingIndicatorLabel.setHidden(false)
//                
//            case server.you:
//                isServing = server.opponent
//                opponentServingIndicatorLabel.setHidden(false)
//                yourServingIndicatorLabel.setHidden(true)
//                
//            }
//            if (opponentSetScore + yourSetScore) % 2 == 0 {
//                WKInterfaceDevice.current().play(WKHapticType.notification)
//            }
            setScore = (yourSetScore, opponentSetScore)
            
            opponentGameScore = 0
            yourGameScore = 0
            firstPlayerGameScoreLabel.setTitle("Love", for: .normal)
            secondPlayerGameScoreLabel.setTitle("Love", for: .normal)
//            yourSetScoreLabel.setText(String(yourSetScore))
            
            let opponentGameScoreToSend = ["Opponent's game score": "Love"]
            session.sendMessage(opponentGameScoreToSend, replyHandler: nil, errorHandler: {error in
                // catch any errors here
                print(error)
            })
            
            let yourGameScoreToSend = ["Your game score": "Love"]
            session.sendMessage(yourGameScoreToSend, replyHandler: nil, errorHandler: {error in
                // catch any errors here
                print(error)
            })
            
            let yourSetScoreToSend = ["Your set score": String(yourSetScore)]
            session.sendMessage(yourSetScoreToSend, replyHandler: nil, errorHandler: {error in
                // catch any errors here
                print(error)
            })
        } else if yourGameScore >= 40 {
            if yourGameScore == opponentGameScore {
                yourGameScore += 1
                
                if isServing == .you {
                    secondPlayerGameScoreLabel.setTitle("Ad", for: .normal)
                    let yourGameScoreToSend = ["Your game score": "Ad in"]
                    session.sendMessage(yourGameScoreToSend, replyHandler: nil, errorHandler: {error in
                        // catch any errors here
                        print(error)
                    })
                } else {
                    secondPlayerGameScoreLabel.setTitle("Ad", for: .normal)
                    let yourGameScoreToSend = ["Your game score": "Ad out"]
                    session.sendMessage(yourGameScoreToSend, replyHandler: nil, errorHandler: {error in
                        // catch any errors here
                        print(error)
                    })
                }
                firstPlayerGameScoreLabel.setTitle("🎾", for: .normal)
                let opponentGameScoreToSend = ["Opponent's game score": ""]
                session.sendMessage(opponentGameScoreToSend, replyHandler: nil, errorHandler: {error in
                    // catch any errors here
                    print(error)
                })
            } else if yourGameScore < opponentGameScore {
                yourGameScore += 1
                
                secondPlayerGameScoreLabel.setTitle("Deuce", for: .normal)
                firstPlayerGameScoreLabel.setTitle("Deuce", for: .normal)
                let opponentGameScoreToSend = ["Opponent's game score": "Deuce"]
                session.sendMessage(opponentGameScoreToSend, replyHandler: nil, errorHandler: {error in
                    // catch any errors here
                    print(error)
                })
                let yourGameScoreToSend = ["Your game score": "Deuce"]
                session.sendMessage(yourGameScoreToSend, replyHandler: nil, errorHandler: {error in
                    // catch any errors here
                    print(error)
                })
            } else if yourGameScore > opponentGameScore {
//                if (opponentSetScore + yourSetScore) % 2 != 0 {
//                    WKInterfaceDevice.current().play(WKHapticType.notification)
//                } else {
//                    
//                }
                yourSetScore += 1
//                switch isServing {
//                case server.opponent:
//                    isServing = server.you
//                    opponentServingIndicatorLabel.setHidden(true)
//                    yourServingIndicatorLabel.setHidden(false)
//                    
//                    
//                case server.you:
//                    isServing = server.opponent
//                    opponentServingIndicatorLabel.setHidden(false)
//                    yourServingIndicatorLabel.setHidden(true)
//                    
//                    
//                }
                setScore = (yourSetScore, opponentSetScore)
                
                yourGameScore = 0
                opponentGameScore = 0
                secondPlayerGameScoreLabel.setTitle("Love", for: .normal)
                firstPlayerGameScoreLabel.setTitle("Love", for: .normal)
//                yourSetScoreLabel.setText(String(yourSetScore))
                
                let opponentGameScoreToSend = ["Opponent's game score": "Love"]
                session.sendMessage(opponentGameScoreToSend, replyHandler: nil, errorHandler: {error in
                    // catch any errors here
                    print(error)
                })
                
                let yourGameScoreToSend = ["Your game score": "Love"]
                session.sendMessage(yourGameScoreToSend, replyHandler: nil, errorHandler: {error in
                    // catch any errors here
                    print(error)
                })
                
                let yourSetScoreToSend = ["Your set score": String(yourSetScore)]
                session.sendMessage(yourSetScoreToSend, replyHandler: nil, errorHandler: {error in
                    // catch any errors here
                    print(error)
                })
            }
        }
        
        switch setType {
        case 0:
            switch setScore {
            case (6, 0...4):
                opponentGameScore = 0
                yourGameScore = 0
                setScore = (0, 0)
                opponentSetScore = 0
                let opponentSetScoreToSend = ["Opponent's set score": String(opponentSetScore)]
                session.sendMessage(opponentSetScoreToSend, replyHandler: nil, errorHandler: {error in
                    print(error)
                })
                yourSetScore = 0
//                yourSetScoreLabel.setText(String(yourSetScore))
                switch matchLength {
                case 3:
                    switch matchScore {
                    case (1, 0...1):
                        yourMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                        
                        firstPlayerGameScoreLabel.setTitle("", for: .normal)
                        secondPlayerGameScoreLabel.setTitle("🏆", for: .normal)
                        
                        let yourServingIndicatorToSend = ["Your serving indicator": ""]
                        session.sendMessage(yourServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourGameScoreToSend = ["Your game score": "🏆"]
                        session.sendMessage(yourGameScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourSetScoreToSend = ["Your set score": ""]
                        session.sendMessage(yourSetScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourMatchScoreToSend = ["Your match score": String(yourMatchScore)]
                        session.sendMessage(yourMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentServingIndicatorToSend = ["Opponent's serving indicator": ""]
                        session.sendMessage(opponentServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentGameScoreToSend = ["Opponent's game score": ""]
                        session.sendMessage(opponentGameScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentSetScoreToSend = ["Opponent's set score": ""]
                        session.sendMessage(opponentSetScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentMatchScoreToSend = ["Opponent's match score": String(opponentMatchScore)]
                        session.sendMessage(opponentMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                    default:
                        yourMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                        
                        let yourMatchScoreToSend = ["Your match score": String(yourMatchScore)]
                        session.sendMessage(yourMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                    }
                case 5:
                    switch matchScore {
                    case (2, 0...2):
                        yourMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                        
                        firstPlayerGameScoreLabel.setTitle("", for: .normal)
                        secondPlayerGameScoreLabel.setTitle("🏆", for: .normal)
                        
                        let yourServingIndicatorToSend = ["Your serving indicator": ""]
                        session.sendMessage(yourServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourGameScoreToSend = ["Your game score": "🏆"]
                        session.sendMessage(yourGameScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourSetScoreToSend = ["Your set score": ""]
                        session.sendMessage(yourSetScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourMatchScoreToSend = ["Your match score": String(yourMatchScore)]
                        session.sendMessage(yourMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentServingIndicatorToSend = ["Opponent's serving indicator": ""]
                        session.sendMessage(opponentServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentGameScoreToSend = ["Opponent's game score": ""]
                        session.sendMessage(opponentGameScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentSetScoreToSend = ["Opponent's set score": ""]
                        session.sendMessage(opponentSetScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentMatchScoreToSend = ["Opponent's match score": String(opponentMatchScore)]
                        session.sendMessage(opponentMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                    default:
                        yourMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                        
                        let yourMatchScoreToSend = ["Your match score": String(yourMatchScore)]
                        session.sendMessage(yourMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                    }
                case 7:
                    switch matchScore {
                    case (3, 0...3):
                        yourMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                        
                        firstPlayerGameScoreLabel.setTitle("", for: .normal)
                        secondPlayerGameScoreLabel.setTitle("🏆", for: .normal)
                        
                        let yourServingIndicatorToSend = ["Your serving indicator": ""]
                        session.sendMessage(yourServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourGameScoreToSend = ["Your game score": "🏆"]
                        session.sendMessage(yourGameScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourSetScoreToSend = ["Your set score": ""]
                        session.sendMessage(yourSetScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourMatchScoreToSend = ["Your match score": String(yourMatchScore)]
                        session.sendMessage(yourMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentServingIndicatorToSend = ["Opponent's serving indicator": ""]
                        session.sendMessage(opponentServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentGameScoreToSend = ["Opponent's game score": ""]
                        session.sendMessage(opponentGameScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentSetScoreToSend = ["Opponent's set score": ""]
                        session.sendMessage(opponentSetScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentMatchScoreToSend = ["Opponent's match score": String(opponentMatchScore)]
                        session.sendMessage(opponentMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                    default:
                        yourMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                        
                        firstPlayerGameScoreLabel.setTitle("", for: .normal)
                        secondPlayerGameScoreLabel.setTitle("🏆", for: .normal)
                        
                        let yourServingIndicatorToSend = ["Your serving indicator": ""]
                        session.sendMessage(yourServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourGameScoreToSend = ["Your game score": "🏆"]
                        session.sendMessage(yourGameScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourSetScoreToSend = ["Your set score": ""]
                        session.sendMessage(yourSetScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourMatchScoreToSend = ["Your match score": String(yourMatchScore)]
                        session.sendMessage(yourMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentServingIndicatorToSend = ["Opponent's serving indicator": ""]
                        session.sendMessage(opponentServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentGameScoreToSend = ["Opponent's game score": ""]
                        session.sendMessage(opponentGameScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentSetScoreToSend = ["Opponent's set score": ""]
                        session.sendMessage(opponentSetScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentMatchScoreToSend = ["Opponent's match score": String(opponentMatchScore)]
                        session.sendMessage(opponentMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                    }
                default:
//                    opponentServingIndicatorLabel.setHidden(true)
//                    opponentSetScoreLabel.setHidden(true)
                    firstPlayerGameScoreLabel.setTitle("", for: .normal)
//                    yourServingIndicatorLabel.setHidden(true)
//                    yourSetScoreLabel.setHidden(true)
                    secondPlayerGameScoreLabel.setTitle("🏆", for: .normal)
                    yourMatchScore += 1
//                    yourMatchScoreLabel.setText(String(yourMatchScore))
                    matchScore = (yourMatchScore, opponentMatchScore)
                    
                    let opponentGameScoreToSend = ["Opponent's game score": ""]
                    session.sendMessage(opponentGameScoreToSend, replyHandler: nil, errorHandler: {error in
                        // catch any errors here
                        print(error)
                    })
                    
                    let yourGameScoreToSend = ["Your game score": "🏆"]
                    session.sendMessage(yourGameScoreToSend, replyHandler: nil, errorHandler: {error in
                        // catch any errors here
                        print(error)
                    })
                    
                    let opponentSetScoreToSend = ["Your set score": String(opponentSetScore)]
                    session.sendMessage(opponentSetScoreToSend, replyHandler: nil, errorHandler: {error in
                        // catch any errors here
                        print(error)
                    })
                }
//                yourMatchScoreLabel.setText(String(yourMatchScore))
            case (6, 6): break
//                opponentSetScoreLabel.setText("Tiebreaker")
//                yourSetScoreLabel.setText("Tiebreaker")
            case (7, 5...6):
                opponentGameScore = 0
                yourGameScore = 0
                setScore = (0, 0)
                opponentSetScore = 0
                let opponentSetScoreToSend = ["Opponent's set score": String(opponentSetScore)]
                session.sendMessage(opponentSetScoreToSend, replyHandler: nil, errorHandler: {error in
                    print(error)
                })
                yourSetScore = 0
//                yourSetScoreLabel.setText(String(yourSetScore))
                switch matchLength {
                case 3:
                    switch matchScore {
                    case (1, 0...1):
                        yourMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                        
                        firstPlayerGameScoreLabel.setTitle("", for: .normal)
                        secondPlayerGameScoreLabel.setTitle("🏆", for: .normal)
                        
                        let yourServingIndicatorToSend = ["Your serving indicator": ""]
                        session.sendMessage(yourServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourGameScoreToSend = ["Your game score": "🏆"]
                        session.sendMessage(yourGameScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourSetScoreToSend = ["Your set score": ""]
                        session.sendMessage(yourSetScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourMatchScoreToSend = ["Your match score": String(yourMatchScore)]
                        session.sendMessage(yourMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentServingIndicatorToSend = ["Opponent's serving indicator": ""]
                        session.sendMessage(opponentServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentGameScoreToSend = ["Opponent's game score": ""]
                        session.sendMessage(opponentGameScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentSetScoreToSend = ["Opponent's set score": ""]
                        session.sendMessage(opponentSetScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentMatchScoreToSend = ["Opponent's match score": String(opponentMatchScore)]
                        session.sendMessage(opponentMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                    default:
                        yourMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                        
                        let yourMatchScoreToSend = ["Your match score": String(yourMatchScore)]
                        session.sendMessage(yourMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                    }
                case 5:
                    switch matchScore {
                    case (2, 0...2):
                        yourMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                        
                        firstPlayerGameScoreLabel.setTitle("", for: .normal)
                        secondPlayerGameScoreLabel.setTitle("🏆", for: .normal)
                        
                        let yourServingIndicatorToSend = ["Your serving indicator": ""]
                        session.sendMessage(yourServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourGameScoreToSend = ["Your game score": "🏆"]
                        session.sendMessage(yourGameScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourSetScoreToSend = ["Your set score": ""]
                        session.sendMessage(yourSetScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourMatchScoreToSend = ["Your match score": String(yourMatchScore)]
                        session.sendMessage(yourMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentServingIndicatorToSend = ["Opponent's serving indicator": ""]
                        session.sendMessage(opponentServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentGameScoreToSend = ["Opponent's game score": ""]
                        session.sendMessage(opponentGameScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentSetScoreToSend = ["Opponent's set score": ""]
                        session.sendMessage(opponentSetScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentMatchScoreToSend = ["Opponent's match score": String(opponentMatchScore)]
                        session.sendMessage(opponentMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                    default:
                        yourMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                        
                        let yourMatchScoreToSend = ["Your match score": String(yourMatchScore)]
                        session.sendMessage(yourMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                    }
                case 7:
                    switch matchScore {
                    case (3, 0...3):
                        yourMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                        
                        firstPlayerGameScoreLabel.setTitle("", for: .normal)
                        secondPlayerGameScoreLabel.setTitle("🏆", for: .normal)
                        
                        let yourServingIndicatorToSend = ["Your serving indicator": ""]
                        session.sendMessage(yourServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourGameScoreToSend = ["Your game score": "🏆"]
                        session.sendMessage(yourGameScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourSetScoreToSend = ["Your set score": ""]
                        session.sendMessage(yourSetScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourMatchScoreToSend = ["Your match score": String(yourMatchScore)]
                        session.sendMessage(yourMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentServingIndicatorToSend = ["Opponent's serving indicator": ""]
                        session.sendMessage(opponentServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentGameScoreToSend = ["Opponent's game score": ""]
                        session.sendMessage(opponentGameScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentSetScoreToSend = ["Opponent's set score": ""]
                        session.sendMessage(opponentSetScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentMatchScoreToSend = ["Opponent's match score": String(opponentMatchScore)]
                        session.sendMessage(opponentMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                    default:
                        yourMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                        
                        let yourMatchScoreToSend = ["Your match score": String(yourMatchScore)]
                        session.sendMessage(yourMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                    }
                default:
                    yourMatchScore += 1
                    matchScore = (yourMatchScore, opponentMatchScore)
                    
                    firstPlayerGameScoreLabel.setTitle("", for: .normal)
                    secondPlayerGameScoreLabel.setTitle("🏆", for: .normal)
                    
                    let yourServingIndicatorToSend = ["Your serving indicator": ""]
                    session.sendMessage(yourServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                        print(error)
                    })
                    
                    let yourGameScoreToSend = ["Your game score": "🏆"]
                    session.sendMessage(yourGameScoreToSend, replyHandler: nil, errorHandler: {error in
                        print(error)
                    })
                    
                    let yourSetScoreToSend = ["Your set score": ""]
                    session.sendMessage(yourSetScoreToSend, replyHandler: nil, errorHandler: {error in
                        print(error)
                    })
                    
                    let yourMatchScoreToSend = ["Your match score": String(yourMatchScore)]
                    session.sendMessage(yourMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                        print(error)
                    })
                    
                    let opponentServingIndicatorToSend = ["Opponent's serving indicator": ""]
                    session.sendMessage(opponentServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                        print(error)
                    })
                    
                    let opponentGameScoreToSend = ["Opponent's game score": ""]
                    session.sendMessage(opponentGameScoreToSend, replyHandler: nil, errorHandler: {error in
                        print(error)
                    })
                    
                    let opponentSetScoreToSend = ["Opponent's set score": ""]
                    session.sendMessage(opponentSetScoreToSend, replyHandler: nil, errorHandler: {error in
                        print(error)
                    })
                    
                    let opponentMatchScoreToSend = ["Opponent's match score": String(opponentMatchScore)]
                    session.sendMessage(opponentMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                        print(error)
                    })
                }
            default:
                break
            }
        // Advantage set
        default:
            switch setScore {
            case (6, 0...4):
                opponentGameScore = 0
                yourGameScore = 0
                setScore = (0, 0)
                opponentSetScore = 0
                let opponentSetScoreToSend = ["Opponent's set score": String(opponentSetScore)]
                session.sendMessage(opponentSetScoreToSend, replyHandler: nil, errorHandler: {error in
                    print(error)
                })
                yourSetScore = 0
//                yourSetScoreLabel.setText(String(yourSetScore))
                switch matchLength {
                case 3:
                    switch matchScore {
                    case (1, 0...1):
                        yourMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                        
                        firstPlayerGameScoreLabel.setTitle("", for: .normal)
                        secondPlayerGameScoreLabel.setTitle("🏆", for: .normal)
                        
                        let yourServingIndicatorToSend = ["Your serving indicator": ""]
                        session.sendMessage(yourServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourGameScoreToSend = ["Your game score": "🏆"]
                        session.sendMessage(yourGameScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourSetScoreToSend = ["Your set score": ""]
                        session.sendMessage(yourSetScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourMatchScoreToSend = ["Your match score": String(yourMatchScore)]
                        session.sendMessage(yourMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentServingIndicatorToSend = ["Opponent's serving indicator": ""]
                        session.sendMessage(opponentServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentGameScoreToSend = ["Opponent's game score": ""]
                        session.sendMessage(opponentGameScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentSetScoreToSend = ["Opponent's set score": ""]
                        session.sendMessage(opponentSetScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentMatchScoreToSend = ["Opponent's match score": String(opponentMatchScore)]
                        session.sendMessage(opponentMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                    default:
                        yourMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                        
                        let yourMatchScoreToSend = ["Your match score": String(yourMatchScore)]
                        session.sendMessage(yourMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                    }
                case 5:
                    switch matchScore {
                    case (2, 0...2):
                        yourMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                        
                        firstPlayerGameScoreLabel.setTitle("", for: .normal)
                        secondPlayerGameScoreLabel.setTitle("🏆", for: .normal)
                        
                        let yourServingIndicatorToSend = ["Your serving indicator": ""]
                        session.sendMessage(yourServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourGameScoreToSend = ["Your game score": "🏆"]
                        session.sendMessage(yourGameScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourSetScoreToSend = ["Your set score": ""]
                        session.sendMessage(yourSetScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourMatchScoreToSend = ["Your match score": String(yourMatchScore)]
                        session.sendMessage(yourMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentServingIndicatorToSend = ["Opponent's serving indicator": ""]
                        session.sendMessage(opponentServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentGameScoreToSend = ["Opponent's game score": ""]
                        session.sendMessage(opponentGameScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentSetScoreToSend = ["Opponent's set score": ""]
                        session.sendMessage(opponentSetScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentMatchScoreToSend = ["Opponent's match score": String(opponentMatchScore)]
                        session.sendMessage(opponentMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                    default:
                        yourMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                        
                        let yourMatchScoreToSend = ["Your match score": String(yourMatchScore)]
                        session.sendMessage(yourMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                    }
                case 7:
                    switch matchScore {
                    case (3, 0...3):
                        yourMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                        
                        firstPlayerGameScoreLabel.setTitle("", for: .normal)
                        secondPlayerGameScoreLabel.setTitle("🏆", for: .normal)
                        
                        let yourServingIndicatorToSend = ["Your serving indicator": ""]
                        session.sendMessage(yourServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourGameScoreToSend = ["Your game score": "🏆"]
                        session.sendMessage(yourGameScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourSetScoreToSend = ["Your set score": ""]
                        session.sendMessage(yourSetScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourMatchScoreToSend = ["Your match score": String(yourMatchScore)]
                        session.sendMessage(yourMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentServingIndicatorToSend = ["Opponent's serving indicator": ""]
                        session.sendMessage(opponentServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentGameScoreToSend = ["Opponent's game score": ""]
                        session.sendMessage(opponentGameScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentSetScoreToSend = ["Opponent's set score": ""]
                        session.sendMessage(opponentSetScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentMatchScoreToSend = ["Opponent's match score": String(opponentMatchScore)]
                        session.sendMessage(opponentMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                    default:
                        yourMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                        
                        let yourMatchScoreToSend = ["Your match score": String(yourMatchScore)]
                        session.sendMessage(yourMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                    }
                default:
                    yourMatchScore += 1
                    matchScore = (yourMatchScore, opponentMatchScore)
                    
                    firstPlayerGameScoreLabel.setTitle("", for: .normal)
                    secondPlayerGameScoreLabel.setTitle("🏆", for: .normal)
                    
                    let yourServingIndicatorToSend = ["Your serving indicator": ""]
                    session.sendMessage(yourServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                        print(error)
                    })
                    
                    let yourGameScoreToSend = ["Your game score": "🏆"]
                    session.sendMessage(yourGameScoreToSend, replyHandler: nil, errorHandler: {error in
                        print(error)
                    })
                    
                    let yourSetScoreToSend = ["Your set score": ""]
                    session.sendMessage(yourSetScoreToSend, replyHandler: nil, errorHandler: {error in
                        print(error)
                    })
                    
                    let yourMatchScoreToSend = ["Your match score": String(yourMatchScore)]
                    session.sendMessage(yourMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                        print(error)
                    })
                    
                    let opponentServingIndicatorToSend = ["Opponent's serving indicator": ""]
                    session.sendMessage(opponentServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                        print(error)
                    })
                    
                    let opponentGameScoreToSend = ["Opponent's game score": ""]
                    session.sendMessage(opponentGameScoreToSend, replyHandler: nil, errorHandler: {error in
                        print(error)
                    })
                    
                    let opponentSetScoreToSend = ["Opponent's set score": ""]
                    session.sendMessage(opponentSetScoreToSend, replyHandler: nil, errorHandler: {error in
                        print(error)
                    })
                    
                    let opponentMatchScoreToSend = ["Opponent's match score": String(opponentMatchScore)]
                    session.sendMessage(opponentMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                        print(error)
                    })
                }
            default:
                if (yourSetScore > opponentSetScore + 1) && (opponentSetScore >= 5) {
                    opponentGameScore = 0
                    yourGameScore = 0
                    setScore = (0, 0)
                    opponentSetScore = 0
//                    opponentSetScoreLabel.setText(String(opponentSetScore))
                    yourSetScore = 0
//                    yourSetScoreLabel.setText(String(yourSetScore))
                    switch matchLength {
                    case 3:
                        switch matchScore {
                        case (1, 0...1):
                            yourMatchScore += 1
                            matchScore = (yourMatchScore, opponentMatchScore)
                            
                            firstPlayerGameScoreLabel.setTitle("", for: .normal)
                            secondPlayerGameScoreLabel.setTitle("🏆", for: .normal)
                            
                            let yourServingIndicatorToSend = ["Your serving indicator": ""]
                            session.sendMessage(yourServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                            
                            let yourGameScoreToSend = ["Your game score": "🏆"]
                            session.sendMessage(yourGameScoreToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                            
                            let yourSetScoreToSend = ["Your set score": ""]
                            session.sendMessage(yourSetScoreToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                            
                            let yourMatchScoreToSend = ["Your match score": String(yourMatchScore)]
                            session.sendMessage(yourMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                            
                            let opponentServingIndicatorToSend = ["Opponent's serving indicator": ""]
                            session.sendMessage(opponentServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                            
                            let opponentGameScoreToSend = ["Opponent's game score": ""]
                            session.sendMessage(opponentGameScoreToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                            
                            let opponentSetScoreToSend = ["Opponent's set score": ""]
                            session.sendMessage(opponentSetScoreToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                            
                            let opponentMatchScoreToSend = ["Opponent's match score": String(opponentMatchScore)]
                            session.sendMessage(opponentMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                        default:
                            yourMatchScore += 1
                            matchScore = (yourMatchScore, opponentMatchScore)
                            
                            let yourMatchScoreToSend = ["Your match score": String(yourMatchScore)]
                            session.sendMessage(yourMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                        }
                    case 5:
                        switch matchScore {
                        case (2, 0...2):
                            yourMatchScore += 1
                            matchScore = (yourMatchScore, opponentMatchScore)
                            
                            firstPlayerGameScoreLabel.setTitle("", for: .normal)
                            secondPlayerGameScoreLabel.setTitle("🏆", for: .normal)
                            
                            let yourServingIndicatorToSend = ["Your serving indicator": ""]
                            session.sendMessage(yourServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                            
                            let yourGameScoreToSend = ["Your game score": "🏆"]
                            session.sendMessage(yourGameScoreToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                            
                            let yourSetScoreToSend = ["Your set score": ""]
                            session.sendMessage(yourSetScoreToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                            
                            let yourMatchScoreToSend = ["Your match score": String(yourMatchScore)]
                            session.sendMessage(yourMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                            
                            let opponentServingIndicatorToSend = ["Opponent's serving indicator": ""]
                            session.sendMessage(opponentServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                            
                            let opponentGameScoreToSend = ["Opponent's game score": ""]
                            session.sendMessage(opponentGameScoreToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                            
                            let opponentSetScoreToSend = ["Opponent's set score": ""]
                            session.sendMessage(opponentSetScoreToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                            
                            let opponentMatchScoreToSend = ["Opponent's match score": String(opponentMatchScore)]
                            session.sendMessage(opponentMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                        default:
                            yourMatchScore += 1
                            matchScore = (yourMatchScore, opponentMatchScore)
                            
                            let yourMatchScoreToSend = ["Your match score": String(yourMatchScore)]
                            session.sendMessage(yourMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                        }
                    case 7:
                        switch matchScore {
                        case (3, 0...3):
                            yourMatchScore += 1
                            matchScore = (yourMatchScore, opponentMatchScore)
                            
                            firstPlayerGameScoreLabel.setTitle("", for: .normal)
                            secondPlayerGameScoreLabel.setTitle("🏆", for: .normal)
                            
                            let yourServingIndicatorToSend = ["Your serving indicator": ""]
                            session.sendMessage(yourServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                            
                            let yourGameScoreToSend = ["Your game score": "🏆"]
                            session.sendMessage(yourGameScoreToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                            
                            let yourSetScoreToSend = ["Your set score": ""]
                            session.sendMessage(yourSetScoreToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                            
                            let yourMatchScoreToSend = ["Your match score": String(yourMatchScore)]
                            session.sendMessage(yourMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                            
                            let opponentServingIndicatorToSend = ["Opponent's serving indicator": ""]
                            session.sendMessage(opponentServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                            
                            let opponentGameScoreToSend = ["Opponent's game score": ""]
                            session.sendMessage(opponentGameScoreToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                            
                            let opponentSetScoreToSend = ["Opponent's set score": ""]
                            session.sendMessage(opponentSetScoreToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                            
                            let opponentMatchScoreToSend = ["Opponent's match score": String(opponentMatchScore)]
                            session.sendMessage(opponentMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                        default:
                            yourMatchScore += 1
                            matchScore = (yourMatchScore, opponentMatchScore)
                            
                            let yourMatchScoreToSend = ["Your match score": String(yourMatchScore)]
                            session.sendMessage(yourMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                                print(error)
                            })
                        }
                    default:
                        yourMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                        
                        firstPlayerGameScoreLabel.setTitle("", for: .normal)
                        secondPlayerGameScoreLabel.setTitle("🏆", for: .normal)
                        
                        let yourServingIndicatorToSend = ["Your serving indicator": ""]
                        session.sendMessage(yourServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourGameScoreToSend = ["Your game score": "🏆"]
                        session.sendMessage(yourGameScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourSetScoreToSend = ["Your set score": ""]
                        session.sendMessage(yourSetScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourMatchScoreToSend = ["Your match score": String(yourMatchScore)]
                        session.sendMessage(yourMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentServingIndicatorToSend = ["Opponent's serving indicator": ""]
                        session.sendMessage(opponentServingIndicatorToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentGameScoreToSend = ["Opponent's game score": ""]
                        session.sendMessage(opponentGameScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentSetScoreToSend = ["Opponent's set score": ""]
                        session.sendMessage(opponentSetScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let opponentMatchScoreToSend = ["Opponent's match score": String(opponentMatchScore)]
                        session.sendMessage(opponentMatchScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                    }
                }
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        // Handle received message.
        var gameScoreValue: String
        var setScoreValue: String
        var particularPlayerIsOpponentForUpdatingGameScore: Bool
        var particularPlayerIsOpponentForUpdatingSetScore: Bool
        
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
                print()
            } else {
                self.secondPlayerGameScoreLabel.setTitle(gameScoreValue, for: .normal)
            }
        }
        //send a reply
        replyHandler(["Value":"Hello Watch" as AnyObject])
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        self.firstPlayerGameScoreLabel.setTitle("Deuce", for: .normal)
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // Begin the activation process for the new Apple Watch.
        session.activate()
    }
    
}
