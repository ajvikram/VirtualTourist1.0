//
//  FlickrConstants.swift
//  VirtualTourist1.0
//
//  Created by Ajay Singh on 1/15/18.
//  Copyright © 2018 ATT. All rights reserved.
//

import Foundation

extension FlickrClient {
    
    struct HeaderKeys
    {
        static let Accept = "Accept"
        static let ContentType = "Content-Type"
        static let ApplicationId = "X-Parse-Application-Id"
        static let RestAPIKey = "X-Parse-REST-API-Key"
    }
    
    struct HeaderValues
    {
        static let JSON = "application/json"
    }
    
    struct BaseURL
    {
    static let FLICKR_URL : String = "https://api.flickr.com/services/rest"
    }
    
    struct Methods {
        static let Search = "flickr.photos.search"
    }
    
    struct Errors
    {
        static let connectionError = "Connection error."
        static let UnexpectedSystemError = "Unexpected system error has occurred."
    }
    
    
    struct API {
        static var apiKey = "ea3bd6e60cf77b02e1ca49e7f0f8db2e"
        static var myPreciouuuuss = "62a4299f78ca5225"
        static var coordinateLat : Double = 40.0
        static var coordinateLong : Double = -120.0
        static var JSONFormat = "json"
    }
    
    struct URLKeys {
        static let APIKey = "api_key"
        static let BoundingBox = "bbox"
        static let Format = "format"
        static let Extras = "extras"
        static let Latitude = "lat"
        static let Longitude = "lon"
        static let Method = "method"
        static let NoJSONCallback = "nojsoncallback"
        static let Page = "page"
        static let PerPage = "per_page"
    }
    
    struct URLValues {
        static let URLMediumPhoto = "url_m"
    }
    
    struct JSONResponseKeys {
        static let Results = "results"
        static let ID = "id"
        static let Status = "stat"
        static let Code = "code"
        static let Message = "message"
        static let Pages = "pages"
        static let Photos = "photos"
        static let Photo = "photo"
    }
    
}
