//
//  BrowseViewController.swift
//  Game Closet
//
//  Created by Matthew Young on 4/3/16.
//  Copyright © 2016 Matthew Young. All rights reserved.
//

import UIKit

class BrowsePlatformViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var browseTableView: UITableView!
    
    var platformNamesArray: [String]! {
        return PlatformsHandler.sharedInstance.namesArray
    }
    
    var selectedPlatform: (name: String, id: String)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        browseTableView.delegate = self
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return platformNamesArray != nil ? platformNamesArray.count : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BrowseCell")
        if let platformNamesArray = platformNamesArray {
            cell?.textLabel?.text = platformNamesArray[indexPath.row]
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
    
}

