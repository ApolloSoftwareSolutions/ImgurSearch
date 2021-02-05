//
//  ImgurHelper.swift
//  ImgurSearch
//
//  Created by Amit Barman on 6/11/18.
//  Copyright (c) 2018 Apollo Software, All rights reserved.
//

import Foundation
import UIKit

extension StringProtocol {
    var firstUppercased: String {
        guard let first = first else { return "" }
        return String(first).uppercased() + dropFirst()
    }
}
@objc public class ImgurHelper: NSObject {
    
    func getDateTime(_ts: String) -> String {
        let unixTimestamp = Double(_ts)
        let date = Date(timeIntervalSince1970: unixTimestamp!)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let strDate = dateFormatter.string(from: date)
        return strDate
    }
    
    func getSearchString(sort: String, window: String) -> String {
        var sort_ : String
        var window_ : String
        print("Getting Search String ->" + sort + "," + window)
        sort_ = sort
        sort_.remove(at: sort_.startIndex)
        window_ = window
        window_.remove(at: window_.startIndex)
        
        return "" + sort_.firstUppercased + ", " + window_.firstUppercased;
    }
    
    func captureScreen(view:UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
    }
}
