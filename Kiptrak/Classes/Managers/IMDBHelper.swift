//
//  IMDBHelper.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 1/13/18.
//  Copyright © 2018 Supernovacaine Inc. All rights reserved.
//

import OAuthSwift

class IMDBHelper: NSObject {
    
    static let shared = IMDBHelper()
    let oauth = OAuth2Swift(consumerKey: "", consumerSecret: "", authorizeUrl: "", responseType: "")
    
    func getTrivia(forWatchable watchable: KrangWatchable, completion:(([String]) -> ())?) {
        guard let urlForIMDB = watchable.urlForIMDB,
            let urlForTrivia = URL(string: "\(urlForIMDB.absoluteString)/trivia") else {
            return
        }
        
        URLSession.shared.dataTask(with: urlForTrivia) { (data, response, error) in
            guard let data = data, let html = String(data: data, encoding: .utf8) else {
                DispatchQueue.main.async {
                    completion?([])
                }
                return
            }
            
            do {
                let regex = try NSRegularExpression(pattern: "(?s)(?<=<div class=\"sodatext\">).*?(?=</div>)", options: [])
                let piecesOfTrivia = regex.matches(in: html, options: [], range: NSRange(html.startIndex..., in: html)).map {
                    String(html[Range($0.range, in: html)!])
                    }.map {
                        $0.html2String
                }
                DispatchQueue.main.async {
                    completion?(piecesOfTrivia)
                }
            } catch {
                DispatchQueue.main.async {
                    completion?([])
                }
            }
        }.resume()
    }

}

extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

extension String {
    var html2AttributedString: NSAttributedString? {
        return Data(utf8).html2AttributedString
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}
