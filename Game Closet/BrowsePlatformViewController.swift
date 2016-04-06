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
    
    var platformNamesArray: [String]! {
        return PlatformsHandler.sharedInstance.namesArray
    }
    
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
    
    var selectedPlatform: (name: String, id: String)!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        platformsNamesOwnedArray = getListOfPlatformNamesOwned()
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
        selectedPlatform = PlatformsHandler.sharedInstance.getPlatformTupleAtIndex(indexPath.row)!
        performSegueWithIdentifier("pushLetterSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "pushLetterSegue" {
            let controller = segue.destinationViewController as! BrowseLetterViewController
            controller.selectedPlatform = selectedPlatform
        }
    }
    
    func getListOfPlatformNamesOwned() -> [String]{
        
        var newPlatformNamesArray: [String] = []
        
        try! fetchedResultsController.performFetch()
        let platforms = fetchedResultsController.fetchedObjects as! [Platform]
        for item in platforms {
            for device in platformNamesArray {
                if item.name == device {
                    var alreadyInArray = false
                    
                    for object in platformNamesArray {
                        if item.name == object {
                            alreadyInArray = true
                            break
                        }
                    }
                    if alreadyInArray == false {
                        newPlatformNamesArray.append(item.name)
                    }
                }
            }
        }
        print(newPlatformNamesArray)
        return newPlatformNamesArray
    }
    
}

