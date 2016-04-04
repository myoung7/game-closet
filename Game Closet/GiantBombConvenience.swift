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
        
        taskForGETMethod(method: method, parameters: [:]) { (result, error) in
            guard error == nil else {
                completionHandler(result: nil, error: error)
                return
            }
            
            guard let data = result else {
                completionHandler(result: nil, error: nil) //TODO: Replace with actual NSError
                return
            }
            
            completionHandler(result: data, error: nil)
            
        }
        
    }
    
}