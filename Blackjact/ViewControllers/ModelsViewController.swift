//
//  ModelsViewController.swift
//  Blackjact
//
//  Created by PVZS on 11/30/19.
//  Copyright © 2020 SanzharIndustries. All rights reserved.
//

import UIKit

class ModelsViewController: UIViewController {
    // MARK:- Properties
    @IBOutlet private weak var collectionView: UICollectionView!
    var model = ""
    
    
    // MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    
    // MARK:- Actions
    @IBAction private func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard segue.identifier == "startTheGame" else { return }
        var gameVCProtocol: GameVCProtocol!
        gameVCProtocol = segue.destination as! GameViewController
        gameVCProtocol.model = self.model
    }
}


extension ModelsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Content.models.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reuseID", for: indexPath) as! ImageDetailCollectionViewCell
        cell.layer.cornerRadius = 5
        
        let model = Content.models[indexPath.row]
        cell.imageName = model
        cell.title = model
        return cell
    }
}

extension ModelsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        model = Content.models[indexPath.row]
        self.performSegue(withIdentifier: "startTheGame", sender: nil)
    }
}

extension ModelsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let constant = collectionView.frame.width * 0.5 - 15
        return CGSize(width: constant, height: constant)
    }
}
