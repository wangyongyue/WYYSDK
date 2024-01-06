//
//  WRouter.swift
//  WYYSDK
//
//  Created by wyy on 2023/6/5.
//

import Foundation
/**
 路由协议
 */
public protocol WRouterProtocol {
    init()
    func router_json(_ params:[String:Any]?)
    func router_event()
}
/**
 路由单例
 */
public class WRouter {
    public static let shared = WRouter()
    private var dic:[String:String]?
    //读取本期json文件
    init() {
        if let path = Bundle.main.path(forResource: "wrouter", ofType: "json") {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                    let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                    self.dic =  jsonResult as? [String:String]
                } catch {
                
                }
            }
    }
}
//路由方法
public extension WRouter {
    func send(_ name:String,_ params:[String:Any]?) {
        if let pro = dic?[name], let type = NSClassFromString(pro) as? WRouterProtocol.Type {
            let target = type.init()
            target.router_json(params)
            target.router_event()
        }
    }
    func send(_ name:String) {
        if let pro = dic?[name], let type = NSClassFromString(pro) as? WRouterProtocol.Type {
            let target = type.init()
            target.router_event()
        }
    }
}

