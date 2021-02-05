//
//  ImgurDownloader.swift
//  ImgurSearch
//
//  Created by Amit Barman on 6/11/18.
//  Copyright (c) 2018 Apollo Software, All rights reserved.
//

import Foundation

@objc public class ImgurDownloader: NSObject {
    
    func doDownload(url: String, file: String) -> String {
        return(url + "/" + file);
    }
    
    func doTest () -> String {
        return "test"
    }
    
    func load(url: URL, to localUrl: URL, completion: @escaping () -> ()) {
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request = URLRequest(url: url)
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Success: \(statusCode)")
                }
                
                do {
                    try FileManager.default.copyItem(at: tempLocalUrl, to: localUrl)
                    completion()
                } catch (let writeError) {
                    print("error writing file \(localUrl) : \(writeError)")
                }
                
            }
        }
        task.resume()
    }
}
