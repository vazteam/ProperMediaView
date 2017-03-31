//
//  AVPlayerView.swift
//  ProperMediaViewDemo
//
//  Created by Murawaki on 2017/03/30.
//  Copyright © 2017年 Murawaki. All rights reserved.
//

import UIKit
import AVFoundation

public class AVPlayerView: UIView {
    
    public var playLayer: AVPlayerLayer {
        get {
            return self.layer as! AVPlayerLayer
        }
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    override public class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}
