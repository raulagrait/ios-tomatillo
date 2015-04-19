//
//  MoviesTableViewDataSource.swift
//  Tomatillo
//
//  Created by Raul Agrait on 4/19/15.
//  Copyright (c) 2015 rateva. All rights reserved.
//

import Foundation
import UIKit

class MoviesTableViewDataSource: NSObject, UITableViewDataSource {
    
    var searchText: String = ""
    private var isFiltering: Bool {
        return !searchText.isEmpty
    }
    
    var filteredMovies: [NSDictionary]?
    var movies: [NSDictionary]?
    
    func getMovie(atIndex: Int) -> NSDictionary? {
        if isFiltering, let filteredMovies = filteredMovies {
            return filteredMovies[atIndex]
        } else if let movies = movies {
            return movies[atIndex]
        }
        return nil
    }
    
    func filterMovies(callback: () -> Void) {
        filteredMovies = movies?.filter({ (movie) -> Bool in
            if let title = movie["title"] as? String {
                if let range = title.rangeOfString(self.searchText, options: NSStringCompareOptions.CaseInsensitiveSearch) {
                    return true
                }
            }
            return false
        })
        callback()
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering, let filteredMovies = filteredMovies {
            return filteredMovies.count
        }
        
        if let movies = movies {
            return movies.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = getMovie(indexPath.row)!
        
        cell.titleLabel.text = movie["title"] as? String
        cell.synopsisLabel.text = movie["synopsis"] as? String
        
        let url = NSURL(string: movie.valueForKeyPath("posters.thumbnail") as! String)!
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