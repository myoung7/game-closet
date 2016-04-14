//
//  BrowseViewController.swift
//  Game Closet
//
//  Created by Matthew Young on 4/3/16.
//  Copyright © 2016 Matthew Young. All rights reserved.
//

import UIKit
import CoreData

class BrowsePlatformViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var browseTableView: UITableView!
    
    var platformsNamesOwnedArray: [String]?
    var platformsOwnedArray: [Platform]?
    
    var selectedPlatformTuple: PlatformTuple!
    
//    var platformNamesArray: [String]! {
//        return PlatformsHandler.sharedInstance.namesArray
//    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Platform")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
//        fetchRequest.predicate = NSPredicate(format: "platform == %@", self.selectedPlatform.name)
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        platformsNamesOwnedArray = getListOfPlatformNamesOwned()
        browseTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        browseTableView.delegate = self
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return platformsNamesOwnedArray != nil ? platformsNamesOwnedArray!.count : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BrowseCell")
        if let platformsNamesOwnedArray = platformsNamesOwnedArray {
            cell?.textLabel?.text = platformsNamesOwnedArray[indexPath.row]
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let platformName = platformsNamesOwnedArray![indexPath.row]
        selectedPlatformTuple = PlatformsHandler.sharedInstance.getPlatformTupleWithIdentifier(platformName)
        performSegueWithIdentifier("pushLetterSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "pushLetterSegue" {
            let controller = segue.destinationViewController as! BrowseLetterViewController
            controller.selectedPlatform = selectedPlatformTuple
        }
    }
    
    func getListOfPlatformNamesOwned() -> [String]?{
        
        var newPlatformNamesSet: Set<String> = []
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("ERROR: Could not fetch data for Platforms in BrowsePlatformViewController.")
            return nil
        }
        let platforms = fetchedResultsController.fetchedObjects as! [Platform]
        for item in platforms {
            newPlatformNamesSet.insert(item.name)
        }
        print(newPlatformNamesSet)
        return Array(newPlatformNamesSet)
    }
    
}

