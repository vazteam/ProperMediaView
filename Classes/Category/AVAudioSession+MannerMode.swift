//
//  AVAudioSession+mannerModeVolume.swift
//  PROF
//
//  Created by Murawaki on 2017/02/27.
//  Copyright © 2017年 VAZ inc. All rights reserved.
//

import Foundation
import AVFoundation

extension AVAudioSession {
    
    static func setVolumeWhenMannerMode(isVolume: Bool) {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            if isVolume {
                //マナーモード時出力 + 音楽割り込み
                try audioSession.setCategory(AVAudioSessionCategoryPlayback, with: .defaultToSpeaker)
                try audioSession.setActive(true)
                
            } else {
                //マナーモード非出力 + 音楽割り込みなし
                try audioSession.setCategory(AVAudioSessionCategoryAmbient, with: .defaultToSpeaker)
                try audioSession.setActive(false)
            }
        } catch {
            let audioSessionSetEroor = NSError(domain: "AVAudioSession Set faild", code: -1, userInfo: nil)
            print(audioSessionSetEroor.localizedDescription)
        }
    }
}
