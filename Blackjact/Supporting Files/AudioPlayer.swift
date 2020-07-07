/*
 * Qulynym
 * AudioPlayer.swift
 *
 * Created by: Metah on 2/24/19
 *
 * Copyright © 2019 Automatization X Software. All rights reserved.
*/

import Foundation
import AVFoundation

struct AudioPlayer {
    // MARK:- Properties
    static var backgroundAudioPlayer = AVAudioPlayer()
    static var wellDoneAudioPlayer = AVAudioPlayer()
    static var tryAgainAudioPlayer = AVAudioPlayer()
    
 
    // MARK:- Background Audio
    static func initBackgroundAudioPlayer() {
        initPlayer(didWin: nil)
        backgroundAudioPlayer.numberOfLoops = -1
        backgroundAudioPlayer.volume = 0.1
    }
    
    static func initTryAgainAudio() {
        initPlayer(didWin: false)
    }
    static func initWellDoneAudio() {
        initPlayer(didWin: true)
    }
    
    private static func initPlayer(didWin: Bool?) {
        if let didWin = didWin {
            let name = didWin ? "wellDone" : "tryAgain"
            let url = setupPaths(name: name)
            
            if didWin {
                initPlayers(player: &wellDoneAudioPlayer, url: url)
            } else {
                initPlayers(player: &tryAgainAudioPlayer, url: url)
            }
        } else {
            let url = setupPaths(name: "Sangiccc")
            initPlayers(player: &backgroundAudioPlayer, url: url)
        }
    }
    
    
    // MARK:- Extra Audios
    private static func setupPaths(name: String) -> URL {
        let filePath = Bundle.main.path(forResource: name, ofType: "mp3")
        let url = URL.init(fileURLWithPath: filePath!)
        return url
    }
    
    private static func initPlayers(player: inout AVAudioPlayer, url: URL) {
        do {
            player = try AVAudioPlayer(contentsOf: url)
        } catch {
            return 
        }
    }
}
