//
//  CollectionViewCells.swift
//  Blackjact
//
//  Created by Metah on 6/14/20.
//  Copyright © 2020 Askar Almukhamet. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    // MARK:- Properties
    var imageName: String! {
        didSet {
            imageView.image = UIImage(named: imageName)
        }
    }
    @IBOutlet private weak var imageView: UIImageView!
}

class ImageDetailCollectionViewCell: ImageCollectionViewCell {
    // MARK:- Properties
    var title: String! {
        didSet {
            titleLabel.text = title
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel!
}
