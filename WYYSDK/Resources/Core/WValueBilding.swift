//
//  WValueBilding.swift
//  WYYSDK
//
//  Created by WYY on 2023/7/14.
//

import Foundation
/**
绑定
 */
public class WValueBilding<T> {
    public var objc:Any?
    public var call:((T?)->Void)?
    public var textCall:((T?)->Void)?
    init(delegate:(WValueBilding)->Void) {
        delegate(self)
    }
    public func valueEvent(_ call:@escaping (T?)->Void) {
        self.call = call
    }
    public func valueUpdate(_ call:@escaping (T?)->Void) {
        self.textCall = call
    }
}
extension WValueBilding {
    @discardableResult
    static func <- (te:WValueBilding,ob:WObserver<T>) -> WObserver<T>{
        te.valueEvent {[weak ob] value in
            ob?.defaultValue = value
            ob?.send()
        }
        ob.call { value in
            te.textCall?(value)
        }
        ob.send()
        
        return ob
    }
}
