//
//  FirebaseUserListener.swift
//  ChatApp
//
//  Created by Sophia Zhu on 9/1/21.
//

import Foundation
import Firebase

class FirebaseUserListener {
    
    static let shared = FirebaseUserListener()
    
    private init() {}
    
    // MARK: - Login
    func loginUserWithEmail(email: String, password: String, completion: @escaping(_ error: Error?, _ isEmailVerified: Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
            if error == nil && authDataResult!.user.isEmailVerified {
                FirebaseUserListener.shared.downloadUserFromFirebase(userId: authDataResult!.user.uid, email: email)
                completion(error, true)
            } else {
                print("email is not verified")
                completion(error, false)
            }
        }
    }
    
    
    // MARK: - Register
    func registerUserWith(email: String, password: String, completion: @escaping (_ error: Error?) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) {
            (authDataResult, error) in
            
            completion(error)
            
            if error == nil {
                
                //send verification email
                authDataResult!.user.sendEmailVerification { (error) in
                    print("auth email sent with error", error?.localizedDescription)
                }
                
                // create user and save it
                if authDataResult?.user != nil {
                    
                    let user = User(id: authDataResult!.user.uid, username: email, email: email, pushId: "", avatarLink: "", status: "Hey there I'm using Messager")
                    
                    saveUserLocally(user)
                    self.saveUserToFirestore(user)
                    
                }
            }
        }
    }
    
    // MARK: - Resend link methods
    func resendVerificationEmail(email: String, completion: @escaping(_ error: Error?) -> Void) {
        Auth.auth().currentUser?.reload(completion: { (error) in
            Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                completion(error)
            })
        })
    }
    
    func resetPasswordFor(email: String, completion: @escaping(_ error: Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            completion(error)
        }
    }
    

    func logOutCurrentUser(completion: @escaping(_ error: Error?) -> Void) {
        do {
            try Auth.auth().signOut()
            userDefaults.removeObject(forKey: kCURRENTUSER)
            userDefaults.synchronize()
            completion(nil)
        } catch let error as NSError{
            completion(error)
            
        }
        
        
    }
    
    // MARK: - Save users
    func saveUserToFirestore(_ user: User) {
        
        do {
            try FirebaseReference(.User).document(user.id).setData(from: user)
            
        } catch {
            print(error.localizedDescription, "adding user")
 
        }
    }
    
    // MARK: - download
    func downloadUserFromFirebase(userId: String, email: String? = nil){
        FirebaseReference(.User).document(userId).getDocument { (querySnapshot, error) in
            guard let document = querySnapshot else {
                print("no document for user")
                return
            }
            let result = Result {
                try? document.data(as: User.self)
                
            }
            switch result {
            case .success(let userObject):
                if let user = userObject {
                    saveUserLocally(user)
                } else {
                    print(" Document does not exist")
                }
            case .failure(let error):
                print("Error decoding user ", error)
                
            }
            
        }
        
    }
    
    //return all users
    func downloadAllUsersFromFirebase(completion: @escaping(_ allUsers: [User]) -> Void) {
        var users: [User] = []
        FirebaseReference(.User).limit(to: 500).getDocuments { (querySnapshot, error) in
            guard let document = querySnapshot?.documents else {
                print("no documents in all users")
                return
                
            }
            let allUsers = document.compactMap { (QueryDocumentSnapshot) -> User? in
                return try? QueryDocumentSnapshot.data(as: User.self)
            }
            
            for user in allUsers {
                if User.currentId != user.id {
                    users.append(user)
                }
            }
            
            completion(users) // return all users
        }
    }
    
    func downloadUsersFromFirebase(withIds: [String], completion: @escaping (_ allUsers: [User]) -> Void) {
        var count = 0
        var usersArray: [User] = []
        
        for userId in withIds {
            FirebaseReference(.User).document(userId).getDocument { (QuerySnapshot, error) in
                guard let document = QuerySnapshot else {
                    print("no document for users")
                    return
                }
                let user = try? document.data(as: User.self)
                usersArray.append(user!)
                if count == withIds.count {
                    completion(usersArray) //return specified user id                }
                    
                    
                }
            }
        }
    }
}
