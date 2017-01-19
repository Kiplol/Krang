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
    var progress: Float = 0.0 {
        didSet {
            self.fillView.frame.size.width = self.bounds.size.width * CGFloat(self.progress)
        }
    }
    
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
        self.fillView.backgroundColor = UIColor.accent
        self.addSubview(self.fillView)
        self.progress = 0.0
    }

}
