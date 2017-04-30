//
//  MotionManager.swift
//  Deuce
//
//  Created by Austin Conlon on 3/24/17.
//  Copyright © 2017 Austin Conlon. All rights reserved.
//

import Foundation
import CoreMotion
import WatchKit

/**
 `MotionManagerDelegate` exists to inform delegates of motion changes.
 These contexts can be used to enable application specific behavior.
 */
protocol MotionManagerDelegate: class {
    func didUpdateForehandSwingCount(_ manager: MotionManager, forehandCount: Int)
    func didUpdateBackhandSwingCount(_ manager: MotionManager, backhandCount: Int)
}

class MotionManager {
    // MARK: Properties
    
    let motionManager = CMMotionManager()
    let queue = OperationQueue()
    let wristLocationIsLeft = WKInterfaceDevice.current().wristLocation == .left
    
    // MARK: Application Specific Constants
    
    let yawThreshold = 1.95 // Radians
    let rateThreshold = 5.5 // Radians/sec
    let resetThreshold = 5.5 * 0.05 // To avoid double counting on the return swing.
    
    // The app is using 50hz data and the buffer is going to hold 1s worth of data.
    let sampleInterval = 1.0 / 50
    let rateAlongGravityBuffer = RunningBuffer(size: 50)
    
    weak var delegate: MotionManagerDelegate?
    
    // Swing counts
    
    var forehandCount = 0
    var backhandCount = 0
    
    var recentDetection = false
    
    // MARK: Initialization
    
    init() {
        // Serial queue for sample handling and calculations.
        queue.maxConcurrentOperationCount = 1
        queue.name = "MotionManagerQueue"
    }
    
    func resetAllState() {
        forehandCount = 0
        backhandCount = 0
        recentDetection = false
        rateAlongGravityBuffer.reset()
        
        delegate?.didUpdateForehandSwingCount(self, forehandCount: 0)
        delegate?.didUpdateBackhandSwingCount(self, backhandCount: 0)
    }
    
    func incrementForehandCountAndUpdateDelegate() {
        if (!recentDetection) {
            forehandCount += 1
            recentDetection = true
            delegate?.didUpdateForehandSwingCount(self, forehandCount: forehandCount)
        }
    }
    
    func incrementBackhandCountAndUpdateDelegate() {
        if (!recentDetection) {
            backhandCount += 1
            recentDetection = true
            delegate?.didUpdateBackhandSwingCount(self, backhandCount: backhandCount)
        }
    }
    
    func startUpdates() {
        if !motionManager.isDeviceMotionActive {
            print("Device Motion is not available.")
            return
        }
        // Reset everything when we start.
        resetAllState()
        
        motionManager.deviceMotionUpdateInterval = sampleInterval // 0.02 seconds
        motionManager.startDeviceMotionUpdates(to: queue) { (deviceMotion: CMDeviceMotion?, error: Error?) in
            if error != nil {
                print("Encountered error: \(error!)")
            }
            
            if deviceMotion != nil {
                self.processDeviceMotion(deviceMotion!)
            }
        }
    }
    
    func processDeviceMotion(_ deviceMotion: CMDeviceMotion) {
        let gravity = deviceMotion.gravity
        let rotateRate = deviceMotion.rotationRate
        
        let rateAlongGravity = rotateRate.x * gravity.x
                             + rotateRate.y * gravity.y
                             + rotateRate.z * gravity.z
        rateAlongGravityBuffer.addSample(rateAlongGravity)
        
        if !rateAlongGravityBuffer.isFull() {
            return
        }
        
        let accumulatedYawRot = rateAlongGravityBuffer.sum() * sampleInterval
        let peakRate = accumulatedYawRot > 0 ?
            rateAlongGravityBuffer.max() : rateAlongGravityBuffer.min()
    
        if (accumulatedYawRot < -yawThreshold && peakRate < -rateThreshold) {
            // Counter clockwise swing.
            if (wristLocationIsLeft) {
                incrementBackhandCountAndUpdateDelegate()
            } else {
                incrementForehandCountAndUpdateDelegate()
            }
        } else if (accumulatedYawRot > yawThreshold && peakRate > rateThreshold) {
            // Clockwise swing
            if (wristLocationIsLeft) {
                incrementForehandCountAndUpdateDelegate()
            } else {
                incrementBackhandCountAndUpdateDelegate()
            }
        }
        
        if (recentDetection && abs(rateAlongGravityBuffer.recentMean()) < resetThreshold) {
            recentDetection = false
            rateAlongGravityBuffer.reset()
        }
    }
    
    func stopUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.stopDeviceMotionUpdates()
        }
    }
}
