//
//  MoviesCollectionDataSource.swift
//  Tomatillo
//
//  Created by Raul Agrait on 4/19/15.
//  Copyright (c) 2015 rateva. All rights reserved.
//

import Foundation
import UIKit

class MoviesCollectionViewDataSource: BaseMoviesDataSource, UICollectionViewDataSource {
    
    class var reuseIdentifier: String {
        get { return "MovieCollectionCell" }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return getMovieCount()
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let reuseId = MoviesCollectionViewDataSource.reuseIdentifier
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseId, forIndexPath: indexPath) as! MovieCollectionCell
        
        let movieData = getMovieData(indexPath.row)
        let lowResUrlString = movieData[MovieDataKey.LowResUrlString]!
        let highResUrlString = movieData[MovieDataKey.HighResUrlString]!

        cell.posterImageView.image = nil
        cell.posterImageView?.setMultipleUrls(firstString: lowResUrlString, secondString: highResUrlString)
        cell.titleLabel.text = movieData[MovieDataKey.Title]
        
        return cell
    }
}