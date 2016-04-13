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

class BrowseGameListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var selectedPlatformTuple: PlatformTuple!
    var filteredString: String!
    var gameList: [Game]!
    var selectedGameList = [Game]()
    var selectedGame: Game!
    
    var searchSeguePerformed = false //True if view controller was loaded due to a segue from the SearchViewController.
    var multipleSelectEnabled = false
    
    @IBOutlet weak var gameListTableView: UITableView!
    
//    var sharedContext: NSManagedObjectContext {
//        return CoreDataStackManager.sharedInstance().managedObjectContext
//    }
    
//    lazy var temporaryObjectContext: NSManagedObjectContext = {
//        let coordinator = CoreDataStackManager.sharedInstance().persistentStoreCoordinator
//        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
//        managedObjectContext.persistentStoreCoordinator = coordinator
//        return managedObjectContext
//    }()
    
//    lazy var fetchedResultsController: NSFetchedResultsController = {
//        let fetchRequest = NSFetchRequest(entityName: "Game")
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "imageURL", ascending: true)]
//        fetchRequest.predicate = NSPredicate(format: "platform == %@", self.selectedPlatformTuple.name)
//        
//        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.temporaryObjectContext, sectionNameKeyPath: nil, cacheName: nil)
//        
//        return fetchedResultsController
//    }()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        getGames()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameListTableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameList != nil ? gameList.count : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("GameListCell") as! GameListCell
        
        let game = gameList[indexPath.row]
        
        cell.gameNameTitleLabel.text = game.name
        cell.gameDescriptionTitleLabel.text = game.info
        
        GiantBombClient.sharedInstance.downloadImageWithURL(game.imageURL) { (resultImage, errorString) in
            guard errorString == nil else {
                print(errorString)
                return
            }
            
            guard resultImage != nil else {
                print("ERROR: Image could not be loaded.")
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                cell.imageView?.image = resultImage!
            })
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        gameWasSelectedAtIndexPath(indexPath)
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
    
//    func getGames() {
//        let parameters = [
//            GiantBombClient.ParameterKeys.Filter:
//                "\(GiantBombClient.ParameterKeys.Name):\(filteredString),\(GiantBombClient.ParameterKeys.Platforms):\(selectedPlatform.id)"
//        ]
//        
//        GiantBombClient.sharedInstance.getGameListWithFilters(parameters, context: temporaryObjectContext) { (result, errorString) in
//            guard errorString == nil else {
//                print(errorString!)
//                return
//            }
//            
//            
//        }
//    }
    
    //TODO: Finish setting up
    
}
