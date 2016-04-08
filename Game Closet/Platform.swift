//
//  Platform.swift
//  Game Closet
//
//  Created by Matthew Young on 4/5/16.
//  Copyright © 2016 Matthew Young. All rights reserved.
//

import Foundation
import CoreData

class Platform: NSManagedObject {
    
    struct Keys {
        static let Name = "name"
        static let ID = "id"
    }
    
    @NSManaged var name: String
    @NSManaged var id: String
    @NSManaged var games: [Game]
    
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Platform", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        name = dictionary[Keys.Name] as! String
        id = dictionary[Keys.ID] as! String
    }
    
}