//
//  DataController.swift
//  VirtualTourist
//
//  Created by Deer on 16/11/1441 AH.
//  Copyright © 1441 Rahaf Naif. All rights reserved.
//

import Foundation

class API {
    
    static var api_key = "6881688955b1b8441665e9d3fdebc225"
    
    class func photoRequest(lat:Double,long:Double,completionHandler: @escaping (photos?,Error?) -> Void) {
        
        var request = URLRequest(url: URL(string: "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(api_key)&tags=&accuracy=11&lat=\(lat)&lon=\(long)&per_page=12&format=json&nojsoncallback=1" )!)
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request ) { data, response, error in
          guard let data = data else {
              completionHandler(nil, error)
              return
          }
            
          
          let decoder = JSONDecoder()
          let photo = try! decoder.decode(photos.self, from: data)
          completionHandler(photo , error)
          
            print(String(data: data, encoding: .utf8)!)
        }
        task.resume()
        
    }
    
}
