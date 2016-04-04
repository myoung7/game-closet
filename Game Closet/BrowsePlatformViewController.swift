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
    
    var platformsArray: [String]? {
        if let path = NSBundle.mainBundle().pathForResource("Game Closet Data", ofType: "plist") {
            if let data = NSDictionary(contentsOfFile: path) {
                if let platforms = data["platforms"] as? [String] {
                    return platforms
                }
            }
        }
       return nil
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        browseTableView.delegate = self
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return platformsArray != nil ? platformsArray!.count : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BrowseCell")
        cell?.textLabel?.text = platformsArray![indexPath.row]
        
        return cell!
    }
    
}

