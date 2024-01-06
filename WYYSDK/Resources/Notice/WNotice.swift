//
//  WNotice.swift
//  WYYSDK
//
//  Created by wyy on 2023/6/2.
//

import Foundation
import UIKit
/**
 全局通知
 */
public class WNotic {
    public static let shared = WNotic()
}
/**
 通知方法
 */
public extension WNotic {
    func observer(_ name:NSNotification.Name?,_ call:@escaping (NSNotification)->Void,_ pool:WPool) {
        let target = WNoticTarget(call:call)
        NotificationCenter.default.addObserver(target, selector: #selector(target.notificationContent(_:)), name: name, object: nil)
        pool.dismiss {
            NotificationCenter.default.removeObserver(target, name: name, object: nil)
        }
    }
    func send(_ name:NSNotification.Name,_ data:Any?) {
        NotificationCenter.default.post(name: name, object: data)
    }
    func observer(_ name:String,_ call:@escaping (NSNotification)->Void,_ pool:WPool) {
        observer(NSNotification.Name(name), call, pool)
    }
    func send(_ name:String,_ data:Any?) {
        send(NSNotification.Name(name), data)
    }
}
public class WNoticTarget {
    public let call:(NSNotification)->Void
    init(call: @escaping (NSNotification) -> Void) {
        self.call = call
    }
    @objc public  func notificationContent(_ n:NSNotification) {
        self.call(n)
    }
}
