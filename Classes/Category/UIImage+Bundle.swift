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
        
        let frameworkBundle = Bundle(for: ProperMediaView.self)
        let bundleUrl = frameworkBundle.resourceURL?.appendingPathComponent("ProperMediaView.bundle")
        let resourceBundle = Bundle(url: bundleUrl!)
        let image = UIImage(named: named, in: resourceBundle, compatibleWith: nil)
        
        return image
    }
}

