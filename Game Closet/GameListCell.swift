//
//  GameListCell.swift
//  Game Closet
//
//  Created by Matthew Young on 4/6/16.
//  Copyright © 2016 Matthew Young. All rights reserved.
//

import Foundation
import UIKit

class GameListCell: UITableViewCell {
    
    @IBOutlet weak var gameImageView: UIImageView!
    
    @IBOutlet weak var gameNameTitleLabel: UILabel!
    @IBOutlet weak var gameDescriptionTitleLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //Everything below, copied from http://stackoverflow.com/questions/26041820/auto-layout-get-uiimageview-height-to-calculate-cell-height-correctly/26056737#26056737
    
    internal var aspectConstraint : NSLayoutConstraint? {
        didSet {
            if oldValue != nil {
                gameImageView.removeConstraint(oldValue!)
            }
            if aspectConstraint != nil {
                aspectConstraint?.priority = 999
                gameImageView.addConstraint(aspectConstraint!)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        aspectConstraint = nil
    }
    
    func setPostedImage(image : UIImage) {
        
        let aspect = image.size.width / image.size.height
        
        aspectConstraint = NSLayoutConstraint(item: gameImageView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: gameImageView, attribute: NSLayoutAttribute.Height, multiplier: aspect, constant: 0.0)
        
        gameImageView.image = image
    }
    
}