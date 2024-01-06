//
//  WView.swift
//  WYYSDK
//
//  Created by wyy on 2023/5/30.
//

import Foundation
import UIKit
@discardableResult
public func View<T>(_ t:T,_ b:(T)->Void) -> T{
    b(t)
    return t
}

public extension UIView {
    
    var w_superview:UIView?{
        set {newValue?.addSubview(self)}
        get {return self.superview}
    }
    var w_backgroundColor:WDefaultTarget<UIColor>{
        WDefaultTarget<UIColor>.init {[weak self] value in
            self?.backgroundColor = value
        }
    }
    var w_cornerRadius:WDefaultTarget<CGFloat>{
        WDefaultTarget<CGFloat>.init { [weak self] value in
            self?.layer.cornerRadius = value ?? 0.0
            self?.layer.masksToBounds = true
        }
    }
    
}

public extension UIView {
    var w_X:WDefaultTarget<CGFloat>{
        WDefaultTarget<CGFloat>.init {[weak self] value in
            var rect = self?.frame
            rect?.origin.y = value ?? 0.0
            self?.frame = rect ?? CGRectZero
        }
    }
    var w_Y:WDefaultTarget<CGFloat>{
        WDefaultTarget<CGFloat>.init {[weak self] value in
            var rect = self?.frame
            rect?.origin.y = value ?? 0.0
            self?.frame = rect ?? CGRectZero
        }
    }
    var w_Width:WDefaultTarget<CGFloat>{
        WDefaultTarget<CGFloat>.init {[weak self] value in
            var rect = self?.frame
            rect?.size.width = value ?? 0.0
            self?.frame = rect ?? CGRectZero
        }
    }
    var w_Height:WDefaultTarget<CGFloat>{
        WDefaultTarget<CGFloat>.init {[weak self] value in
            var rect = self?.frame
            rect?.size.height = value ?? 0.0
            self?.frame = rect ?? CGRectZero
        }
    }
    var w_Size:WDefaultTarget<CGSize>{
        WDefaultTarget<CGSize>.init {[weak self] value in
            var rect = self?.frame
            rect?.size = value ?? CGSizeZero
            self?.frame = rect ?? CGRectZero
        }
    }
    var w_Frame:WDefaultTarget<CGRect>{
        WDefaultTarget<CGRect>.init {[weak self] value in
            self?.frame = value ?? CGRectZero
        }
    }
    
}
