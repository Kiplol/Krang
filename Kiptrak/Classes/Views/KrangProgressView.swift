//
//  KrangProgressView.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 1/19/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit

class KrangProgressView: UIView {
    
    //MARK:- ivars
    private let fillView = UIView()
    private var displayLink: CADisplayLink? = nil
    
    var progress: Float = 0.0 {
        didSet {
            self.fillView.frame.size.width = self.bounds.size.width * CGFloat(self.progress)
        }
    }
    
    var startDate:Date? = nil
    var endDate:Date? = nil
    
    //MARK:- Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    func commonInit() {
        self.backgroundColor = UIColor.clear
        self.fillView.frame = CGRect(x: 0, y: 0, width: 0, height: self.bounds.size.height)
        self.fillView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.fillView.backgroundColor = UIColor.accent.alpha(0.2)
        self.addSubview(self.fillView)
        self.progress = 0.0
    }
    
    //MARK:-
    func start() {
        guard let _ = self.startDate, let _ = self.endDate else {
            self.stop()
            self.reset()
            return
        }
        
        if self.displayLink == nil {
            self.displayLink = CADisplayLink(target: self, selector: #selector(KrangProgressView.update))
            self.displayLink?.add(to: RunLoop.main, forMode: .defaultRunLoopMode)
        }
    }
    
    func stop() {
        self.displayLink?.remove(from: RunLoop.main, forMode: .defaultRunLoopMode)
        self.displayLink?.invalidate()
        self.displayLink = nil
    }
    
    func reset() {
        self.progress = 0.0
    }
    
    func update() {
        guard let startDate = self.startDate, let endDate = self.endDate else {
            self.stop()
            self.reset()
            return
        }
        
        let totalRunTime = endDate.timeIntervalSince1970 - startDate.timeIntervalSince1970
        let now = Date().timeIntervalSince1970
        let watchedSoFar = now - startDate.timeIntervalSince1970
        self.progress = Float(Double(watchedSoFar) / Double(totalRunTime))
    }

}
