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
    
    var selectedPlatform: (name: String, id: String)!
    
    var selectedFilter: String!
    var selectedLetter: String!
    
    let alphabetArray: [String] = [
        "0-9","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"
        ]
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "\(selectedPlatform.name)"
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alphabetArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BrowseCell")!
        cell.textLabel?.text = alphabetArray[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedFilter = alphabetArray[indexPath.row]
        selectedLetter = alphabetArray[indexPath.row]
        performSegueWithIdentifier("pushGameViewController", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "pushGameViewController" {
            let controller = segue.destinationViewController as! BrowseGameListViewController
            
            let platform = [
                Platform.Keys.Name: self.selectedPlatform.name,
                Platform.Keys.ID: self.selectedPlatform.id
            ]
            
            controller.selectedPlatform = Platform(dictionary: platform, context: self.sharedContext)
            
            controller.filteredString = selectedFilter
            controller.selectedLetter = selectedLetter
            controller.searchSeguePerformed = false
        }
    }
    
    //TODO: Add didSelect function for tableview to segue to the BrowseGameListViewController

}