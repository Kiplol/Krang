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
    
    convenience init?(gradientColors:[UIColor], size:CGSize = CGSize(width: 10, height: 10), locations: [Float] = [] )
    {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colors = gradientColors.map {(color: UIColor) -> AnyObject? in return color.cgColor as AnyObject? } as NSArray
        let gradient: CGGradient
        if locations.count > 0 {
            let cgLocations = locations.map { CGFloat($0) }
            gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: cgLocations)!
        } else {
            gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: nil)!
        }
        context!.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: size.height), options: CGGradientDrawingOptions(rawValue: 0))
        self.init(cgImage:(UIGraphicsGetImageFromCurrentImageContext()?.cgImage!)!)
        UIGraphicsEndImageContext()
    }
}

extension UIImageView {
    
    func setAvatar(fromURL url:String?) {
        guard let url = url else {
            //TODO: Set default avatar
            self.image = nil
            return
        }
        
        guard let urlURL = URL(string: url) else {
            //TODO: Set default avatar
            self.image = nil
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
    
    func setPoster(fromMovie movie:KrangMovie?) {
        guard let posterURL = movie?.posterImageURL else {
            //TODO
            self.image = #imageLiteral(resourceName: "poster_placeholder_dark")
            return
        }
        
        guard let url = URL(string: posterURL) else {
            //TODO
            self.image = #imageLiteral(resourceName: "poster_placeholder_dark")
            return
        }
        
        self.kf.setImage(with: url)
    }
    
    func setPoster(fromEpisode episode:KrangEpisode?) {
        guard let szURL = episode?.posterImageURL else {
            //TODO
            self.image = #imageLiteral(resourceName: "poster_placeholder_dark")
            return
        }
        
        guard let url = URL(string: szURL) else {
            //TODO
            self.image = #imageLiteral(resourceName: "poster_placeholder_dark")
            return
        }
        
        self.kf.setImage(with: url)
    }
    
    func setPoster(fromWatchable watchable:KrangWatchable?) {
        guard let szURL = watchable?.posterImageURL else {
            //TODO
            self.image = #imageLiteral(resourceName: "poster_placeholder_dark")
            return
        }
        
        guard let url = URL(string: szURL) else {
            //TODO
            self.image = #imageLiteral(resourceName: "poster_placeholder_dark")
            return
        }
        
        self.kf.setImage(with: url)
    }
    
    func setStill(fromEpisode episode:KrangEpisode?) {
        guard let stillURL = episode?.stillImageURL else {
            //TODO
            self.image = nil
            return
        }
        
        guard let url = URL(string: stillURL) else {
            //TODO
            self.image = nil
            return
        }
        
        self.kf.setImage(with: url)
    }
    
}
