//
//  KrangImageUtils.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 1/10/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit
import Kingfisher

extension UIImage
{
    func tintWithColor(color:UIColor)->UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return self
        }

        
        // flip the image
//        CGContextScaleCTM(context, 1.0, -1.0)
//        CGContextTranslateCTM(context, 0.0, -self.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.translateBy(x: 0.0, y: -self.size.height)
        
        // multiply blend mode
//        CGContextSetBlendMode(context, kCGBlendModeMultiply)
        context.setBlendMode(.color)
        
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
//        CGContextClipToMask(context, rect, self.CGImage)
//        color.setFill()
//        CGContextFillRect(context, rect)
        context.clip(to: rect, mask: self.cgImage!)
        color.setFill()
        context.fill(rect)
        
        // create uiimage
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}

extension UIImageView {
    
    func setAvatar(fromURL url:String?) {
        guard let url = url else {
            //TODO: Set default avatar
            return
        }
        
        guard let urlURL = URL(string: url) else {
            //TODO: Set default avatar
            return
        }
        
        self.kf.setImage(with: urlURL)
    }
    
    func setCoverImage(fromURL url:String?) {
        guard let url = url else {
            self.image = #imageLiteral(resourceName: "cover_default_1")
            return
        }
        
        guard let urlURL = URL(string: url) else {
            self.image = #imageLiteral(resourceName: "cover_default_1")
            return
        }
        
        self.kf.setImage(with: urlURL)
    }
    
}
