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
    
}
