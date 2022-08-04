//
//  PhotoMessage.swift
//  ChatApp
//
//  Created by Sophia Zhu on 9/24/21.
//

import Foundation
import MessageKit

class PhotoMessage: NSObject, MediaItem {
    
    var url: URL?
    
    var image: UIImage?
    
    var placeholderImage: UIImage
    
    var size: CGSize
    
    init(path: String) {
        self.url = URL(fileURLWithPath: path)
        self.placeholderImage = UIImage(named: "photoPlaceholder")!
        self.size = CGSize(width: 240, height: 240)
        
    }
    
}
