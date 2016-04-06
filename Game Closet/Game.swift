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
    
    //TODO: Finish implementation
    
}