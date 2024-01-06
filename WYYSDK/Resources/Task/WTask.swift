//
//  WTask.swift
//  WYYSDK
//
//  Created by wyy on 2023/6/2.
//

import Foundation

/**
 任务管理器
 */
public class WTaskManager {
    public static let manager = WTaskManager()
    private var tasks = [WTask]()
    private var lock = WTaskLock()
    private var watchs = [WTaskWatch]()

}
/**
 全局接口
 */
public extension WTaskManager {
    
    func taskWatch(_ call:@escaping ()->Void,_ pool:WPool){
        let task = WTaskWatch(event: call)
        self.watchs.append(task)
        pool.dismiss {[weak self] in
            self?.watchs.removeAll(where: {$0 === task})
        }
    }
    func taskWatchSend() {
        watchs.forEach {$0.watchSend()}
    }
    
}
/**
 任务接口
 */
public extension WTaskManager {
    func task(_ ident:String,_ call:@escaping (Any)->Void) ->WTask{
        var tas:WTask?
        lock.lock {
            if let task = tasks.first(where: {$0.ident == ident}) {
                task.watchEvent(call)
                tas =  task
            }
            let t = WTask(ident, call) {[weak self] in
                self?.taskWatchSend()
            }
            tasks.append(t)
            tas = t
        }
        return tas!
    }
    func taskSend(_ ident:String,_ data:Any) {
        lock.lock {
            if let task = tasks.first(where: {$0.ident == ident}) {
                task.taskData = data
                task.watchSend()
            }
        }
    }
    func taskInit(_ ident:String,_ data:Any){
        lock.lock {
            if let task = tasks.first(where: {$0.ident == ident}) {
                task.taskData = data
            }
            tasks.append(WTask(ident, data, {[weak self] in
                self?.taskWatchSend()
            }))
        }
    }
    
}
/**
 任务
 */
public class WTask {
    public var watchs = [WTaskWatch]()
    public var watchAll:()->Void
    public var ident:String
    public var taskData:Any?
    public init(_ ident:String,_ data:Any,_ watchAll:@escaping ()->Void) {
        self.ident = ident
        self.taskData = data
        self.watchAll = watchAll
    }
    public init(_ ident:String,_ call:@escaping (Any)->Void,_ watchAll:@escaping ()->Void) {
        if let data = taskData {
            call(data)
        }
        self.ident = ident
        self.watchAll = watchAll
        self.watchs.append(WTaskWatch(event: { [weak self] in
            if let data = self?.taskData {
                call(data)
            }
        }))
    }
    @discardableResult
    public func watchEvent(_ call:@escaping (Any)->Void) -> Self{
        if let data = taskData {
            call(data)
        }
        self.watchs.append(WTaskWatch(event: { [weak self] in
            if let data = self?.taskData {
                call(data)
            }
        }))
        return self
    }
    public func watchSend() {
        watchs.forEach {$0.watchSend()}
        watchAll()
    }
    
    public func pool(_ id:String,_ p:WTaskPool?) {
        
        let wat = self.watchs.last
        p?.watchEvent(ident + id, event: {[weak self] in
            self?.watchs.removeAll(where: {$0 === wat})
        })
    }
    public func pool(_ p:WTaskPool?) {
        
        let wat = self.watchs.last
        p?.watchEvent(nil, event: {[weak self] in
            self?.watchs.removeAll(where: {$0 === wat})
        })
    }
}
/**
 任务响应
 */
public class WTaskWatch {
    public var events = [WTaskEvent]()
    init(event:@escaping () -> Void) {
        events.append(WTaskEvent(pool: nil, event: event))
    }
    public func watchSend() {
        events.forEach({$0.event()})
    }
}
/**
 任务释放池
 */
public class WTaskPool {
    public var events = [WTaskEvent]()
    public func watchEvent(_ pool:String?,event:@escaping () -> Void) {
        remove(pool)
        events.append(WTaskEvent(pool: pool, event: event))
    }
    public func watchSend() {
        events.forEach({$0.event()})
    }
    public func remove(_ pool:String?) {
        events.forEach {
            if $0.pool != nil && $0.pool == pool {
                $0.event()
            }
        }
        events.removeAll(where: { $0.pool != nil && $0.pool == pool })
    }
    deinit {
        events.forEach({$0.event()})
    }
}
public class WTaskEvent {
    public let pool:String?
    public var event:()->Void
    init(pool: String?, event: @escaping () -> Void) {
        self.pool = pool
        self.event = event
    }
}


//互斥锁
public class WTaskLock {
    private let lock = NSLock()
    func lock(_ call:()->Void) {
        lock.lock()
        call()
        lock.unlock()
    }
}
/*
 字符串转字典JSON
 */
public func w_stringToJson(_ str:String?) -> [String:Any]? {
    if let jsonString = str {
        let jsonData:Data = jsonString.data(using: .utf8)!
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        return dict as? [String:Any]
    }
    return nil
}

/*
 字典JSON转字符串
 */
public func w_jsonToString(_ json:[String:Any]?) -> String? {
    
    if let jsonObj = json {
        if(!JSONSerialization.isValidJSONObject(jsonObj)) {
            return ""
        }
       let data : NSData! = try? JSONSerialization.data(withJSONObject: jsonObj, options: []) as NSData
       let JSONString = NSString(data:data as Data,encoding: String.Encoding.utf8.rawValue)
       return JSONString as? String
    }
    
   return nil
}
