//
//  UISlideView.swift
//  WYYSDK
//
//  Created by wyy on 2023/7/5.
//

import UIKit

//实现
class UISlideTable:UITableView {
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    var config = UISlideConfig()

}
extension UISlideTable {
   
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        config.scrollViewDidScroll(scrollView)
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        config.scrollViewWillBeginDragging(scrollView)
    }
}
/**
多个scrollerview叠加使用
 */

public enum  SrollDirection  {
    case none
    case up
    case down
}
public class UISlideHoverConfig {
    var height:CGFloat?
    var hidden = false

}
public protocol UISlideProtocle {
    func slideContent(_ call:@escaping (Bool) ->Void)
}
public class UISlideHoverView:UIScrollView {
    private var controllerCall = [(Int)->CGFloat]()
    fileprivate var controllerArray = [UIViewController]()
    fileprivate var hoverH:CGFloat = 0.0
    private var configDic = [Int:Bool]()
    
    public  func sliderController(_ controller: UIViewController? ,_ config:@escaping (Int)->CGFloat) -> Self{
        if let vc = controller {
            controllerCall.append(config)
            controllerArray.append(vc)
            let top = findCurrentController(self)
            top?.addChild(vc)
            let index = controllerArray.count - 1
            if let co = vc as? UISlideProtocle , index >= 0 {
                co.slideContent {[weak self] isC in
                    self?.reloadLayoutHeight(index, isC)
                }
            }
        }
        return self
    }
    
    public func scrollTo() {
        
        self.setContentOffset(CGPoint.init(x: 0.0, y: hoverH), animated: true)
    }
    private func findCurrentController(_ view:UIView) -> UIViewController?{
        if let vc  = view.w_viewController() {
            return vc
        }
        if let v = view.superview {
            return findCurrentController(v)
        }
        return nil
    }
    public func reload() {
        for item in self.subviews {
            item.removeFromSuperview()
        }
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.isDirectionalLockEnabled = true
        self.bounces = false
        for vc in controllerArray {
            self.addSubview(vc.view)
        }
       
        layoutConfig()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        layoutConfig()
    }
    private func reloadLayoutHeight(_ index:Int,_ hidden:Bool) {
        configDic[index] = hidden
        layoutConfig()
    }
    private func layoutConfig() {
        if self.frame.height == 0 {return}
        var i = 0
        var h:CGFloat = 0
        for item in controllerCall {
            let config = UISlideHoverConfig()
            config.height = item(i)
            if let isH = configDic[i] {
                config.hidden = isH
            }
            let height = config.height ?? 0.0
            let hover = config.height ?? 0.0
            let vc = controllerArray[i]
            if i + 1 == controllerCall.count {
                if h == 0 && hover > 0 {
                    self.contentOffset = CGPoint.init(x: 0, y: hover)
                }
                hoverH = hover + h
                let total = self.frame.height + hover
                vc.view.w.top == h
                vc.view.w.height == total
                vc.view.w.left >> vc.view.w.right == 0
                
                h += total
            }else {
                var c_height = height
                if config.hidden {
                    c_height = 0
                }
                vc.view.w.top == h
                vc.view.w.height == c_height
                vc.view.w.right == 0
                
                h += c_height
            }
            i += 1
        }
        self.contentSize = CGSize(width: self.frame.width, height: h)
    }
}
class UISlideConfig {
    var offsetY:CGFloat = 0
    var lastOffsetY:CGFloat = 0
    var sdir:SrollDirection = .none

}
extension UISlideConfig {
    func findbaseScroller(_ view:UIView?) -> UISlideHoverView?{
        if view == nil {
            return nil
        }
        if let base  = view?.superview as? UISlideHoverView {
            return base
        }
        return findbaseScroller(view?.superview)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let currentY = scrollView.contentOffset.y
        let parent = findbaseScroller(scrollView)
        let hoverY = parent?.hoverH ?? 0
        let baseOfferY = parent?.contentOffset.y ?? 0
        
        if parent?.controllerArray.last?.view.frame.origin.y ?? 0 == 0 {
            return
        }
        if baseOfferY < -30 {
            findbaseScroller(scrollView)?.contentOffset = CGPoint.init(x: 0, y: 0)
            return
        }
        offsetY = baseOfferY
        if lastOffsetY <= currentY {
            sdir = .up
        }else {
            sdir = .down
        }
        if sdir == .up && baseOfferY < hoverY {
            offsetY += scrollView.contentOffset.y
            if offsetY > hoverY {offsetY = hoverY}
            parent?.contentOffset = CGPoint.init(x: 0, y: offsetY)
            scrollView.contentOffset = CGPoint.init(x: 0, y: 0)
        } else
        if sdir == .down && currentY < 0 && baseOfferY == hoverY{
            if offsetY != hoverY {offsetY = hoverY}
            offsetY += scrollView.contentOffset.y
            if offsetY < 0 {offsetY = 0}
            parent?.contentOffset = CGPoint.init(x: 0, y: offsetY)
            scrollView.contentOffset = CGPoint.init(x: 0, y: 0)
        } else
        if sdir == .down && currentY < 0 && baseOfferY < hoverY && baseOfferY > 0 {
            offsetY += scrollView.contentOffset.y
            if offsetY < 0 {offsetY = 0}
            parent?.contentOffset = CGPoint.init(x: 0, y: offsetY)
            scrollView.contentOffset = CGPoint.init(x: 0, y: 0)
        } else
        if sdir == .down && currentY < 0 && baseOfferY == 0 {
            offsetY = 0
            parent?.contentOffset = CGPoint.init(x: 0, y: 0)
        }
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastOffsetY = scrollView.contentOffset.y
    }
   
}

extension  UISlideHoverView:UIGestureRecognizerDelegate{
    func isCanScroll(_ ges:UIGestureRecognizer) -> Bool{
       
        if self.contentOffset.y <= hoverH {
            let location = ges.location(in: self)
            if let frame = controllerArray.last?.view.frame {
                var rect = frame
                rect.origin.y -= self.contentOffset.y
                return !CGRectContainsPoint(rect, location)
            }
        }
        return true
    }
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return isCanScroll(gestureRecognizer)
    }
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {

        if (otherGestureRecognizer.view?.w_className() == "UITableViewWrapperView" && otherGestureRecognizer is UIPanGestureRecognizer) {
            return true
        }
        if let view = otherGestureRecognizer.view as? UIScrollView ,view.contentSize.width >  view.frame.width {
            return true
        }
       
        return false
    }
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true;
    }
   
}
extension UIView {
    func w_className() ->String {
        return NSStringFromClass(self.classForCoder)
    }
    func w_viewController() ->UIViewController? {
        let view = self;
        while(view.next != nil) {
            if let next = view.next, next.isKind(of: UIViewController.classForCoder()) {
                return next as? UIViewController
            }
        }
        return nil
    }
   
}
