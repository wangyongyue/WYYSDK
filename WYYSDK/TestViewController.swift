//
//  TestViewController.swift
//  WYYSDK
//
//  Created by wyy on 2023/7/3.
//

import UIKit
class TestViewController: UIViewController {

    @WKV("aa")
    var name:String?
    
    @WKV("assa")
    static var age:String?
    @WDB("teach")
    var teach:WDB<Teach>
    
    @WObserver(.green)
    var acolor:UIColor?
    
    @WObserver
    var click:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // Do any additional setup after loading the view.
        let button = View(UIButton()) {
            $0.w_backgroundColor <- $acolor
            $0.w_superview =  self.view
            $0.w_controllEvent(.touchUpInside) <- $click
        }
        
        button.w.top >> button.w.left == 200
        button.w.width >> button.w.height == 160
        
        click  = "dddddd"
        $click.call {[weak self] value in
            print(value)
            self?.dismiss(animated: true)
        }
        
        let a = Student()
        a.title = "sdfsdf"
        print(a.w_toJson())
        let b = Student()
        b.w_fromJson(["name":"aaaa"])
        print(b.title)
        
        let c = WJson(a.w_toJson())
        print(c.age.string)
        
        print(name)
        name = "aaaa"

        print(TestViewController.age)
        TestViewController.age = "ddddd"
        TestViewController.age = "cccc"
        print(TestViewController.age)
        TestViewController.age = "adfge111"
        
        let t = teach.findOne {$0.$name == "a"}
        print(t?.name)
        
        WNotic.shared.observer("asd", { d in
            print(d)
        }, pool)
        WNotic.shared.send("asd", "jjjjjjj")
        
        WRouter.shared.send("test", nil)
        WToast.show("收到酸辣粉")
      
        let label = View(UILabel()) {
            $0.w_backgroundColor <- $acolor
            $0.textColor = .black
            $0.text = "布局布局布局布局布局布局布局"
            $0.w_superview =  self.view

        }
        
        label.w.top >> label.w.left == 100
        label.w.width >> label.w.height == 160
        label.w.width <= 50
        
        
        WTaskManager.manager.task("abc1") { a in
            print(a)
        }.pool("1", tpool)
        WTaskManager.manager.task("abc") { a in
            print(a)
        }.pool("1", tpool)
        WTaskManager.manager.taskWatch({
            print("sdfs")
        }, pool)
        WTaskManager.manager.taskSend("abc", "abccccc")
        WTaskManager.manager.taskSend("abc1", "abccccc1")

    }
    let pool = WPool()
    let tpool = WTaskPool()
    
    

}
class Test :WRouterProtocol {
    required init(){}
    func router_json(_ params: [String : Any]?) {
        
    }
    func router_event() {
        
    }
}
class Student:WJSONProtocol {
    var title:String?
    required init(){}
    func w_keyPathsAndKeys(_ data: [String : Any]) {
        w_keyPath(\Student.title, "name", data)

    }
    func w_keyPathsAndKeys(_ pointer: UnsafeMutablePointer<[AnyKeyPath : String]>) {
        w_keyPath(\Student.title, "name", pointer)
    }
}

class Teach:WPropertyProtocol  {
    required init(){}
    func w_keyValue(_ data:[String:Any]) {
        $name.w_keyValue(data)
    }
    func w_keyValue(_ pointer: UnsafeMutablePointer<[String : Any]>) {
        $name.w_keyValue(pointer)
    }
    
    @WProperty("teach","name")
    var name:String?
}
