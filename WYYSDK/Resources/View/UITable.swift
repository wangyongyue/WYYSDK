//
//  WTable.swift
//  WYYSDK
//
//  Created by wyy on 2023/5/30.
//

import Foundation
import UIKit
public extension UITableView {

    var w_array:WTableDelegate {
        WTableDelegate(table: self)
    }
    var w_sectionArray:WTableDelegate {
        WTableDelegate(table: self)
    }
    var w_headerArray:WTableDelegate {
        WTableDelegate(table: self)
    }
    var w_footerArray:WTableDelegate {
        WTableDelegate(table: self)
    }
    var w_delegate:WTableDelegate? {
        self.delegate as? WTableDelegate
    }
}
/**
注册代理事件
 */
extension WTableDelegate {
    @discardableResult
    static func <- (te:WTableDelegate,ob:WObserver<Array<Any>>) -> WObserver<Array<Any>>{
        ob.call { value in
            te.relaod(value)
        }
        return ob
    }
    @discardableResult
    static func <- (te:WTableDelegate,ob:WObserver<Array<Array<Any>>>) -> WObserver<Array<Array<Any>>>{
        ob.call { value in
            te.relaodSection(value)
        }
        return ob
    }
}
public class WTableDelegate:WScrollerDelegate {
    let proxy = WTableProxy()
    public var array:[Any]?
    public var sectionArray:[[Any]]?
    public var headerArray:[Any]?
    public var footerArray:[Any]?
    private var isSection:Bool {//是否二维数组
        return sectionArray != nil
    }
    public var table:UITableView
    init(array: [Any]? = nil, table: UITableView) {
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
extension WTableDelegate {
    public func register<C:UITableViewCell,M>(_ cellType:C.Type ,_ modelType:M.Type,_ cellFor:@escaping (C,M,IndexPath) -> Void,select:@escaping (M,IndexPath) -> Void) {
        proxy.register(self.table, cellType, modelType: modelType, cellFor, select)
    }
    public func registerHeader<C:UIView,M>(_ cellType:C.Type ,_ modelType:M.Type,_ cellFor:@escaping (C,M,Int) -> Void,height:@escaping (M,Int) -> CGFloat) {
        proxy.registerHeader(self.table, cellType, modelType: modelType, cellFor, height)
    }
    public func registerFooter<C:UIView,M>(_ cellType:C.Type ,_ modelType:M.Type,_ cellFor:@escaping (C,M,Int) -> Void,height:@escaping (M,Int) -> CGFloat) {
        proxy.registerFooter(self.table, cellType, modelType: modelType, cellFor, height)
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
extension WTableDelegate {
    public func numberOfSections(in tableView: UITableView) -> Int {
        if isSection == true {
            return sectionArray?.count ?? 1
        }
        return 1
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (isSection == true ? sectionArray?.count:array?.count) ?? 0
    }
}
extension WTableDelegate {
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return proxy.tableView(tableView, viewForHeaderInSection: section, dataModel: headerArray?[section])
    }
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return proxy.tableView(tableView, viewForFooterInSection: section, dataModel: footerArray?[section])
    }
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return proxy.tableView(tableView, heightForHeaderInSection: section, dataModel: headerArray?[section])
    }
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return proxy.tableView(tableView, heightForFooterInSection: section, dataModel: footerArray?[section])
    }
    
}
extension WTableDelegate:UITableViewDelegate,UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = isSection == true ? sectionArray?[indexPath.section][indexPath.row]:array?[indexPath.row]
        return proxy.tableView(tableView, cellForRowAt: indexPath, dataModel: model)
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = isSection == true ? sectionArray?[indexPath.section][indexPath.row]:array?[indexPath.row]
        proxy.tableView(tableView, didSelectRowAt: indexPath, dataModel: model)
    }
}
/**
代理类
 */
public class WTableProxy {
    var cellIDs = [String:WTableReg]()
    var headerIDs = [String:WTableRegView]()
    var footerIDs = [String:WTableRegView]()
    
}

extension WTableProxy {
    public func register<C:UITableViewCell,M>(_ tableView: UITableView,_ cellType:C.Type ,modelType:M.Type,_ cellFor:@escaping (C,M,IndexPath) -> Void,_ select:@escaping (M,IndexPath) -> Void) {
        let cellReuseIdentifier = NSStringFromClass(modelType as! AnyClass)
        tableView.register(cellType, forCellReuseIdentifier: cellReuseIdentifier)
        let reg = WTableReg.init(cellType, modelType) { cell, model, indexPath in
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath,dataModel:Any?) -> UITableViewCell {
        
        
        if let model = dataModel {
            
            let identifier = NSStringFromClass(type(of: model) as! AnyClass)
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
            if let a = cellIDs[identifier]{
                a.invoke(cell,model,indexPath)
            }
            cell.selectionStyle = .none
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath,dataModel:Any?) {
        
        if let model = dataModel {
            let identifier = NSStringFromClass(type(of: model) as! AnyClass)
            if let a = cellIDs[identifier]{
                a.select(model,indexPath)
            }
        }
    }
}

extension WTableProxy {
    public func registerHeader<C:UIView,M>(_ tableView: UITableView,_ cellType:C.Type ,modelType:M.Type,_ cellFor:@escaping (C,M,Int) -> Void,_ height:@escaping (M,Int) -> CGFloat) {
        let cellReuseIdentifier = NSStringFromClass(modelType as! AnyClass)
        let reg = WTableRegView.init(cellType, modelType) { cell, model, indexPath in
            if let a = cell as? C,let b = model as? M {
                cellFor(a,b,indexPath)
            }
        } height: { model, indexPath in
            if let b = model as? M {
                return height(b,indexPath)
            }
            return 0
        }
        headerIDs[cellReuseIdentifier] = reg

    }
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int,dataModel:Any?) -> UIView? {
        if let model = dataModel {
            let identifier = NSStringFromClass(type(of: model) as! AnyClass)
            if let a = headerIDs[identifier]{
                let cell = a.cellType.init()
                a.invoke(cell,model,section)
                return cell
            }
        }
        return nil
    }
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int,dataModel:Any?) -> CGFloat {
        if let model = dataModel {
            let identifier = NSStringFromClass(type(of: model) as! AnyClass)
            if let a = headerIDs[identifier]{
                return a.height(model,section)
            }
        }
        return 0.0
    }
}
extension WTableProxy {
    public func registerFooter<C:UIView,M>(_ tableView: UITableView,_ cellType:C.Type ,modelType:M.Type,_ cellFor:@escaping (C,M,Int) -> Void,_ height:@escaping (M,Int) -> CGFloat) {
        let cellReuseIdentifier = NSStringFromClass(modelType as! AnyClass)
        let reg = WTableRegView.init(cellType, modelType) { cell, model, indexPath in
            if let a = cell as? C,let b = model as? M {
                cellFor(a,b,indexPath)
            }
        } height: { model, indexPath in
            if let b = model as? M {
                return height(b,indexPath)
            }
            return 0
        }
        footerIDs[cellReuseIdentifier] = reg

    }
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int,dataModel:Any?) -> UIView? {
        if let model = dataModel {
            let identifier = NSStringFromClass(type(of: model) as! AnyClass)
            if let a = footerIDs[identifier]{
                let cell = a.cellType.init()
                a.invoke(cell,model,section)
                return cell
            }
        }
        return nil
    }
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int,dataModel:Any?) -> CGFloat {
        if let model = dataModel {
            let identifier = NSStringFromClass(type(of: model) as! AnyClass)
            if let a = headerIDs[identifier]{
                return a.height(model,section)
            }
        }
        return 0.0
    }
    
}

class WTableReg {
    var cellType:UITableViewCell.Type
    var modelType:Any.Type
    var invoke:(UITableViewCell,Any,IndexPath) -> Void
    var select:(Any,IndexPath) -> Void
    init(_ cellType:UITableViewCell.Type,_ modelType:Any.Type,_ invoke:@escaping (UITableViewCell,Any,IndexPath) -> Void,select:@escaping (Any,IndexPath) -> Void) {
        self.cellType = cellType
        self.modelType = modelType
        self.invoke = invoke
        self.select = select

    }
    
}
class WTableRegView {
    var cellType:UIView.Type
    var modelType:Any.Type
    var invoke:(UIView,Any,Int) -> Void
    var height:(Any,Int) -> CGFloat
    init(_ cellType:UIView.Type,_ modelType:Any.Type,_ invoke:@escaping (UIView,Any,Int) -> Void,height:@escaping (Any,Int) -> CGFloat) {
        self.cellType = cellType
        self.modelType = modelType
        self.invoke = invoke
        self.height = height

    }
    
}
