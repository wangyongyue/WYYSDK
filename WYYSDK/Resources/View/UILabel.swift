//
//  VLabel.swift
//  WYYSDK
//
//  Created by wyy on 2023/5/30.
//

import Foundation
import UIKit
public extension UILabel {
    var w_text:WDefaultTarget<String>{
        WDefaultTarget<String>.init {[weak self] value in
            self?.text = value
        }
    }
    var w_textColor:WDefaultTarget<UIColor>{
        WDefaultTarget<UIColor>.init {[weak self] value in
            self?.textColor = value ?? .clear
        }
    }
    var w_textAlignment:WDefaultTarget<NSTextAlignment>{
        return WDefaultTarget<NSTextAlignment>.init {[weak self] value in
            self?.textAlignment = value ?? .left
        }
    }
    var w_font:WDefaultTarget<UIFont>{
        WDefaultTarget<UIFont>.init {[weak self] value in
            self?.font = value ?? UIFont()
        }
    }
    var w_attributedText:WDefaultTarget<NSAttributedString>{
        WDefaultTarget<NSAttributedString>.init {[weak self] value in
            self?.attributedText = value
        }
    }
   
}
