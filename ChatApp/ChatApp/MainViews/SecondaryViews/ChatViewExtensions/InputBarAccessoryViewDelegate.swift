//
//  InputBarAccessoryViewDelegate.swift
//  ChatApp
//
//  Created by Sophia Zhu on 9/20/21.
//

import Foundation
import InputBarAccessoryView

extension ChatViewController : InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        print("typing...")
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        for component in inputBar.inputTextView.components {
            if let text = component as? String {
                
                print("send message with text ", text)
                
            }
        }
        messageInputBar.inputTextView.text = ""
        messageInputBar.invalidatePlugins()
    }
}
