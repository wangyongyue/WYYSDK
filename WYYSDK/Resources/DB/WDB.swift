//
//  WDB.swift
//  WYYSDK
//
//  Created by wyy on 2023/6/2.
//

import Foundation
/*
 json协议
 */
public protocol WPropertyProtocol {
    init()
    func w_keyValue(_ data:[String:Any])
    func w_keyValue(_ pointer: UnsafeMutablePointer<[String : Any]>)
}
public extension WPropertyProtocol {
    func w_toJson() -> [String:Any] {
        var dic = [String:Any]()
        withUnsafeMutablePointer(to: &dic) { pointer in
            w_keyValue(pointer)
        }
        return dic
    }
    func w_fromJson(_ data:[String:Any]) {
        w_keyValue(data)
    }
}

/*
 运算符重载
 condition 进行字符串拼接
 */
public extension WProperty {
    
    static func == (r:WProperty,x:String) -> WProperty<String>{
        let nr = WProperty<String>(r.table,r.key)
        nr.condition = "\(nr.key) = '\(x)'"
        return nr
    }
    static func == (r:WProperty,x:Double) -> WProperty<String>{
        let nr = WProperty<String>(r.table,r.key)
        nr.condition = "\(nr.key) = '\(x)'"
        return nr
    }
    static func || (r:WProperty,x:WProperty) -> WProperty{
        
        r.condition = "\(r.condition) or \(x.condition)"
        return r
    }
    static func && (r:WProperty,x:WProperty) -> WProperty{
        
        r.condition = "\(r.condition) and \(x.condition)"
        return r
    }
    
    static func > (r:WProperty,x:Double) -> WProperty<String>{
        let nr = WProperty<String>(r.table,r.key)
        nr.condition = "\(nr.key) > '\(x)'"
        return nr
    }
    static func < (r:WProperty,x:Double) -> WProperty<String>{
        let nr = WProperty<String>(r.table,r.key)
        nr.condition = "\(nr.key) < '\(x)'"
        return nr
    }
    static func >= (r:WProperty,x:Double) -> WProperty<String>{
        let nr = WProperty<String>(r.table,r.key)
        nr.condition = "\(nr.key) >= '\(x)'"
        return nr
        
    }
    static func <= (r:WProperty,x:Double) -> WProperty<String>{
        let nr = WProperty<String>(r.table,r.key)
        nr.condition = "\(nr.key) <= '\(x)'"
        return nr
    }
    static func limit (r:WProperty,x:UInt) -> WProperty<String>{
        let nr = WProperty<String>(r.table,r.key)
        nr.condition = "limit \(x)"
        return nr
    }
    
}

/*
 @propertyWrapper 属性包装器，可以重写包装属性的setter,getter方法
 属性：
 key       定义数据库字段 | 转json字段值
 table     数据库表名
 condition 条件语句拼接
 */
@propertyWrapper
public class WProperty<T> {
    private var key:String
    private var table:String
    public var condition:String = ""

    public init(_ table:String,_ key: String){
        self.key = key
        self.table = table
        
        /*
         新建表，和新增数据表字段
         */
        WSQL.setUpTableAndKeys(table,key)

    }
    /*
     值
     */
   private var defaultValue:T?
    
    /*
     setter ,getter 执行快
     必须实现
     */
    public  var wrappedValue: T?{
        
        get {return defaultValue}
        set {defaultValue = newValue}
    }
    
    /*
     映射
     可以通过 $ 美元符号访问
     */
    public var projectedValue:WProperty{
        get{return self}
        set{}
    }
    
    /*
     返回当前key,和defaultValue
     */
    public func w_keyValue(_ pointer: UnsafeMutablePointer<[String : Any]>) {
        if let value = defaultValue {
            pointer.pointee[key] = value
        }
    }
    /*
     通过json赋值
     */
    public func w_keyValue(_ data: [String : Any]) {
        if let value = data[key] as? T {
            defaultValue = value
        }else {
            if let value = data[key]{
                if T.self is Double.Type {
                    defaultValue = Double("\(value)") as? T
                }else
                if T.self is Float.Type {
                    defaultValue = Float("\(value)") as? T
                }else
                if T.self is Int.Type {
                    defaultValue = Int("\(value)") as? T
                }else
                if T.self is String.Type {
                    defaultValue = "\(value)" as? T
                }
               
            }
        }
    }
    
}


/*
 自定义属性包装器类
 */
@propertyWrapper
public class WDB<T:WPropertyProtocol>{
    /*
     表名
     必填
     */
    private var table:String
    
    public init(_ table:String){
        self.table = table
        /*
         初始化时更新数据库sql
         */
        WSQL.commit()
    }
    /*
     返回当前类实例，方便使用
     */
    public var wrappedValue:WDB{
        get {return self}
        set {}
    }
    
    /*
     提交执行缓存sql
     */
    private func commit() {
        WSQL.commit()
    }
    /*
     model数据转json
     参数：
     data  数据内容
     */
    private func w_toJsonArray(_ data:[T]) -> [[String:Any]] {
        var array = [[String:Any]]()
        for item in data {
            array.append(item.w_toJson())
        }
        return array
    }

    /*
     json数据转model
     参数：
     type  数据类型
     data  数据内容
     */
    private func w_toModelArray(_ type:T.Type,_ data:[Any]?) -> [T]?{
        if let items = data {
            var array = [T]()
            for item in items {
                if let json = item as? [String:Any] {
                    let m = type.init()
                    m.w_fromJson(json)
                    array.append(m)
                }
            }
            return array
        }
        return nil
    }
}

/*
 扩展 WDB
 提供增删改查接口
 */
public extension WDB {
    
    func find(__ condition:(T)->WProperty<String>,limit:UInt) -> T?{
        commit()
        let con = condition(T.init())
        let sql  = "\(con.condition) limit \(limit)"
        return w_toModelArray(T.self, WSQL.find(table, sql))?.first
    }
    /*
     查询单个数据
     参数：
     type      数据类型
     condition 条件语句
     */
    func findOne(_ condition:(T)->WProperty<String>) -> T?{
        commit()
        let con = condition(T.init())
        return w_toModelArray(T.self, WSQL.find(table, con.condition))?.first
    }
    
    /*
     查询数据
     参数：
     type      数据类型
     condition 条件语句
     */
    func find(_ condition:(T)->WProperty<String>) -> [T]?{
        commit()
        let con = condition(T.init())
        return w_toModelArray(T.self, WSQL.find(table, con.condition))
    }
    
    /*
     查询全部数据
     参数：
     type      数据类型
     */
    func findAll() -> [T]?{
        commit()
        return w_toModelArray(T.self, WSQL.find(table, ""))
    }
    
    /*
     删除数据
     参数：
     type      数据类型
     condition 条件语句
     */
    @discardableResult
    func delete(_ condition:(T)->WProperty<String>) -> Bool{
        let con = condition(T.init())
        return WSQL.delete(table, con.condition)
    }
    
    /*
     新增数据
     参数：
     data      数据内容
     */
    @discardableResult
    func insert(_ data:[T]) -> Bool{
        let array = w_toJsonArray(data)
        return WSQL.insert(table, array)
    }
    
    /*
     更新数据
     参数：
     type      数据类型
     condition 条件语句
     data      更新数据内容
     */
    @discardableResult
    func update(_ data:(T)->Void,condition:(T)->WProperty<String>) -> Bool{
        let con = condition(T.init())
        let m = T.init()
        data(m)
        return WSQL.update(table, m.w_toJson(), con.condition)
    }
   
}



