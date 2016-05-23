//
//  BrowseGameListViewController.swift
//  Game Closet
//
//  Created by Matthew Young on 4/5/16.
//  Copyright © 2016 Matthew Young. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class BrowseGameListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    var selectedPlatformTuple: PlatformTuple!
    var selectedPlatform: Platform!
    var filteredString: String!
    var gameList: [Game]!
    var selectedGameList = [Game]()
    var selectedGame: Game!
    var selectedLetter: String!
    
    var searchSeguePerformed = false //True if view controller was loaded due to a segue from the SearchViewController.
    var multipleSelectEnabled = false
    
    @IBOutlet weak var greyLoadingView: UIView!
    
    @IBOutlet weak var gameListTableView: UITableView!
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    @IBAction func editButtonPressed(sender: UIBarButtonItem) {
        if gameListTableView.editing {
            if gameListTableView.indexPathsForSelectedRows == nil {
                gameListTableView.editing = false
                setButtonToEdit()
            } else {
                displayDeleteAlertMessage()
            }
        } else {
            gameListTableView.editing = true
            setButtonToCancel()
        }
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var temporaryObjectContext: NSManagedObjectContext = {
        let coordinator = CoreDataStackManager.sharedInstance().persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Game")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "imageURL", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "platform.name == %@ AND name beginswith %@", self.selectedPlatform.name, self.selectedLetter)
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }()
    
    // MARK: - Life Cycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if searchSeguePerformed {
            editButton.enabled = false
            editButton.title = ""
        }
        
        if !searchSeguePerformed {
            
            print(selectedPlatform.name)
            
            try! fetchedResultsController.performFetch()
            
            if let objects = fetchedResultsController.fetchedObjects as? [Game] {
                print(objects)
                gameList = objects
                print("Got game objects!")
                gameListTableView.reloadData()
            }
            
            fetchedResultsController.delegate = self
        }
        
        gameListTableView.reloadData()
    }
    
    func displayDeleteAlertMessage() {
        let alertController = UIAlertController(title: "Delete Selected Games", message: "Are you sure you want to remove the selected games from your collection?", preferredStyle: .Alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .Destructive) { _ in
            self.deleteSelectedGames()
            self.setButtonToEdit()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { _ in
            self.gameListTableView.editing = false
            self.setButtonToEdit()
        }
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Remove selected games from personal collection.
    
    func deleteSelectedGames() {
        if let indexPaths = gameListTableView.indexPathsForSelectedRows {
            for index in indexPaths {
                let game = fetchedResultsController.objectAtIndexPath(index) as! Game
                sharedContext.deleteObject(game)
            }
        }
        print("Deleted objects!")
        gameListTableView.editing = false
    }
    
    // MARK: - Table View Delegate/Data Source Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !searchSeguePerformed {
            let sectionInfo = self.fetchedResultsController.sections![section]
            return sectionInfo.numberOfObjects
        } else {
            return gameList != nil ? gameList.count : 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("GameListCell") as! GameListCell
        cell.selectionStyle = .Gray
        
        cell.activityIndicator.startAnimating()
        
        configureCell(cell: cell, indexPath: indexPath)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if gameListTableView.indexPathsForSelectedRows == nil {
            setButtonToCancel()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if !gameListTableView.editing {
            gameWasSelectedAtIndexPath(indexPath)
        } else {
            setButtonToDelete()
        }
    }
    
    
    // MARK - NSFetchedResultsController Delegate Methods
    
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.gameListTableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            gameListTableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        case .Delete:
            gameListTableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Move:
            gameListTableView.moveRowAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.gameListTableView.endUpdates()
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    func gameWasSelectedAtIndexPath(indexPath: NSIndexPath) {
        if multipleSelectEnabled {
            selectedGameList.append(gameList[indexPath.row])
        } else {
            selectedGame = gameList[indexPath.row]
            performSegueWithIdentifier("gameSelectedSegue", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "gameSelectedSegue" {
            let controller = segue.destinationViewController as! GameDetailViewController
            controller.currentGame = selectedGame
        }
    }
    
    // MARK: - Configure Table View Cells
    
    func configureCell(cell cell: GameListCell, indexPath: NSIndexPath) {
        
        cell.gameImageView.image = nil
        
        let game = gameList[indexPath.row]
        
        cell.gameNameTitleLabel.text = game.name
        cell.gameDescriptionTitleLabel.text = game.info
        
        guard game.gameImage == nil else {
            cell.setPostedImage(game.gameImage!)
            cell.activityIndicator.stopAnimating()
            return
        }
        
        guard let imageURL = game.imageURL else {
            cell.gameImageView.image = nil
            cell.activityIndicator.stopAnimating()
            return
        }
        
        GiantBombClient.sharedInstance.downloadImageWithURL(imageURL) { (resultImage, errorString) in
            guard errorString == nil else {
                print(errorString)
                dispatch_async(dispatch_get_main_queue(), {
                    cell.activityIndicator.stopAnimating()
                })
                return
            }
            
            guard resultImage != nil else {
                print("ERROR: Image could not be loaded.")
                dispatch_async(dispatch_get_main_queue(), {
                    cell.activityIndicator.stopAnimating()
                })
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                ImageHandler.sharedInstance.storeImageWithIdentifier(game.id, image: resultImage!)
                cell.setPostedImage(game.gameImage!)
                cell.activityIndicator.stopAnimating()
            })
        }
    }
    
    func setButtonToEdit() {
        editButton.title = "Edit"
        editButton.tintColor = nil
    }
    
    func setButtonToCancel() {
        editButton.title = "Cancel"
        editButton.tintColor = nil
    }
    
    func setButtonToDelete() {
        editButton.title = "Delete"
        editButton.tintColor = UIColor.redColor()
    }
    
}
