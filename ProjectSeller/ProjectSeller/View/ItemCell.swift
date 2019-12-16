//
//  ImageCell.swift
//  PageControl(ProgressBar)
//
//  Created by Jaycee on 2019/12/08.
//  Copyright © 2019 Jaycee. All rights reserved.
//

import UIKit

class ItemCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!

    static let reusableIdentifier = "ItemCell"
    static let nibName = "ItemCell"
           
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .white
        self.imageView.layer.cornerRadius = 14       
        self.imageView.clipsToBounds = true
        self.imageView.layer.borderWidth = 1
        self.imageView.layer.borderColor = UIColor.darkBlueGrey.cgColor
        
        
        self.title.numberOfLines = 2
        self.title.textColor = .black
        self.title.adjustsFontSizeToFitWidth = true
        self.title.adjustsFontSizeToFitWidth = true

        self.subtitle.numberOfLines = 1
        self.subtitle.textColor = .darkGray
        self.subtitle.adjustsFontSizeToFitWidth = true

    }

}
