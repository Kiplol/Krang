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
