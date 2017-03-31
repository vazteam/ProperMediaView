//
//  ProperMediaViewController.swift
//  ProperMediaView
//
//  Created by Murawaki on 2017/02/19.
//  Copyright © 2017年 Murawaki. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

extension ProperMediaFullScreenView {
    public static func show(mediaView: ProperMediaView, fromViewController: UIViewController) {
        let mediaFullScreenVc = ProperMediaFullScreenViewController(mediaView: mediaView)
        fromViewController.present(mediaFullScreenVc, animated: false, completion: nil)
    }
}

class ProperMediaFullScreenViewController: UIViewController {
    var mediaView: ProperMediaFullScreenView
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    init(mediaView: ProperMediaView) {
        self.mediaView = ProperMediaFullScreenView(displacedMediaView: mediaView)
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationCapturesStatusBarAppearance = true
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
// MARK: - override UIViewController method
    override func loadView() {
        self.view = mediaView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mediaView.closeButton.addTarget(self, action: #selector(self.closeButtonTouchUppedInside), for: .touchUpInside)
        mediaView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.mediaViewPanGestured(gesture:))))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mediaView.initOverlayView()
        mediaView.present()
        
        if mediaView.isMovie() {
            AVAudioSession.setVolumeWhenMannerMode(isVolume: true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        AVAudioSession.setVolumeWhenMannerMode(isVolume: false)
    }
    
    func configureMediaView(velocityY: CGFloat) {
        if fabs(velocityY) > 750 {
            mediaView.dismiss(isPanUpward: velocityY > 0, completion: {
                self.dismiss(animated: false, completion: nil)
            })
        } else {
            mediaView.returnMovieViewCenter()
        }
    }
    
// MARK: - Action
    func closeButtonTouchUppedInside() {
        mediaView.dismiss(isPanUpward: true, completion: {
            self.dismiss(animated: false, completion: nil)
        })
    }
    
    func mediaViewPanGestured(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .changed:
            let point: CGPoint = gesture.translation(in: self.view)
            let moveView: UIView = mediaView.contentsView
            let movedPoint: CGPoint = CGPoint(x: moveView.center.x, y: moveView.center.y + point.y)
            moveView.center = movedPoint
            gesture.setTranslation(CGPoint.zero, in: self.view)
            
            mediaView.conformBlurToSwipe()
            
        case .ended:
            configureMediaView(velocityY: gesture.velocity(in: mediaView).y)
            
        case .cancelled:
            mediaView.returnMovieViewCenter()
            
        default:
            break
        }
        
    }
}
