//
//  MinimalRenderer.swift
//  CVCVDisplayLinkSetOutputHandlerRadar
//
//  Created by idz on 6/5/16.
//  Copyright © 2016 iOS Developer Zone. All rights reserved.
//

import Foundation
import OpenGL.GL3

class MinimalRenderer: Renderable {
    
    var red: GLfloat = 0.5
    var green: GLfloat = 0.5
    var blue: GLfloat = 0.5
    
    func prepare() {
        
    }
    
    func permute(value: GLfloat) -> GLfloat {
        var value = value
        let d = GLfloat(0.01)
        switch arc4random_uniform(3) {
        case 0:
            value -= d
            return (value < 0.0) ? 1.0 : value
        case 1:
            return value
        case 2:
            value += d
            return (value > 1.0) ? 0.0 : value
        default:
            debugPrint("Wasn't expecting that!")
            return value
        }
    }
    
    func render() {
        glClearColor(self.red, self.green, self.blue, GLfloat(1.0))
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        self.red = permute(self.red)
        self.green = permute(self.green)
        self.blue = permute(self.blue)
    }
    
}