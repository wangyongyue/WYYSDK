//
//  WDefaultTarget.swift
//  WYYSDK
//
//  Created by WYY on 2023/7/14.
//

import Foundation
//普通监听转换target
public class WDefaultTarget<T> {
    public let block:(T?)->Void
    init(block: @escaping (T?) -> Void) {
        self.block = block
    }
}
extension WDefaultTarget {
    @discardableResult
    static func <- (ta:WDefaultTarget,ob:WObserver<T>) -> WObserver<T>{
        ob.call { a in
            ta.block(a)
        }
        ob.send()
        return ob
    }
}
