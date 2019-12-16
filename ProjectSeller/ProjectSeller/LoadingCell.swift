//
//  LoadingCell.swift
//  kimjongchan
//
//  Created by Jaycee on 2019/12/11.
//  Copyright © 2019 Jaycee. All rights reserved.
//

import UIKit

class LoadingCell: UICollectionViewCell {
    @IBOutlet weak var myIndicator: UIImageView!
    static let reusableIdentifier = "LoadingCell"
    static let nibName = "LoadingCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

public extension UIImageView {
    
    func spin(repeatCount: Float) {
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.fromValue = 0
        rotation.toValue = 5 * Double.pi
        rotation.duration = 0.5
        rotation.repeatCount = repeatCount
        layer.add(rotation, forKey: "spin")
    }
    
    func stopSpinning() {
        layer.removeAllAnimations()
    }
    
}
