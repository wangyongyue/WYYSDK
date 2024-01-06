//
//  WText.swift
//  WYYSDK
//
//  Created by wyy on 2023/5/30.
//

import UIKit
import CoreFoundation

public extension UITextView {
    
    var w_textColor:WDefaultTarget<UIColor>{
        WDefaultTarget<UIColor>.init {[weak self] value in
            self?.textColor = value ?? .clear
        }
    }
    var w_textAlignment:WDefaultTarget<NSTextAlignment>{
        WDefaultTarget<NSTextAlignment>.init {[weak self] value in
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
    func w_textViewDidChange<T>() -> WValueEvent<T> {
        w_event(w_delegate(), "textViewDidChange")
    }
    var w_text:WValueBilding<String>{
        w_bilding(w_delegate(), "textViewDidChange") { [weak self] value in
            self?.text = value
        }
    }
    
}
public extension UITextView {
    func w_delegate() ->WEventProtocol {
        var delegate:WEventProtocol?
        if let dele = self.delegate {
            delegate = dele as? WEventProtocol
        }else {
            let dele = WTextDelegate()
            self.delegate = dele
            delegate = dele
        }
        return delegate!
    }
    
}

/**
 代理
 */
public class WTextDelegate:NSObject,WEventProtocol {
    public var subs = WSubscribe()
    public var value:String?
    public func valueDelegate(_ ident:String,_ call:@escaping (Any?)->Void) {
        subs.subscribe(ident) {[weak self] in
            call(self?.value)
        }
    }
    
}
extension WTextDelegate:UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        value = textView.text
        subs.send("textViewDidChange")
    }

}

