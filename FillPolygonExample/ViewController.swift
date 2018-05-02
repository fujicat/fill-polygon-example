//
//  ViewController.swift
//  FillPolygonExample
//
//  Created by 片桐孝昌 on 2018/04/25.
//  Copyright © 2018年 片桐孝昌. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        let v = view as? BezierLinesView
        v?.setup()
        v?.fill()
        v?.beginDraw()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

