//
//  Extension+UIColor.swift
//  kimjongchan
//
//  Created by Jaycee on 2019/12/13.
//  Copyright © 2019 Jaycee. All rights reserved.
//

import UIKit

public func colorFromDecimalRGB(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, alpha: CGFloat = 1.0) -> UIColor {
    return UIColor(
        red: red / 255.0,
        green: green / 255.0,
        blue: blue / 255.0,
        alpha: alpha
    )
}
// MARK: Custom Defined Colors
extension UIColor {
    class var coralPink: UIColor {
        return colorFromDecimalRGB(255, 88, 108)
    }
    
    class var dark: UIColor {
        return colorFromDecimalRGB(20, 20, 40)
    }
    
    class var darkAlpha: UIColor {
        return colorFromDecimalRGB(20, 20, 20, alpha: 0.16)
       }
    
    class var blueyGrey: UIColor {
        return colorFromDecimalRGB(171, 171, 196)
    }
    
    class var darkBlueGrey: UIColor {
        return colorFromDecimalRGB(24, 24, 80, alpha: 0.04)
    }
    
    class var coolGrey: UIColor {
        return colorFromDecimalRGB(163, 163, 181)
    }
    
    class var paleGrey: UIColor {
        return colorFromDecimalRGB(246, 246, 250)
    }
    
    class var darkSkyBlue: UIColor {
           return colorFromDecimalRGB(74, 144, 226)
       }
}
