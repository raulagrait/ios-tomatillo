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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MoviesCollectionViewDataSource.reuseIdentifier, forIndexPath: indexPath) as! MovieCollectionCell
        cell.backgroundColor = UIColor.purpleColor()
        return cell
    }
}