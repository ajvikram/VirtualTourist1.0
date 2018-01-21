//
//  FlickrClient.swift
//  VirtualTourist1.0
//
//  Created by Ajay Singh on 1/15/18.
//  Copyright © 2018 ATT. All rights reserved.
//

import Foundation

class FlickrClient {
    
    static let sharedInstance = FlickrClient()
    var totalPages: Int16?
    lazy var session = {
        return URLSession.shared
    }()
    
    func setHeaders(request: NSMutableURLRequest, setJson:Bool) -> NSMutableURLRequest
    {
        if (setJson)
        {
            request.addValue(HeaderValues.JSON, forHTTPHeaderField: HeaderKeys.Accept)
            request.addValue(HeaderValues.JSON, forHTTPHeaderField: HeaderKeys.ContentType)
        }
        return request
    }
    
    func getUrlFromMethod(resourceName: String) -> String
    {
        return BaseURL.FLICKR_URL + "/?method=" + resourceName
    }
    
    func makeTaskCall (request:URLRequest , completionHandlerForTaskCall : @escaping (_ result : AnyObject? , _ error: NSError?) -> Void)
    {
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            if error == nil
            {
                //Success
                Converter.parseJSONToAnyObject(response: data! as NSData, completionHandler: completionHandlerForTaskCall)
            }
            else
            {
                //Failure
                completionHandlerForTaskCall(nil, error! as NSError)
            }
        }
        task.resume()
    }
    
    func downloadPhotosForPin (_ pin: Pin, completionHandlerForPhotosForPin: @escaping (_ success: Bool, [[String: AnyObject]]?, _ errorMessage : String?)->Void)
    {
        let methodUrl = getUrlFromMethod(resourceName: Methods.Search)
        let randomPageNumber = pin.pagesOfPhotos
        let parameters : [String: AnyObject] = [
            URLKeys.APIKey : API.apiKey as AnyObject,
            URLKeys.Format : API.JSONFormat as AnyObject,
            URLKeys.NoJSONCallback : 1 as AnyObject,
            URLKeys.Extras : URLValues.URLMediumPhoto as AnyObject,
            URLKeys.Latitude : pin.latitude as AnyObject,
            URLKeys.Longitude : pin.longitude as AnyObject,
            URLKeys.Page : Converter.randomWithinPageLimit(randomPageNumber: Int(randomPageNumber)) as AnyObject,
            URLKeys.PerPage : 20 as AnyObject
            
        ]
        let urlString = methodUrl + "&" + Converter.escapedParameters(parameters)
        var request = URLRequest(url: URL(string: urlString)!)
        
        request = setHeaders(request: request as! NSMutableURLRequest, setJson: false) as URLRequest
        makeTaskCall(request: request as URLRequest) { (result, error) in
            if error == nil
            {
                    let parsedResponse =  self.parsePhotosHelper(result as AnyObject)
                   
                    completionHandlerForPhotosForPin(true, parsedResponse,nil)
            }
            else
            {
                //Failure
                completionHandlerForPhotosForPin(false, nil, Errors.connectionError)
            }
        }
    }
    
    func getImage(_ photoURL: String?, completionHandler:@escaping (Data?, String?) -> Void) -> URLSessionTask? {
        
        if let photoURL = photoURL {
            let url = URL(string: photoURL)!
            
            let request = URLRequest(url: url)
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: {data, response, downloadError in
                
                if let error = downloadError {
                    completionHandler(nil, error.localizedDescription)
                } else {
                    completionHandler(data!, nil)
                }
            })
            task.resume()
            return task
        } else {
            completionHandler(nil, "Path was nil")
            return nil
        }
        
    }
    
    func parsePhotosHelper(_ data: AnyObject!) -> [[String: AnyObject]]? {
        //check downloaded photos?
        guard let photos = data.value(forKey: "photos") as? [String: AnyObject] else {
            return nil
        }
        guard let photo = photos["photo"] as? [[String: AnyObject]] else {
            return nil
        }
        guard let numberOfPhotos = photos["pages"] as? Int else {
            return nil
        }
        totalPages = Int16(numberOfPhotos)
        return photo
    }
        
    
}
