//
//  ViewController.swift
//  WYYSDK
//
//  Created by wyy on 2023/5/29.
//

import UIKit

class ViewController: UIViewController {
    
    @WObserver(.green)
    var acolor:UIColor?
    
    @WObserver
    var title1:String?
    
    @WObserver
    var title2:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let label = View(UILabel()) {
            $0.w_backgroundColor <- $acolor
            $0.textColor = .black
            $0.w_superview =  self.view
            $0.w_text <- $title1
            
        }
        
        acolor = .green
        
        $title1 <- $title2
        title2 = "100"
        
        let button = View(UIButton()) {
            $0.w_backgroundColor <- $acolor
            $0.w_superview =  self.view
            $0.w_controllEvent(.touchUpInside) <- $click
        }
        
       
    
       
        label.w.top >> label.w.left == 10
        label.w.width == 100
        label.w.height == 100

        button.w.top == 200
        button.w.left == 10
        button.w.width >> button.w.height == 100
        
        click  = "dddddd"
        $click.call {[weak self] value in
            print(value)
            self?.present(TestViewController(), animated: true)
        }
       
        let table = View(UITableView()) {
            $0.w_array <- $array
            $0.w_offset <- $offset
            $0.w_superview =  self.view
            $0.estimatedRowHeight = 50
            $0.w_delegate?.register(StudCell.self, Studentaa.self) { cell, model, index in
                cell.title = model.title

            } select: { model, index in
                print(index.row)
            }
        }
        
        table.w.top == 300
        table.w.left == 0
        table.w.width == 100
        table.w.height == 500
        
        

        
        var array = [Any]()
        for i in 0..<10 {
            let s = Studentaa()
            s.title = "dfdf"
            array.append(s)
        }
        self.array = array
        
        let scroller = View(UIScrollView()) {
//            $0.w_offset <- $offset
            $0.w_superview =  self.view
            $0.contentSize = CGSize.init(width: 100, height: 200)
            $0.backgroundColor = .red
        }
        
        scroller.w.top == 300
        scroller.w.left == 100
        scroller.w.width >> scroller.w.height == 100
        offset = CGPoint.init(x: 0, y: 20)
        $offset.call { p in
            print(p)
        }
        
        let textView = View(UITextView()) {
            $0.w_text <- $editor
            $0.w_superview =  self.view
            $0.backgroundColor = .yellow
        }
        
        textView.w.top == 400
        textView.w.left == 100
        textView.w.width >> textView.w.height == 100
        $editor.call { p in
            print(p)
        }
    }
    @WObserver
    var editor:String?
    @WObserver
    var click:String?
    @WObserver
    var array:[Any]?
    
    @WObserver
    var offset:CGPoint?
}

class Studentaa {
    var title:String?
}

class StudCell:UITableViewCell {
    @WObserver
    var title:String?
    @WObserver
    var click:String?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let label = View(UILabel()) {
            $0.textColor = .black
            $0.w_text <- $title
            $0.w_superview =  self.contentView
            $0.font = UIFont.systemFont(ofSize: 30)

        }
        label.w.top >> label.w.left == 0
        label.w.right == 0
        label.w.height == 50
        
        let button = View(UIButton()) {
            $0.backgroundColor = UIColor.red
            $0.w_superview =  self.contentView
            $0.w_controllEvent(.touchUpInside) <- $click
        }
        
        button.w.top >> label.w.bottom == 0
        button.w.width >> button.w.height == 30
        button.w.bottom == 0
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
