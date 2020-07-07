//
//  EntryViewController.swift
//  Blackjact
//
//  Created by Metah on 6/16/20.
//  Copyright © 2020 Askar Almukhamet. All rights reserved.
//

import UIKit

class EntryViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        AudioPlayer.initBackgroundAudioPlayer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AudioPlayer.backgroundAudioPlayer.play()
    }
}
