//
//  Pin+CoreDataProperties.swift
//  VirtualTourist1.0
//
//  Created by Ajay Singh on 1/19/18.
//  Copyright © 2018 ATT. All rights reserved.
//
//

import Foundation
import CoreData


extension Pin {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pin> {
        return NSFetchRequest<Pin>(entityName: "Pin")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var pagesOfPhotos: Int16
    @NSManaged public var vtphotos: NSSet?

}

// MARK: Generated accessors for vtphotos
extension Pin {

    @objc(addVtphotosObject:)
    @NSManaged public func addToVtphotos(_ value: Photos)

    @objc(removeVtphotosObject:)
    @NSManaged public func removeFromVtphotos(_ value: Photos)

    @objc(addVtphotos:)
    @NSManaged public func addToVtphotos(_ values: NSSet)

    @objc(removeVtphotos:)
    @NSManaged public func removeFromVtphotos(_ values: NSSet)

}
