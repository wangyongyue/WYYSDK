//
//  WValueEvent.swift
//  WYYSDK
//
//  Created by WYY on 2023/7/14.
//

import UIKit
//时间和绑定
public extension UIView {
    func w_bilding<T>(_ delegate:WEventProtocol,_ name:String,_ call:@escaping (T?)->Void) -> WValueBilding<T>{
        return WValueBilding<T> {e in
            delegate.valueDelegate(name) {[weak e] value in
                e?.call?(value as? T)
            }
            e.valueUpdate{value in
                call(value)
            }
            e.objc = delegate
            
        }
    }
    func w_event<T>(_ delegate:WEventProtocol,_ name:String) -> WValueEvent<T>{
        return WValueEvent<T> {e in
            delegate.valueDelegate(name) {[weak e] _ in
                e?.call?()
            }
            e.objc = delegate
        }
    }

}
public protocol WEventProtocol {
    func valueDelegate(_ ident:String,_ call:@escaping (Any?)->Void)
}
/**
事件
 */
public class WValueEvent<T> {
    public var objc:Any?
    public var call:(()->Void)?
    init(delegate:(WValueEvent)->Void) {
        delegate(self)
    }
    public func textEvent(_ call:@escaping ()->Void) {
        self.call = call
    }
    public func event(){}
}
extension WValueEvent {
    @discardableResult
    static func <- (te:WValueEvent,ob:WObserver<T>) -> WObserver<T>{
        te.textEvent {[weak ob] in
            ob?.send()
        }
        ob.call { _ in
            te.event()
        }
        return ob
    }
}
