//
//  UIImage+Bundle.swift
//  ProperMediaViewDemo
//
//  Created by Murawaki on 2017/03/31.
//  Copyright © 2017年 Murawaki. All rights reserved.
//

import Foundation
import UIKit

public extension UIImage {
    public static func bundledImage(named: String) -> UIImage? {
        if let image = UIImage(named: named) {
            return image
        }
        
        let bundle = Bundle.init(for: self)
        if let image = UIImage(named: named, in: bundle, compatibleWith: nil){
            return image
        }
        
        let path = Bundle.main.path(forResource: "ProperMediaView", ofType: "bundle")!
        let bundleWithPath = Bundle(path: path)
        let image = UIImage(named: named, in: bundleWithPath, compatibleWith: nil)
        
        return image
    }
}
