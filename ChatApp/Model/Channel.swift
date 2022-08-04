//
//  Channel.swift
//  ChatApp
//
//  Created by Sophia Zhu on 9/27/21.
//

import Foundation
import FirebaseFirestoreSwift
import Firebase

struct Channel: Codable {
    
    var id = ""
    var name = ""
    var adminId = ""
    var memberIds = [""]
    var avatarLink = ""
    var aboutChannel = ""
    @ServerTimestamp var createdDate = Date()
    @ServerTimestamp var lastMessageDate = Date()
    
    enum CodingKeys: String, CodingKey {
        //if match with server name, no need to assign
        case id
        case name
        case adminId
        case memberIds
        case avatarLink
        case aboutChannel
        case createdDate
        case lastMessageDate = "date"// match with server name
    
    }
}
