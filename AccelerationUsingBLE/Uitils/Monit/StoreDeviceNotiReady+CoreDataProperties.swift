//
//  StoreDeviceNotiReady+CoreDataProperties.swift
//  Monit
//
//  Created by john.lee on 2019. 1. 2..
//  Copyright © 2019년 맥. All rights reserved.
//
//

import Foundation
import CoreData


extension StoreDeviceNotiReady {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoreDeviceNotiReady> {
        return NSFetchRequest<StoreDeviceNotiReady>(entityName: "StoreDeviceNotiReady")
    }

    @NSManaged public var id: Int32
    @NSManaged public var noti: String?
    @NSManaged public var did: String?
    @NSManaged public var type: String?
    @NSManaged public var time: String?

}
