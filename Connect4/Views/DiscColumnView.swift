//
//  DiscsColumnView.swift
//  Connect4
//
//  Created by Yuhong He on 04/12/2023.
//

import UIKit
import AVFoundation
// The balls in each column are placed on this view

class DiscColumnView: UIView, UICollisionBehaviorDelegate {
    public var gravity = UIGravityBehavior() // Gravity effects
    public var collider = UICollisionBehavior() // Boundary collision effects
    public var animator: UIDynamicAnimator?
    private var droppingSound: AVPlayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.animator = UIDynamicAnimator(referenceView: self)
        self.animator?.addBehavior(self.gravity)
        self.collider.translatesReferenceBoundsIntoBoundary =  true
        self.animator?.addBehavior(self.collider)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addAnimationItem(discsView: DiscView) {
        collider.addItem(discsView)
        gravity.addItem(discsView)
        playDroppingSound()
    }
    
    func removeAnimationItem(discsView: DiscView) {
        collider.removeItem(discsView)
        gravity.removeItem(discsView)
    }
    
    private func playDroppingSound() {
        if let soundURL = Bundle.main.url(forResource: "drop", withExtension: "mp3") {
            droppingSound = AVPlayer(url: soundURL)
            droppingSound?.play()
        }
    }
}
