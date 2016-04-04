//
//  GiantBombConvenience.swift
//  Game Closet
//
//  Created by Matthew Young on 4/4/16.
//  Copyright © 2016 Matthew Young. All rights reserved.
//

import Foundation

extension GiantBombClient {
    
    func getPlatformsList(completionHandler: CompletionHander) {
        let method = Methods.Platforms
        
        let parameters = [
            ParameterKeys.FieldList: ParameterKeys.Name,
            ParameterKeys.Sort: "\(ParameterKeys.Name):asc"
        ]
        
        taskForGETMethod(method: method, parameters: parameters) { (result, error) in
            guard error == nil else {
                completionHandler(result: nil, error: error)
                return
            }
            
            guard let data = result else {
                completionHandler(result: nil, error: nil) //TODO: Replace with actual NSError
                return
            }
            
            let results = data["results"] as! [[String: AnyObject]]
            var platformNamesArray: [String] = []
            
            for item in results {
                let name = item["name"] as! String
                platformNamesArray.append(name)
            }
            
            completionHandler(result: platformNamesArray, error: nil)
            
        }
        
    }
    
}