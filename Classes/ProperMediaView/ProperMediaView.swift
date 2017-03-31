//
//  ProperMoviePlayView.swift
//  ProperNowDetailViewController
//
//  Created by Murawaki on 2017/01/30.
//  Copyright © 2017年 VAZ inc. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

import SDWebImage

@objc protocol ProperMediaViewDelegate: class {
    @objc optional func moviePlayViewVolumeChanged(isVolume: Bool)
}

public class ProperMediaView: UIView {
    @IBOutlet weak var playerView: AVPlayerView!
    @IBOutlet weak var imageView: ProgressImageView!
    @IBOutlet weak var topProgressView: UIProgressView!
    @IBOutlet weak var bottomProgressView: UIView!
    @IBOutlet weak var operationAreaView: UIView!
    @IBOutlet weak var replayButton: UIButton!
    @IBOutlet weak var playAndPauseButton: UIButton!
    @IBOutlet weak var bottomOperateStackView: UIStackView!
    @IBOutlet weak var playTimeLabel: UILabel!
    @IBOutlet weak var laodingProgressView: UIProgressView!
    @IBOutlet weak var seekSlider: UISlider!
    @IBOutlet weak var durationTimeLabel: UILabel!
    @IBOutlet weak var volumeButton: UIButton!
    @IBOutlet weak var translucentView: UIView!
    
    var media: ProperMedia
    var isNeedsDownloadOriginal: Bool = false
    var isLoadedOriginalImage: Bool = false
    var isPlaying: Bool = false
    var isFullScreen: Bool
    var isPlayWaiting: Bool = false
    var progressColor: UIColor {
        didSet{
            self.topProgressView.progressTintColor = progressColor
            self.seekSlider.minimumTrackTintColor = progressColor
        }
    }
    
    weak var delegate: ProperMediaViewDelegate?
    private weak var fromViewController: UIViewController?
    
    var videoPlayer: AVPlayer!
    fileprivate var playerItem: AVPlayerItem?
    fileprivate var isPausedBySeekSlider: Bool = false
    fileprivate var isFullScreenViewFetchWaiting: Bool = false
    fileprivate var currentImageUrl: URL?
    
    var displaceMovieView: ProperMediaView!
    
    private var movieDurationSeconds: Double {
        var dutarion: CMTime = kCMTimeZero
        if let videoDuration = self.videoPlayer.currentItem?.duration {
            dutarion = videoDuration
        }
        return CMTimeGetSeconds( dutarion )
    }
    
    private var isShowPlayingOperaters: Bool {
        return bottomOperateStackView.alpha == 1.0
    }
    
    private var isShowEndedOperaters: Bool {
        return replayButton.alpha == 1.0
    }
    
    private var bounceAnimation: CAKeyframeAnimation {
        let anim = CAKeyframeAnimation(keyPath: "transform.scale")
        anim.duration = 0.3
        anim.values = [0.6, 1.2, 1, 1.1, 1]
        anim.keyTimes = [0, 0.4, 0.6, 0.8, 1.0]
        return anim
    }
    
    public init(frame: CGRect, media: ProperMedia, isNeedsDownloadOriginalImage: Bool = false, isFullScreen: Bool = false) {
        self.media = media
        self.isFullScreen = isFullScreen
        self.progressColor = UIColor(red:0.92, green:0.26, blue:0.21, alpha:1.00)
        self.isNeedsDownloadOriginal = isNeedsDownloadOriginalImage
        
        super.init(frame: frame)
        
        commonInit()
        fetchContent(media: media)
    }
    
    public convenience init(frame: CGRect, media: ProperMedia, videoPlayer: AVPlayer) {
        self.init(frame: frame, media: media)
        
        self.media = media
        self.isFullScreen = true
        self.videoPlayer = videoPlayer
        self.playerItem  = videoPlayer.currentItem
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("ProperMediaView can't init from nib")
    }
    
    private func commonInit() {
        self.backgroundColor = UIColor.clear
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "ProperMediaView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        addSubview(view)
        
		view.translatesAutoresizingMaskIntoConstraints = false
		let bindings = ["view": view]
		addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
		                                              options:NSLayoutFormatOptions(rawValue: 0),
		                                              metrics:nil,
		                                              views: bindings))
		addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",
		                                              options:NSLayoutFormatOptions(rawValue: 0),
		                                              metrics:nil,
		                                              views: bindings))
        
        //下のビューのグラデーション
        let bottomColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        let gradientColors: [CGColor] = [UIColor.clear.cgColor, bottomColor.cgColor]
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.frame = self.bottomOperateStackView.bounds
        self.bottomOperateStackView.layer.insertSublayer(gradientLayer, at: 0)
        
        self.translucentView.alpha = 0
        self.bottomOperateStackView.isUserInteractionEnabled = true
        self.operationAreaView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tappedOperationAreaView(gesture:))))
        self.seekSlider.setThumbImage(#imageLiteral(resourceName: "icon_sliderThumb").resizeImage(size: CGSize(sideLength: 17)), for: .normal)
        
        self.dissmissMovieEndedOperaters()
        self.dismissMoviePlayingOperaters()
        self.layer.masksToBounds = true
    }
    
    deinit {
        if self.videoPlayer != nil {
            self.videoPlayer.pause()
            self.videoPlayer = nil
        }
        
        self.playerItem = nil
    }
    
// MARK: - public func
    public func fetchContent(media: ProperMedia) {
        removeVideoItems()
        
        self.media = media
        
        if !media.isMovie {
            //画像の時
            imageView.dismissLoading()
            topProgressView.isHidden = true
            playerView.isHidden = true
            bottomProgressView.isHidden = true
        } else {
            //動画のとき
            imageView.showLoading()
            topProgressView.isHidden = false
            playerView.isHidden = false
            bottomProgressView.isHidden = false
        }
        
        self.superview?.layoutIfNeeded()

        if self.playerItem != nil {
            if let currentUrl: URL = (videoPlayer.currentItem?.asset as? AVURLAsset)?.url {
                if media.mediaUrl == currentUrl {
                    return
                }
            }
        }
        
        
        self.seekSlider.maximumTrackTintColor = UIColor.clear
        self.laodingProgressView.trackTintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        self.laodingProgressView.setProgress(0, animated: false)
        
        startDownloadImage()
    }
    
    //フルスクリーン時に複製される時用　（動画
    func fetchContent(media: ProperMedia, player: AVPlayer, fullScreen: Bool) {
        fetchContent(media: media)
        videoPlayer = player
        isFullScreen = fullScreen
        topProgressView.isHidden = true
        
        whenReadyToPlay()
    }
    
    //フルスクリーン時に複製される時用　（画像
    func fetchContent(media: ProperMedia, originalImage: UIImage?) {
        self.media = media
        isFullScreen = true
        isNeedsDownloadOriginal = true
        imageView.dismissLoading()
        topProgressView.isHidden = true
        playerView.isHidden = true
        
        if let originalImage: UIImage = originalImage {
            self.imageView.image = originalImage
            self.isLoadedOriginalImage = true
            return
        }
        
        startDownloadImage()
    }
    
    public func setEnableFullScreen(fromViewController: UIViewController) {
        self.fromViewController = fromViewController
    }
    
    public func play() {
        guard isVideo() else {
            return
        }
        
        ifNeedStartDownload()
        
        if self.videoPlayer != nil {
            self.videoPlayer.play()
            self.isPlaying = true
            self.isPlayWaiting = false
            self.isPausedBySeekSlider = false
            
            let duration = CMTimeGetSeconds((videoPlayer.currentItem?.asset.duration)!)
            self.durationTimeLabel.text = self.stringFromSeconds(seconds: duration)
            
            DispatchQueue.main.async {
                self.playAndPauseButton.setBackgroundImage(#imageLiteral(resourceName: "btn_movie_pause"), for: .normal)
                self.dismissMoviePlayingOperaters(animation: true)
                //フルスクリーンなら音声を入れる
                AVAudioSession.setVolumeWhenMannerMode(isVolume: self.isFullScreen && self.isVideo())
            }
        } else {
            isPlayWaiting = true
        }
        
    }
    
    public func pause() {
        if self.videoPlayer == nil && !isPlaying {
            return
        }
        videoPlayer.pause()
        isPlaying = false
        self.playAndPauseButton.setBackgroundImage(#imageLiteral(resourceName: "btn_movie_play"), for: .normal)
    }
    
    public func playOrPause() {
        if isPlaying {
            self.pause()
        } else {
            self.play()
        }
    }
    
    public func changeVolume(isVolume: Bool) {
        guard self.videoPlayer != nil else {
            return
        }
        
        if isVolume {
            self.volumeButton.setImage(#imageLiteral(resourceName: "volume_off"), for: .normal)
            self.videoPlayer.volume = 0
        } else {
            self.volumeButton.setImage(#imageLiteral(resourceName: "volume_on"), for: .normal)
            self.videoPlayer.volume = 1.0
        }
        self.delegate?.moviePlayViewVolumeChanged?(isVolume: isVolume)
    }
    
    //ビューの状態を保ったまま渡すために複製
    func initDisplacement() -> ProperMediaView {
        displaceMovieView = ProperMediaView(frame: CGRect.zero, media: media)
        
        displaceMovieView.bounds = self.bounds
        displaceMovieView.center = self.center
        displaceMovieView.delegate = self.delegate
        displaceMovieView.layer.masksToBounds = true
        
        //動画の時
        if isVideo() {
            if videoPlayer != nil {
                displaceMovieView.fetchContent(media: media, player: videoPlayer, fullScreen: true)
            } else {
                displaceMovieView.fetchContent(media: media)
            }
            return displaceMovieView
        }
        
        //画像のとき
        if isLoadedOriginalImage {
            displaceMovieView.fetchContent(media: media, originalImage: imageView.image)
            return displaceMovieView
        }
        
        displaceMovieView.fetchContent(media: media, originalImage: nil)
        return displaceMovieView
    }
    
    public func isVideo() -> Bool {
        return media.isMovie
    }
    
// MARK: - private func
    private func removeVideoItems() {
        pause()
        dissmissMovieEndedOperaters()
        playerItem?.removeObserver(self, forKeyPath: "status")
        
        videoPlayer = nil
        playerItem = nil
        isPlayWaiting = false
    }
    
    private func startDownloadImage() {
        if let currentImageUrl = self.currentImageUrl,
            currentImageUrl == media.mediaUrl {
                return
        }
        
        imageView.sd_setImage(with: media.thumbnailImageUrl, placeholderImage: #imageLiteral(resourceName: "default_image"), options: .allowInvalidSSLCertificates) { (image, error, cacheType, url) in
            //サムネイルだけでなく、オリジナルサイズの画像もダウンロードする場合は続行
            if !self.isNeedsDownloadOriginal {
                return
            }
            
            self.topProgressView.isHidden = false
            self.topProgressView.progress = 0.0
            self.topProgressView.progressTintColor = self.progressColor
            
            self.translucentView.alpha = 1.0
            
            self.imageView.sd_setImage(with: self.media.mediaUrl, placeholderImage: self.imageView.image, progress: { (done, entity, url) in
                DispatchQueue.main.async {
                    var progress: Float = 0
                    if done > 0 {
                        progress = Float(entity/done)
                    }
                    self.topProgressView.setProgress(progress, animated: true)
                }
            }) { (image, error, cachType, url) in
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.2, animations: {
                        self.translucentView.alpha = 0
                    }, completion: { _ in
                        self.isLoadedOriginalImage = true
                        self.topProgressView.isHidden = true
                        self.currentImageUrl = self.media.mediaUrl
                    })
                }
            }
        }
    }
    
    private func startDownloadMovie() {
        let avAsset = AVURLAsset(url: media.mediaUrl, options: nil)
        avAsset.loadValuesAsynchronously(forKeys: ["tracks"], completionHandler: {
            DispatchQueue.main.async {
                var error: NSError?
                let status = avAsset.statusOfValue(forKey: "tracks", error: &error)
                
                if status == .loaded {
                    self.playerItem = AVPlayerItem(asset: avAsset)
                    self.playerItem?.addObserver(self, forKeyPath: "status", options:[.new, .initial], context: nil)
                    self.videoPlayer = AVPlayer(playerItem: self.playerItem)
                } else {
                    if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }
        })
    }
    
    private func updateFirstLoadingProgress() {
        if self.videoPlayer == nil {
            //前半50%は見た目だけ
            let currentProgress = self.topProgressView.progress
            let randomAddProgress = (arc4random() % 20)
            var nextProgress = currentProgress + Float(randomAddProgress)/1000
            if nextProgress > 0.5 {
                nextProgress = 0.5
            }
            DispatchQueue.main.async {
                self.topProgressView.progress = nextProgress
            }
        } else {
            //残りの50%は進捗に合わせる
            if let loadedTimeRangeDuration = playerItem?.loadedTimeRanges.first?.timeRangeValue.duration {
                let loadedRatio = loadedTimeRangeDuration.seconds / 5.0
                self.topProgressView.setProgress(Float(loadedRatio * 0.5) + 0.5, animated: true)
            }
        }
    
        if self.isPlaying { //再生が始まったら隠す
            self.topProgressView.setProgress(1.0, animated: true)
            UIView.animate(withDuration: 0.3, animations: { 
                self.topProgressView.alpha = 0
            })
        } else {  //再生が始まっていなければ再帰的に繰り返す
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
                 self.updateFirstLoadingProgress()
            }
        }
    }
    
    private func ifNeedStartDownload() {
        if videoPlayer == nil && !isPlayWaiting {
            self.updateFirstLoadingProgress()
            self.startDownloadMovie()
        }
    }
    
    private func showMoviePlayingOperaters() {
        if !isFullScreen {
            return
        }
        
        UIView.animate(withDuration: 0.3) {
            self.bottomOperateStackView.alpha = 1.0
            self.playAndPauseButton.alpha = 1.0
        }
    }
    
    private func dismissMoviePlayingOperaters(animation: Bool = false) {
        var duration: Double = 0
        if animation {
            duration = 0.3
        }
        UIView.animate(withDuration: TimeInterval(duration)) { 
            self.bottomOperateStackView.alpha = 0
            self.playAndPauseButton.alpha = 0
        }
    }
    
    @objc private func showMovieEndedOperaters() {
        self.dismissMoviePlayingOperaters(animation: true)
        UIView.animate(withDuration: 0.3) {
            self.operationAreaView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            self.replayButton.transform = CGAffineTransform.identity
            self.replayButton.alpha = 1.0
        }
    }
    
    private func dissmissMovieEndedOperaters(animation: Bool = false) {
        var duration: Double = 0
        if animation {
            duration = 0.3
        }
        UIView.animate(withDuration: TimeInterval(duration)) {
            self.operationAreaView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.replayButton.transform = CGAffineTransform(translationX: 0, y: 15)
            self.replayButton.alpha = 0.0
        }
    }
    
    //ex: (125) -> "02:05"
    private func stringFromSeconds(seconds: Double) -> String {
        if seconds > 0 {
            let minStr = NSString(format: "%02d", Int(seconds) / 60)
            let secStr = NSString(format: "%02d", Int(seconds) % 60)
            return (minStr as String) + ":" + (secStr as String)
        }
        
        return "00:00"
    }
    
   // MARK: - Observer & Notification
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "status" {
            let status: AVPlayerItemStatus? = self.playerItem?.status
            
            if status == .readyToPlay {
                print("status readyToPlay")
                whenReadyToPlay()
                return
            } else if status == .unknown {
                print("status unknown")
            } else if status == .failed {
                print("status failed")
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    private func whenReadyToPlay() {
        guard videoPlayer != nil else {
            return
        }
        
        let layer = self.playerView.layer as! AVPlayerLayer
        layer.videoGravity = AVLayerVideoGravityResizeAspect
        layer.player = self.videoPlayer
        
        //再生時間の同期
        let timeInterval: CMTime = CMTimeMakeWithSeconds(0.05, Int32(NSEC_PER_SEC))
        self.videoPlayer.addPeriodicTimeObserver(forInterval: timeInterval, queue: nil) { (_) -> Void in
            self.whenMoviePlayingPeriodic()
        }
        
        //最後まで再生した時のNotification
        NotificationCenter.default.addObserver(self, selector: #selector(self.showMovieEndedOperaters), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerItem)
        
        self.playerView.backgroundColor = UIColor.black
        
        if isFullScreenViewFetchWaiting {
            displaceMovieView.fetchContent(media: media, player: videoPlayer, fullScreen: true)
        }
        
        if isPlayWaiting {
            DispatchQueue.main.async {
                self.play()
            }
        }
    }
    
    //再生時の同期
    private func whenMoviePlayingPeriodic() {
        guard isPlaying else {
            return
        }
        
        let time = CMTimeGetSeconds(self.videoPlayer.currentTime())
        let ratio = time / movieDurationSeconds
        
        //playTimeLabel
        self.playTimeLabel.text = stringFromSeconds(seconds: time)
        
        //movieSlider
        self.seekSlider.value = Float(ratio)
        
        //bottomProgress
        let lineWidth: CGFloat = 3.0
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0)
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: self.bounds.height - lineWidth/2))
        path.addLine(to: CGPoint(x: self.bounds.width * CGFloat(ratio), y: self.bounds.height - lineWidth/2))
        if isShowEndedOperaters {
            UIColor.clear.setStroke()
        } else {
            progressColor.setStroke()
        }
        
        path.lineWidth = lineWidth
        path.stroke()
        bottomProgressView.layer.contents = UIGraphicsGetImageFromCurrentImageContext()?.cgImage
        UIGraphicsEndImageContext()
        
        //Operator
        if isShowEndedOperaters {
            dissmissMovieEndedOperaters(animation: true)
        }
        
        //loading Progress
        guard let currentItem = videoPlayer.currentItem else {
            return
        }
        
        if let loadedTimeRangeDuration = currentItem.loadedTimeRanges.first?.timeRangeValue.duration {
            let ratio = loadedTimeRangeDuration.seconds / currentItem.asset.duration.seconds
            self.laodingProgressView.setProgress(Float(ratio), animated: false)
        }
    }
    
    @IBAction func touchUppedReplayButton(_ sender: UIButton) {
        if videoPlayer == nil {
            return
        }
            
        videoPlayer.seek(to: CMTimeMakeWithSeconds(0, Int32(NSEC_PER_SEC)))
        videoPlayer.play()
        dissmissMovieEndedOperaters(animation: true)
    }
    
    @IBAction func touchDownedLikeButton(_ sender: UIButton) {
        sender.imageView?.layer.add(self.bounceAnimation, forKey: "TouchDownLikeButton")
    }
    
    @IBAction func touchDownedReplayButton(_ sender: UIButton) {
        let anim = CABasicAnimation(keyPath: "transform.rotation")
        anim.duration = 0.5
        anim.toValue = -Double.pi / 2
        sender.imageView?.layer.add(anim, forKey: "TouchDownReplayButton")
    }
    
    @IBAction func touchUppedPlayAndPauseButton(_ sender: UIButton) {
        self.playOrPause()
        sender.layer.add(self.bounceAnimation, forKey: "TouchUppedPlayAndPauseButtonAnimation")
    }
    
    @IBAction func touchUppedVolumeButton(_ sender: UIButton) {
        guard self.videoPlayer != nil else {
            return
        }
        
        if self.videoPlayer.volume == 0 {
            self.changeVolume(isVolume: false)
        } else {
            self.changeVolume(isVolume: true)
        }
    }
    
    @IBAction func touchDownedSeekSlider(_ sender: UISlider) {
        if isPlaying {
            self.pause()
            self.isPausedBySeekSlider = true
        }
    }
    
    @IBAction func touchUpInsideSeekSlider(_ sender: UISlider) {
        if isPausedBySeekSlider {
            self.play()
        }
    }
    
    @IBAction func touchUpOutsideSeekSlider(_ sender: UISlider) {
        if isPausedBySeekSlider {
            self.play()
        }
    }
    
    @IBAction func valueChangedSeekSlider(_ sender: UISlider) {
        let seekSeconds = CMTimeMakeWithSeconds(movieDurationSeconds*Double(sender.value), Int32(NSEC_PER_SEC))
        videoPlayer.seek(to: seekSeconds, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
    }
    
    func tappedOperationAreaView(gesture: UITapGestureRecognizer) {
        if !isFullScreen {
            if let vc: UIViewController = fromViewController {
                ProperMediaFullScreenView.show(mediaView: self, fromViewController: vc)
            }
        }
        
        if isShowPlayingOperaters {
            dismissMoviePlayingOperaters(animation: true)
        } else {
            if !isShowEndedOperaters && isVideo() {
                showMoviePlayingOperaters()
            }
        }
    }
}
