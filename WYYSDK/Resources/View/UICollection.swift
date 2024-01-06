//
//  WCollection.swift
//  WYYSDK
//
//  Created by wyy on 2023/5/30.
//

import Foundation
import UIKit
public extension UICollectionView {
    var w_array:WCollectionDelegate {
        WCollectionDelegate(table: self)
    }
    var w_headerArray:WCollectionDelegate {
        WCollectionDelegate(table: self)
    }
    var w_footerArray:WCollectionDelegate {
        WCollectionDelegate(table: self)
    }
    var w_delegate:WCollectionDelegate? {
        self.delegate as? WCollectionDelegate
    }
    func collectionViewLayout<T:UICollectionViewLayout>(_ t:T.Type,_ la:(T)->Void) {
        if let layout = self.collectionViewLayout as? T {
            la(layout)
        }else {
            la(t.init())
        }
        
    }
}
/**
注册代理事件
 */
extension WCollectionDelegate {
    @discardableResult
    static func <- (te:WCollectionDelegate,ob:WObserver<Array<Any>>) -> WObserver<Array<Any>>{
        ob.call { value in
            te.relaod(value)
        }
        return ob
    }
    @discardableResult
    static func <- (te:WCollectionDelegate,ob:WObserver<Array<Array<Any>>>) -> WObserver<Array<Array<Any>>>{
        ob.call { value in
            te.relaodSection(value)
        }
        return ob
    }
}
public class WCollectionDelegate:NSObject {
    let proxy = WCollectionProxy()
    public var array:[Any]?
    public var sectionArray:[[Any]]?
    public var headerArray:[Any]?
    public var footerArray:[Any]?
    private var isSection:Bool {//是否二维数组
        return sectionArray != nil
    }
    public var table:UICollectionView
    init(array: [Any]? = nil, table: UICollectionView) {
        self.array = array
        self.table = table
        super.init()
        self.table.delegate = self
        self.table.dataSource = self

    }
    
}
/**
 公共接口
 */
extension WCollectionDelegate {
    
    public func register<C:UICollectionViewCell,M>(_ table:UICollectionView,_ cellType:C.Type ,_ modelType:M.Type,_ cellFor:@escaping (C,M,IndexPath) -> Void,select:@escaping (M,IndexPath) -> Void) {
        proxy.register(table, cellType, modelType: modelType, cellFor, select)

    }
    public func registerHeader<C:UICollectionReusableView,M>(_ tableView: UICollectionView,_ cellType:C.Type ,modelType:M.Type,_ cellFor:@escaping (C,M,IndexPath) -> Void) {
        proxy.registerHeader(tableView, cellType, modelType: modelType, cellFor)
    }
   public func registerFooter<C:UICollectionReusableView,M>(_ tableView: UICollectionView,_ cellType:C.Type ,modelType:M.Type,_ cellFor:@escaping (C,M,IndexPath) -> Void) {
       proxy.registerFooter(tableView, cellType, modelType: modelType, cellFor)

    }
    
    public func relaod(_ data:[Any]?){
        array = data
        table.reloadData()
    }
    public func relaodSection(_ data:[[Any]]?){
        sectionArray = data
        table.reloadData()
    }
    public func relaodHeader(_ data:[Any]?){
        headerArray = data
        table.reloadData()
    }
    public func relaodFooter(_ data:[Any]?){
        footerArray = data
        table.reloadData()
    }
    
}

extension WCollectionDelegate:UICollectionViewDelegate,UICollectionViewDataSource {
    public  func numberOfSections(in collectionView: UICollectionView) -> Int {
        if isSection == true {
            return sectionArray?.count ?? 1
        }
        return 1
    }
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (isSection == true ? sectionArray?.count:array?.count) ?? 0

    }
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = isSection == true ? sectionArray?[indexPath.section][indexPath.row]:array?[indexPath.row]

        return proxy.collectionView(collectionView, cellForRowAt: indexPath, dataModel: model)

    }
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = isSection == true ? sectionArray?[indexPath.section][indexPath.row]:array?[indexPath.row]

        proxy.collectionView(collectionView, didSelectRowAt: indexPath, dataModel: model)
        
    }
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var model = headerArray?[indexPath.row]
        if kind == UICollectionView.elementKindSectionFooter {
            model = footerArray?[indexPath.row]
        }
        return proxy.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath, dataModel: model)
    }
    
  
}
/**
代理类
 */
public class WCollectionProxy {
    private var cellIDs = [String:WCollectionReg]()
    private var headerIDs = [String:WCollectionRegView]()
    private var footerIDs = [String:WCollectionRegView]()

    public func register<C:UICollectionViewCell,M>(_ tableView: UICollectionView,_ cellType:C.Type ,modelType:M.Type,_ cellFor:@escaping (C,M,IndexPath) -> Void,_ select:@escaping (M,IndexPath) -> Void) {
        let cellReuseIdentifier = NSStringFromClass(modelType as! AnyClass)
        tableView.register(cellType, forCellWithReuseIdentifier: cellReuseIdentifier)
        let reg = WCollectionReg.init(cellType, modelType) { cell, model, indexPath in
            if let a = cell as? C,let b = model as? M {
                cellFor(a,b,indexPath)
            }
        } select: { model, indexPath in
            if let b = model as? M {
                select(b,indexPath)
            }
        }
        cellIDs[cellReuseIdentifier] = reg

    }
    public func registerHeader<C:UICollectionReusableView,M>(_ tableView: UICollectionView,_ cellType:C.Type ,modelType:M.Type,_ cellFor:@escaping (C,M,IndexPath) -> Void) {
        let cellReuseIdentifier = NSStringFromClass(modelType as! AnyClass)
        tableView.register(cellType, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: cellReuseIdentifier)
        let reg = WCollectionRegView(cellType, modelType) { cell, model, indexPath in
            if let a = cell as? C,let b = model as? M {
                cellFor(a,b,indexPath)
            }
        }
        headerIDs[cellReuseIdentifier] = reg
    }
   public func registerFooter<C:UICollectionReusableView,M>(_ tableView: UICollectionView,_ cellType:C.Type ,modelType:M.Type,_ cellFor:@escaping (C,M,IndexPath) -> Void) {
        let cellReuseIdentifier = NSStringFromClass(modelType as! AnyClass)
        tableView.register(cellType, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: cellReuseIdentifier)
       let reg = WCollectionRegView(cellType, modelType) { cell, model, indexPath in
           if let a = cell as? C,let b = model as? M {
               cellFor(a,b,indexPath)
           }
       }
       footerIDs[cellReuseIdentifier] = reg
    }
    

    
}
public extension WCollectionProxy {
    func collectionView(_ tableView: UICollectionView, cellForRowAt indexPath: IndexPath,dataModel:Any?) -> UICollectionViewCell {
        
        
        if let model = dataModel {
            
            let identifier = NSStringFromClass(type(of: model) as! AnyClass)
            let cell = tableView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
            if let a = cellIDs[identifier]{
                a.invoke(cell,model,indexPath)
            }
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ tableView: UICollectionView, didSelectRowAt indexPath: IndexPath,dataModel:Any?) {
        
        if let model = dataModel {
            let identifier = NSStringFromClass(type(of: model) as! AnyClass)
            if let a = cellIDs[identifier]{
                a.select(model,indexPath)
            }
        }
    }
    func collectionView(_ tableView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath,dataModel:Any?) -> UICollectionReusableView {

        if let model = dataModel {
            
            let identifier = NSStringFromClass(type(of: model) as! AnyClass)
            let reusableview = tableView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath)
            if let a = cellIDs[identifier]{
                a.invoke(reusableview,model,indexPath)
            }
            return reusableview
        }
        
        return UICollectionReusableView()
        
    }
}
public class WCollectionReg {
    var cellType:UIView.Type
    var modelType:Any.Type
    var invoke:(UIView,Any,IndexPath) -> Void
    var select:(Any,IndexPath) -> Void
    init(_ cellType:UIView.Type,_ modelType:Any.Type,_ invoke:@escaping (UIView,Any,IndexPath) -> Void,select:@escaping (Any,IndexPath) -> Void) {
        self.cellType = cellType
        self.modelType = modelType
        self.invoke = invoke
        self.select = select

    }
    
}
class WCollectionRegView {
    var cellType:UICollectionReusableView.Type
    var modelType:Any.Type
    var invoke:(UICollectionReusableView,Any,IndexPath) -> Void
    init(_ cellType:UICollectionReusableView.Type,_ modelType:Any.Type,_ invoke:@escaping (UICollectionReusableView,Any,IndexPath) -> Void) {
        self.cellType = cellType
        self.modelType = modelType
        self.invoke = invoke

    }
    
}


