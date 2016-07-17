//
//  GameDetailViewController.swift
//  Game Closet
//
//  Created by Matthew Young on 4/9/16.
//  Copyright © 2016 Matthew Young. All rights reserved.
//

import Foundation
import CoreData
import CoreImage
import UIKit
import SafariServices

class GameDetailViewController: UIViewController {
    
    var currentGame: Game!
    
    @IBOutlet weak var defaultView: UIView!
    
    @IBOutlet weak var gameImageView: UIImageView!
    @IBOutlet weak var backgroundGameImageView: UIImageView!

    @IBOutlet weak var gameInfoLabel: UILabel!
    @IBOutlet weak var alreadyInCollectionLabel: UILabel!
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var removeButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var siteURLButton: UIButton!
    
    let gameDidDeleteFromCollectionNotification = "GameDidDeleteFromCollectionNotification"
    let gameDidAddToCollectionNotification = "GameDidAddToCollectionNotification"
    
    @IBAction func giantBombURLButton() {
        UIApplication.sharedApplication().openURL(NSURL(string: GiantBombClient.Constants.GiantBombURL)!)
    }
    
    @IBAction func shareButtonPressed(sender: UIBarButtonItem) {
        
        let shareString = ["Check out this game from my Game Closet: '\(currentGame.name)' on \(currentGame.platform.name) \(currentGame.siteURL)"]
        let excludedActivities = [UIActivityTypePrint, UIActivityTypeAirDrop, UIActivityTypePostToFacebook]
        
        let activityController = UIActivityViewController(activityItems: shareString, applicationActivities: nil)
        activityController.excludedActivityTypes = excludedActivities
        
        presentViewController(activityController, animated: true, completion: nil)
    }
    
    @IBAction func siteURLButtonPressed() {
        let webViewController = SFSafariViewController(URL: NSURL(string: currentGame.siteURL)!)
        presentViewController(webViewController, animated: true, completion: nil)
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
        addGameToCollection()
    }
    
    @IBAction func removeButtonPressed(sender: UIBarButtonItem) {
        displayRemoveConfirmationPrompt()
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if currentGame != nil {
            defaultView.hidden = true
            loadGameDetails()
            setImageViewBackground()
            
            shareButton.enabled = true
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(gameObjectDeletedFromCollection), name: gameDidDeleteFromCollectionNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(gameObjectAddedToCollection), name: gameDidAddToCollectionNotification, object: nil)
            
            if gameIsInCollection {
                addButton.enabled = false
                removeButton.enabled = true
                alreadyInCollectionLabel.hidden = false
            } else {
                addButton.enabled = true
                removeButton.enabled = false
                alreadyInCollectionLabel.hidden = true
            }
        } else {
            loadDefaultView()
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: gameDidDeleteFromCollectionNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: gameDidAddToCollectionNotification, object: nil)
    }
    
    func gameObjectDeletedFromCollection() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func gameObjectAddedToCollection() {
        gameIsInCollection = true
        addButton.enabled = false
        removeButton.enabled = true
        changeAlreadyInCollectionLabel()
    }
    
    // MARK: - Loads the details of the selected game.
    
    func changeAlreadyInCollectionLabel() {
        UIView.animateWithDuration(1) { 
            self.alreadyInCollectionLabel.hidden = !self.alreadyInCollectionLabel.hidden
        }
    }
    
    func loadDefaultView() {
        defaultView.hidden = false
        
        addButton.enabled = false
        removeButton.enabled = false
        shareButton.enabled = false
    }
    
    func loadGameDetails() {
        
        let titleLabel = UILabel(frame: CGRectMake(0, 0, 440, 44))
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .Center
        titleLabel.textColor = UIColor.whiteColor()
        
        
        
        titleLabel.text = currentGame.name
        
        navigationItem.titleView = titleLabel
        
        gameInfoLabel.text = currentGame.info
        
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
    
    // MARK: - Adds game to personal collection.
    
    func addGameToCollection() {
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
        
        let gameAddedNotification = NSNotification(name: self.gameDidAddToCollectionNotification, object: nil)
        NSNotificationCenter.defaultCenter().postNotification(gameAddedNotification)
        
        print("Added game to collection!")
    }
    
    func setImageViewBackground() {
        
        guard let currentGameImage = currentGame.gameImage else {
            print("ERROR: No game image found.")
            return
        }
        
        if let backgroundImage = CIImage(image: currentGameImage) {
            let gaussianBlurFilter = CIFilter(name: "CIGaussianBlur")
            gaussianBlurFilter?.setDefaults()
            gaussianBlurFilter?.setValue(backgroundImage, forKey: kCIInputImageKey)
            gaussianBlurFilter?.setValue(15, forKey: kCIInputRadiusKey)
            backgroundGameImageView.image = UIImage(CIImage: (gaussianBlurFilter?.outputImage)!)
            backgroundGameImageView.contentMode = .ScaleToFill
        }
    }
    
    func displayRemoveConfirmationPrompt() {
        let alertTitleString = "Remove Confirmation"
        let alertMessageString = "Are you sure you want to remove this game from your collection?"
        let alertController = UIAlertController(title: alertTitleString, message: alertMessageString, preferredStyle: .Alert);
        
        let removeActionTitleString = "Remove"
        let removeAction = UIAlertAction(title: removeActionTitleString, style: .Destructive) { _ in
            let gameObjectArray = self.fetchedResultsController.fetchedObjects as! [Game]
            
            guard let gameObject = gameObjectArray.first else {
                print("Error: Could not delete game from collection.")
                return
            }
            
            self.sharedContext.deleteObject(gameObject)
            CoreDataStackManager.sharedInstance().saveContext()
            
            let gameDeletedNotification = NSNotification(name: self.gameDidDeleteFromCollectionNotification, object: nil)
            NSNotificationCenter.defaultCenter().postNotification(gameDeletedNotification)
        }
        
        let cancelActionTitleString = "Cancel"
        let cancelAction = UIAlertAction(title: cancelActionTitleString, style: .Cancel, handler: nil)
        
        alertController.addAction(removeAction)
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
        
    }
    
}
