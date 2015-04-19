//
//  MovieCollectionCell.swift
//  Tomatillo
//
//  Created by Raul Agrait on 4/19/15.
//  Copyright (c) 2015 rateva. All rights reserved.
//

import UIKit

class MovieCollectionCell: UICollectionViewCell {
    var posterImageView: UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializePosterImageView()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializePosterImageView()
    }
    
    func initializePosterImageView() {
        posterImageView = UIImageView(frame: bounds)
        self.addSubview(posterImageView!)
    }

    
}