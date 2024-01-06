//
//  UIGestureRecognizer.swift
//  WYYSDK
//
//  Created by WYY on 2023/7/14.
//

import UIKit
public extension UITapGestureRecognizer {
    var w_superview:UIView?{
        set {newValue?.addGestureRecognizer(self)}
        get {return self.view}
    }
    func w_controllEvent<T>() ->WGestureRecognizerTarget<T> {
        WGestureRecognizerTarget<T>(target: self)
    }
    
    
}

//普通监听转换target
public class WGestureRecognizerTarget<T> {
    public var block:(()->Void)?
    public let target:UIGestureRecognizer
    init(target:UIGestureRecognizer) {
        self.target = target
        target.addTarget(self, action: #selector(clickEvent))
    }
    @objc public func clickEvent() {
        self.block?()
    }
    public func clickCall(_ c:@escaping ()->Void) {
        self.block = c
    }
    public func event(){}
 
}
extension WGestureRecognizerTarget {
    @discardableResult
    static func <- (ta:WGestureRecognizerTarget,ob:WObserver<T>) -> WObserver<T>{
        ta.clickCall {[weak ob]  in
            ob?.send()
        }
        ob.call { _ in
            ta.event()
        }
        return ob
    }
}
