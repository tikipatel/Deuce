//
//  InterfaceController.swift
//  Deuce WatchKit Extension
//
//  Created by Austin Conlon on 11/27/16.
//  Copyright © 2016 Austin Conlon. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class InterfaceController: WKInterfaceController, WCSessionDelegate {
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(watchOS 2.2, *)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) { }

    // MARK: Properties
    var session: WCSession!
    
    @IBOutlet var seriesLengthLabel: WKInterfaceLabel!
    @IBOutlet var seriesLengthSlider: WKInterfaceSlider!
    @IBOutlet var typeOfSetSlider: WKInterfaceSwitch!
    
    @IBOutlet var opponentServingIndicatorLabel: WKInterfaceLabel!
    @IBOutlet var opponentSetScoreLabel: WKInterfaceLabel!
    @IBOutlet var opponentGameScoreLabel: WKInterfaceLabel!
    @IBOutlet var opponentMatchScoreLabel: WKInterfaceLabel!
    
    @IBOutlet var yourServingIndicatorLabel: WKInterfaceLabel!
    @IBOutlet var yourSetScoreLabel: WKInterfaceLabel!
    @IBOutlet var yourGameScoreLabel: WKInterfaceLabel!
    @IBOutlet var yourMatchScoreLabel: WKInterfaceLabel!
    
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
    
    var gameScoreValue: String
    var setScoreValue: String
    var particularPlayerIsOpponentForUpdatingGameScore: Bool
    var particularPlayerIsOpponentForUpdatingSetScore: Bool
    
    override func contextForSegue(withIdentifier segueIdentifier: String) -> Any? {
        // Return data to be accessed in ResultsController
        return self.settingsData
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        // Make sure data was passed properly and update the label accordingly
        if let dictionary: [String: Int] = context as? [String: Int] {
            let matchLength = dictionary["match length"]
            let setType = dictionary["set type"]
            self.matchLength = matchLength!
            self.setType = setType!
        }
    }
    
    override init() {
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
        
        gameScoreValue = "Love"
        setScoreValue = "0"
        particularPlayerIsOpponentForUpdatingGameScore = true
        particularPlayerIsOpponentForUpdatingSetScore = true
        
        super.init()
        
        if ((arc4random_uniform(2)) == 0) {
            isServing = server.opponent
            opponentServingIndicatorLabel?.setHidden(false)
            
        } else {
            isServing = server.you
            yourServingIndicatorLabel?.setHidden(false)
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if (WCSession.isSupported()) {
            session = WCSession.default()
            session.delegate = self
            session.activate()
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    // , replyHandler: @escaping ([String : Any]) -> Void
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // Handle received message.
        
        if let particularPlayerScore = message["Opponent's game score"] as? String {
            
            particularPlayerIsOpponentForUpdatingGameScore = true
            gameScoreValue = particularPlayerScore
            
        } else if let particularPlayerScore = message["Your game score"] as? String {
            
            particularPlayerIsOpponentForUpdatingGameScore = false
            gameScoreValue = particularPlayerScore
            
        } else if let particularPlayerScore = message["Opponent's set score"] as? String {
            
            particularPlayerIsOpponentForUpdatingSetScore = true
            setScoreValue = particularPlayerScore
            
        } else if let particularPlayerScore = message["Your set score"] as? String {
            
            particularPlayerIsOpponentForUpdatingSetScore = false
            setScoreValue = particularPlayerScore
        
        } else {
            
            gameScoreValue = "Error"
            setScoreValue = "Error"
            particularPlayerIsOpponentForUpdatingGameScore = false
            particularPlayerIsOpponentForUpdatingSetScore = false
       
        }
        
        DispatchQueue.main.sync {
            if particularPlayerIsOpponentForUpdatingGameScore == true {
                
                self.opponentGameScoreLabel.setText(gameScoreValue)
                
                if particularPlayerIsOpponentForUpdatingSetScore == true {
                    self.opponentSetScoreLabel.setText(setScoreValue)
                } else {
                    self.yourSetScoreLabel.setText(setScoreValue)
                }
                
            } else if particularPlayerIsOpponentForUpdatingGameScore == false {
                
                self.yourGameScoreLabel.setText(gameScoreValue)
                
                if particularPlayerIsOpponentForUpdatingSetScore == true {
                    self.opponentSetScoreLabel.setText(setScoreValue)
                } else {
                    self.yourSetScoreLabel.setText(setScoreValue)
                }
            }
        }
    }

    // Mark: Actions
    @IBAction func sendMessage() {
        let messageToSend = ["Value":"New score"]
        session.sendMessage(messageToSend, replyHandler: { replyMessage in
            //handle and present the message on screen
            let value = replyMessage["Value"] as? String
            self.yourSetScoreLabel.setText(value)
        }, errorHandler: {error in
            // catch any errors here
            print(error)
        })
    }
    
    @IBAction func seriesLengthSlider(_ value: Float) {
        switch value {
        case 2:
            settingsData["match length"] = 3
            seriesLengthLabel.setText("Best-of three sets")
        case 3:
            settingsData["match length"] = 5
            seriesLengthLabel.setText("Best-of five sets")
        case 4:
            settingsData["match length"] = 7
            seriesLengthLabel.setText("Best-of seven sets")
        default:
            settingsData["match length"] = 1
            seriesLengthLabel.setText("One set")
        }
    }
    
    @IBAction func typeOfSetSlider(_ value: Bool) {
        switch value {
        case false:
            settingsData["set type"] = 0
            typeOfSetSlider.setTitle("Tiebreaker set")
        case true:
            settingsData["set type"] = 1
            typeOfSetSlider.setTitle("Advantage set")
        }
    }
    
    @IBAction func incrementOpponentScore(_ sender: Any) {
        if opponentGameScore <= 15 {
            opponentGameScore += 15
            WKInterfaceDevice.current().play(WKHapticType.click)
            opponentGameScoreLabel.setText(String(opponentGameScore))
            let messageToSend = ["Opponent's game score": String(opponentGameScore)]
            session.sendMessage(messageToSend, replyHandler: { replyMessage in
                //handle and present the message on screen
                _ = replyMessage["Opponent's game score"] as? String
            }, errorHandler: {error in
                // catch any errors here
                print(error)
            })
        } else if opponentGameScore == 30 {
            opponentGameScore += 10
            WKInterfaceDevice.current().play(WKHapticType.click)
            if yourGameScore <= 30 {
                opponentGameScoreLabel.setText(String(opponentGameScore))
                let messageToSend = ["Opponent's game score": String(opponentGameScore)]
                session.sendMessage(messageToSend, replyHandler: { replyMessage in
                    //handle and present the message on screen
                    _ = replyMessage["Opponent's game score"] as? String
                }, errorHandler: {error in
                    // catch any errors here
                    print(error)
                })
            } else if yourGameScore == 40 {
                opponentGameScoreLabel.setText("Deuce")
                yourGameScoreLabel.setText("Deuce")
                let opponentGameScoreToSend = ["Opponent's game score": "Deuce"]
                session.sendMessage(opponentGameScoreToSend, replyHandler: { replyMessage in
                    //handle and present the message on screen
                    _ = replyMessage["Opponent's game score"] as? String
                }, errorHandler: {error in
                    // catch any errors here
                    print(error)
                })
                let yourGameScoreToSend = ["Your game score": "Deuce"]
                session.sendMessage(yourGameScoreToSend, replyHandler: { replyMessage in
                    //handle and present the message on screen
                    _ = replyMessage["Opponent's game score"] as? String
                }, errorHandler: {error in
                    // catch any errors here
                    print(error)
                })
            }
            
        } else if opponentGameScore == 40 && yourGameScore <= 30 {
            if (opponentSetScore + yourSetScore) % 2 != 0 {
                WKInterfaceDevice.current().play(WKHapticType.notification)
            } else {
                WKInterfaceDevice.current().play(WKHapticType.click)
            }
            
            opponentSetScore += 1
            switch isServing {
            case server.opponent:
                isServing = server.you
                opponentServingIndicatorLabel.setHidden(true)
                yourServingIndicatorLabel.setHidden(false)
            case server.you:
                isServing = server.opponent
                opponentServingIndicatorLabel.setHidden(false)
                yourServingIndicatorLabel.setHidden(true)
            }
            setScore = (yourSetScore, opponentSetScore)
            
            opponentGameScore = 0
            yourGameScore = 0
            opponentGameScoreLabel.setText("Love")
            yourGameScoreLabel.setText("Love")
            opponentSetScoreLabel.setText(String(opponentSetScore))
            let opponentGameScoreToSend = ["Opponent's game score": "Love"]
            session.sendMessage(opponentGameScoreToSend, replyHandler: { replyMessage in
                //handle and present the message on screen
                _ = replyMessage["Opponent's game score"] as? String
            }, errorHandler: {error in
                // catch any errors here
                print(error)
            })
            let yourGameScoreToSend = ["Your game score": "Love"]
            session.sendMessage(yourGameScoreToSend, replyHandler: { replyMessage in
                //handle and present the message on screen
                _ = replyMessage["Your game score"] as? String
            }, errorHandler: {error in
                // catch any errors here
                print(error)
            })
        } else if opponentGameScore >= 40 {
            if opponentGameScore == yourGameScore {
                opponentGameScore += 1
                WKInterfaceDevice.current().play(WKHapticType.click)
                
                if isServing == .opponent {
                    opponentGameScoreLabel.setText("Advantage in")
                    let messageToSend = ["Opponent's game score": "Ad in"]
                    session.sendMessage(messageToSend, replyHandler: { replyMessage in
                        //handle and present the message on screen
                        _ = replyMessage["Opponent's game score"] as? String
                    }, errorHandler: {error in
                        // catch any errors here
                        print(error)
                    })
                } else {
                    opponentGameScoreLabel.setText("Advantage out")
                    let messageToSend = ["Opponent's game score": "Ad out"]
                    session.sendMessage(messageToSend, replyHandler: { replyMessage in
                        //handle and present the message on screen
                        _ = replyMessage["Opponent's game score"] as? String
                    }, errorHandler: {error in
                        // catch any errors here
                        print(error)
                    })
                }
                
                yourGameScoreLabel.setText(nil)
                
                let messageToSend = ["Your game score": ""]
                session.sendMessage(messageToSend, replyHandler: { replyMessage in
                    //handle and present the message on screen
                    _ = replyMessage["Your game score"] as? String
                }, errorHandler: {error in
                    // catch any errors here
                    print(error)
                })
            } else if opponentGameScore < yourGameScore {
                opponentGameScore += 1
                
                WKInterfaceDevice.current().play(WKHapticType.click)
                
                opponentGameScoreLabel.setText("Deuce")
                yourGameScoreLabel.setText("Deuce")
                
                let opponentGameScoreToSend = ["Opponent's game score": "Deuce"]
                session.sendMessage(opponentGameScoreToSend, replyHandler: { replyMessage in
                    //handle and present the message on screen
                    _ = replyMessage["Opponent's game score"] as? String
                }, errorHandler: {error in
                    // catch any errors here
                    print(error)
                })
                
                let yourGameScoreToSend = ["Your game score": "Deuce"]
                session.sendMessage(yourGameScoreToSend, replyHandler: { replyMessage in
                    //handle and present the message on screen
                    _ = replyMessage["Opponent's game score"] as? String
                }, errorHandler: {error in
                    // catch any errors here
                    print(error)
                })
            } else if opponentGameScore > yourGameScore {
                if (opponentSetScore + yourSetScore) % 2 != 0 {
                    WKInterfaceDevice.current().play(WKHapticType.notification)
                } else {
                    WKInterfaceDevice.current().play(WKHapticType.click)
                }
                opponentSetScore += 1
                switch isServing {
                case server.opponent:
                    isServing = server.you
                    opponentServingIndicatorLabel.setHidden(true)
                    yourServingIndicatorLabel.setHidden(false)
                    
                    
                case server.you:
                    isServing = server.opponent
                    opponentServingIndicatorLabel.setHidden(false)
                    yourServingIndicatorLabel.setHidden(true)
                    
                    
                }
                setScore = (yourSetScore, opponentSetScore)
                
                opponentGameScore = 0
                yourGameScore = 0
                opponentGameScoreLabel.setText("Love")
                yourGameScoreLabel.setText("Love")
                opponentSetScoreLabel.setText(String(opponentSetScore))
                
                let opponentGameScoreToSend = ["Opponent's game score": "Love"]
                session.sendMessage(opponentGameScoreToSend, replyHandler: { replyMessage in
                    //handle and present the message on screen
                    _ = replyMessage["Opponent's game score"] as? String
                }, errorHandler: {error in
                    // catch any errors here
                    print(error)
                })
                
                let yourGameScoreToSend = ["Your game score": "Love"]
                session.sendMessage(yourGameScoreToSend, replyHandler: { replyMessage in
                    //handle and present the message on screen
                    _ = replyMessage["Opponent's game score"] as? String
                }, errorHandler: {error in
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
                opponentSetScoreLabel.setText(String(opponentSetScore))
                yourSetScore = 0
                yourSetScoreLabel.setText(String(yourSetScore))
                switch matchLength {
                case 3:
                    switch matchScore {
                    case (0...1, 1):
                        opponentServingIndicatorLabel.setHidden(true)
                        opponentSetScoreLabel.setHidden(true)
                        opponentGameScoreLabel.setText("🏆")
                        yourServingIndicatorLabel.setHidden(true)
                        yourSetScoreLabel.setHidden(true)
                        yourGameScoreLabel.setHidden(true)
                        opponentMatchScore += 1
                        opponentMatchScoreLabel.setText(String(opponentMatchScore))
                        matchScore = (yourMatchScore, opponentMatchScore)
                        let opponentGameScoreToSend = ["Opponent's game score": "🏆"]
                        session.sendMessage(opponentGameScoreToSend, replyHandler: nil, errorHandler: {error in
                            print(error)
                        })
                        
                        let yourGameScoreToSend = ["Your game score": ""]
                        session.sendMessage(yourGameScoreToSend, replyHandler: nil, errorHandler: {error in
                            // catch any errors here
                            print(error)
                        })
                        
                    default:
                        opponentMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                    }
                case 5:
                    switch matchScore {
                    case (0...2, 2):
                        opponentServingIndicatorLabel.setHidden(true)
                        opponentSetScoreLabel.setHidden(true)
                        opponentGameScoreLabel.setText("🏆")
                        yourServingIndicatorLabel.setHidden(true)
                        yourSetScoreLabel.setHidden(true)
                        yourGameScoreLabel.setHidden(true)
                        opponentMatchScore += 1
                        opponentMatchScoreLabel.setText(String(opponentMatchScore))
                        matchScore = (yourMatchScore, opponentMatchScore)
                        let opponentGameScoreToSend = ["Opponent's game score": "🏆"]
                        session.sendMessage(opponentGameScoreToSend, replyHandler: { replyMessage in
                            //handle and present the message on screen
                            _ = replyMessage["Opponent's game score"] as? String
                        }, errorHandler: {error in
                            // catch any errors here
                            print(error)
                        })
                        let yourGameScoreToSend = ["Your game score": ""]
                        session.sendMessage(yourGameScoreToSend, replyHandler: { replyMessage in
                            //handle and present the message on screen
                            _ = replyMessage["Your game score"] as? String
                        }, errorHandler: {error in
                            // catch any errors here
                            print(error)
                        })
                        
                    default:
                        opponentMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                    }
                case 7:
                    switch matchScore {
                    case (0...3, 3):
                        opponentServingIndicatorLabel.setHidden(true)
                        opponentSetScoreLabel.setHidden(true)
                        opponentGameScoreLabel.setText("🏆")
                        yourServingIndicatorLabel.setHidden(true)
                        yourSetScoreLabel.setHidden(true)
                        yourGameScoreLabel.setHidden(true)
                        opponentMatchScore += 1
                        opponentMatchScoreLabel.setText(String(opponentMatchScore))
                        matchScore = (yourMatchScore, opponentMatchScore)
                        let opponentGameScoreToSend = ["Opponent's game score": "🏆"]
                        session.sendMessage(opponentGameScoreToSend, replyHandler: { replyMessage in
                            //handle and present the message on screen
                            _ = replyMessage["Opponent's game score"] as? String
                        }, errorHandler: {error in
                            // catch any errors here
                            print(error)
                        })
                        let yourGameScoreToSend = ["Your game score": ""]
                        session.sendMessage(yourGameScoreToSend, replyHandler: { replyMessage in
                            //handle and present the message on screen
                            _ = replyMessage["Your game score"] as? String
                        }, errorHandler: {error in
                            // catch any errors here
                            print(error)
                        })
                        
                    default:
                        opponentMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                    }
                default:
                    switch matchScore {
                    case (0, 0):
                        opponentServingIndicatorLabel.setHidden(true)
                        opponentSetScoreLabel.setHidden(true)
                        opponentGameScoreLabel.setText("🏆")
                        yourServingIndicatorLabel.setHidden(true)
                        yourSetScoreLabel.setHidden(true)
                        yourGameScoreLabel.setHidden(true)
                        opponentMatchScore += 1
                        opponentMatchScoreLabel.setText(String(opponentMatchScore))
                        matchScore = (yourMatchScore, opponentMatchScore)
                        let opponentGameScoreToSend = ["Opponent's game score": "🏆"]
                        session.sendMessage(opponentGameScoreToSend, replyHandler: { replyMessage in
                            //handle and present the message on screen
                            _ = replyMessage["Opponent's game score"] as? String
                        }, errorHandler: {error in
                            // catch any errors here
                            print(error)
                        })
                        let yourGameScoreToSend = ["Your game score": ""]
                        session.sendMessage(yourGameScoreToSend, replyHandler: { replyMessage in
                            //handle and present the message on screen
                            _ = replyMessage["Your game score"] as? String
                        }, errorHandler: {error in
                            // catch any errors here
                            print(error)
                        })
                        
                    default:
                        opponentMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                    }
                }
                opponentMatchScoreLabel.setText(String(opponentMatchScore))
            case (6, 6):
                opponentSetScoreLabel.setText("Tiebreaker")
                yourSetScoreLabel.setText("Tiebreaker")
            case (5...6, 7):
                setScore = (0, 0)
                opponentSetScore = 0
                yourSetScore = 0
                opponentMatchScore += 1
                opponentSetScoreLabel.setText("0")
                yourSetScoreLabel.setText("0")
                opponentMatchScoreLabel.setText(String(opponentMatchScore))
                yourMatchScoreLabel.setText(String(yourMatchScore))
                switch matchLength {
                case 3:
                    switch matchScore {
                    case (0...1, 1):
                        opponentServingIndicatorLabel.setHidden(true)
                        opponentSetScoreLabel.setHidden(true)
                        opponentGameScoreLabel.setText("🏆")
                        yourServingIndicatorLabel.setHidden(true)
                        yourSetScoreLabel.setHidden(true)
                        yourGameScoreLabel.setHidden(true)
                        opponentMatchScore += 1
                        opponentMatchScoreLabel.setText(String(opponentMatchScore))
                        matchScore = (yourMatchScore, opponentMatchScore)
                        let opponentGameScoreToSend = ["Opponent's game score": "🏆"]
                        session.sendMessage(opponentGameScoreToSend, replyHandler: { replyMessage in
                            //handle and present the message on screen
                            _ = replyMessage["Opponent's game score"] as? String
                        }, errorHandler: {error in
                            // catch any errors here
                            print(error)
                        })
                        let yourGameScoreToSend = ["Your game score": ""]
                        session.sendMessage(yourGameScoreToSend, replyHandler: { replyMessage in
                            //handle and present the message on screen
                            _ = replyMessage["Your game score"] as? String
                        }, errorHandler: {error in
                            // catch any errors here
                            print(error)
                        })
                        
                    default:
                        opponentMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                    }
                case 5:
                    switch matchScore {
                    case (0...2, 2):
                        opponentServingIndicatorLabel.setHidden(true)
                        opponentSetScoreLabel.setHidden(true)
                        opponentGameScoreLabel.setText("🏆")
                        yourServingIndicatorLabel.setHidden(true)
                        yourSetScoreLabel.setHidden(true)
                        yourGameScoreLabel.setHidden(true)
                        opponentMatchScore += 1
                        opponentMatchScoreLabel.setText(String(opponentMatchScore))
                        matchScore = (yourMatchScore, opponentMatchScore)
                        let opponentGameScoreToSend = ["Opponent's game score": "🏆"]
                        session.sendMessage(opponentGameScoreToSend, replyHandler: { replyMessage in
                            //handle and present the message on screen
                            _ = replyMessage["Opponent's game score"] as? String
                        }, errorHandler: {error in
                            // catch any errors here
                            print(error)
                        })
                        let yourGameScoreToSend = ["Your game score": ""]
                        session.sendMessage(yourGameScoreToSend, replyHandler: { replyMessage in
                            //handle and present the message on screen
                            _ = replyMessage["Your game score"] as? String
                        }, errorHandler: {error in
                            // catch any errors here
                            print(error)
                        })
                        
                    default:
                        opponentMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                    }
                case 7:
                    switch matchScore {
                    case (0...3, 3):
                        opponentServingIndicatorLabel.setHidden(true)
                        opponentSetScoreLabel.setHidden(true)
                        opponentGameScoreLabel.setText("🏆")
                        yourServingIndicatorLabel.setHidden(true)
                        yourSetScoreLabel.setHidden(true)
                        yourGameScoreLabel.setHidden(true)
                        opponentMatchScore += 1
                        opponentMatchScoreLabel.setText(String(opponentMatchScore))
                        matchScore = (yourMatchScore, opponentMatchScore)
                        let opponentGameScoreToSend = ["Opponent's game score": "🏆"]
                        session.sendMessage(opponentGameScoreToSend, replyHandler: { replyMessage in
                            //handle and present the message on screen
                            _ = replyMessage["Opponent's game score"] as? String
                        }, errorHandler: {error in
                            // catch any errors here
                            print(error)
                        })
                        let yourGameScoreToSend = ["Your game score": ""]
                        session.sendMessage(yourGameScoreToSend, replyHandler: { replyMessage in
                            //handle and present the message on screen
                            _ = replyMessage["Your game score"] as? String
                        }, errorHandler: {error in
                            // catch any errors here
                            print(error)
                        })
                        
                    default:
                        opponentMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                    }
                default:
                    switch matchScore {
                    case (0, 0):
                        opponentServingIndicatorLabel.setHidden(true)
                        opponentSetScoreLabel.setHidden(true)
                        opponentGameScoreLabel.setText("🏆")
                        yourServingIndicatorLabel.setHidden(true)
                        yourSetScoreLabel.setHidden(true)
                        yourGameScoreLabel.setHidden(true)
                        opponentMatchScore += 1
                        opponentMatchScoreLabel.setText(String(opponentMatchScore))
                        matchScore = (yourMatchScore, opponentMatchScore)
                        let opponentGameScoreToSend = ["Opponent's game score": "🏆"]
                        session.sendMessage(opponentGameScoreToSend, replyHandler: { replyMessage in
                            //handle and present the message on screen
                            _ = replyMessage["Opponent's game score"] as? String
                        }, errorHandler: {error in
                            // catch any errors here
                            print(error)
                        })
                        let yourGameScoreToSend = ["Your game score": ""]
                        session.sendMessage(yourGameScoreToSend, replyHandler: { replyMessage in
                            //handle and present the message on screen
                            _ = replyMessage["Your game score"] as? String
                        }, errorHandler: {error in
                            // catch any errors here
                            print(error)
                        })
                        
                    default:
                        opponentMatchScore += 1
                        matchScore = (yourMatchScore, opponentMatchScore)
                    }
                }
                opponentMatchScoreLabel.setText(String(opponentMatchScore))
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
                opponentSetScoreLabel.setText(String(opponentSetScore))
                yourSetScore = 0
                yourSetScoreLabel.setText(String(yourSetScore))
                switch matchLength {
                case 3:
                    switch matchScore {
                    case (0...1, 1):
                        opponentServingIndicatorLabel.setHidden(true)
                        opponentSetScoreLabel.setHidden(true)
                        opponentGameScoreLabel.setText("🏆")
                        yourServingIndicatorLabel.setHidden(true)
                        yourSetScoreLabel.setHidden(true)
                        yourGameScoreLabel.setHidden(true)
                        opponentMatchScore += 1
                        opponentMatchScoreLabel.setText(String(opponentMatchScore))
                        matchScore = (yourMatchScore, opponentMatchScore)
                        let opponentGameScoreToSend = ["Opponent's game score": "🏆"]
                        session.sendMessage(opponentGameScoreToSend, replyHandler: { replyMessage in
                            //handle and present the message on screen
                            _ = replyMessage["Opponent's game score"] as? String
                        }, errorHandler: {error in
                            // catch any errors here
                            print(error)
                        })
                        let yourGameScoreToSend = ["Your game score": ""]
                        session.sendMessage(yourGameScoreToSend, replyHandler: { replyMessage in
                            //handle and present the message on screen
                            _ = replyMessage["Your game score"] as? String
                        }, errorHandler: {error in
                            // catch any errors here
                            print(error)
                        })
                        
                    default:
                        opponentMatchScore += 1
                        opponentMatchScoreLabel.setText(String(opponentMatchScore))
                        matchScore = (yourMatchScore, opponentMatchScore)
                    }
                case 5:
                    switch matchScore {
                    case (0...2, 2):
                        opponentServingIndicatorLabel.setHidden(true)
                        opponentSetScoreLabel.setHidden(true)
                        opponentGameScoreLabel.setText("🏆")
                        yourServingIndicatorLabel.setHidden(true)
                        yourSetScoreLabel.setHidden(true)
                        yourGameScoreLabel.setHidden(true)
                        opponentMatchScore += 1
                        opponentMatchScoreLabel.setText(String(opponentMatchScore))
                        matchScore = (yourMatchScore, opponentMatchScore)
                        let opponentGameScoreToSend = ["Opponent's game score": "🏆"]
                        session.sendMessage(opponentGameScoreToSend, replyHandler: { replyMessage in
                            //handle and present the message on screen
                            _ = replyMessage["Opponent's game score"] as? String
                        }, errorHandler: {error in
                            // catch any errors here
                            print(error)
                        })
                        let yourGameScoreToSend = ["Your game score": ""]
                        session.sendMessage(yourGameScoreToSend, replyHandler: { replyMessage in
                            //handle and present the message on screen
                            _ = replyMessage["Your game score"] as? String
                        }, errorHandler: {error in
                            // catch any errors here
                            print(error)
                        })
                        
                    default:
                        opponentMatchScore += 1
                        opponentMatchScoreLabel.setText(String(opponentMatchScore))
                        matchScore = (yourMatchScore, opponentMatchScore)
                    }
                case 7:
                    switch matchScore {
                    case (0...3, 3):
                        opponentServingIndicatorLabel.setHidden(true)
                        opponentSetScoreLabel.setHidden(true)
                        opponentGameScoreLabel.setText("🏆")
                        yourServingIndicatorLabel.setHidden(true)
                        yourSetScoreLabel.setHidden(true)
                        yourGameScoreLabel.setHidden(true)
                        opponentMatchScore += 1
                        opponentMatchScoreLabel.setText(String(opponentMatchScore))
                        matchScore = (yourMatchScore, opponentMatchScore)
                        let opponentGameScoreToSend = ["Opponent's game score": "🏆"]
                        session.sendMessage(opponentGameScoreToSend, replyHandler: { replyMessage in
                            //handle and present the message on screen
                            _ = replyMessage["Opponent's game score"] as? String
                        }, errorHandler: {error in
                            // catch any errors here
                            print(error)
                        })
                        let yourGameScoreToSend = ["Your game score": ""]
                        session.sendMessage(yourGameScoreToSend, replyHandler: { replyMessage in
                            //handle and present the message on screen
                            _ = replyMessage["Your game score"] as? String
                        }, errorHandler: {error in
                            // catch any errors here
                            print(error)
                        })
                        
                    default:
                        opponentMatchScore += 1
                        opponentMatchScoreLabel.setText(String(opponentMatchScore))
                        matchScore = (yourMatchScore, opponentMatchScore)
                    }
                default:
                    opponentServingIndicatorLabel.setHidden(true)
                    opponentSetScoreLabel.setHidden(true)
                    opponentGameScoreLabel.setText("🏆")
                    yourServingIndicatorLabel.setHidden(true)
                    yourSetScoreLabel.setHidden(true)
                    yourGameScoreLabel.setHidden(true)
                    opponentMatchScore += 1
                    opponentMatchScoreLabel.setText(String(opponentMatchScore))
                    matchScore = (yourMatchScore, opponentMatchScore)
                    let opponentGameScoreToSend = ["Opponent's game score": "🏆"]
                    session.sendMessage(opponentGameScoreToSend, replyHandler: { replyMessage in
                        //handle and present the message on screen
                        _ = replyMessage["Opponent's game score"] as? String
                    }, errorHandler: {error in
                        // catch any errors here
                        print(error)
                    })
                    let yourGameScoreToSend = ["Your game score": ""]
                    session.sendMessage(yourGameScoreToSend, replyHandler: { replyMessage in
                        //handle and present the message on screen
                        _ = replyMessage["Your game score"] as? String
                    }, errorHandler: {error in
                        // catch any errors here
                        print(error)
                    })
                    
                    
                }
                opponentMatchScoreLabel.setText(String(opponentMatchScore))
            default:
                if (opponentSetScore > yourSetScore + 1) && (yourSetScore >= 5) {
                    opponentGameScore = 0
                    yourGameScore = 0
                    setScore = (0, 0)
                    opponentSetScore = 0
                    opponentSetScoreLabel.setText(String(opponentSetScore))
                    yourSetScore = 0
                    yourSetScoreLabel.setText(String(yourSetScore))
                    switch matchLength {
                    case 3:
                        switch matchScore {
                        case (0...1, 1):
                            opponentServingIndicatorLabel.setHidden(true)
                            opponentSetScoreLabel.setHidden(true)
                            opponentGameScoreLabel.setText("🏆")
                            yourServingIndicatorLabel.setHidden(true)
                            yourSetScoreLabel.setHidden(true)
                            yourGameScoreLabel.setHidden(true)
                            opponentMatchScore += 1
                            opponentMatchScoreLabel.setText(String(opponentMatchScore))
                            matchScore = (yourMatchScore, opponentMatchScore)
                            let opponentGameScoreToSend = ["Opponent's game score": "🏆"]
                            session.sendMessage(opponentGameScoreToSend, replyHandler: { replyMessage in
                                //handle and present the message on screen
                                _ = replyMessage["Opponent's game score"] as? String
                            }, errorHandler: {error in
                                // catch any errors here
                                print(error)
                            })
                            let yourGameScoreToSend = ["Your game score": ""]
                            session.sendMessage(yourGameScoreToSend, replyHandler: { replyMessage in
                                //handle and present the message on screen
                                _ = replyMessage["Your game score"] as? String
                            }, errorHandler: {error in
                                // catch any errors here
                                print(error)
                            })
                            
                        default:
                            opponentMatchScore += 1
                            opponentMatchScoreLabel.setText(String(opponentMatchScore))
                            matchScore = (yourMatchScore, opponentMatchScore)
                        }
                    case 5:
                        switch matchScore {
                        case (0...2, 2):
                            opponentServingIndicatorLabel.setHidden(true)
                            opponentSetScoreLabel.setHidden(true)
                            opponentGameScoreLabel.setText("🏆")
                            yourServingIndicatorLabel.setHidden(true)
                            yourSetScoreLabel.setHidden(true)
                            yourGameScoreLabel.setHidden(true)
                            opponentMatchScore += 1
                            opponentMatchScoreLabel.setText(String(opponentMatchScore))
                            matchScore = (yourMatchScore, opponentMatchScore)
                            let opponentGameScoreToSend = ["Opponent's game score": "🏆"]
                            session.sendMessage(opponentGameScoreToSend, replyHandler: { replyMessage in
                                //handle and present the message on screen
                                _ = replyMessage["Opponent's game score"] as? String
                            }, errorHandler: {error in
                                // catch any errors here
                                print(error)
                            })
                            let yourGameScoreToSend = ["Your game score": ""]
                            session.sendMessage(yourGameScoreToSend, replyHandler: { replyMessage in
                                //handle and present the message on screen
                                _ = replyMessage["Your game score"] as? String
                            }, errorHandler: {error in
                                // catch any errors here
                                print(error)
                            })
                            
                        default:
                            opponentMatchScore += 1
                            opponentMatchScoreLabel.setText(String(opponentMatchScore))
                            matchScore = (yourMatchScore, opponentMatchScore)
                        }
                    case 7:
                        switch matchScore {
                        case (0...3, 3):
                            opponentServingIndicatorLabel.setHidden(true)
                            opponentSetScoreLabel.setHidden(true)
                            opponentGameScoreLabel.setText("🏆")
                            yourServingIndicatorLabel.setHidden(true)
                            yourSetScoreLabel.setHidden(true)
                            yourGameScoreLabel.setHidden(true)
                            opponentMatchScore += 1
                            opponentMatchScoreLabel.setText(String(opponentMatchScore))
                            matchScore = (yourMatchScore, opponentMatchScore)
                            let opponentGameScoreToSend = ["Opponent's game score": "🏆"]
                            session.sendMessage(opponentGameScoreToSend, replyHandler: { replyMessage in
                                //handle and present the message on screen
                                _ = replyMessage["Opponent's game score"] as? String
                            }, errorHandler: {error in
                                // catch any errors here
                                print(error)
                            })
                            let yourGameScoreToSend = ["Your game score": ""]
                            session.sendMessage(yourGameScoreToSend, replyHandler: { replyMessage in
                                //handle and present the message on screen
                                _ = replyMessage["Your game score"] as? String
                            }, errorHandler: {error in
                                // catch any errors here
                                print(error)
                            })
                            
                        default:
                            opponentMatchScore += 1
                            opponentMatchScoreLabel.setText(String(opponentMatchScore))
                            matchScore = (yourMatchScore, opponentMatchScore)
                        }
                    default:
                        opponentServingIndicatorLabel.setHidden(true)
                        opponentSetScoreLabel.setHidden(true)
                        opponentGameScoreLabel.setText("🏆")
                        yourServingIndicatorLabel.setHidden(true)
                        yourSetScoreLabel.setHidden(true)
                        yourGameScoreLabel.setHidden(true)
                        opponentMatchScore += 1
                        opponentMatchScoreLabel.setText(String(opponentMatchScore))
                        matchScore = (yourMatchScore, opponentMatchScore)
                        let opponentGameScoreToSend = ["Opponent's game score": "🏆"]
                        session.sendMessage(opponentGameScoreToSend, replyHandler: { replyMessage in
                            //handle and present the message on screen
                            _ = replyMessage["Opponent's game score"] as? String
                        }, errorHandler: {error in
                            // catch any errors here
                            print(error)
                        })
                        let yourGameScoreToSend = ["Your game score": ""]
                        session.sendMessage(yourGameScoreToSend, replyHandler: { replyMessage in
                            //handle and present the message on screen
                            _ = replyMessage["Your game score"] as? String
                        }, errorHandler: {error in
                            // catch any errors here
                            print(error)
                        })
                        
                    }
                    opponentMatchScoreLabel.setText(String(opponentMatchScore))
                }
            }
        }
    }
    
    @IBAction func incrementYourScore(_ sender: Any) {
        if yourGameScore <= 15 {
            yourGameScore += 15
            WKInterfaceDevice.current().play(WKHapticType.click)
            yourGameScoreLabel.setText(String(yourGameScore))
            let messageToSend = ["Your game score": String(yourGameScore)]
            session.sendMessage(messageToSend, replyHandler: { replyMessage in
                //handle and present the message on screen
                _ = replyMessage["Your game score"] as? String
            }, errorHandler: {error in
                // catch any errors here
                print(error)
            })
        } else if yourGameScore == 30 {
            yourGameScore += 10
            WKInterfaceDevice.current().play(WKHapticType.click)
            if opponentGameScore <= 30 {
                yourGameScoreLabel.setText(String (yourGameScore))
                let messageToSend = ["Your game score": String(yourGameScore)]
                session.sendMessage(messageToSend, replyHandler: { replyMessage in
                    //handle and present the message on screen
                    _ = replyMessage["Your game score"] as? String
                }, errorHandler: {error in
                    // catch any errors here
                    print(error)
                })
            } else if opponentGameScore == 40 {
                opponentGameScoreLabel.setText("Deuce")
                yourGameScoreLabel.setText("Deuce")
                let opponentGameScoreToSend = ["Opponent's game score": "Deuce"]
                session.sendMessage(opponentGameScoreToSend, replyHandler: { replyMessage in
                    //handle and present the message on screen
                    _ = replyMessage["Opponent's game score"] as? String
                }, errorHandler: {error in
                    // catch any errors here
                    print(error)
                })
                let yourGameScoreToSend = ["Your game score": "Deuce"]
                session.sendMessage(yourGameScoreToSend, replyHandler: { replyMessage in
                    //handle and present the message on screen
                    _ = replyMessage["Your game score"] as? String
                }, errorHandler: {error in
                    // catch any errors here
                    print(error)
                })
            }
            
        } else if yourGameScore == 40 && opponentGameScore <= 30 {
            if (opponentSetScore + yourSetScore) % 2 != 0 {
                WKInterfaceDevice.current().play(WKHapticType.notification)
            } else {
                WKInterfaceDevice.current().play(WKHapticType.click)
            }
            yourSetScore += 1
            switch isServing {
            case server.opponent:
                isServing = server.you
                opponentServingIndicatorLabel.setHidden(true)
                yourServingIndicatorLabel.setHidden(false)
                
            case server.you:
                isServing = server.opponent
                opponentServingIndicatorLabel.setHidden(false)
                yourServingIndicatorLabel.setHidden(true)
                
            }
            if (opponentSetScore + yourSetScore) % 2 == 0 {
                WKInterfaceDevice.current().play(WKHapticType.notification)
            }
            setScore = (yourSetScore, opponentSetScore)
            
            opponentGameScore = 0
            yourGameScore = 0
            opponentGameScoreLabel.setText("Love")
            yourGameScoreLabel.setText("Love")
            yourSetScoreLabel.setText(String(yourSetScore))
            let opponentGameScoreToSend = ["Opponent's game score": "Love"]
            session.sendMessage(opponentGameScoreToSend, replyHandler: { replyMessage in
                //handle and present the message on screen
                _ = replyMessage["Opponent's game score"] as? String
            }, errorHandler: {error in
                // catch any errors here
                print(error)
            })
            let yourGameScoreToSend = ["Your game score": "Love"]
            session.sendMessage(yourGameScoreToSend, replyHandler: { replyMessage in
                //handle and present the message on screen
                _ = replyMessage["Your game score"] as? String
            }, errorHandler: {error in
                // catch any errors here
                print(error)
            })
        } else if yourGameScore >= 40 {
            if yourGameScore == opponentGameScore {
                yourGameScore += 1
                WKInterfaceDevice.current().play(WKHapticType.click)
                if isServing == .you {
                    yourGameScoreLabel.setText("Advantage in")
                    let yourGameScoreToSend = ["Your game score": "Ad in"]
                    session.sendMessage(yourGameScoreToSend, replyHandler: { replyMessage in
                        //handle and present the message on screen
                        _ = replyMessage["Your game score"] as? String
                    }, errorHandler: {error in
                        // catch any errors here
                        print(error)
                    })
                } else {
                    yourGameScoreLabel.setText("Advantage out")
                    let yourGameScoreToSend = ["Your game score": "Ad out"]
                    session.sendMessage(yourGameScoreToSend, replyHandler: { replyMessage in
                        //handle and present the message on screen
                        _ = replyMessage["Your game score"] as? String
                    }, errorHandler: {error in
                        // catch any errors here
                        print(error)
                    })
                }
                opponentGameScoreLabel.setText(nil)
                let opponentGameScoreToSend = ["Opponent's game score": ""]
                session.sendMessage(opponentGameScoreToSend, replyHandler: { replyMessage in
                    //handle and present the message on screen
                    _ = replyMessage["Opponent's game score"] as? String
                }, errorHandler: {error in
                    // catch any errors here
                    print(error)
                })
            } else if yourGameScore < opponentGameScore {
                yourGameScore += 1
                WKInterfaceDevice.current().play(WKHapticType.click)
                yourGameScoreLabel.setText("Deuce")
                opponentGameScoreLabel.setText("Deuce")
                let opponentGameScoreToSend = ["Opponent's game score": "Deuce"]
                session.sendMessage(opponentGameScoreToSend, replyHandler: { replyMessage in
                    //handle and present the message on screen
                    _ = replyMessage["Opponent's game score"] as? String
                }, errorHandler: {error in
                    // catch any errors here
                    print(error)
                })
                let yourGameScoreToSend = ["Your game score": "Deuce"]
                session.sendMessage(yourGameScoreToSend, replyHandler: { replyMessage in
                    //handle and present the message on screen
                    _ = replyMessage["Your game score"] as? String
                }, errorHandler: {error in
                    // catch any errors here
                    print(error)
                })
            } else if yourGameScore > opponentGameScore {
                if (opponentSetScore + yourSetScore) % 2 != 0 {
                    WKInterfaceDevice.current().play(WKHapticType.notification)
                } else {
                    WKInterfaceDevice.current().play(WKHapticType.click)
                }
                yourSetScore += 1
                switch isServing {
                case server.opponent:
                    isServing = server.you
                    opponentServingIndicatorLabel.setHidden(true)
                    yourServingIndicatorLabel.setHidden(false)
                    
                case server.you:
                    isServing = server.opponent
                    opponentServingIndicatorLabel.setHidden(false)
                    yourServingIndicatorLabel.setHidden(true)
        
                }
                setScore = (yourSetScore, opponentSetScore)
                
                yourGameScore = 0
                opponentGameScore = 0
                yourGameScoreLabel.setText("Love")
                opponentGameScoreLabel.setText("Love")
                yourSetScoreLabel.setText(String(yourSetScore))
                
                let opponentGameScoreToSend = ["Opponent's game score": "Love"]
                session.sendMessage(opponentGameScoreToSend, replyHandler: { replyMessage in
                    //handle and present the message on screen
                    _ = replyMessage["Opponent's game score"] as? String
                }, errorHandler: {error in
                    // catch any errors here
                    print(error)
                })
                let yourGameScoreToSend = ["Your game score": "Love"]
                session.sendMessage(yourGameScoreToSend, replyHandler: { replyMessage in
                    //handle and present the message on screen
                    _ = replyMessage["Your game score"] as? String
                }, errorHandler: {error in
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
                opponentSetScoreLabel.setText(String(opponentSetScore))
                yourSetScore = 0
                yourSetScoreLabel.setText(String(yourSetScore))
                switch matchLength {
                case 3:
                    switch matchScore {
                    case (1, 0...1):
                        opponentServingIndicatorLabel.setHidden(true)
                        opponentSetScoreLabel.setHidden(true)
                        opponentGameScoreLabel.setHidden(true)
                        yourServingIndicatorLabel.setHidden(true)
                        yourSetScoreLabel.setHidden(true)
                        yourGameScoreLabel.setText("🏆")
                        yourMatchScore += 1
                        yourMatchScoreLabel.setText(String(yourMatchScore))
                        matchScore = (yourMatchScore, opponentMatchScore)
                        let opponentGameScoreToSend = ["Opponent's game score": ""]
                        session.sendMessage(opponentGameScoreToSend, replyHandler: { replyMessage in
                            //handle and present the message on screen
                            _ = replyMessage["Opponent's game score"] as? String
                        }, errorHandler: {error in
                            // catch any errors here
                            print(error)
                        })
                        let yourGameScoreToSend = ["Your game score": "🏆"]
                        session.sendMessage(yourGameScoreToSend, replyHandler: { replyMessage in
                            //handle and present the message on screen
                            _ = replyMessage["Your game score"] as? String
                        }, errorHandler: {error in
                            // catch any errors here
                            print(error)
                        })
                        
                    default:
                        yourMatchScore += 1
                        yourMatchScoreLabel.setText(String(yourMatchScore))
                        matchScore = (yourMatchScore, opponentMatchScore)
                    }
                case 5:
                    switch matchScore {
                    case (2, 0...2):
                        opponentServingIndicatorLabel.setHidden(true)
                        opponentSetScoreLabel.setHidden(true)
                        opponentGameScoreLabel.setHidden(true)
                        yourServingIndicatorLabel.setHidden(true)
                        yourSetScoreLabel.setHidden(true)
                        yourGameScoreLabel.setText("🏆")
                        yourMatchScore += 1
                        yourMatchScoreLabel.setText(String(yourMatchScore))
                        matchScore = (yourMatchScore, opponentMatchScore)
                        let opponentGameScoreToSend = ["Opponent's game score": ""]
                        session.sendMessage(opponentGameScoreToSend, replyHandler: { replyMessage in
                            //handle and present the message on screen
                            _ = replyMessage["Opponent's game score"] as? String
                        }, errorHandler: {error in
                            // catch any errors here
                            print(error)
                        })
                        let yourGameScoreToSend = ["Your game score": "🏆"]
                        session.sendMessage(yourGameScoreToSend, replyHandler: { replyMessage in
                            //handle and present the message on screen
                            _ = replyMessage["Your game score"] as? String
                        }, errorHandler: {error in
                            // catch any errors here
                            print(error)
                        })
                        
                    default:
                        yourMatchScore += 1
                        yourMatchScoreLabel.setText(String(yourMatchScore))
                        matchScore = (yourMatchScore, opponentMatchScore)
                    }
                case 7:
                    switch matchScore {
                    case (3, 0...3):
                        opponentServingIndicatorLabel.setHidden(true)
                        opponentSetScoreLabel.setHidden(true)
                        opponentGameScoreLabel.setHidden(true)
                        yourServingIndicatorLabel.setHidden(true)
                        yourSetScoreLabel.setHidden(true)
                        yourGameScoreLabel.setText("🏆")
                        yourMatchScore += 1
                        yourMatchScoreLabel.setText(String(yourMatchScore))
                        matchScore = (yourMatchScore, opponentMatchScore)
                        let opponentGameScoreToSend = ["Opponent's game score": ""]
                        session.sendMessage(opponentGameScoreToSend, replyHandler: { replyMessage in
                            //handle and present the message on screen
                            _ = replyMessage["Opponent's game score"] as? String
                        }, errorHandler: {error in
                            // catch any errors here
                            print(error)
                        })
                        let yourGameScoreToSend = ["Your game score": "🏆"]
                        session.sendMessage(yourGameScoreToSend, replyHandler: { replyMessage in
                            //handle and present the message on screen
                            _ = replyMessage["Your game score"] as? String
                        }, errorHandler: {error in
                            // catch any errors here
                            print(error)
                        })
                        
                    default:
                        yourMatchScore += 1
                        yourMatchScoreLabel.setText(String(yourMatchScore))
                        matchScore = (yourMatchScore, opponentMatchScore)
                    }
                default:
                    opponentServingIndicatorLabel.setHidden(true)
                    opponentSetScoreLabel.setHidden(true)
                    opponentGameScoreLabel.setHidden(true)
                    yourServingIndicatorLabel.setHidden(true)
                    yourSetScoreLabel.setHidden(true)
                    yourGameScoreLabel.setText("🏆")
                    yourMatchScore += 1
                    yourMatchScoreLabel.setText(String(yourMatchScore))
                    matchScore = (yourMatchScore, opponentMatchScore)
                    let opponentGameScoreToSend = ["Opponent's game score": ""]
                    session.sendMessage(opponentGameScoreToSend, replyHandler: { replyMessage in
                        //handle and present the message on screen
                        _ = replyMessage["Opponent's game score"] as? String
                    }, errorHandler: {error in
                        // catch any errors here
                        print(error)
                    })
                    let yourGameScoreToSend = ["Your game score": "🏆"]
                    session.sendMessage(yourGameScoreToSend, replyHandler: { replyMessage in
                        //handle and present the message on screen
                        _ = replyMessage["Your game score"] as? String
                    }, errorHandler: {error in
                        // catch any errors here
                        print(error)
                    })
                    
                    
                }
                yourMatchScoreLabel.setText(String(yourMatchScore))
            case (6, 6):
                opponentSetScoreLabel.setText("Tiebreaker")
                yourSetScoreLabel.setText("Tiebreaker")
            case (7, 5...6):
                opponentGameScore = 0
                yourGameScore = 0
                setScore = (0, 0)
                opponentSetScore = 0
                opponentSetScoreLabel.setText(String(opponentSetScore))
                yourSetScore = 0
                yourSetScoreLabel.setText(String(yourSetScore))
                switch matchLength {
                case 3:
                    switch matchScore {
                    case (1, 0...1):
                        opponentServingIndicatorLabel.setHidden(true)
                        opponentSetScoreLabel.setHidden(true)
                        opponentGameScoreLabel.setHidden(true)
                        yourServingIndicatorLabel.setHidden(true)
                        yourSetScoreLabel.setHidden(true)
                        yourGameScoreLabel.setText("🏆")
                        yourMatchScore += 1
                        yourMatchScoreLabel.setText(String(yourMatchScore))
                        matchScore = (yourMatchScore, opponentMatchScore)
                        let opponentGameScoreToSend = ["Opponent's game score": ""]
                        session.sendMessage(opponentGameScoreToSend, replyHandler: { replyMessage in
                            //handle and present the message on screen
                            _ = replyMessage["Opponent's game score"] as? String
                        }, errorHandler: {error in
                            // catch any errors here
                            print(error)
                        })
                        let yourGameScoreToSend = ["Your game score": "🏆"]
                        session.sendMessage(yourGameScoreToSend, replyHandler: { replyMessage in
                            //handle and present the message on screen
                            _ = replyMessage["Your game score"] as? String
                        }, errorHandler: {error in
                            // catch any errors here
                            print(error)
                        })
                        
                    default:
                        yourMatchScore += 1
                        yourMatchScoreLabel.setText(String(yourMatchScore))
                        matchScore = (yourMatchScore, opponentMatchScore)
                    }
                case 5:
                    switch matchScore {
                    case (2, 0...2):
                        opponentServingIndicatorLabel.setHidden(true)
                        opponentSetScoreLabel.setHidden(true)
                        opponentGameScoreLabel.setHidden(true)
                        yourServingIndicatorLabel.setHidden(true)
                        yourSetScoreLabel.setHidden(true)
                        yourGameScoreLabel.setText("🏆")
                        yourMatchScore += 1
                        yourMatchScoreLabel.setText(String(yourMatchScore))
                        matchScore = (yourMatchScore, opponentMatchScore)
                        let opponentGameScoreToSend = ["Opponent's game score": ""]
                        session.sendMessage(opponentGameScoreToSend, replyHandler: { replyMessage in
                            //handle and present the message on screen
                            _ = replyMessage["Opponent's game score"] as? String
                        }, errorHandler: {error in
                            // catch any errors here
                            print(error)
                        })
                        let yourGameScoreToSend = ["Your game score": "🏆"]
                        session.sendMessage(yourGameScoreToSend, replyHandler: { replyMessage in
                            //handle and present the message on screen
                            _ = replyMessage["Your game score"] as? String
                        }, errorHandler: {error in
                            // catch any errors here
                            print(error)
                        })
                        
                    default:
                        yourMatchScore += 1
                        yourMatchScoreLabel.setText(String(yourMatchScore))
                        matchScore = (yourMatchScore, opponentMatchScore)
                    }
                case 7:
                    switch matchScore {
                    case (3, 0...3):
                        opponentServingIndicatorLabel.setHidden(true)
                        opponentSetScoreLabel.setHidden(true)
                        opponentGameScoreLabel.setHidden(true)
                        yourServingIndicatorLabel.setHidden(true)
                        yourSetScoreLabel.setHidden(true)
                        yourGameScoreLabel.setText("🏆")
                        yourMatchScore += 1
                        yourMatchScoreLabel.setText(String(yourMatchScore))
                        matchScore = (yourMatchScore, opponentMatchScore)
                        let opponentGameScoreToSend = ["Opponent's game score": ""]
                        session.sendMessage(opponentGameScoreToSend, replyHandler: { replyMessage in
                            //handle and present the message on screen
                            _ = replyMessage["Opponent's game score"] as? String
                        }, errorHandler: {error in
                            // catch any errors here
                            print(error)
                        })
                        let yourGameScoreToSend = ["Your game score": "🏆"]
                        session.sendMessage(yourGameScoreToSend, replyHandler: { replyMessage in
                            //handle and present the message on screen
                            _ = replyMessage["Your game score"] as? String
                        }, errorHandler: {error in
                            // catch any errors here
                            print(error)
                        })
                        
                    default:
                        yourMatchScore += 1
                        yourMatchScoreLabel.setText(String(yourMatchScore))
                        matchScore = (yourMatchScore, opponentMatchScore)
                    }
                default:
                    opponentServingIndicatorLabel.setHidden(true)
                    opponentSetScoreLabel.setHidden(true)
                    opponentGameScoreLabel.setHidden(true)
                    yourServingIndicatorLabel.setHidden(true)
                    yourSetScoreLabel.setHidden(true)
                    yourGameScoreLabel.setText("🏆")
                    yourMatchScore += 1
                    yourMatchScoreLabel.setText(String(yourMatchScore))
                    matchScore = (yourMatchScore, opponentMatchScore)
                    let opponentGameScoreToSend = ["Opponent's game score": ""]
                    session.sendMessage(opponentGameScoreToSend, replyHandler: { replyMessage in
                        //handle and present the message on screen
                        _ = replyMessage["Opponent's game score"] as? String
                    }, errorHandler: {error in
                        // catch any errors here
                        print(error)
                    })
                    let yourGameScoreToSend = ["Your game score": "🏆"]
                    session.sendMessage(yourGameScoreToSend, replyHandler: { replyMessage in
                        //handle and present the message on screen
                        _ = replyMessage["Your game score"] as? String
                    }, errorHandler: {error in
                        // catch any errors here
                        print(error)
                    })
                    
                    
                }
                yourMatchScoreLabel.setText(String(yourMatchScore))
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
                opponentSetScoreLabel.setText(String(opponentSetScore))
                yourSetScore = 0
                yourSetScoreLabel.setText(String(yourSetScore))
                switch matchLength {
                case 3:
                    switch matchScore {
                    case (1, 0...1):
                        opponentServingIndicatorLabel.setHidden(true)
                        opponentSetScoreLabel.setHidden(true)
                        opponentGameScoreLabel.setHidden(true)
                        yourServingIndicatorLabel.setHidden(true)
                        yourSetScoreLabel.setHidden(true)
                        yourGameScoreLabel.setText("🏆")
                        yourMatchScore += 1
                        yourMatchScoreLabel.setText(String(yourMatchScore))
                        matchScore = (yourMatchScore, opponentMatchScore)
                        let opponentGameScoreToSend = ["Opponent's game score": ""]
                        session.sendMessage(opponentGameScoreToSend, replyHandler: { replyMessage in
                            //handle and present the message on screen
                            _ = replyMessage["Opponent's game score"] as? String
                        }, errorHandler: {error in
                            // catch any errors here
                            print(error)
                        })
                        let yourGameScoreToSend = ["Your game score": "🏆"]
                        session.sendMessage(yourGameScoreToSend, replyHandler: { replyMessage in
                            //handle and present the message on screen
                            _ = replyMessage["Your game score"] as? String
                        }, errorHandler: {error in
                            // catch any errors here
                            print(error)
                        })
                        
                    default:
                        yourMatchScore += 1
                        yourMatchScoreLabel.setText(String(yourMatchScore))
                        matchScore = (yourMatchScore, opponentMatchScore)
                    }
                case 5:
                    switch matchScore {
                    case (2, 0...2):
                        opponentServingIndicatorLabel.setHidden(true)
                        opponentSetScoreLabel.setHidden(true)
                        opponentGameScoreLabel.setHidden(true)
                        yourServingIndicatorLabel.setHidden(true)
                        yourSetScoreLabel.setHidden(true)
                        yourGameScoreLabel.setText("🏆")
                        yourMatchScore += 1
                        yourMatchScoreLabel.setText(String(yourMatchScore))
                        matchScore = (yourMatchScore, opponentMatchScore)
                        let opponentGameScoreToSend = ["Opponent's game score": ""]
                        session.sendMessage(opponentGameScoreToSend, replyHandler: { replyMessage in
                            //handle and present the message on screen
                            _ = replyMessage["Opponent's game score"] as? String
                        }, errorHandler: {error in
                            // catch any errors here
                            print(error)
                        })
                        let yourGameScoreToSend = ["Your game score": "🏆"]
                        session.sendMessage(yourGameScoreToSend, replyHandler: { replyMessage in
                            //handle and present the message on screen
                            _ = replyMessage["Your game score"] as? String
                        }, errorHandler: {error in
                            // catch any errors here
                            print(error)
                        })
                        
                    default:
                        yourMatchScore += 1
                        yourMatchScoreLabel.setText(String(yourMatchScore))
                        matchScore = (yourMatchScore, opponentMatchScore)
                    }
                case 7:
                    switch matchScore {
                    case (3, 0...3):
                        opponentServingIndicatorLabel.setHidden(true)
                        opponentSetScoreLabel.setHidden(true)
                        opponentGameScoreLabel.setHidden(true)
                        yourServingIndicatorLabel.setHidden(true)
                        yourSetScoreLabel.setHidden(true)
                        yourGameScoreLabel.setText("🏆")
                        yourMatchScore += 1
                        yourMatchScoreLabel.setText(String(yourMatchScore))
                        matchScore = (yourMatchScore, opponentMatchScore)
                        let opponentGameScoreToSend = ["Opponent's game score": ""]
                        session.sendMessage(opponentGameScoreToSend, replyHandler: { replyMessage in
                            //handle and present the message on screen
                            _ = replyMessage["Opponent's game score"] as? String
                        }, errorHandler: {error in
                            // catch any errors here
                            print(error)
                        })
                        let yourGameScoreToSend = ["Your game score": "🏆"]
                        session.sendMessage(yourGameScoreToSend, replyHandler: { replyMessage in
                            //handle and present the message on screen
                            _ = replyMessage["Your game score"] as? String
                        }, errorHandler: {error in
                            // catch any errors here
                            print(error)
                        })
                        
                    default:
                        yourMatchScore += 1
                        yourMatchScoreLabel.setText(String(yourMatchScore))
                        matchScore = (yourMatchScore, opponentMatchScore)
                    }
                default:
                    opponentServingIndicatorLabel.setHidden(true)
                    opponentSetScoreLabel.setHidden(true)
                    opponentGameScoreLabel.setHidden(true)
                    yourServingIndicatorLabel.setHidden(true)
                    yourSetScoreLabel.setHidden(true)
                    yourGameScoreLabel.setText("🏆")
                    yourMatchScore += 1
                    yourMatchScoreLabel.setText(String(yourMatchScore))
                    matchScore = (yourMatchScore, opponentMatchScore)
                    let opponentGameScoreToSend = ["Opponent's game score": ""]
                    session.sendMessage(opponentGameScoreToSend, replyHandler: { replyMessage in
                        //handle and present the message on screen
                        _ = replyMessage["Opponent's game score"] as? String
                    }, errorHandler: {error in
                        // catch any errors here
                        print(error)
                    })
                    let yourGameScoreToSend = ["Your game score": "🏆"]
                    session.sendMessage(yourGameScoreToSend, replyHandler: { replyMessage in
                        //handle and present the message on screen
                        _ = replyMessage["Your game score"] as? String
                    }, errorHandler: {error in
                        // catch any errors here
                        print(error)
                    })
                    
                    
                }
                yourMatchScoreLabel.setText(String(yourMatchScore))
            default:
                if (yourSetScore > opponentSetScore + 1) && (opponentSetScore >= 5) {
                    opponentGameScore = 0
                    yourGameScore = 0
                    setScore = (0, 0)
                    opponentSetScore = 0
                    opponentSetScoreLabel.setText(String(opponentSetScore))
                    yourSetScore = 0
                    yourSetScoreLabel.setText(String(yourSetScore))
                    switch matchLength {
                    case 3:
                        switch matchScore {
                        case (1, 0...1):
                            opponentServingIndicatorLabel.setHidden(true)
                            opponentSetScoreLabel.setHidden(true)
                            opponentGameScoreLabel.setHidden(true)
                            yourServingIndicatorLabel.setHidden(true)
                            yourSetScoreLabel.setHidden(true)
                            yourGameScoreLabel.setText("🏆")
                            yourMatchScore += 1
                            yourMatchScoreLabel.setText(String(yourMatchScore))
                            matchScore = (yourMatchScore, opponentMatchScore)
                            let opponentGameScoreToSend = ["Opponent's game score": ""]
                            session.sendMessage(opponentGameScoreToSend, replyHandler: { replyMessage in
                                //handle and present the message on screen
                                _ = replyMessage["Opponent's game score"] as? String
                            }, errorHandler: {error in
                                // catch any errors here
                                print(error)
                            })
                            let yourGameScoreToSend = ["Your game score": "🏆"]
                            session.sendMessage(yourGameScoreToSend, replyHandler: { replyMessage in
                                //handle and present the message on screen
                                _ = replyMessage["Your game score"] as? String
                            }, errorHandler: {error in
                                // catch any errors here
                                print(error)
                            })
                            
                        default:
                            yourMatchScore += 1
                            yourMatchScoreLabel.setText(String(yourMatchScore))
                            matchScore = (yourMatchScore, opponentMatchScore)
                        }
                    case 5:
                        switch matchScore {
                        case (2, 0...2):
                            opponentServingIndicatorLabel.setHidden(true)
                            opponentSetScoreLabel.setHidden(true)
                            opponentGameScoreLabel.setHidden(true)
                            yourServingIndicatorLabel.setHidden(true)
                            yourSetScoreLabel.setHidden(true)
                            yourGameScoreLabel.setText("🏆")
                            yourMatchScore += 1
                            yourMatchScoreLabel.setText(String(yourMatchScore))
                            matchScore = (yourMatchScore, opponentMatchScore)
                            let opponentGameScoreToSend = ["Opponent's game score": ""]
                            session.sendMessage(opponentGameScoreToSend, replyHandler: { replyMessage in
                                //handle and present the message on screen
                                _ = replyMessage["Opponent's game score"] as? String
                            }, errorHandler: {error in
                                // catch any errors here
                                print(error)
                            })
                            let yourGameScoreToSend = ["Your game score": "🏆"]
                            session.sendMessage(yourGameScoreToSend, replyHandler: { replyMessage in
                                //handle and present the message on screen
                                _ = replyMessage["Your game score"] as? String
                            }, errorHandler: {error in
                                // catch any errors here
                                print(error)
                            })
                            
                        default:
                            yourMatchScore += 1
                            yourMatchScoreLabel.setText(String(yourMatchScore))
                            matchScore = (yourMatchScore, opponentMatchScore)
                        }
                    case 7:
                        switch matchScore {
                        case (3, 0...3):
                            opponentServingIndicatorLabel.setHidden(true)
                            opponentSetScoreLabel.setHidden(true)
                            opponentGameScoreLabel.setHidden(true)
                            yourServingIndicatorLabel.setHidden(true)
                            yourSetScoreLabel.setHidden(true)
                            yourGameScoreLabel.setText("🏆")
                            yourMatchScore += 1
                            yourMatchScoreLabel.setText(String(yourMatchScore))
                            matchScore = (yourMatchScore, opponentMatchScore)
                            let opponentGameScoreToSend = ["Opponent's game score": ""]
                            session.sendMessage(opponentGameScoreToSend, replyHandler: { replyMessage in
                                //handle and present the message on screen
                                _ = replyMessage["Opponent's game score"] as? String
                            }, errorHandler: {error in
                                // catch any errors here
                                print(error)
                            })
                            let yourGameScoreToSend = ["Your game score": "🏆"]
                            session.sendMessage(yourGameScoreToSend, replyHandler: { replyMessage in
                                //handle and present the message on screen
                                _ = replyMessage["Your game score"] as? String
                            }, errorHandler: {error in
                                // catch any errors here
                                print(error)
                            })
                            
                        default:
                            yourMatchScore += 1
                            yourMatchScoreLabel.setText(String(yourMatchScore))
                            matchScore = (yourMatchScore, opponentMatchScore)
                        }
                    default:
                        opponentServingIndicatorLabel.setHidden(true)
                        opponentSetScoreLabel.setHidden(true)
                        opponentGameScoreLabel.setHidden(true)
                        yourServingIndicatorLabel.setHidden(true)
                        yourSetScoreLabel.setHidden(true)
                        yourGameScoreLabel.setText("🏆")
                        yourMatchScore += 1
                        yourMatchScoreLabel.setText(String(yourMatchScore))
                        matchScore = (yourMatchScore, opponentMatchScore)
                        let opponentGameScoreToSend = ["Opponent's game score": ""]
                        session.sendMessage(opponentGameScoreToSend, replyHandler: { replyMessage in
                            //handle and present the message on screen
                            _ = replyMessage["Opponent's game score"] as? String
                        }, errorHandler: {error in
                            // catch any errors here
                            print(error)
                        })
                        let yourGameScoreToSend = ["Your game score": "🏆"]
                        session.sendMessage(yourGameScoreToSend, replyHandler: { replyMessage in
                            //handle and present the message on screen
                            _ = replyMessage["Your game score"] as? String
                        }, errorHandler: {error in
                            // catch any errors here
                            print(error)
                        })
                        
                    }
                    yourMatchScoreLabel.setText(String(yourMatchScore))
                }
            }
        }
    }
}
