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
    
    var selectedPlatformTuple: PlatformTuple!
    var selectedPlatform: Platform!
    
    var gameList: [Game]!
    
    @IBOutlet weak var greyLoadingView: UIView!
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBAction func searchButtonPressed(sender: UIButton) {
        greyLoadingView.hidden = false
        searchForGameList()
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
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let platform = PlatformsHandler.sharedInstance.getPlatformTupleWithIdentifier(platformNamesArray[0])
        selectedPlatformTuple = platform
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    //MARK: - Picker View Delegate Methods
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let platformString = platformNamesArray[row]
        return NSAttributedString(string: platformString, attributes: [NSForegroundColorAttributeName:UIColor(red: (168.0 / 255.0), green: (127.0 / 255.0), blue: (67.0 / 255.0), alpha: 1)])
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return platformNamesArray.count
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let platform = PlatformsHandler.sharedInstance.getPlatformTupleWithIdentifier(platformNamesArray[row])
        selectedPlatformTuple = platform
        print(selectedPlatformTuple.name)
    }
    
    //MARK: - Search for the list of games with specified filters.
    
    func searchForGameList() {
        
        let filters = [
            GiantBombClient.ParameterKeys.Filter: "\(GiantBombClient.ParameterKeys.Platforms):\(selectedPlatformTuple.id),\(GiantBombClient.ParameterKeys.Name):\(titleTextField.text!)",
            GiantBombClient.ParameterKeys.FieldList: "\(GiantBombClient.ParameterKeys.Name),\(GiantBombClient.ParameterKeys.Image),\(GiantBombClient.ParameterKeys.Deck),\(GiantBombClient.ParameterKeys.ID),\(GiantBombClient.ParameterKeys.SiteURL)"
        ]
        
        let platformDictionary = [
            Platform.Keys.Name: selectedPlatformTuple.name,
            Platform.Keys.ID: selectedPlatformTuple.id
        ]
        
        let platform = Platform(dictionary: platformDictionary, context: self.temporaryObjectContext)
        selectedPlatform = platform
        
        GiantBombClient.sharedInstance.getGameListWithFilters(filters, platform: platform,context: self.temporaryObjectContext) { (result, errorString) in
            guard errorString == nil else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.displayErrorMessage(errorString!)
                    self.greyLoadingView.hidden = true
                })
                return
            }
            
            guard result.count > 0 else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.displayErrorMessage("No results found.")
                    self.greyLoadingView.hidden = true
                })
                return
            }
            
            self.gameList = result as! [Game]
            
            dispatch_async(dispatch_get_main_queue(), {
                self.greyLoadingView.hidden = true
                self.performSegueWithIdentifier("searchBrowseGameSegue", sender: self)
            })
            
        }
    }
    
    func displayErrorMessage(messageString: String) {
        let alertController = UIAlertController(title: "Search Failed", message: messageString, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(action)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "searchBrowseGameSegue" {
            let controller = segue.destinationViewController as! BrowseGameListViewController
            controller.gameList = gameList
            controller.selectedPlatformTuple = selectedPlatformTuple
            controller.searchSeguePerformed = true
        }
    }
}