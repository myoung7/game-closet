//
//  PlatformsHandler.swift
//  Game Closet
//
//  Created by Matthew Young on 4/5/16.
//  Copyright © 2016 Matthew Young. All rights reserved.
//

import Foundation

class PlatformsHandler {
    
    static let sharedInstance = PlatformsHandler()
    
    var namesArray: [String]? {
        
        var arrayOfPlatforms: [String] = []
        
        if let path = NSBundle.mainBundle().pathForResource("platforms", ofType: "plist") {
            if let data = NSDictionary(contentsOfFile: path) {
                if let platforms = data["platforms"] as? [[String: AnyObject]] {
                    for dictionary in platforms {
                        let name = dictionary["name"] as! String
                        arrayOfPlatforms.append(name)
                    }
                    return arrayOfPlatforms
                }
            }
        }
        print("ERROR: Could not load Platforms.plist file.")
        return nil
    }
    
    var idsArray: [String]? {
        var arrayOfPlatforms: [String] = []
        
        if let path = NSBundle.mainBundle().pathForResource("platforms", ofType: "plist") {
            if let data = NSDictionary(contentsOfFile: path) {
                if let platforms = data["platforms"] as? [[String: AnyObject]] {
                    for dictionary in platforms {
                        let id = dictionary["id"] as! Int
                        arrayOfPlatforms.append(String(id))
                    }
                    return arrayOfPlatforms
                }
            }
        }
        print("ERROR: Could not load Platforms.plist file.")
        return nil
    }
    
    func getPlatformTupleAtIndex(index: Int) -> (name: String, id: String)? {
        if namesArray?[index] != nil && idsArray?[index] != nil {
            return (namesArray![index], idsArray![index])
        } else {
            return nil
        }
    }
}
