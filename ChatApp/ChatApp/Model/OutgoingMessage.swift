//
//  OutgoingMessage.swift
//  ChatApp
//
//  Created by Sophia Zhu on 9/20/21.
//

import Foundation
import UIKit
import FirebaseFirestoreSwift
import Gallery

class OutgoingMessage {
    
    class func send(chatId: String, text: String? , photo: UIImage?, video: Video?, audio: String?, audioDuration: Float = 0.0, location: String?, memberIds: [String]) {
        let currentUser = User.currentUser!
        let message = LocalMessage()
        message.id = UUID().uuidString
        message.chatRoomId = chatId
        message.senderId = currentUser.id
        message.senderName = currentUser.username
        message.senderInitials = String(currentUser.username.first!)
        message.date = Date()
        message.status = kSENT
        print("text is ", text)
        if text != nil {
            //send text message
            sendTextMessage(message: message, text: text!, memberIds: memberIds)
        }
        
        if photo != nil {
            sendPictureMessage(message: message, photo: photo!, memberIds: memberIds)
        }
        
        if video != nil {
            sendVideoMessage(message: message, video: video!, memberIds: memberIds)
            
        }
        
        if location != nil {
            sendLocationMessage(message: message, memberIds: memberIds)
            print("send location", LocationManager.shared.currentLocation)
            
        }
        
        if audio != nil {
            print ("send audio", audio, audioDuration)
            sendAudioMessage(message: message, audioFileName: audio!, audioDuration: audioDuration, memberIds: memberIds)
        }
        
        // TODO: send push notification
        FirebaseRecentListener.shared.updateRecents(chatRoomId: chatId, lastMessage: message.message)
        //TODO: update recent
        
    }
    
    class func sendChannel(channel: Channel, text: String? , photo: UIImage?, video: Video?, audio: String?, audioDuration: Float = 0.0, location: String?) {
        let currentUser = User.currentUser!
        var channel = channel
        
        let message = LocalMessage()
        message.id = UUID().uuidString
        message.chatRoomId = channel.id
        message.senderId = currentUser.id
        message.senderName = currentUser.username
        message.senderInitials = String(currentUser.username.first!)
        message.date = Date()
        message.status = kSENT
        
        if text != nil {
            //send text message
            sendTextMessage(message: message, text: text!, memberIds: channel.memberIds, channel: channel)
        }
        
        if photo != nil {
            sendPictureMessage(message: message, photo: photo!, memberIds: channel.memberIds, channel: channel)
        }
        
        if video != nil {
            sendVideoMessage(message: message, video: video!, memberIds: channel.memberIds, channel: channel)
            
        }
        
        if location != nil {
            sendLocationMessage(message: message, memberIds: channel.memberIds, channel: channel)
            
        }
        
        if audio != nil {
            sendAudioMessage(message: message, audioFileName: audio!, audioDuration: audioDuration, memberIds: channel.memberIds)
        }
        //send push notifications
        
        channel.lastMessageDate = Date()
        FirebaseChannelListener.shared.saveChannel(channel)
    }
    
    
    
    
    class func sendMessage(message: LocalMessage, memberIds: [String]) {
        RealmManager.shared.saveToRealm(message)
        
        for memberId in memberIds {
            //save to filebase
            print("save message for \(memberId)")
            FirebaseMessageListener.shared.addMessage(message, memberId: memberId)
        }
    }
    
    
    class func sendChannelMessage(message: LocalMessage, channel: Channel) {
        RealmManager.shared.saveToRealm(message)
        FirebaseMessageListener.shared.addChannelMessage(message, channel: channel)
    }
}

func sendTextMessage(message: LocalMessage, text: String, memberIds: [String], channel: Channel? = nil) {
    message.message = text
    message.type = kTEXT
    if channel != nil {
        //save for channel
        OutgoingMessage.sendChannelMessage(message: message, channel: channel!)
    } else {
        OutgoingMessage.sendMessage(message: message, memberIds: memberIds)

    }
    
}




func sendPictureMessage(message: LocalMessage, photo: UIImage, memberIds: [String], channel: Channel? = nil) {
    print("sending picture message")
    
    message.message = "Picture Message" //show at the msg preview
    message.type = kPHOTO
    let fileName = Date().stringDate()
    let fileDirectory = "MediaMessages/Photo/" + "\(message.chatRoomId)/" + "_\(fileName)" + ".jpg"
    //save locally , dont need to upload to firebase and download again
    FileStorage.saveFileLocally(fileData: photo.jpegData(compressionQuality: 0.6)! as NSData, fileName: fileName)
    
    FileStorage.uploadImage(photo, directory: fileDirectory) { (imageURL) in
        if imageURL != nil {
            message.pictureUrl = imageURL!
            
            if channel != nil {
                //save for channel
                OutgoingMessage.sendChannelMessage(message: message, channel: channel!)
            } else {
                OutgoingMessage.sendMessage(message: message, memberIds: memberIds)

            }
        }
    }
    
}

func sendVideoMessage(message: LocalMessage, video: Video, memberIds: [String], channel: Channel? = nil) {
    
    message.message = "Video Message"
    message.type = kVIDEO
    
    let fileName = Date().stringDate()
    let thumbnailDirectory = "MediaMessages/Photo/" + "\(message.chatRoomId)/" + "_\(fileName)" + ".jpg"
    let videoDirectory = "MediaMessages/Video/" + "\(message.chatRoomId)/" + "_\(fileName)" + ".mov"
    let editor = VideoEditor() // convert video
    editor.process(video: video) {(processedVideo, videoUrl) in
        if let tempPath = videoUrl {
            let thumbnail = videoThumbnail(video: tempPath)
            
            FileStorage.saveFileLocally(fileData: thumbnail.jpegData(compressionQuality: 0.7)! as NSData , fileName: fileName)
            FileStorage.uploadImage(thumbnail, directory: thumbnailDirectory) { (imageLink) in
                if imageLink != nil {
                    
                    //upload video
                    let videoData = NSData(contentsOfFile: tempPath.path) //convert nsdata
                    FileStorage.saveFileLocally(fileData: videoData!, fileName: fileName + ".mov")
                    FileStorage.uploadVideo(videoData!, directory: videoDirectory) {
                        (videoLink) in
                        message.pictureUrl = imageLink ?? ""
                        message.videoUrl = videoLink ?? ""
                        
                        if channel != nil {
                            //save for channel
                            OutgoingMessage.sendChannelMessage(message: message, channel: channel!)
                        } else {
                            OutgoingMessage.sendMessage(message: message, memberIds: memberIds)

                        }
                    }
                }
            }
        }
    }
}

func sendLocationMessage(message: LocalMessage, memberIds: [String], channel: Channel? = nil) {
    let currentLocation = LocationManager.shared.currentLocation
    message.message = "Location message"
    message.type = kLOCATION
    message.latitude = currentLocation?.latitude ?? 0.0
    message.longtitude = currentLocation?.longitude ?? 0.0
    
    if channel != nil {
        //save for channel
        OutgoingMessage.sendChannelMessage(message: message, channel: channel!)
    } else {
        OutgoingMessage.sendMessage(message: message, memberIds: memberIds)

    }
}



func sendAudioMessage(message: LocalMessage, audioFileName: String, audioDuration: Float, memberIds: [String], channel: Channel? = nil) {
    message.message = "Audio message"
    message.type = kAUDIO
    let fileDirectory = "MediaMessages/Audio/" + "\(message.chatRoomId)/" + "_\(audioFileName)" + ".m4a"
    FileStorage.uploadAudio(audioFileName, directory: fileDirectory) { (audioUrl) in
        if audioUrl != nil {
            
            message.audioUrl = audioUrl ?? ""
            message.audioDuration = Double(audioDuration)
            if channel != nil {
                //save for channel
                OutgoingMessage.sendChannelMessage(message: message, channel: channel!)
            } else {
                OutgoingMessage.sendMessage(message: message, memberIds: memberIds)
            }
        }
    }
}
