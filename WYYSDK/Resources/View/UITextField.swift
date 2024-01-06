//
//  WTextField.swift
//  WYYSDK
//
//  Created by wyy on 2023/5/30.
//

import UIKit
public extension UITextField {

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
    
    var w_text:WValueBilding<String>{
        w_bilding(w_delegate(), "textFieldDidChangeSelection") { [weak self] value in
            self?.text = value
        }
    }
    func w_textViewDidChange<T>() -> WValueEvent<T> {
        w_event(w_delegate(), "textFieldDidChangeSelection")
    }
    func w_textFieldDidBeginEditing<T>() -> WValueEvent<T> {
        w_event(w_delegate(), "textFieldDidBeginEditing")
    }
    func w_textFieldDidEndEditing<T>() -> WValueEvent<T> {
        w_event(w_delegate(), "textFieldDidEndEditing")
    }
    
}
public extension UITextField {
    func w_delegate() ->WEventProtocol {
        var delegate:WEventProtocol?
        if let dele = self.delegate {
            delegate = dele as? WEventProtocol
        }else {
            let dele = WTextFieldDelegate()
            self.delegate = dele
            delegate = dele
        }
        return delegate!
    }
    
}
/**
 代理
 */
public class WTextFieldDelegate:NSObject,WEventProtocol {
    public var subs = WSubscribe()
    public var value:String?
    public func valueDelegate(_ ident:String,_ call:@escaping (Any?)->Void) {
        subs.subscribe(ident) {[weak self] in
            call(self?.value)
        }
    }
    
}
extension WTextFieldDelegate:UITextFieldDelegate {
    public func textFieldDidChangeSelection(_ textField: UITextField) {
        value = textField.text
        subs.send("textFieldDidChangeSelection")
    }
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        subs.send("textFieldDidBeginEditing")
    }
    public func textFieldDidEndEditing(_ textField: UITextField) {
        subs.send("textFieldDidEndEditing")

    }
}

