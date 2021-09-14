//
//  GlobalFunctions.swift
//  ChatApp
//
//  Created by Sophia Zhu on 9/12/21.
//

import Foundation


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
