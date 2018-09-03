//
//  ChatContact.swift
//  MessagesHistoryBrowser
//
//  Created by Guillaume Laurent on 10/10/15.
//  Copyright © 2015 Guillaume Laurent. All rights reserved.
//

import Cocoa

class ChatContact: NSManagedObject {

    @NSManaged var identifier:String
    @NSManaged var name:String
    @NSManaged var known:Bool

    @NSManaged var chats:NSSet
    @NSManaged var messages:NSSet
    @NSManaged var attachments:NSSet

//    static let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Contact")
    static let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)


    convenience init(managedObjectContext:NSManagedObjectContext, withName aName:String, withIdentifier anIdentifier:String) {

        let entityDescription = NSEntityDescription.entity(forEntityName: "Contact", in: managedObjectContext)
        self.init(entity: entityDescription!, insertInto: managedObjectContext)

        name = aName
        identifier = anIdentifier
    }

//    class func setupFetchRequest() {
//        if (ChatContact.fetchRequest().sortDescriptors == nil) {
//            ChatContact.fetchRequest().sortDescriptors = [ChatContact.sortDescriptor]
//        }
//    }

//    class func allContactsInContext(managedObjectContext:NSManagedObjectContext) -> [ChatContact] {
//
//        var allContacts = [ChatContact]()
//
//        do {
//            let results = try managedObjectContext.executeFetchRequest(fetchRequest)
//            allContacts = results as! [ChatContact]
//        } catch let error as NSError {
//            print("\(__FUNCTION__) : Could not fetch \(error), \(error.userInfo)")
//        }
//
//        return allContacts
//    }

    class func allKnownContacts(_ managedObjectContext:NSManagedObjectContext) -> [ChatContact] {

        return allContactsWithPredicate(managedObjectContext, predicate:NSPredicate(format: "known == YES && messages.@count > 0"))
    }

    class func allUnknownContacts(_ managedObjectContext:NSManagedObjectContext) -> [ChatContact] {

        return allContactsWithPredicate(managedObjectContext, predicate:NSPredicate(format: "known == NO && messages.@count > 0"))
    }

    class func allContactsWithPredicate(_ managedObjectContext:NSManagedObjectContext, predicate:NSPredicate? = nil) -> [ChatContact] {

        var allContacts = [ChatContact]()

        guard let appDelegate = NSApp.delegate as? AppDelegate else { return [ChatContact]() }

        managedObjectContext.performAndWait { () -> Void in

            do {
                let contactFetchRequest:NSFetchRequest<NSFetchRequestResult> = fetchRequest()
                contactFetchRequest.predicate = predicate
                contactFetchRequest.sortDescriptors = [ChatContact.sortDescriptor]
                
                let results = try managedObjectContext.fetch(contactFetchRequest)
                allContacts = results as! [ChatContact]
            } catch let error as NSError {
                print("\(#function) : Could not fetch \(error), \(error.userInfo)")
            }
        }

        return allContacts
    }

    class func allContacts(_ managedObjectContext:NSManagedObjectContext) -> [ChatContact] {
        return allContactsWithPredicate(managedObjectContext)
    }

    class func contactIn(_ managedObjectContext:NSManagedObjectContext, named name:String, withIdentifier identifier:String) -> ChatContact {
        let contactNamedFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Contact")
        let namePredicate = NSPredicate(format: "name == %@", name)
        contactNamedFetchRequest.predicate = namePredicate

        var res:ChatContact?

        managedObjectContext.performAndWait { () -> Void in

            do {
                let r = try managedObjectContext.fetch(contactNamedFetchRequest)
                let foundContacts = r as! [ChatContact]

                if foundContacts.count > 0 {
                    res = foundContacts[0]
                } else {
                    res = ChatContact(managedObjectContext: managedObjectContext, withName: name, withIdentifier: identifier)
                }
            } catch let error as NSError {
                print("\(#function) : Could not fetch \(error), \(error.userInfo)")

                res = ChatContact(managedObjectContext: managedObjectContext, withName: name, withIdentifier: identifier)
            }
        }

        return res!
    }

}
