//
//  ProperMediaObject.swift
//  ProperMediaViewDemo
//
//  Created by Murawaki on 2017/03/30.
//  Copyright © 2017年 Murawaki. All rights reserved.
//

import Foundation
import UIKit

public protocol ProperMedia {
    var placeHolder: UIImage? { get }
    var thumbnailImageUrl: URL { get }
    var mediaUrl: URL { get }
    var isMovie: Bool { get }
}

public struct ProperImage: ProperMedia {
    public var placeHolder: UIImage?
    public var thumbnailImageUrl: URL
    public var mediaUrl: URL
    public var isMovie: Bool

    public init(thumbnailUrl: URL, originalImageUrl: URL, placeHolder: UIImage? = nil) {
        self.thumbnailImageUrl = thumbnailUrl
        self.mediaUrl = originalImageUrl
        self.isMovie = false
    }
    
    public init(thumbnailUrlStr: String, originalImageUrlStr: String, placeHolder: UIImage? = nil) {
        if let thumbnailUrl = URL(string: thumbnailUrlStr) {
            self.thumbnailImageUrl = thumbnailUrl
        } else {
            self.thumbnailImageUrl = URL(string: "https://www.google.co.jp/logos/doodles/2017/sergei-diaghilevs-145th-birthday-5691313237262336-hp.jpg")!
            print("thumbnailUrlStr is could'n convert URL")
        }

        if let originalImageUrl = URL(string: originalImageUrlStr) {
            self.mediaUrl = originalImageUrl
        } else {
            self.mediaUrl = URL(string: "https://www.google.co.jp/logos/doodles/2017/sergei-diaghilevs-145th-birthday-5691313237262336-hp.jpg")!
            print("originalImageUrlStr is could'n convert URL")
        }
        
        self.isMovie = false
    }
}

public struct ProperMovie: ProperMedia {
    public var placeHolder: UIImage?
    public var thumbnailImageUrl: URL
    public var mediaUrl: URL
    public var isMovie: Bool
    
    public init(thumbnailUrl: URL, movieUrl: URL, placeHolder: UIImage? = nil) {
        self.thumbnailImageUrl = thumbnailUrl
        self.mediaUrl = movieUrl
        self.isMovie = true
    }
    
    public init(thumbnailUrlStr: String, movieUrlStr: String, placeHolder: UIImage? = nil) {
        
        if let thumbnailUrl = URL(string: thumbnailUrlStr) {
            self.thumbnailImageUrl = thumbnailUrl
        } else {
            self.thumbnailImageUrl = URL(string: "https://www.google.co.jp/logos/doodles/2017/sergei-diaghilevs-145th-birthday-5691313237262336-hp.jpg")!
            print("thumbnailUrlStr is could'n convert URL")
        }
        
        if let movieUrl = URL(string: movieUrlStr) {
            self.mediaUrl = movieUrl
        } else {
            self.mediaUrl = URL(string: "https://www.google.co.jp/logos/doodles/2017/sergei-diaghilevs-145th-birthday-5691313237262336-hp.jpg")!
            print("movieUrlStr is could'n convert URL")
        }
        
        self.isMovie = true
    }
}
