//
//  PFMovieThumbnailView.swift
//  PFNowDetailViewController
//
//  Created by Murawaki on 2017/02/01.
//  Copyright © 2017年 VAZ inc. All rights reserved.
//

import Foundation
import UIKit

class ProgressImageView: UIImageView {
    private var loadingImageView = UIImageView(image: UIImage.bundledImage(named: "loading"))
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        loadingImageView.center = CGPoint(x: self.bounds.width/2, y: self.bounds.height/2)
        
        var biggastLength: CGFloat = self.frame.size.width
        if self.frame.size.width > self.frame.size.height {
            biggastLength = self.frame.width
        }
        loadingImageView.frame.size = CGSize(sideLength: biggastLength * 0.1)
    }

    override func awakeFromNib() {
        loadingImageView.alpha = 0.8
        self.addSubview(loadingImageView)
        
        let rotateAnim = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnim.toValue = Double.pi
        rotateAnim.duration = 0.5
        rotateAnim.repeatCount = MAXFLOAT
        rotateAnim.isCumulative = true
        loadingImageView.layer.add(rotateAnim, forKey: "rotateAnimation")
    }
    
    func showLoading() {
        loadingImageView.isHidden = false
    }
    
    func dismissLoading() {
        loadingImageView.isHidden = true
    }
}
