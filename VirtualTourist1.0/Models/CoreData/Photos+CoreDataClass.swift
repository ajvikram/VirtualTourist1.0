//
//  Photos+CoreDataClass.swift
//  VirtualTourist1.0
//
//  Created by Ajay Singh on 1/19/18.
//  Copyright © 2018 ATT. All rights reserved.
//
//

import Foundation
import CoreData


public class Photos: NSManagedObject {
    convenience init( id : String, image : NSData, imageUrl : String, context: NSManagedObjectContext) {
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entity(forEntityName: "Photos", in: context) {
            self.init(entity: ent, insertInto: context)
            self.id = id
            self.image = image
            self.imageUrl = imageUrl
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}
