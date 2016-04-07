//
//  SearchViewController.swift
//  Game Closet
//
//  Created by Matthew Young on 4/3/16.
//  Copyright © 2016 Matthew Young. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class SearchViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var selectedPlatformTuple: PlatformTuple! = PlatformsHandler.sharedInstance.getPlatformTupleAtIndex(0)
    var selectedPlatform: Platform!
    
    var gameList: [Game]!
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBAction func searchButtonPressed(sender: UIButton) {
        
        let filters = [
            GiantBombClient.ParameterKeys.Filter: "\(GiantBombClient.ParameterKeys.Platforms):\(selectedPlatformTuple.id),\(GiantBombClient.ParameterKeys.Name):\(titleTextField.text!)",
            GiantBombClient.ParameterKeys.FieldList: "\(GiantBombClient.ParameterKeys.Name),\(GiantBombClient.ParameterKeys.Image),\(GiantBombClient.ParameterKeys.Deck),\(GiantBombClient.ParameterKeys.ID)"
        ]
        
        let platformDictionary = [
            GiantBombClient.ParameterKeys.Name: selectedPlatformTuple.name,
            GiantBombClient.ParameterKeys.ID: selectedPlatformTuple.id
        ]
        
        let platform = Platform(dictionary: platformDictionary, context: self.temporaryObjectContext)
        selectedPlatform = platform
        
        GiantBombClient.sharedInstance.getGameListWithFilters(filters, platform: platform,context: self.temporaryObjectContext) { (result, errorString) in
            guard errorString == nil else {
                print(errorString)
                return
            }
            
            self.gameList = result as! [Game]
            
            dispatch_async(dispatch_get_main_queue(), {
                self.performSegueWithIdentifier("searchBrowseGameSegue", sender: self)
            })
            
        }
        
    }
    
    @IBAction func tapGestureRecognized(sender: UITapGestureRecognizer) {
        view.endEditing(false)
    }
    
    lazy var temporaryObjectContext: NSManagedObjectContext = {
        let coordinator = CoreDataStackManager.sharedInstance().persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    var platformNamesArray: [String]! {
        return PlatformsHandler.sharedInstance.namesArray
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return platformNamesArray[row]
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return platformNamesArray.count
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let platform = PlatformsHandler.sharedInstance.getPlatformTupleAtIndex(row)
        selectedPlatformTuple = platform
        print(selectedPlatformTuple.name)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "searchBrowseGameSegue" {
            let controller = segue.destinationViewController as! BrowseGameListViewController
            controller.gameList = gameList
            controller.selectedPlatformTuple = selectedPlatformTuple
        }
    }
}