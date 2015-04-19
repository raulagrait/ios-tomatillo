//
//  BaseMoviesDataSource.swift
//  Tomatillo
//
//  Created by Raul Agrait on 4/19/15.
//  Copyright (c) 2015 rateva. All rights reserved.
//

import Foundation
import UIKit

class BaseMoviesDataSource: NSObject {
    
    var searchText: String = ""
    var isFiltering: Bool {
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
    
    func getMovieCount() -> Int {
        if isFiltering, let filteredMovies = filteredMovies {
            return filteredMovies.count
        }
        
        if let movies = movies {
            return movies.count
        }
        return 0
    }
}