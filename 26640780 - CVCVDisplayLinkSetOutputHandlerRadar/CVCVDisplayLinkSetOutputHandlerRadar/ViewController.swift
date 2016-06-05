//
//  ViewController.swift
//  CVCVDisplayLinkSetOutputHandlerRadar
//
//  Created by idz on 6/4/16.
//  Copyright © 2016 iOS Developer Zone. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet var openGLView: OpenGLView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.openGLView.renderer = MinimalRenderer()
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

