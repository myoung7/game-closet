//
//  Game.swift
//  Game Closet
//
//  Created by Matthew Young on 4/5/16.
//  Copyright © 2016 Matthew Young. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Game: NSManagedObject {
    
    struct Keys {
        static let Name = "name"
        static let ID = "id"
        static let Info = "info"
        static let ImageURL = "imageURL"
    }
    
    @NSManaged var name: String
    @NSManaged var id: String
    @NSManaged var info: String?
    @NSManaged var imageURL: String?
    @NSManaged var platform: Platform
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String: AnyObject?], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Game", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        name = dictionary[Keys.Name] as! String
        id = dictionary[Keys.ID] as! String
        info = dictionary[Keys.Info] as? String
        imageURL = dictionary[Keys.ImageURL] as? String
    }
    
    var gameImage: UIImage? {
        
        let imagePath = ImageHandler.sharedInstance.generateImagePathURL(id)
        if let image = UIImage(contentsOfFile: imagePath.path!) {
            return image
        } else {
            return nil
        }
    }
    
    override func prepareForDeletion() {
        print("Deleted game \(name)")
    }
    
}