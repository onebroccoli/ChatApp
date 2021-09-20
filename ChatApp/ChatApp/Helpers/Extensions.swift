//
//  Extensions.swift
//  ChatApp
//
//  Created by Sophia Zhu on 9/12/21.
//

import UIKit

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
}
