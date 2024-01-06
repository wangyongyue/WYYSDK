//
//  WJson.swift
//  WYYSDK
//
//  Created by wyy on 2023/6/1.
//

import Foundation
/*
 JSON配置协议
 */
public protocol WJSONProtocol {
    init()
    func w_keyPathsAndKeys(_ data:[String:Any])
    func w_keyPathsAndKeys(_ pointer:UnsafeMutablePointer<[AnyKeyPath:String]>)

}
public extension WJSONProtocol {
   
    func w_toJson() -> [String:Any] {
        var json = [String:Any]()
        var dic = [AnyKeyPath:String]()
        withUnsafeMutablePointer(to: &dic) { pointer in
            w_keyPathsAndKeys(pointer)
        }
        dic.forEach { k1,k2 in
            if let value = self[keyPath: k1] {
                if let model = value as? WJSONProtocol {
                    json[k2] = model.w_toJson()

                }else if let array = value as? [WJSONProtocol] {
                    var jsonArray = [Any]()
                    for model in array {
                        jsonArray.append(model.w_toJson())
                    }
                    json[k2] = jsonArray

                }else {
                    json[k2] = self[keyPath: k1]
                }
            }
        }
        return json
    }
   
    func w_fromJson(_ data:[String:Any]) {
        w_keyPathsAndKeys(data)
    }
    func w_keyPath<T,P>(_ keyPath:ReferenceWritableKeyPath<T, P?>,_ key:String,_ pointer:UnsafeMutablePointer<[AnyKeyPath:String]>) {
        pointer.pointee[keyPath] = key
    }
    func w_keyPath<T,P>(_ keyPath:ReferenceWritableKeyPath<T, P?>,_ key:String,_ json:[String:Any]) {
        if let target = self as? T {
            if let value = json[key] as? P {
                target[keyPath: keyPath] = value
            }else if let value = json[key] as? [String:Any] {
                if let t = P.self as? WJSONProtocol.Type {
                    let model = t.init()
                    model.w_fromJson(value)
                    target[keyPath: keyPath] = model as? P
                }
            }else if let array = json[key] as? [Any] {
                for item in array {
                    if let value = item as? [String:Any] {
                        w_keyPath(keyPath,key, value)
                    }
                }
            }
        }
    }
}

