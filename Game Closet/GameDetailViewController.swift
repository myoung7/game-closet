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
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    @IBAction func shareButtonPressed(sender: UIBarButtonItem) {
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
        }
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
