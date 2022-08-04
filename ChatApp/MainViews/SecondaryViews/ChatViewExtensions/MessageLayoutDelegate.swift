//
//  MessageLayoutDelegate.swift
//  ChatApp
//
//  Created by Sophia Zhu on 9/20/21.
//

import Foundation
import MessageKit

extension ChatViewController : MessagesLayoutDelegate {
    //MARK: - Cell top label
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.section % 3 == 0 {
            //TODO: set different size for pull to reload
            if ((indexPath.section == 0 ) && (allLocalMessages.count > displayingMessagesCount)) {
                return 40
            }
            return 18
        }
        return 0
    }
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return isFromCurrentSender(message: message) ? 17 : 0
    }
    
    // MARK: - Message bottom label
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return indexPath.section != mkMessages.count - 1 ? 10 : 0
    }
    
    //show sender initial in the chat
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.set(avatar: Avatar(initials: mkMessages[indexPath.section].senderInitials))
    }
}



extension ChannelChatViewController : MessagesLayoutDelegate {
    //MARK: - Cell top label
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.section % 3 == 0 {
            //TODO: set different size for pull to reload
            if ((indexPath.section == 0 ) && (allLocalMessages.count > displayingMessagesCount)) {
                return 40
            }
            return 18
        }
        return 0
    }
//    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
//        return isFromCurrentSender(message: message) ? 17 : 0
//    }
//
    // MARK: - Message bottom label
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
//        return indexPath.section != mkMessages.count - 1 ? 10 : 0
        return 10 //防止最后一条没有时间
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.set(avatar: Avatar(initials: mkMessages[indexPath.section].senderInitials))
    }
}
