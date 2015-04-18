//
//  MovieCell.swift
//  Tomatillo
//
//  Created by Raul Agrait on 4/15/15.
//  Copyright (c) 2015 rateva. All rights reserved.
//

import UIKit

class MovieCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!    
    @IBOutlet weak var synopsisLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    
    let rottenGreen = UIColor(red: 54.0/255.0, green: 129.0/255.0, blue: 26.0/255.0, alpha: 0.5)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        var backgroundView = UIView()
        backgroundView.backgroundColor = rottenGreen
        self.selectedBackgroundView = backgroundView
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        var color = selected ? rottenGreen : UIColor.whiteColor()
        backgroundColor = color
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        var color = highlighted ? rottenGreen : UIColor.whiteColor()
        backgroundColor = color
    }

}
