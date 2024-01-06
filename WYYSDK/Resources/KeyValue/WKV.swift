//
//  WKV.swift
//  WYYSDK
//
//  Created by wyy on 2023/6/1.
//

import Foundation
@propertyWrapper
public class WKV<T> {
    private var key:String
    public init(_ key: String){
        self.key = key
    }
    var defaultValue:T?
    public  var wrappedValue: T?{
        
        get {
            if defaultValue == nil {
                defaultValue = find()
            }
            return defaultValue
        }
        set {
            save(newValue)
            defaultValue = newValue
        }
    }
    
    private func save(_ t:T?) {
         UserDefaults.standard.setValue(t, forKey: key)
    }
    private func find() -> T? {
       return UserDefaults.standard.value(forKey: key) as? T
    }
}
