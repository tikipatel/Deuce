//
//  ViewController.swift
//  Deuce
//
//  Created by Austin Conlon on 11/27/16.
//  Copyright © 2017 Austin Conlon. All rights reserved.
//

import UIKit

class ViewController: UIViewController {


    // MARK: Properties
    @IBOutlet weak var firstPlayerGameScoreLabel: UIButton!
    @IBOutlet weak var firstPlayerSetScoreLabel: UILabel!
    @IBOutlet weak var firstPlayerMatchScoreLabel: UILabel!
    @IBOutlet weak var firstPlayerServingLabel: UILabel!
    
    @IBOutlet weak var secondPlayerGameScoreLabel: UIButton!
    @IBOutlet weak var secondPlayerSetScoreLabel: UILabel!
    @IBOutlet weak var secondPlayerMatchScoreLabel: UILabel!
    @IBOutlet weak var secondPlayerServingLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        firstPlayerServingLabel.isHidden = true
        secondPlayerServingLabel.isHidden = true
        
        ScoreManager.determineWhoServes()
        if let server = ScoreManager.server {
            switch server {
            case .first:
                firstPlayerServingLabel.isHidden = false
            case .second:
                secondPlayerServingLabel.isHidden = false
            }
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        // Initialize properties here.
        
        super.init(coder: aDecoder)!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Mark: Actions
    
    @IBAction func changeMatchLength(_ sender: Any) {
    }
    
    @IBAction func changeTypeOfSet(_ sender: Any) {
    }
    
    @IBAction func incrementFirstPlayerScore(_ sender: Any) {
        firstPlayer.incrementGameScore()
        switch firstPlayer.gameScore {
        case 0:
            firstPlayerGameScoreLabel.setTitle("Love", for: .normal)
            secondPlayerGameScoreLabel.setTitle("Love", for: .normal)
        case 40:
            switch ScoreManager.isInDeuceSituation {
            case true:
                firstPlayerGameScoreLabel.setTitle("Deuce", for: .normal)
                secondPlayerGameScoreLabel.setTitle("Deuce", for: .normal)
            case false:
                if let _ = ScoreManager.advantage { // Advantage first player
                    if let server = ScoreManager.server {
                        switch server {
                        case .first:
                            firstPlayerGameScoreLabel.setTitle("Ad in", for: .normal)
                        case .second:
                            firstPlayerGameScoreLabel.setTitle("Ad out", for: .normal)
                        }
                    }
                }
                if ScoreManager.advantage == nil {
                    firstPlayerGameScoreLabel.setTitle(String(firstPlayer.gameScore), for: .normal)
                }
            }
        default:
            firstPlayerGameScoreLabel.setTitle(String(firstPlayer.gameScore), for: .normal)
        }
    }
    
    @IBAction func incrementSecondPlayerScore(_ sender: Any) {
        secondPlayer.incrementGameScore()
        switch secondPlayer.gameScore {
        case 0:
            firstPlayerGameScoreLabel.setTitle("Love", for: .normal)
            secondPlayerGameScoreLabel.setTitle("Love", for: .normal)
        case 40:
            if ScoreManager.isInDeuceSituation {
                firstPlayerGameScoreLabel.setTitle("Deuce", for: .normal)
                secondPlayerGameScoreLabel.setTitle("Deuce", for: .normal)
            } else {
                secondPlayerGameScoreLabel.setTitle(String(secondPlayer.gameScore), for: .normal)
            }
        default:
            if ScoreManager.advantage == .second {
                secondPlayerGameScoreLabel.setTitle("Ad in", for: .normal)
            } else if ScoreManager.advantage == nil {
                secondPlayerGameScoreLabel.setTitle(String(secondPlayer.gameScore), for: .normal)
            }
        }
    }
    
}
