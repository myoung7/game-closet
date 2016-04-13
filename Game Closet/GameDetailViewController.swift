//
//  GameDetailViewController.swift
//  Game Closet
//
//  Created by Matthew Young on 4/9/16.
//  Copyright © 2016 Matthew Young. All rights reserved.
//

import Foundation
import UIKit

class GameDetailViewController: UIViewController {
    
    var currentGame: Game!
    
    @IBOutlet weak var gameImageView: UIImageView!

    @IBOutlet weak var gameInfoLabel: UILabel!
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    @IBAction func shareButtonPressed(sender: UIBarButtonItem) {
    }
    
    @IBAction func addButtonPressed(sender: UIBarButtonItem) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadGameDetails()
    }
    
    func loadGameDetails() {
        
        navigationItem.title = currentGame.name
        
        gameInfoLabel.text = currentGame.info
        
        GiantBombClient.sharedInstance.downloadImageWithURL(currentGame.imageURL) { (resultImage, errorString) in
            guard errorString == nil else {
                print(errorString!)
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.gameImageView.image = resultImage!
            })
        }
    }
}
