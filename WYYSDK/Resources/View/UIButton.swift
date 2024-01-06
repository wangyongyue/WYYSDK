//
//  WButton.swift
//  WYYSDK
//
//  Created by wyy on 2023/5/30.
//

import UIKit
public extension UIButton {

    func w_setTtile(_ st:UIControl.State) -> WDefaultTarget<String> {
        WDefaultTarget<String>.init {[weak self] value in
            self?.setTitle(value, for: st)
        }
    }
    func w_setTtileColor(_ st:UIControl.State) -> WDefaultTarget<UIColor> {
        WDefaultTarget<UIColor>.init {[weak self] value in
            self?.setTitleColor(value, for: st)
        }
    }
    func w_setTitleShadowColor(_ st:UIControl.State) -> WDefaultTarget<UIColor> {
        WDefaultTarget<UIColor>.init {[weak self] value in
            self?.setTitleShadowColor(value, for: st)
        }
    }
    func w_setImage(_ st:UIControl.State) -> WDefaultTarget<UIColor> {
        WDefaultTarget<UIColor>.init {[weak self] value in
            self?.setTitleShadowColor(value, for: st)
        }
    }
    func w_setBackgroundImage(_ st:UIControl.State) -> WDefaultTarget<UIImage> {
        WDefaultTarget<UIImage>.init {[weak self] value in
            self?.setBackgroundImage(value, for: st)
        }
    }
    var w_font:WDefaultTarget<UIFont>{
        WDefaultTarget<UIFont>.init {[weak self] value in
            self?.titleLabel?.font = value ?? UIFont()
        }
    }
    var w_attributedText:WDefaultTarget<NSAttributedString>{
        WDefaultTarget<NSAttributedString>.init {[weak self] value in
            self?.titleLabel?.attributedText = value
        }
    }
 
    func w_controllEvent<T>(_ e:UIControl.Event) ->WClickTarget<T> {
        WClickTarget<T>(target: self, event: e)
    }
    
    
}
//普通监听转换target
public class WClickTarget<T> {
    public var block:(()->Void)?
    public let target:UIControl
    init(target:UIControl,event:UIControl.Event) {
        self.target = target
        target.addTarget(self, action: #selector(clickEvent), for: event)
    }
    @objc public func clickEvent() {
        self.block?()
    }
    public func clickCall(_ c:@escaping ()->Void) {
        self.block = c
    }
    public func event(){}
 
}
extension WClickTarget {
    @discardableResult
    static func <- (ta:WClickTarget,ob:WObserver<T>) -> WObserver<T>{
        ta.clickCall {[weak ob]  in
            ob?.send()
        }
        ob.call { _ in
            ta.event()
        }
        return ob
    }
}
