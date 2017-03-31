//
//  ViewController.swift
//  ProperMediaViewDemo
//
//  Created by Murawaki on 2017/03/30.
//  Copyright © 2017年 Murawaki. All rights reserved.
//

import UIKit
import SDWebImage

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*Debug
        let webImageCache = SDImageCache.shared()
        webImageCache.clearMemory()
        webImageCache.clearDisk {}*/
       
        //Image
        let imageMedia = ProperImage(thumbnailUrl: URL(string: "https://i.gyazo.com/f4f9410028b33650b7f2f0c76e3e82ff.png")!,
                                originalImageUrl: URL(string: "https://i.gyazo.com/f32151613b826dec8faab456f1d6e8b6.png")!)
        let imageMediaView = ProperMediaView(frame: CGRect(x: 0, y: 0, width: 200, height: 200), media: imageMedia, isNeedsDownloadOriginalImage: true)
        imageMediaView.setEnableFullScreen(fromViewController: self)
        
        //Movie
        let movieMedia = ProperMovie(thumbnailUrlStr: "https://i.gyazo.com/f4f9410028b33650b7f2f0c76e3e82ff.png",
                                     movieUrlStr: "http://img.profring.com/medias/4813cacbc19667eacb05c8705d9db7a5120832mnKcTmYOH8XiszVsaTMuohH8ovnCXSsH.mp4")
        let movieMediaView = ProperMediaView(frame: CGRect(x: 0, y: 0, width: 200, height: 200), media: movieMedia)
        movieMediaView.setEnableFullScreen(fromViewController: self)
        
        imageMediaView.center = view.center
        imageMediaView.center.y -= 150
        
        movieMediaView.center = view.center
        movieMediaView.center.y += 150
        
        view.addSubview(imageMediaView)
        view.addSubview(movieMediaView)
        
        //再生が開始されてからDLが始まる
        movieMediaView.play()
    }
}

