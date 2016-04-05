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
    
    var selectedPlatform: Platform!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        browseTableView.delegate = self
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Platform.allValues.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BrowseCell")
        cell?.textLabel?.text = Platform.allValues[indexPath.row].rawValue
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedPlatform = Platform.allValues[indexPath.row]
        performSegueWithIdentifier("pushLetterSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "pushLetterSegue" {
            let controller = segue.destinationViewController as! BrowseLetterViewController
            controller.selectedPlatform = selectedPlatform
        }
    }
    
}

