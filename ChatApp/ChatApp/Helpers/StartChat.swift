//
//  StartChat.swift
//  ChatApp
//
//  Created by Sophia Zhu on 9/15/21.
//

import Foundation
import Firebase

// MARK: - StartChat
func startChat(user1: User, user2: User) -> String { //chatRoomId
    //create chat id so the conversation between users are unique
    let chatRoomId = chatRoomIdFrom(user1Id: user1.id, user2Id: user2.id)
    createRecentItems(chatRoomId: chatRoomId, users: [user1, user2])
    return chatRoomId
}

func restartChat(chatRoomId: String, memberIds: [String]) {
    FirebaseUserListener.shared.downloadUsersFromFirebase(withIds: memberIds) { (users) in
        if users.count > 0 {
            createRecentItems(chatRoomId: chatRoomId, users: users)
        }
    }
}



func createRecentItems(chatRoomId: String, users: [User]) { //create chatId in firebase
    var memberIdsToCreateRecent = [users.first!.id, users.last!.id]
    print("members to create recent is", memberIdsToCreateRecent)
    
    //does user have recent?
    FirebaseReference((.Recent)).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments {(snapshot, error) in
        guard let snapshot = snapshot else { return }
        if !snapshot.isEmpty {
            memberIdsToCreateRecent = removeMemberWhoHasRecent(snapshot: snapshot, memberIds: memberIdsToCreateRecent)
            print("updated members to create recent is", memberIdsToCreateRecent)

            
            
        }
        
        for userId in memberIdsToCreateRecent {
            print("creating recent for user with id ", userId)
            let senderUser = userId == User.currentId ? User.currentUser! : getReceiverFrom(users: users) // current sender is ourself
            let receiverUser = userId == User.currentId ? getReceiverFrom(users: users) : User.currentUser! //receiverUser is opposite of senderUser
            
            let recentObject = RecentChat(id: UUID().uuidString, chatRoomId: chatRoomId, senderId: senderUser.id, senderName: senderUser.username, receiverId: receiverUser.id, receiverName: receiverUser.username, date: Date(), memberIds: [senderUser.id, receiverUser.id], lastMessage: "", unreadCounter: 0, avatarLink: receiverUser.avatarLink)
            
            FirebaseRecentListener.shared.saveRecent(recentObject) //first create FirebaseRecentListener class
        }
    }
    
}


func removeMemberWhoHasRecent(snapshot: QuerySnapshot, memberIds: [String]) -> [String] {
    var memberIdsToCreateRecent = memberIds
    for recentData in snapshot.documents {
        let currentRecent = recentData.data() as Dictionary
        if let currentUserId = currentRecent[kSENDERID] {
            if memberIdsToCreateRecent.contains(currentUserId as! String) {
                memberIdsToCreateRecent.remove(at: memberIdsToCreateRecent.firstIndex(of: currentUserId as! String)!)
            }
            
        }
    }
    return memberIdsToCreateRecent
}


func chatRoomIdFrom(user1Id: String, user2Id: String) -> String {
    var chatRoomId = ""
    let value = user1Id.compare(user2Id).rawValue
    chatRoomId = value < 0 ? (user1Id + user2Id) : (user2Id + user1Id)
    return chatRoomId
}

//already know one user, need to get the other one except current user
func getReceiverFrom(users: [User]) -> User {
    var allUsers = users
    allUsers.remove(at: allUsers.firstIndex(of: User.currentUser!)!)
    return allUsers.first!
}
