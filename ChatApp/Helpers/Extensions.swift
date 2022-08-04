//
//  Extensions.swift
//  ChatApp
//
//  Created by Sophia Zhu on 9/12/21.
//

import UIKit
//add circle image
extension UIImage {
    
    var isPortrait: Bool { return size.height > size.width }
    var isLandscape: Bool { return size.width > size.height}
    var breadth: CGFloat { return min(size.width, size.height)}
    var breadthSize: CGSize { return CGSize(width: breadth, height: breadth)}
    var breadRect: CGRect { return CGRect(origin: .zero, size: breadthSize)}
    
    var circleMasked: UIImage? {
        UIGraphicsBeginImageContextWithOptions(breadthSize, false, scale)
        
        defer { UIGraphicsEndImageContext() }
        guard let cgImage = cgImage?.cropping(to: CGRect(origin: CGPoint(x: isLandscape ? floor((size.width - size.height)/2) : 0, y: isPortrait ? floor((size.height - size.width) / 2) : 0), size: breadthSize)) else {return nil}
        
        UIBezierPath(ovalIn: breadRect).addClip()
        UIImage(cgImage: cgImage).draw(in: breadRect)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}


extension Date {
    func longDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy"
        return dateFormatter.string(from: self)
    }
    
    
    func time() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: self)
    }
    
    func stringDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMyyyyHHmmss" //for save to firebase
        return dateFormatter.string(from: self)
    }
    
    func interval(ofComponent comp: Calendar.Component, from date: Date) -> Float {
        let currentCalendar = Calendar.current
        guard let start = currentCalendar.ordinality(of: comp, in: .era, for: date) else { return 0 }
        guard let end =   currentCalendar.ordinality(of: comp, in: .era, for: self) else { return 0 }
        
        return Float(start - end)
    }
}
