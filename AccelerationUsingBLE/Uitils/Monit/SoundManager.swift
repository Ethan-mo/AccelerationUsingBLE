//
//  SoundManager.swift
//  Monit
//
//  Created by john.lee on 2018. 5. 10..
//  Copyright © 2018년 맥. All rights reserved.
//

import Foundation
import AVFoundation

class SoundManager {
    static var m_instance: SoundManager!
    static var instance: SoundManager {
        get {
            if (m_instance == nil) {
                m_instance = SoundManager()
            }
            
            return m_instance
        }
    }
    
    var player: AVAudioPlayer?
    
    func playSound(name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)

            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            
            guard let player = player else { return }
            
            player.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func playRingtoneSound(name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else { return }
        var soundId:SystemSoundID = 0
        AudioServicesCreateSystemSoundID(url as CFURL, &soundId)
        AudioServicesPlaySystemSound(soundId)
    }
}
