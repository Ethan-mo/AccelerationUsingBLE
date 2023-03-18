//
//  CoreDataInfo.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 21..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import CoreData

class CoreDataInfo {
    
    var storeDeviceNoti = CoreDataInfo_StoreDeviceNoti()
    var storeDeviceNotiReady = CoreDataInfo_StoreDeviceNotiReady()
    var storeShareMemberNoti = CoreDataInfo_StoreShareMemberNoti()
    var storeConnectedSensor = CoreDataInfo_StoreConnectedSensor()
    var storeConnectedLamp = CoreDataInfo_StoreConnectedLamp()
    var storeHubGraph = CoreDataInfo_StoreHubGraph()
    var storeLampGraph = CoreDataInfo_StoreLampGraph()
    var storeNewAlarm = CoreDataInfo_StoreNewAlarm()
    var storeSensorMovGraph = CoreDataInfo_StoreSensorMovGraph()
    var storeSensorVocGraph = CoreDataInfo_StoreSensorVocGraph()
    var storeDiaperSensingLog = CoreDataInfo_StoreDiaperSensingLog()
    
    var m_NSManagedObjectContext: NSManagedObjectContext?
    var m_NSManagedObjectBackgroundContext: NSManagedObjectContext?
    var m_entity = [String : NSEntityDescription]()
    
    var context: NSManagedObjectContext {
        get {
            if (m_NSManagedObjectContext == nil) {
                if #available(iOS 10.0, *) {
                    m_NSManagedObjectContext = self.persistentContainer.viewContext
                } else {
                    m_NSManagedObjectContext = self.managedObjectContext
                }
            }
            return m_NSManagedObjectContext!
        }
    }
    
    var backgroundContext: NSManagedObjectContext {
        get {
            if (m_NSManagedObjectBackgroundContext == nil) {
                if #available(iOS 10.0, *) {
                    m_NSManagedObjectBackgroundContext = self.persistentContainer.newBackgroundContext()
                } else {
                    m_NSManagedObjectBackgroundContext = self.backgroundManagedObjectContext
                }
            }
            return m_NSManagedObjectBackgroundContext!
        }
    }
    
    func setValueString(obj: NSManagedObject, key: String, value: String) {
        obj.setValue(DataManager.instance.m_configData.localEncryptData(string: value), forKey: key)
    }
    
    func setValueInt(obj: NSManagedObject, key: String, value: Int) {
        obj.setValue(DataManager.instance.m_configData.localEncryptData(string: value.description), forKey: key)
    }
    
    func getValueString(obj: NSManagedObject, key: String) -> String {
        return DataManager.instance.m_configData.localDecryptData(string: obj.value(forKey: key) as? String ?? "")
    }
    
    func getValueInt(obj: NSManagedObject, key: String) -> Int {
        return Int(DataManager.instance.m_configData.localDecryptData(string: obj.value(forKey: key) as? String ?? "")) ?? -1
    }
    
    func initInfo() {
        deleteAllData(entity: "StoreDeviceNoti")
        deleteAllData(entity: "StoreDeviceNotiReady")
        deleteAllData(entity: "StoreShareMemberNoti")
        deleteAllData(entity: "StoreConnectedSensor")
        deleteAllData(entity: "StoreConnectedLamp")
        deleteAllData(entity: "StoreHubGraph")
        deleteAllData(entity: "StoreNewAlarm")
        deleteAllData(entity: "StoreLampGraph")
        deleteAllData(entity: "StoreSensorMovGraph")
        deleteAllData(entity: "StoreSensorVocGraph")
        deleteAllData(entity: "StoreDiaperSensingLog")
    }
    
    func getEntity(name: String) -> NSEntityDescription? {
        if let _entity = m_entity[name] {
            return _entity
        }
        
        let _context = DataManager.instance.m_coreDataInfo.context
        if let _entity = NSEntityDescription.entity(forEntityName: name, in: _context) {
            m_entity.updateValue(_entity, forKey: name)
            return _entity
        }
        return nil
    }

    func deleteAllData(entity: String)
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        
        do
        {
            let results = try context.fetch(fetchRequest)
            for managedObject in results
            {
                let managedObjectData = managedObject as! NSManagedObject
                context.delete(managedObjectData)
            }
            saveData()
        } catch let error as NSError {
            Debug.print("[ERROR] Detele all data in \(entity) error : \(error) \(error.userInfo)", event: .error)
        }
    }
    
    func saveData() {
        do {
            if context.hasChanges {
                try context.save()
            }
        } catch {
            let nserror = error as NSError
            
            Debug.print("[ERROR] Unresolved error \(nserror), \(nserror.userInfo)", event: .error)
//            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    func backgroundSaveData() {
        do {
            if backgroundContext.hasChanges {
                try backgroundContext.save()
            }
        } catch {
            let nserror = error as NSError
            
            Debug.print("[ERROR] Unresolved error \(nserror), \(nserror.userInfo)", event: .error)
            //            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    // MARK: - utility routines
    lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    // MARK: - Core Data stack (generic)
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "CoreDataMain", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
//        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
//        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        let url = self.applicationDocumentsDirectory.appendingPathComponent("CoreData_Main").appendingPathExtension("sqlite")
//
//        do {
//            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
//        } catch {
//            let dict : [String : Any] = [NSLocalizedDescriptionKey        : "Failed to initialize the application's saved data" as NSString,
//                                         NSLocalizedFailureReasonErrorKey : "There was an error creating or loading the application's saved data." as NSString,
//                                         NSUnderlyingErrorKey             : error as NSError]
//
//            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
//            fatalError("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
//        }
//
//        return coordinator
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("CoreDataMain.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            let options = [ NSMigratePersistentStoresAutomaticallyOption : true, NSInferMappingModelAutomaticallyOption : true ]
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            Debug.print("[ERROR] Unresolved error \(wrappedError), \(wrappedError.userInfo)", event: .error)
//            abort()
        }

        return coordinator
    }()
    
    // MARK: - Core Data stack (iOS 9)
    @available(iOS 9.0, *)
    lazy var managedObjectContext: NSManagedObjectContext = {
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
//        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return managedObjectContext
    }()
    
    @available(iOS 9.0, *)
    lazy var backgroundManagedObjectContext: NSManagedObjectContext = {
        var backgroundManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundManagedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        //        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return backgroundManagedObjectContext
    }()
    
    // MARK: - Core Data stack (iOS 10)
    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataMain")
        container.loadPersistentStores(completionHandler: {
            (storeDescription, error) in
            if let error = error as NSError?
            {
                Debug.print("[ERROR] Unresolved error \(error), \(error.userInfo)", event: .error)
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        )
        
        return container
    }()
}
