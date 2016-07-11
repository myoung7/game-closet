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
    
    @IBOutlet weak var gameImageView: UIImageView!
    @IBOutlet weak var backgroundGameImageView: UIImageView!

    @IBOutlet weak var gameInfoLabel: UILabel!
    @IBOutlet weak var alreadyInCollectionLabel: UILabel!
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var siteURLButton: UIButton!
    
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
        changeAlreadyInCollectionLabel()
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadGameDetails()
        setImageViewBackground()
        if gameIsInCollection {
            addButton.enabled = false
            alreadyInCollectionLabel.hidden = false
        } else {
            alreadyInCollectionLabel.hidden = true
        }
    }
    
    // MARK: - Loads the details of the selected game.
    
    func changeAlreadyInCollectionLabel() {
        UIView.animateWithDuration(1) { 
            self.alreadyInCollectionLabel.hidden = !self.alreadyInCollectionLabel.hidden
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
    
}
