
//
//  WOBS.swift
//  WYYSDK
//
//  Created by wyy on 2023/6/1.
//

import Foundation
/**
观察者
 */
@propertyWrapper
public class WObserver<T> {
    private var ident:String?
    public init(){}
    public init(_ value:T? = nil){self.defaultValue = value}
    var defaultValue:T?
    public  var wrappedValue: T?{
        get {return defaultValue}
        set {
            defaultValue = newValue
            send()
        }
    }
    public var projectedValue:WObserver{
        get {return self}
        set {}
    }
    private let subs = WSubscribe()
    public func send() {
        subs.send()
    }
    public func call(_ ident:String,_ b:@escaping (T?)->Void) {
        subs.subscribe(ident) {[weak self] in
            b(self?.defaultValue)
        }
    }
    public func call(_ ident:Int,_ b:@escaping (T?)->Void) {
        subs.subscribe("\(ident)") {[weak self] in
            b(self?.defaultValue)
        }
    }
    public func call(_ b:@escaping (T?)->Void) {
        subs.subscribe {[weak self] in
            b(self?.defaultValue)
        }
    }
    deinit {
        
    }
}

/**
回调事件
 */
public class WEvent {
    public var ident:String?
    public var event:()->Void
    init(event: @escaping () -> Void) {
        self.event = event
    }
    init(ident:String,event: @escaping () -> Void) {
        self.event = event
        self.ident = ident
    }
    
}
/**
释放池
 */
public class WPool {
    private var defaultEvents = [WEvent]()
    public func dismiss(_ event:@escaping ()->Void) {
        let e = WEvent {
            event()
        }
        defaultEvents.append(e)
    }
    public func remove() {
        defaultEvents.forEach { $0.event()}
        defaultEvents.removeAll()
    }
    deinit {
        remove()
    }
}


/**
订阅
 */
public class WSubscribe {
    fileprivate var event  = [WEvent]()
    public func subscribe(_ e:@escaping ()->Void) {
        self.event.append(WEvent(event: e))
    }
    public func subscribe(_ ident:String,_ e:@escaping ()->Void) {
        if let ev = self.event.first(where: {return $0.ident == ident }) {
            ev.event = e
        }else {
            self.event.append(WEvent(ident: ident, event: e))
        }
    }
    public func send() {
        self.event.forEach { $0.event()}
    }
    public func send(_ ident:String) {
        self.event.forEach {
            if ident == $0.ident {
                $0.event()
            }            
        }
    }
}

/**
链接符
 */
extension WObserver {
    @discardableResult
    static func <- (ta:WObserver<T>,ob:WObserver<T>) -> WObserver<T>{
        ob.call {[weak ta] a in
            ta?.defaultValue = a
            ta?.send()
        }
        ob.send()
        return ob
    }
    
}
infix operator <-: WDefaultTargetPrecedence
precedencegroup WDefaultTargetPrecedence {
   associativity: right
   higherThan: ComparisonPrecedence
   assignment: false
}

