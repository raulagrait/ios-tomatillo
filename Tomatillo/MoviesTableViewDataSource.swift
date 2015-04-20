//
//  MoviesTableViewDataSource.swift
//  Tomatillo
//
//  Created by Raul Agrait on 4/19/15.
//  Copyright (c) 2015 rateva. All rights reserved.
//

import Foundation
import UIKit

class MoviesTableViewDataSource: BaseMoviesDataSource, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getMovieCount()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movieData = getMovieData(indexPath.row)
        cell.titleLabel.text = movieData[MovieDataKey.Title]
        cell.synopsisLabel.text = movieData[MovieDataKey.Synopsis]

        let urlString = movieData[MovieDataKey.LowResUrlString]!
        let url = NSURL(string: urlString)!
        var urlRequest = NSURLRequest(URL: url)
        
        cell.posterImageView.image = nil        
        cell.posterImageView.setImageWithURLRequest(urlRequest, placeholderImage: nil, success: { (request: NSURLRequest!, response: NSURLResponse!, image: UIImage!) -> Void in
            
            let fromCache = (request == nil)
            if (fromCache) {
                cell.posterImageView.image = image
            } else {
                UIView.transitionWithView(cell.posterImageView, duration: 1.0, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
                    cell.posterImageView.image = image
                    }, completion: nil)
            }
            
            }, failure: nil)
        return cell
    }
}