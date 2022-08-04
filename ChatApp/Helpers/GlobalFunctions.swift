//
//  GlobalFunctions.swift
//  ChatApp
//
//  Created by Sophia Zhu on 9/12/21.
//

import Foundation
import UIKit
import AVFoundation

//extract image name from url
/*
 ///https://firebasestorage.googleapis.com/v0/b/chapapp-660ad.appspot.com/o/Avatars%2F_OzPBJ83sTRaVatJxgbkAl7otolp2.jpg?alt=media&token=5c89ead0-2748-4c2f-b2e2-7890bc0bd25d
 */

// first get OzPBJ83sTRaVatJxgbkAl7otolp2.jpg?alt=media&token=5c89ead0-2748-4c2f-b2e2-7890bc0bd25d
// then OzPBJ83sTRaVatJxgbkAl7otolp2.jpg
// last OzPBJ83sTRaVatJxgbkAl7otolp2

func fileNameFrom(fileUrl: String) -> String {

    return ((fileUrl.components(separatedBy: "_").last)!.components(separatedBy: "?").first!).components(separatedBy: ".").first!

}


// show in the chat page, show how long the msg was received. just now/ minutes/ hours ago
func timeElapsed(_ date: Date) -> String {
    let seconds = Date().timeIntervalSince(date)
    var elapsed = ""
    if seconds < 60 {
        elapsed = "Just now"
    } else if seconds < 60*60 {
        let minutes = Int(seconds / 60)
        let minText = minutes > 1 ? "mins" : "min"
        elapsed = " \(minutes) \(minText)"
        
    } else if seconds < 24 * 60 * 60 {
        let hours = Int(seconds / (60 * 60))
        let hourText = hours > 1 ? "hours" : "hour"

        elapsed = "\(hours) \(hourText)"
    } else {
        elapsed = date.longDate()
    }
    return elapsed
}

//give video a thumbnail image
func videoThumbnail(video: URL) -> UIImage {
    let asset = AVURLAsset(url: video, options: nil)
    let imageGenerator = AVAssetImageGenerator(asset:  asset)
    imageGenerator.appliesPreferredTrackTransform = true
    
    let time = CMTimeMakeWithSeconds(0.5, preferredTimescale: 1000)
    var actualTime = CMTime.zero
    
    var image: CGImage?
    
    do {
        image = try imageGenerator.copyCGImage(at: time, actualTime: &actualTime)
    } catch let error as NSError {
        print("error making thumbnail ", error.localizedDescription)
    }
    
    if image != nil {
        return UIImage(cgImage: image!)
    } else {
        return UIImage(named: "photoPlaceholder")!
    }
}
