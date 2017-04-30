//
//  InterfaceController.swift
//  Deuce WatchKit Extension
//
//  Created by Austin Conlon on 11/27/16.
//  Copyright © 2017 Austin Conlon. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    // MARK: Properties
    
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
//    var settingsData: [String: Int]
    
//    override func contextForSegue(withIdentifier segueIdentifier: String) -> Any? {
//        // Return data to be accessed in ResultsController
//        return self.settingsData
//    }
    
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
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override init() {
        // Initialize properties here.
        matchLength = 1
        setType = 1
//        settingsData = ["match length": matchLength, "set type": setType]
        
        super.init()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func seriesLengthSlider(_ value: Float) {
        switch value {
        case 2:
            ScoreManager.matchLength = .bestOfThreeSets
            seriesLengthLabel.setText("Best-of three sets")
        case 3:
            ScoreManager.matchLength = .bestOfFiveSets
            seriesLengthLabel.setText("Best-of five sets")
        case 4:
            ScoreManager.matchLength = .bestOfSevenSets
            seriesLengthLabel.setText("Best-of seven sets")
        default:
            ScoreManager.matchLength = .oneSet
            seriesLengthLabel.setText("One set")
        }
    }
    
    @IBAction func typeOfSetSlider(_ value: Bool) {
        switch value {
        case false:
            ScoreManager.setType = .tiebreaker
            typeOfSetSlider.setTitle("Tiebreaker set")
        case true:
            ScoreManager.setType = .advantage
            typeOfSetSlider.setTitle("Advantage set")
        }
    }
    
    @IBAction func incrementOpponentScore(_ sender: Any? = nil) {
    
    }
    
    @IBAction func incrementYourScore(_ sender: Any? = nil) {
        
    }
}
