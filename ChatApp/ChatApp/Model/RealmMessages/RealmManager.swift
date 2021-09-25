//
//  RealmManager.swift
//  ChatApp
//
//  Created by Sophia Zhu on 9/20/21.
//
// take car all save data into our local database


import Foundation
import RealmSwift

class RealmManager {
    
    static let shared = RealmManager()
    let realm = try! Realm()
    private init() {
        
    }
    //T means can pass anything as long as it conforms to object protocol
    func saveToRealm<T: Object>(_ object: T) {
        do {
            try realm.write {
                realm.add(object, update: .all)
//                realm.delete(object)
            }
            
        } catch {
            print ("Error saving realm object ", error.localizedDescription)
        }
    }
    
    
}
