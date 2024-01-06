//
//  WJson.swift
//  WYYSDK
//
//  Created by wyy on 2023/6/1.
//

import Foundation

@dynamicMemberLookup
class WJson{
    private var rawData:Any?
    private var currentData:Any?
    init(_ value:Any?) {
        if let va = value {
            toJson(va)
        }
    }
    init(_ value:String?) {
        if let va = value {
            stringToJson(va)
        }
    }
    init(_ value:Data?) {
        if let va = value {
            dataToJson(va)
        }
    }
   
    subscript(dynamicMember member:String) -> WJson{
        analysis(member)
        return self
    }
    
}

/*
 对外接口，arrar, dic,int,float,double,string
 返回值都会默认值，不会为nil
 */

extension WJson {
    var array:[Any]{
        get{
            var list = [Any]()
            if let data = currentData {
                if let array = data as? [Any] {
                    for item in array{
                        list.append(item)
                    }
                }
            }
            currentData = rawData
            return list
        }
    }
    var dictionary:[String:Any]{
        get{
            var dic = [String:Any]()
            if let data = currentData {
                if let da = data as? [String:Any] {
                    for (k,v) in da {
                        dic[k] = v
                    }
                }
            }
            currentData = rawData
            return dic
        }
    }
    var string:String?{
        get{
            var re:String?
            if let data = currentData {
                re = data as? String
            }
            currentData = rawData
            return re
        }
    }
    var int:Int?{
        get{
            var re:Int?
            if let data = currentData {
                re = data as? Int
            }
            currentData = rawData
            return re
        }
    }
    var float:Float?{
        get{
            var re:Float?
            if let data = currentData {
                re = data as? Float
            }
            currentData = rawData
            return re
        }
    }
    var double:Double?{
        get{
            var re:Double?
            if let data = currentData {
                re = data as? Double
            }
            currentData = rawData
            return re
        }
    }
    var bool:Bool?{
        get{
            var re:Bool?
            if let data = currentData {
                re =  data as? Bool
            }
            currentData = rawData
            return re
        }
    }
}
/*
 对输入数据进行初步解析和判断
 */

fileprivate extension WJson {
    func toJson(_ data:Any){
        rawData = data
        currentData = data
    }
    
    /*
     jsonString转成json
     */
    func stringToJson(_ data:String){
        if let value = data.data(using: .utf8) {
            rawData = try? JSONSerialization.jsonObject(with: value, options: .mutableContainers)
            currentData = rawData
        }
    }
    
    /*
     data转成json
     */
    func dataToJson(_ data:Data){
        rawData = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
        
        currentData = rawData
    }
    
    /*
     如果当前数据是一个数组且属性值是int类型，当作下标解析
     */
    func analysis(_ key:String) {
        
        if let data = currentData {
            if data is [Any] {
                if let index = Int(key){
                    if let array = data as? [Any] {
                        currentData = array[index]
                    }
                }
                
            }else if data is [String:Any] {
                if let dic = data as? [String:Any] {
                    if let some = dic["some"] as? [String:Any] {
                        currentData = some[key]
                    }else{
                        currentData = dic[key]
                    }
                    
                }
            }
        }
    }
}

