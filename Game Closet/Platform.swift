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
    @NSManaged var name: String
    @NSManaged var id: String
    @NSManaged var games: [Game]
    
    //TODO: Finish implementation
    
}