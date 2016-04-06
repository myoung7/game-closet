//
//  Game.swift
//  Game Closet
//
//  Created by Matthew Young on 4/5/16.
//  Copyright © 2016 Matthew Young. All rights reserved.
//

import Foundation
import CoreData

class Game: NSManagedObject {
    @NSManaged var name: String
    @NSManaged var id: String
    @NSManaged var info: String
    @NSManaged var platform: Platform
    
    
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Game", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        name = dictionary[GiantBombClient.ResponseKeys.Name] as! String
        id = dictionary[GiantBombClient.ResponseKeys.ID] as! String
        info = dictionary[GiantBombClient.ResponseKeys.Info] as! String
    }
    
}