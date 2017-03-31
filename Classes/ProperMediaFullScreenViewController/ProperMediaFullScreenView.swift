//
//  ProperMediaView.swift

//
//  Created by Murawaki on 2017/03/01.
//  Copyright © 2017年 Murawaki. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

import SDWebImage

class ProperMediaFullScreenView: UIView {
    var contentsView: ProperMediaView
    
    var closeButton: UIButton
    var overlayView: BlurView
    
    fileprivate var displacedView: ProperMediaView
    fileprivate var isAnimation: Bool = false
    
    init(displacedMediaView: ProperMediaView) {
        self.displacedView = displacedMediaView
        self.contentsView = displacedMediaView.initDisplacement()
        
        self.closeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        self.overlayView = BlurView()
        
        super.init(frame: CGRect.zero)
        self.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        
        commonInit()
    }
    
    private func commonInit() {
        contentsView.center = displacedView.convert(displacedView.bounds.center, to: self)
        contentsView.clipsToBounds = true
        
        let closeImage = UIImage.bundledImage(named: "icon_close")?.withRenderingMode(.alwaysTemplate)
        closeButton.setImage(closeImage, for: .normal)
        
        backgroundColor = UIColor.clear
        addSubview(contentsView)
        addSubview(closeButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        closeButton.frame.origin.y = 6
        closeButton.frame.topRightPoint.x = frame.width - 6
        
        overlayView.frame = bounds.insetBy(dx: -UIScreen.main.bounds.width * 2, dy: -UIScreen.main.bounds.height * 2)
    }
    
    func present() {
        isAnimation = true
        
        let animatedSize = CGSize(width: self.frame.width, height: self.frame.width)
        
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut, animations: { [weak self] in
            
            guard let weakself = self else {
                return
            }
            
            /*TODO
            guard let height: Int = (weakself.displacedView.nowData.media()?.height), let width: Int = (weakself.displacedView.nowData.media()?.width) else {
                return
            }
            
            let height = 1
            let width = 1
            
            let mediaHeight = CGFloat(height)
            let mediaWidth = CGFloat(width)
            
            weakself.contentsView.bounds.size = CGSize(
                width: weakself.bounds.size.width,
                height: weakself.bounds.size.width * CGFloat(mediaHeight / mediaWidth))
            weakself.contentsView.center = weakself.bounds.center
 */
            let magRatioW: CGFloat = animatedSize.width / weakself.contentsView.frame.width
            let magRatioH: CGFloat = animatedSize.height / weakself.contentsView.frame.height
            let moveX: CGFloat = weakself.bounds.center.x - weakself.contentsView.center.x
            let moveY: CGFloat = weakself.bounds.center.y - weakself.contentsView.center.y
            let sizeTransform = CGAffineTransform(scaleX: magRatioW, y: magRatioH)
            let positionTransform = CGAffineTransform(translationX: moveX, y: moveY)
            weakself.contentsView.transform = sizeTransform.concatenating(positionTransform)
            
            weakself.overlayView.blurringView.alpha = 1
            weakself.overlayView.colorView.alpha = 1
            
            }, completion: { [weak self] _ in
                guard let weakself = self else {
                    return
                }
                
                weakself.contentsView.play()
                weakself.isAnimation = false
                
                weakself.contentsView.transform = CGAffineTransform.identity
                weakself.contentsView.frame.size = animatedSize
                weakself.contentsView.center = weakself.bounds.center
        })
    }
    
    func dismiss(isPanUpward: Bool, completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.3, animations: {
            var movieViewCenter = -self.contentsView.frame.height/2
            if isPanUpward {
                movieViewCenter = self.frame.height + self.contentsView.frame.height/2
            }
            self.contentsView.center.y = movieViewCenter
            
            self.overlayView.blurringView.alpha = 0
            self.overlayView.colorView.alpha = 0
            
            self.closeButton.alpha = 0
        }) { _ in
            completion()
        }
    }
    
    func initOverlayView() {
        overlayView.bounds.size = UIScreen.main.bounds.insetBy(dx: -UIScreen.main.bounds.width / 2, dy: -UIScreen.main.bounds.height / 2).size
        
        overlayView.center = bounds.center
        insertSubview(overlayView, at: 0)
    }
    
    func conformBlurToSwipe() {
        let distanceToCenter: CGFloat = fabs(frame.height / 2 - contentsView.center.y)
        let distanceRatio: CGFloat = distanceToCenter / (frame.height)
        
        self.overlayView.blurringView.alpha = 1 - distanceRatio
        self.overlayView.colorView.alpha = 1 - distanceRatio
    }
    
    func returnMovieViewCenter() {
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.contentsView.center.y = self.frame.height/2
            self.overlayView.blurringView.alpha = 1
            self.overlayView.colorView.alpha = 1
        }, completion: nil)
    }
    
    func isMovie() -> Bool {
        return contentsView.isVideo()
    }
    
// MARK: - private func
    private func displacementTargetSize(forSize size: CGSize) -> CGSize {

        let boundingSize = rotationAdjustedBounds().size

        return aspectFitSize(forContentOfSize: size, inBounds: boundingSize)
    }
    
    private func rotationAdjustedBounds() -> CGRect {
        let applicationWindow = UIApplication.shared.delegate?.window?.flatMap { $0 }
        guard let window = applicationWindow else { return UIScreen.main.bounds }
        
        return window.bounds
    }
    
    private func aspectFitSize(forContentOfSize contentSize: CGSize, inBounds bounds: CGSize) -> CGSize {
        
        return AVMakeRect(aspectRatio: contentSize, insideRect: CGRect(origin: CGPoint.zero, size: bounds)).size
    }
    
}
