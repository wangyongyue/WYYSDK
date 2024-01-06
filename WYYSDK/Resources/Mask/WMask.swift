//
//  WMask.swift
//  WYYSDK
//
//  Created by wyy on 2023/6/5.
//

import Foundation
import UIKit
public class WMaskView:UIView{
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    fileprivate var removeCall:(()->Void)?
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        removeCall?()
    }
}
public class WMask {
    public static func showView() -> UIView{
        let window = UIApplication.shared.keyWindow
        let bg  = WMaskView()
        bg.removeCall = { [weak bg] in
            bg?.removeFromSuperview()
        }
        bg.layer.backgroundColor  = UIColor.init(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.5).cgColor
        window?.addSubview(bg)
        bg.frame = window?.bounds ?? CGRectZero
        let main  = UIView()
        bg.addSubview(main)
        main.frame = window?.bounds ?? CGRectZero
        return bg
    }
    
    public static func showView(_ dismiss:@escaping ()->Void) -> UIView{
        let window = UIApplication.shared.keyWindow
        let bg  = WMaskView()
        bg.removeCall = { [weak bg] in
            dismiss()
            bg?.removeFromSuperview()
        }
        bg.layer.backgroundColor  = UIColor.init(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.5).cgColor
        window?.addSubview(bg)
        bg.frame = window?.bounds ?? CGRectZero

        let main  = UIView()
        bg.addSubview(main)
        main.frame = window?.bounds ?? CGRectZero
        return bg
    }
    
    @objc public static func dismiss() {
        if let views = UIApplication.shared.keyWindow?.subviews {
            for v in views {
                if v is WMaskView {
                    v.removeFromSuperview()
                }
            }
        }
    }
    
}
