//
//  InfoViewController.swift
//  Blackjact
//
//  Created by PVZS on 11/30/19.
//  Copyright © 2020 SanzharIndustries. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {
    // MARK:- Properties
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var pageControl: UIPageControl!
    @IBOutlet weak var textView: UITextView!
    
    
    // MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.text = Content.infoText
    }
    
    
    // MARK:- Actions
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}


extension InfoViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reuseID", for: indexPath) as! ImageCollectionViewCell
        cell.imageName = Content.portraits[indexPath.row]
        return cell
    }
}

extension InfoViewController: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
}

extension InfoViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
}
