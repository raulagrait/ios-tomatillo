//
//  UIImageView+Multiple.swift
//  Tomatillo
//
//  Created by Raul Agrait on 4/19/15.
//  Copyright (c) 2015 rateva. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    func setMultipleUrls(firstString firstUrlString: String, secondString secondUrlString: String) {
        loadImage(firstUrlString, callback: {
            dispatch_async(dispatch_get_main_queue(), {
                self.loadImage(secondUrlString, callback: {})
            })
        })
    }
    
    func loadImage(urlString: String, callback: () -> Void) {
        let url = NSURL(string: urlString)!
        let urlRequest = NSURLRequest(URL: url)
        
        self.setImageWithURLRequest(urlRequest, placeholderImage: nil,
            success: { (request: NSURLRequest!, response: NSURLResponse!, image: UIImage!) -> Void in
                self.image = image
                callback()
            },
            failure: { (request: NSURLRequest!, response: NSHTTPURLResponse!, error: NSError!) -> Void in
                println(error)
        })
    }
}