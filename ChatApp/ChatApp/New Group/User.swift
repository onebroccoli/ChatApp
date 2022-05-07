//
//  User.swift
//  ChatApp
//
//  Created by Sophia Zhu on 9/1/21.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

//have two protocols, one codable, one equatable
struct User: Codable, Equatable { //coadble is encoding and decoding
    
    var id = ""
    var username: String
    var email: String
    var pushId = ""
    var avatarLink = ""
    var status: String
    
    static var currentId: String {
        return Auth.auth().currentUser!.uid
        
    }
    
    static var currentUser: User? {
        if  Auth.auth().currentUser != nil {
            if let dictionary = UserDefaults.standard.data(forKey: kCURRENTUSER) {
                let decoder = JSONDecoder()
                
                do {
                    let userObject = try decoder.decode(User.self, from: dictionary)
                    return userObject
                } catch {
                    print("Error decoding user from user defaults", error.localizedDescription)
                }
            }
        }
        return nil //no user
    }
    //equitable
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}

func saveUserLocally(_ user: User) {
    
    let encoder = JSONEncoder()
    do {
        let data = try encoder.encode(user)
        UserDefaults.standard.set(data, forKey: kCURRENTUSER)
    } catch {
        print("error saving user locally", error.localizedDescription)
    }
}


func createDummyUsers() {
    print("create dummy users")
    let names = ["mark","Jen","Bob","Ben","Sophia","Spencer"]
    var imageIndex = 1
    var userIndex = 1
    
    for i in 0..<5 {
        let id = UUID().uuidString
        let fileDirectory = "Avatars/" + "_\(id)" + ".jpg"
        FileStorage.uploadImage(UIImage(named: "user\(imageIndex)")!, directory: fileDirectory) { (avatarLink) in
            let user = User(id: id, username: names[i], email: "user\(userIndex)@mail.com", pushId: "", avatarLink: avatarLink ?? "", status: "No Status")
            userIndex += 1
            FirebaseUserListener.shared.saveUserToFirestore(user)
            
        }
        imageIndex += 1
        if imageIndex == 5 {
            imageIndex = 1 //do not have enough images, just make it use again and agin
        }
    }
}
