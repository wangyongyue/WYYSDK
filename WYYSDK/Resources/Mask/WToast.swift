//
//  WToast.swift
//  WYYSDK
//
//  Created by wyy on 2023/6/5.
//

import Foundation
import UIKit
public class WToast:UIView {
    private let label = UILabel()
    private let view = UIView()
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        addSubview(view)
        view.addSubview(label)

        view.backgroundColor = UIColor.init(white: 0.3, alpha: 0.6)
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.backgroundColor = .clear
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8).isActive = true
        label.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8).isActive = true
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: 5).isActive = true
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -5).isActive = true
        label.widthAnchor.constraint(lessThanOrEqualToConstant: 200).isActive = true

    }
   
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    public static func show(_ text:String) {
        let view = WMask.showView()
        let child = WToast()
        view.addSubview(child)
        view.backgroundColor = .clear
        child.frame = view.bounds
        child.label.text = text
        child.label.alpha = 0.0
        UIView.animate(withDuration: 0.3, delay: 0.1) {
            child.label.alpha = 1.0
        }completion: { Bool in
            UIView.animate(withDuration: 0.2) {
                child.label.alpha = 0.5
            }completion: { Bool in
                view.removeFromSuperview()
            }
        }
        

       
    }
}
