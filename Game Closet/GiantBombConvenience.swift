//
//  GiantBombConvenience.swift
//  Game Closet
//
//  Created by Matthew Young on 4/4/16.
//  Copyright © 2016 Matthew Young. All rights reserved.
//

import Foundation
import CoreData
import UIKit

extension GiantBombClient {
    
    typealias ResultErrorStringCompletionHandler = (result: AnyObject!, errorString: String?) -> Void
    typealias resultImageErrorStringCompletionHandler = (resultImage: UIImage?, errorString: String?) -> Void
    
    func getPlatformsList(completionHandler: CompletionHandler) {
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
    
    func getGameListWithFilters(filters: [String: AnyObject], platform: Platform, context: NSManagedObjectContext, completionHandler: ResultErrorStringCompletionHandler) {
        let method = Methods.Games
        
        var mutableParameters = filters
        
        mutableParameters[ParameterKeys.Sort] = "\(ParameterKeys.Name):asc"
        
        taskForGETMethod(method: method, parameters: mutableParameters) { (result, error) in
            guard error == nil else {
                completionHandler(result: nil, errorString: error!.localizedDescription)
                return
            }
            
            guard let result = result as? [String: AnyObject] else {
                completionHandler(result: nil, errorString: "ERROR: Data not found.")
                return
            }
            
            let resultDictionary = result[ResponseKeys.Results] as! [[String: AnyObject]]
            var gamesDictionary: [Game] = []
            
            for game in resultDictionary {
                
                let imageDictionary = game[ResponseKeys.Image] as! [String: AnyObject]
                
                let dictionary = [
                    Game.Keys.Name: game[ResponseKeys.Name] as! String,
                    Game.Keys.Info: game[ResponseKeys.Deck] as! String,
                    Game.Keys.ImageURL: "http://static.giantbomb.com\(imageDictionary[ResponseKeys.SmallImageURL] as! String)",
                    Game.Keys.ID: String(game[ResponseKeys.ID] as! Int)
                ]
                
                let game = Game(dictionary: dictionary, context: context)
                
                game.platform = platform
                gamesDictionary.append(game)
            }
            
            completionHandler(result: gamesDictionary, errorString: nil)
            
        }
    }
    
    func downloadImageWithURL(imageURL: String, completionHandler: resultImageErrorStringCompletionHandler) {
        
        let url = NSURL(string: imageURL)!
        
        let request = NSURLRequest(URL: url)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                completionHandler(resultImage: nil, errorString: "Error getting image data: \(error!)")
                return
            }
            
            let image = UIImage(data: data!)
            
            completionHandler(resultImage: image, errorString: nil)
        }
        
        task.resume()
        
    }
    
}