//
//  Renderable.swift
//  CVCVDisplayLinkSetOutputHandlerRadar
//
//  Created by idz on 6/4/16.
//  Copyright © 2016 iOS Developer Zone. All rights reserved.
//

import Foundation

protocol Renderable {
    /**
    Called once after the OpenGL context is initialized.
    Load your models, textures, etc. here.
    */
    func prepare()
    /**
    Called to render each frame
    */
    func render()
}
