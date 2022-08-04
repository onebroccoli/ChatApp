//
//  LocationMessage.swift
//  ChatApp
//
//  Created by Sophia Zhu on 9/25/21.
//

import Foundation
import CoreLocation
import MessageKit

class LocationMessage: NSObject, LocationItem {
    var location: CLLocation
    var size: CGSize
    
    init(location: CLLocation) {
        self.location = location
        self.size = CGSize(width: 240, height: 240)
    }
    
    
}
