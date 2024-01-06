//
//  WLayout.swift
//  WYYSDK
//
//  Created by wyy on 2023/6/6.
//

import Foundation
import UIKit

public class WFlex {
    private let _left:WFlexAttribute = WFlexAttribute()
    private let _right:WFlexAttribute = WFlexAttribute()
    private let _top:WFlexAttribute = WFlexAttribute()
    private let _bottom:WFlexAttribute = WFlexAttribute()
    private let _centerX:WFlexAttribute = WFlexAttribute()
    private let _centerY:WFlexAttribute = WFlexAttribute()
    private let _width:WFlexAttribute = WFlexAttribute()
    private let _height:WFlexAttribute = WFlexAttribute()
   
    
    
}
public extension WFlex {
    func left(_ view:UIView,_ x:CGFloat) {
        _left.item = view;_left.attribute = .left;_left.relatedBt = .equal;_left.constant = x
    }
    func right(_ view:UIView,_ x:CGFloat) {
        _right.item = view;_right.attribute = .right;_right.relatedBt = .equal;_right.constant = x
    }
    func top(_ view:UIView,_ x:CGFloat) {
        _top.item = view;_top.attribute = .top;_top.relatedBt = .equal;_top.constant = x
    }
    func bottom(_ view:UIView,_ x:CGFloat) {
        _bottom.item = view;_bottom.attribute = .bottom;_bottom.relatedBt = .equal;_bottom.constant = x
    }
    func centerX(_ view:UIView,_ x:CGFloat) {
        _centerX.item = view;_centerX.attribute = .centerX;_centerX.relatedBt = .equal;_centerX.constant = x
    }
    func centerY(_ view:UIView,_ x:CGFloat) {
        _centerY.item = view;_centerY.attribute = .centerY;_centerY.relatedBt = .equal;_centerY.constant = x
    }
    func width(_ view:UIView,_ x:CGFloat) {
        _width.item = view;_width.attribute = .width;_width.relatedBt = .equal;_width.constant = x
    }
    func height(_ view:UIView,_ x:CGFloat) {
        _height.item = view;_height.attribute = .height;_height.relatedBt = .equal;_height.constant = x
    }
}
public class WFlexAttribute {
    
    weak var item:UIView?
    var attribute:NSLayoutConstraint.Attribute?
    var relatedBt:NSLayoutConstraint.Relation?
    var constant:CGFloat?
  
}

