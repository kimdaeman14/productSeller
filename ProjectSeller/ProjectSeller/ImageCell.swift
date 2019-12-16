//
//  ImageCell.swift
//  kimjongchan
//
//  Created by Jaycee on 2019/12/11.
//  Copyright © 2019 Jaycee. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    static let reusableIdentifier = "ImageCell"
    static let nibName = "ImageCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code 
    }
    
}
