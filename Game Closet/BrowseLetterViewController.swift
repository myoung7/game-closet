//
//  BrowseLetterViewController.swift
//  Game Closet
//
//  Created by Matthew Young on 4/5/16.
//  Copyright © 2016 Matthew Young. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class BrowseLetterViewController: UITableViewController {
    
    var selectedPlatformTuple: (name: String, id: String)!
    
    var selectedFilter: String!
    var selectedLetter: String!
    
    var arrayOfLetters = [String]()
    
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
        fetchRequest.predicate = NSPredicate(format: "platform.name == %@", self.selectedPlatformTuple.name)
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let array = getArrayOfAvailableLetters() {
            arrayOfLetters = array
        }
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "\(selectedPlatformTuple.name)"
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfLetters.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BrowseCell")!
        cell.textLabel?.text = arrayOfLetters[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedFilter = arrayOfLetters[indexPath.row]
        selectedLetter = arrayOfLetters[indexPath.row]
        performSegueWithIdentifier("pushGameViewController", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "pushGameViewController" {
            let controller = segue.destinationViewController as! BrowseGameListViewController
            
            let platform = [
                Platform.Keys.Name: self.selectedPlatformTuple.name,
                Platform.Keys.ID: self.selectedPlatformTuple.id
            ]
            
            controller.selectedPlatform = Platform(dictionary: platform, context: self.temporaryObjectContext)
            
            controller.filteredString = selectedFilter
            controller.selectedLetter = selectedLetter
            controller.searchSeguePerformed = false
        }
    }
    
    func getArrayOfAvailableLetters() -> [String]? {
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            return nil
        }
        
        let gamesArray = fetchedResultsController.fetchedObjects as! [Game]
        var letterArraySet = Set<String>()
        
        for game in gamesArray {
            let index = game.name.characters.startIndex
            let firstLetter = String(game.name[index]).capitalizedString
            letterArraySet.insert(firstLetter)
        }
        
        return Array(letterArraySet)
    }

}