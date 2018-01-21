//
//  Photos+CoreDataProperties.swift
//  VirtualTourist1.0
//
//  Created by Ajay Singh on 1/18/18.
//  Copyright © 2018 ATT. All rights reserved.
//
//

import Foundation
import CoreData


extension Photos {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photos> {
        return NSFetchRequest<Photos>(entityName: "Photos")
    }

    @NSManaged public var filePath: String?
    @NSManaged public var id: String?
    @NSManaged public var image: NSData?
    @NSManaged public var imageUrl: String?
    @NSManaged public var vtpin: Pin?

}
