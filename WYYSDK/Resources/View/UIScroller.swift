//
//  WScroller.swift
//  WYYSDK
//
//  Created by wyy on 2023/5/31.
//

import Foundation
import UIKit
public extension UIScrollView {
    func w_scrollDelegate() -> WEventProtocol {
        var delegate:WEventProtocol?
        if let dele = self.delegate {
            delegate = dele as? WEventProtocol
        }else {
            let dele = WScrollerDelegate()
            self.delegate = dele
            delegate = dele
        }
        return delegate!
    }

    
    var w_offset:WValueBilding<CGPoint>{
        w_bilding(w_scrollDelegate(),"scrollViewDidScroll") { [weak self] value in
            self?.contentOffset = value ?? CGPointZero
        }
    }
    func w_scrollerDidChange<T>() -> WValueEvent<T> {
        w_event(w_scrollDelegate(),"scrollViewDidScroll")
    }
    func w_scrollViewWillBeginDragging<T>() -> WValueEvent<T> {
        w_event(w_scrollDelegate(),"scrollViewWillBeginDragging")
    }
    func w_scrollViewDidEndDragging<T>() -> WValueEvent<T> {
        w_event(w_scrollDelegate(),"scrollViewDidEndDragging")
    }
    func w_scrollViewWillBeginDecelerating<T>() -> WValueEvent<T> {
        w_event(w_scrollDelegate(),"scrollViewWillBeginDecelerating")
    }
    func w_scrollViewDidEndDecelerating<T>() -> WValueEvent<T> {
        w_event(w_scrollDelegate(),"scrollViewDidEndDecelerating")
    }
    
}

/**
 代理
 */

public class WScrollerDelegate:NSObject,WEventProtocol {
    public var subs = WSubscribe()
    public var value:Any?
    public func valueDelegate(_ ident:String,_ call:@escaping (Any?)->Void) {
        subs.subscribe(ident) {[weak self] in
            call(self?.value)
        }
    }
    
}
extension WScrollerDelegate:UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        value = scrollView.contentOffset
        subs.send("scrollViewDidScroll")
    }
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        subs.send("scrollViewWillBeginDragging")
    }
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        subs.send("scrollViewDidEndDragging")
    }
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        subs.send("scrollViewDidEndDecelerating")
    }
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        subs.send("scrollViewWillBeginDecelerating")
    }
    
}
