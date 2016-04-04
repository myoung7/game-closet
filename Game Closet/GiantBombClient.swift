//
//  GiantBombClient.swift
//  Game Closet
//
//  Created by Matthew Young on 4/4/16.
//  Copyright © 2016 Matthew Young. All rights reserved.
//

import Foundation

class GiantBombClient {
    
    typealias CompletionHander = (result: AnyObject!, error: NSError?) -> Void
    
    var session: NSURLSession
    
    init() {
        session = NSURLSession.sharedSession()
    }
    
    static let sharedInstance = GiantBombClient()

    func taskForGETMethod(method method: String, parameters: [String: AnyObject], completionHandler: CompletionHander) {
        var mutableParameters = parameters
        
        guard let apiKey = Constants.APIKey else {
            print("ERROR: Could not load API Key.")
            return
        }
        
        mutableParameters[ParameterKeys.APIKey] = apiKey
        mutableParameters[ParameterKeys.Format] = "json"
        
        let urlString = Constants.SecureBaseURL + method + GiantBombClient.escapedParameters(mutableParameters)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        print(urlString)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            guard error == nil else {
                completionHandler(result: nil, error: error)
                return
            }
            
            guard let data = data else {
                completionHandler(result: nil, error: NSError(domain: "taskForGETMethod", code: -145, userInfo: [NSLocalizedDescriptionKey: "Could not retrieve data in taskForGETMethod."]))
                return
            }
            
            GiantBombClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
        }
        
        task.resume()
    }
    
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: CompletionHander) {
        //Copied from FavoriteActors app.
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject?
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        } catch let error as NSError {
            parsingError = error
            parsedResult = nil
        }
        
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }

    
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            // make sure that it is a string value
            let stringValue = "\(value)"
            
            // Escape it
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            // Append it
            
            if let unwrappedEscapedValue = escapedValue {
                urlVars += [key + "=" + "\(unwrappedEscapedValue)"]
            } else {
                print("Warning: trouble excaping string \"\(stringValue)\"")
            }
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
}