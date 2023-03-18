//
//  StoreConnectedLamp+CoreDataProperties.swift
//  Monit
//
//  Created by john.lee on 10/01/2020.
//  Copyright © 2020 맥. All rights reserved.
//
//

import Foundation
import CoreData


extension StoreConnectedLamp {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoreConnectedLamp> {
        return NSFetchRequest<StoreConnectedLamp>(entityName: "StoreConnectedLamp")
    }

    @NSManaged public var adv: String?
    @NSManaged public var cid: String?
    @NSManaged public var did: String?
    @NSManaged public var dps: String?
    @NSManaged public var enc: String?
    @NSManaged public var login_aid: String?
    @NSManaged public var srl: String?
    @NSManaged public var type: String?
    @NSManaged public var uuid: String?

}
