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
        let image = UIImage(named: named)
        if image == nil {
            let bundle = Bundle.init(for: self)
            return UIImage(named: named, in: bundle, compatibleWith: nil)
        }
        return image
    }
}
