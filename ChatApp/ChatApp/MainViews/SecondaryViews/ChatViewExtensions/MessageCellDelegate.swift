//
//  MessageCellDelegate.swift
//  ChatApp
//
//  Created by Sophia Zhu on 9/20/21.
//

import Foundation
import MessageKit
import AVFoundation
import AVKit
import SKPhotoBrowser

extension ChatViewController : MessageCellDelegate {
    
    func didTapImage(in cell: MessageCollectionViewCell){
//        print("tap") //only works for image and video
        if let indexPath = messagesCollectionView.indexPath(for: cell) {
            
            let mkMessage = mkMessages[indexPath.section]
            if mkMessage.photoItem != nil && mkMessage.photoItem!.image != nil {
                //this is photo message
                var images = [SKPhoto]()
                let photo = SKPhoto.photoWithImage(mkMessage.photoItem!.image!)
                images.append(photo)
                
                let browser = SKPhotoBrowser(photos: images)
                browser.initializePageIndex(0)
                present(browser, animated: true, completion: nil)
            }
            
            if mkMessage.videoItem != nil && mkMessage.videoItem!.url != nil {
                //this is video message
                let player = AVPlayer(url: mkMessage.videoItem!.url!)
                let moviePlayer = AVPlayerViewController()
                let session = AVAudioSession.sharedInstance()
                
                try! session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
                moviePlayer.player = player
                self.present(moviePlayer, animated: true) {
                    moviePlayer.player!.play()
                }
            }
        }

    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        if let indexPath = messagesCollectionView.indexPath(for: cell) {
            let mkMessage = mkMessages[indexPath.section]
            if mkMessage.locationItem != nil {
                let mapView = MapViewController()
                mapView.location = mkMessage.locationItem?.location
                
                navigationController?.pushViewController(mapView, animated: true)
            
            }
        }
    }
}
