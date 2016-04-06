//
//  BrowseGameListViewController.swift
//  Game Closet
//
//  Created by Matthew Young on 4/5/16.
//  Copyright © 2016 Matthew Young. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class BrowseGameListViewController: UIViewController {
    
    var selectedPlatform: (name: String, id: String)!
    var filteredString: String!
    
    lazy var temporaryObjectContext: NSManagedObjectContext = {
        let coordinator = CoreDataStackManager.sharedInstance().persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Game")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "imageURL", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "platform == %@", self.selectedPlatform.name)
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.temporaryObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        getGames()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func getGames() {
        let parameters = [
            GiantBombClient.ParameterKeys.Filter:
                "\(GiantBombClient.ParameterKeys.Name):\(filteredString),\(GiantBombClient.ParameterKeys.Platforms):\(selectedPlatform.id)"
        ]
        
        GiantBombClient.sharedInstance.getGameListWithFilters(parameters, context: temporaryObjectContext) { (result, errorString) in
            guard errorString == nil else {
                print(errorString!)
                return
            }
            
            
        }
    }
    
    //TODO: Finish setting up
    
}
