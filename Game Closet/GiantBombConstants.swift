//
//  GiantBombConstants.swift
//  Game Closet
//
//  Created by Matthew Young on 4/4/16.
//  Copyright © 2016 Matthew Young. All rights reserved.
//

import Foundation

extension GiantBombClient {
    struct Constants {
        static var APIKey: String? {
            //Loads the API Key located in the "Keys.plist"
            var key: NSDictionary?
            
            if let path = NSBundle.mainBundle().pathForResource("Keys", ofType: "plist") {
                key = NSDictionary(contentsOfFile: path)
            }
            
            if let dictionary = key {
                if let apiKey = dictionary["giantBombAPIKey"] as? String {
                    return apiKey
                }
            }
            
            return nil
        }
        
        static let SecureBaseURL = "https://www.giantbomb.com/api/"
    }
    
    struct Methods {
        static let Platforms = "platforms"
        static let Games = "games"
    }
    
    struct ParameterKeys {
        static let APIKey = "api_key"
        static let Format = "format"
        static let FieldList = "field_list"
        static let Filter = "filter"
        static let Sort = "sort"
        static let Name = "name"
        static let Ascending = "asc"
        static let Descending = "desc"
    }
    
    struct ResponseKeys {
        
    }

}
