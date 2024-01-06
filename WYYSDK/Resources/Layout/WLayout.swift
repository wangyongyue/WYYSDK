//
//  WLayout.swift
//  WYYSDK
//
//  Created by wyy on 2023/6/12.
//

import Foundation
import UIKit

public extension UIView {
    var w:WLayout {
        return WLayout(view: self)
    }
}
public class WLayout {
    weak var view:UIView?
    init(view: UIView? = nil) {
        self.view = view
    }
}

/*
 运算符自动布局
 */
public extension WLayout {
    var left:WLayoutAttribute {
        let layout = WLayoutAttribute()
        layout.item = view
        layout.attribute = .left
        return layout
    }
    var right:WLayoutAttribute {
        let layout = WLayoutAttribute()
        layout.item = view
        layout.attribute = .right
        return layout
    }
    var top:WLayoutAttribute {
        let layout = WLayoutAttribute()
        layout.item = view
        layout.attribute = .top
        return layout
    }
    var bottom:WLayoutAttribute {
        let layout = WLayoutAttribute()
        layout.item = view
        layout.attribute = .bottom
        return layout
    }
    var centerX:WLayoutAttribute {
        let layout = WLayoutAttribute()
        layout.item = view
        layout.attribute = .centerX
        return layout
    }
    var centerY:WLayoutAttribute {
        let layout = WLayoutAttribute()
        layout.item = view
        layout.attribute = .centerY
        return layout
    }
    var width:WLayoutAttribute {
        let layout = WLayoutAttribute()
        layout.item = view
        layout.attribute = .width
        return layout
    }
    var height:WLayoutAttribute {
        let layout = WLayoutAttribute()
        layout.item = view
        layout.attribute = .height
        return layout
    }
   

}
/*
 数据类
 */
public class WLayoutAttribute {
    
    weak var item:UIView?
    var attribute:NSLayoutConstraint.Attribute?
    var relatedBt:NSLayoutConstraint.Relation?
    var constant:CGFloat?
    var toLayout:WLayoutAttribute?


}

/*
 自定义操作符  连接符
 */

//infix operator >>: WLayoutLinkPrecedence
//precedencegroup WLayoutLinkPrecedence {
//   associativity: right
//   lowerThan: ComparisonPrecedence
//   assignment: true
//}
public extension WLayoutAttribute {
    
    //绑定布局间隔
    @discardableResult
    static func == (r:WLayoutAttribute,x:CGFloat) -> WLayoutAttribute{
        r.constant = x
        r.toLayout?.constant = x
        dealLayout(r)
        return r
    }
    @discardableResult
    static func >> (r:WLayoutAttribute,x:WLayoutAttribute) -> WLayoutAttribute{
        r.relatedBt = .equal
        r.constant = 0
        r.toLayout = x
        x.relatedBt = .equal
        x.constant = 0
        x.toLayout = x
        return r
    }
    
}
func dealLayout(_ att:WLayoutAttribute) {
    
    if let toLayout = att.toLayout,let item = att.item,let toItem = att.toLayout?.item , item == toItem {
        dealLayoutSuper(att)
        dealLayoutSuper(toLayout)
    }
    else if let toLayout = att.toLayout{
        dealLayout(att, toLayout)
    }
    else if att.toLayout == nil {
        dealLayoutSuper(att)
    }
}

//绑定方法实现

func dealLayout(_ att:WLayoutAttribute,_ toAtt:WLayoutAttribute) {
    removeLayout(att)
    att.item?.translatesAutoresizingMaskIntoConstraints  = false
    let constraint = NSLayoutConstraint.init(item: att.item!, attribute: att.attribute ?? .left, relatedBy: toAtt.relatedBt ?? .equal, toItem: toAtt.item, attribute: toAtt.attribute ?? att.attribute ?? .left, multiplier: 1, constant: toAtt.constant ?? 0.0)
    att.item?.superview?.addConstraint(constraint)
}
func dealLayoutSuper(_ att:WLayoutAttribute) {
    if att.attribute == .width || att.attribute == .height {
        dealLayoutSizeSuper(att)
        return
    }
    removeLayout(att)
    att.item?.translatesAutoresizingMaskIntoConstraints  = false
    let constraint = NSLayoutConstraint.init(item: att.item!, attribute: att.attribute ?? .left, relatedBy: att.relatedBt ?? .equal, toItem: att.item?.superview, attribute: att.attribute ?? .left, multiplier: 1, constant: att.constant ?? 0.0)
    att.item?.superview?.addConstraint(constraint)
}
func dealLayoutSizeSuper(_ att:WLayoutAttribute) {
    removeLayout(att)
    att.item?.translatesAutoresizingMaskIntoConstraints  = false
    let constraint = NSLayoutConstraint.init(item: att.item!, attribute: att.attribute ?? .left, relatedBy: att.relatedBt ?? .equal, toItem: nil, attribute: att.attribute ?? .left, multiplier: 1, constant: att.constant ?? 0.0)
    att.item?.addConstraint(constraint)
}
func removeLayout(_ att:WLayoutAttribute) {
    let con =  att.item?.superview?.constraints.first(where: { it in
        return it.firstItem === att.item && it.firstAttribute == att.attribute
    })
    if let c = con {
        att.item?.superview?.removeConstraint(c)
    }
    let con2 =  att.item?.constraints.first(where: { it in
        return  it.firstAttribute == att.attribute
    })
    if let c = con2 {
        att.item?.removeConstraint(c)
    }
}

public extension WLayoutAttribute {
    
    //布局操作符
    @discardableResult
    static func >= (r:WLayoutAttribute,x:CGFloat) -> WLayoutAttribute{
        r.relatedBt = .greaterThanOrEqual
        r.constant = x
        dealLayout(r)
        return r
    }
    @discardableResult
    static func <= (r:WLayoutAttribute,x:CGFloat) -> WLayoutAttribute{
        r.relatedBt = .lessThanOrEqual
        r.constant = x
        dealLayout(r)
        return r
    }
    @discardableResult
    static func >= (r:WLayoutAttribute,x:WLayoutAttribute) -> WLayoutAttribute{
        x.relatedBt = .greaterThanOrEqual
        r.toLayout = x
        return r
    }
    @discardableResult
    static func <= (r:WLayoutAttribute,x:WLayoutAttribute) -> WLayoutAttribute{
        r.relatedBt = .lessThanOrEqual
        r.toLayout = x
        return r
    }
    
}
