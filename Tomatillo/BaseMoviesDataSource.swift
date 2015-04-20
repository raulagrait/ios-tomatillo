//
//  BaseMoviesDataSource.swift
//  Tomatillo
//
//  Created by Raul Agrait on 4/19/15.
//  Copyright (c) 2015 rateva. All rights reserved.
//

import Foundation
import UIKit

enum MovieDataKey {
    case Title
    case Synopsis
    case LowResUrlString
    case HighResUrlString
}

class BaseMoviesDataSource: NSObject {
    
    var searchText: String = ""
    var isFiltering: Bool {
        return !searchText.isEmpty
    }
    
    var filteredMovies: [NSDictionary]?
    var movies: [NSDictionary]?

    func getMovieData(index: Int) -> [MovieDataKey: String] {
        let movie = getMovie(index)!
        let title = movie["title"] as! String
        let synopsis = movie["synopsis"] as! String
        let lowResUrlString = movie.valueForKeyPath("posters.thumbnail") as! String
        let highResUrlString = getHighResUrlString(from: lowResUrlString)
        
        let data: [MovieDataKey: String] = [
            MovieDataKey.Title: title,
            MovieDataKey.Synopsis:  synopsis,
            MovieDataKey.LowResUrlString: lowResUrlString,
            MovieDataKey.HighResUrlString: highResUrlString
        ]
        return data
    }
    
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
    
    func getMovieCount() -> Int {
        if isFiltering, let filteredMovies = filteredMovies {
            return filteredMovies.count
        }
        
        if let movies = movies {
            return movies.count
        }
        return 0
    }
    
    func getHighResUrlString(from lowResUrlString: String) -> String {
        var urlString = lowResUrlString
        if let range = lowResUrlString.rangeOfString(".*cloudfront.net/", options: .RegularExpressionSearch) {
            urlString = urlString.stringByReplacingCharactersInRange(range, withString: "https://content6.flixster.com/")
        }
        return urlString
    }
}

