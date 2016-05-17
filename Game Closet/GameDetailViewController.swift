//
//  GameDetailViewController.swift
//  Game Closet
//
//  Created by Matthew Young on 4/9/16.
//  Copyright © 2016 Matthew Young. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class GameDetailViewController: UIViewController {
    
    var currentGame: Game!
    
    @IBOutlet weak var gameImageView: UIImageView!

    @IBOutlet weak var gameInfoLabel: UILabel!
    @IBOutlet weak var alreadyInCollectionLabel: UILabel!
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var siteURLButton: UIButton!
    
    @IBAction func shareButtonPressed(sender: UIBarButtonItem) {
        
        let shareString = ["Check out this game from my Game Closet: '\(currentGame.name)' on \(currentGame.platform.name) \(currentGame.siteURL)"]
        let excludedActivities = [UIActivityTypePrint, UIActivityTypeAirDrop, UIActivityTypePostToFacebook]
        
        let activityController = UIActivityViewController(activityItems: shareString, applicationActivities: nil)
        activityController.excludedActivityTypes = excludedActivities
        
        presentViewController(activityController, animated: true, completion: nil)
        
    }
    
    @IBAction func siteURLButtonPressed() {
    }
    
    lazy var gameIsInCollection: Bool = {
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            return false
        }
        if self.fetchedResultsController.fetchedObjects?.count > 0 {
            return true
        } else {
            return false
        }
    }()
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Game")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "imageURL", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "platform.name == %@ AND name == %@", self.currentGame.platform.name, self.currentGame.name)
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }()
    
    @IBAction func addButtonPressed(sender: UIBarButtonItem) {
        addButton.enabled = false
        
        let platformDictionary = [
            Platform.Keys.Name: currentGame.platform.name,
            Platform.Keys.ID: currentGame.platform.id
        ]
        
        let platform = Platform(dictionary: platformDictionary, context: sharedContext)
        
        let dictionary: [String: AnyObject?] = [
            Game.Keys.Name: currentGame.name,
            Game.Keys.ID: currentGame.id,
            Game.Keys.ImageURL: currentGame.imageURL,
            Game.Keys.Info: currentGame.info,
            Game.Keys.SiteURL: currentGame.siteURL
        ]
        
        let game = Game(dictionary: dictionary, context: sharedContext)
        game.platform = platform
        CoreDataStackManager.sharedInstance().saveContext()
        print("Added game to collection!")
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadGameDetails()
        if gameIsInCollection {
            addButton.enabled = false
            alreadyInCollectionLabel.hidden = false
        }
    }
    
    func loadGameDetails() {
        
        navigationItem.title = currentGame.name
        
        gameInfoLabel.text = currentGame.info
        siteURLButton.setTitle(currentGame.siteURL, forState: .Normal)
        
        guard currentGame.gameImage == nil else {
            gameImageView.image = currentGame.gameImage
            return
        }
        
        guard let imageURL = currentGame.imageURL else {
            print("No image URL found for \(currentGame.name)")
            return
        }
        
        GiantBombClient.sharedInstance.downloadImageWithURL(imageURL) { (resultImage, errorString) in
            guard errorString == nil else {
                print(errorString!)
                return
            }
            
            guard let resultImage = resultImage else {
                print("ERROR: Could not load image.")
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.gameImageView.image = resultImage
            })
        }
    }
    
}
