//
//  CGSize+init.swift
//  ProperMediaViewDemo
//
//  Created by Murawaki on 2017/03/30.
//  Copyright © 2017年 Murawaki. All rights reserved.
//

import Foundation
import UIKit

extension CGSize {
    init(sideLength: CGFloat) {
        self.init(width: sideLength, height: sideLength)
    }
}
