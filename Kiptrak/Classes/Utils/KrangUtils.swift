//
//  KrangUtils.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 9/7/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit

class KrangUtils: NSObject {
    
    class var bundleInfo: [String: Any] {
        return Bundle.main.infoDictionary!
    }
    
    class var versionNumberString: String {
        return bundleInfo["CFBundleShortVersionString"] as! String
    }
    
    class var buildNumberString: String {
        return bundleInfo["CFBundleVersion"] as! String
    }
    
    class var versionAndBuildNumberString: String {
        return "\(versionNumberString) (\(buildNumberString))"
    }
    
    class var lastRunVersionNumber: String? {
        return UserDefaults.krangDefaults?.object(forKey: "lastRunVersionNumber") as? String
    }
    
    class func setThisAsLastRunVersion() {
        UserDefaults.krangDefaults?.set(KrangUtils.versionNumberString, forKey: "lastRunVersionNumber")
        UserDefaults.krangDefaults?.synchronize()
    }
    
    class var isFirstTimeRunningThisVersion: Bool {
        guard let lastRunVersion = KrangUtils.lastRunVersionNumber else {
            return true
        }
        return KrangUtils.versionNumberString == lastRunVersion
    }
    
    public enum DisplayType {
        case unknown
        case iphone4
        case iphone5
        case iphone6
        case iphone6plus
        static let iphone7 = iphone6
        static let iphone7plus = iphone6plus
        case iphoneX
    }
    
    public final class Display {
        class var width:CGFloat { return UIScreen.main.bounds.size.width }
        class var height:CGFloat { return UIScreen.main.bounds.size.height }
        class var maxLength:CGFloat { return max(width, height) }
        class var minLength:CGFloat { return min(width, height) }
        class var zoomed:Bool { return UIScreen.main.nativeScale >= UIScreen.main.scale }
        class var retina:Bool { return UIScreen.main.scale >= 2.0 }
        class var phone:Bool { return UIDevice.current.userInterfaceIdiom == .phone }
        class var pad:Bool { return UIDevice.current.userInterfaceIdiom == .pad }
        class var carplay:Bool { return UIDevice.current.userInterfaceIdiom == .carPlay }
        class var tv:Bool { return UIDevice.current.userInterfaceIdiom == .tv }
        class var typeIsLike:DisplayType {
            if phone && maxLength < 568 {
                return .iphone4
            }
            else if phone && maxLength == 568 {
                return .iphone5
            }
            else if phone && maxLength == 667 {
                return .iphone6
            }
            else if phone && maxLength == 736 {
                return .iphone6plus
            }
            else if phone && maxLength == 812 {
                return .iphoneX
            }
            return .unknown
        }
    }
}

extension URL {
    static func from(string: String?) -> URL? {
        if let string = string {
            return URL(string: string)
        } else {
            return nil
        }
    }
}

class UserPrefs {
    
    class var traktSync: Bool {
        get {
            guard let sharedDefaults = UserDefaults.krangDefaults else {
                return false
            }
            return sharedDefaults.object(forKey: "traktSync") as? Bool ?? false
        }
        set {
            guard let sharedDefaults = UserDefaults.krangDefaults else {
                return
            }
            sharedDefaults.set(newValue, forKey: "traktSync")
            sharedDefaults.synchronize()
        }
    }
    
}

extension UserDefaults {
    class var krangDefaults: UserDefaults? { return UserDefaults(suiteName: "group.com.kip.krang") }
}
