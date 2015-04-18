//
//  MovieDetailsViewController.swift
//  Tomatillo
//
//  Created by Raul Agrait on 4/15/15.
//  Copyright (c) 2015 rateva. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var synopsisLabel: UILabel!
    
    var movie: NSDictionary!
    
    @IBOutlet weak var scrollView: UIScrollView!
    var initialScrollY: CGFloat = 0.0
    
    var lowResUrlString: String {
        return movie.valueForKeyPath("posters.thumbnail") as! String
    }
    
    var highResUrlString: String {
        var urlString = lowResUrlString
        var range = urlString.rangeOfString(".*cloudfront.net/", options: .RegularExpressionSearch)
        if let range = range {
            urlString = urlString.stringByReplacingCharactersInRange(range, withString: "https://content6.flixster.com/")
        }
        return urlString
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var movieTitle = movie["title"] as? String
        navigationItem.title = movieTitle

        titleLabel.text = movieTitle
        synopsisLabel.text = movie["synopsis"] as? String
        loadLowResImage()
        
        var margin = titleLabel.frame.minX
        var titleHeight = titleLabel.frame.height
        
        var synopsisFrame = synopsisLabel.frame
        synopsisLabel.frame = CGRect(x: synopsisFrame.minX, y: synopsisFrame.minY, width: synopsisFrame.width, height: 0)
        synopsisLabel.sizeToFit()
        var synopsisHeight = synopsisLabel.frame.height
        var contentHeight = margin + titleHeight + margin + synopsisHeight + margin
        scrollView.contentSize.height = contentHeight
        
        scrollView.delegate = self
        scrollView.clipsToBounds = true
        initialScrollY = scrollView.frame.minY
    }
    
    func loadLowResImage() {
        let urlString = lowResUrlString
        loadImage(urlString, callback: {
            dispatch_async(dispatch_get_main_queue(), {
                self.loadHighResImage()
            })
        })
    }
    
    func loadHighResImage() {
        let urlString = highResUrlString
        loadImage(urlString, callback: {})
    }
    
    func loadImage(urlString: String, callback: () -> Void) {
        let url = NSURL(string: urlString)!
        let urlRequest = NSURLRequest(URL: url)

        self.backgroundImageView.setImageWithURLRequest(urlRequest, placeholderImage: nil,
            success: { (request: NSURLRequest!, response: NSURLResponse!, image: UIImage!) -> Void in
                self.backgroundImageView.image = image
                callback()
            },
            failure: { (request: NSURLRequest!, response: NSHTTPURLResponse!, error: NSError!) -> Void in
                println(error)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
