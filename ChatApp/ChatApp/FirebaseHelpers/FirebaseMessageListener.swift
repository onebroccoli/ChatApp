//
//  FirebaseMessageListener.swift
//  ChatApp
//
//  Created by Sophia Zhu on 9/21/21.
//

import Foundation
import Firebase
import FirebaseFireStoreSwift


class FirebaseMessageListner {
    
    static let shared = FirebaseMessageListener()
    private init() {
        
    }
    
    // MARK: - Add, update, delete
    
    func addMessage(_ message: LocalMessage, memberId: String) {
        
        do {
            let _ = try FirebaseReference(.Messages).document(memberId).collection(message.chatRoomId).document(message.id).setData(from: message)
        }
        catch {
            print("error saving message ", error.localizedDescription)
            
        }
        
    }
}
