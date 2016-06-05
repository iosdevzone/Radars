let useBlock = false
//
//  WireframeViewOpenGL.swift
//  WireframeViewerOpenGLOSX
//
//  Created by idz on 6/2/16.
//  Copyright © 2016 iOS Developer Zone. All rights reserved.
//

import Cocoa
import OpenGL.GL3

class OpenGLView : NSOpenGLView {
    var renderer : Renderable? = nil
    var displayLink: CVDisplayLink? = nil

    
    /**
    Customizes the pixel format options.
    */
    override  class func defaultPixelFormat() -> NSOpenGLPixelFormat {
        let intAttributes  = [ NSOpenGLPFADoubleBuffer,
                               NSOpenGLPFADepthSize, 8,
                              
            NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersion3_2Core , 0]
        let attributes = intAttributes.map { NSOpenGLPixelFormatAttribute($0) }
        if let pixelFormat = NSOpenGLPixelFormat(attributes: attributes) {
            return pixelFormat
        }
        else {
            NSLog("WireframeViewOpenGL: Failed to create desired pixel format using inherited value. This is probably not what you want.")
            return super.defaultPixelFormat()
        }
    }
    
    /**
    Called (once) when the OpenGL context has been established.
    */
    override func prepareOpenGL() {
        withLockedContext("renderFrame") { renderer in
            renderer.prepare()
        }
        if useBlock {
            setupDisplayLinkWithBlock()
        }
        else {
            setupDisplayLinkWithCallback()
        }
    }
    
    /**
    Called when a new frame should be rendered.
    */
    func renderFrame() {
        withLockedContext("renderFrame") { renderer in
            renderer.render()
        }
    }
    
    /**
    Called when an area of the view needs to be redrawn.
    */
    override func drawRect(rect: NSRect) {
        glViewport(GLint(rect.origin.x), GLint(rect.origin.y), GLsizei(rect.size.width), GLsizei(rect.size.height))
        renderFrame()
    }
    
    /**
    Calls a block while holding a lock on the CGLContext.
    Used by `prepareOpenGL` and `renderFrame`.
    */
    func withLockedContext(label: String, block: (Renderable) -> Void) {
        guard let context = self.openGLContext else {
            NSLog("WARNING: nil openGLContext in \(label)")
            return
        }
        
        guard let renderer = self.renderer else {
            NSLog("WARNING: nil renderer in \(label)")
            return
        }
        
        CGLLockContext(context.CGLContextObj)
        context.makeCurrentContext()
        
        block(renderer)
        
        CGLFlushDrawable(context.CGLContextObj)
        CGLUnlockContext(context.CGLContextObj)
    }

    /**
    Converts a core view error code into a developer-friendly string.
    */
    func stringFromCVReturn(expression: CVReturn) -> String {
        switch expression {
        case kCVReturnSuccess: return "kCVReturnSuccess"
        case kCVReturnInvalidDisplay: return "kCVReturnInvalidDisplay"
        case kCVReturnDisplayLinkAlreadyRunning: return "kCVReturnDisplayLinkAlreadyRunning"
        case kCVReturnDisplayLinkNotRunning: return "kCVReturnDisplayLinkNotRunning"
        case kCVReturnDisplayLinkCallbacksNotSet: return "kCVReturnDisplayLinkCallbacksNotSet"
        default: return "Unexpected CVReturn value \(expression)/"
        }
    }
    
    /**
    Error checks Core Video call.
    */
    func errorCheck(expression: CVReturn) {
        precondition(expression == kCVReturnSuccess, "A CoreVideo routine failed \(stringFromCVReturn(expression)).")
    }
    
    /**
    Starts the display link.
    This is common code use by both `setupDisplayLinkWithCallback` and `setupDisplayLinkWithBlock`
    */
    func startDisplayLink(displayLink: CVDisplayLink) {
        if let openGLContext = self.openGLContext {
            NSLog("Starting display link....")
            errorCheck(CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(displayLink, openGLContext.CGLContextObj, openGLContext.pixelFormat.CGLPixelFormatObj))
            errorCheck(CVDisplayLinkStart(displayLink))
        }
    }
    /**
     Sets up a `CVDisplayLink` using an old-style C callback using `CVDisplayLinkSetOutputCallback`
     */
    func setupDisplayLinkWithCallback() {
        
        func displayLinkOutputCallback(
            displayLink: CVDisplayLink, _ inNow: UnsafePointer<CVTimeStamp>,
            _ inOutputTime: UnsafePointer<CVTimeStamp>,
            _ flagsIn: CVOptionFlags,
            _ flagsOut: UnsafeMutablePointer<CVOptionFlags>,
            _ displayLinkContext: UnsafeMutablePointer<Void>) -> CVReturn {
            
                unsafeBitCast(displayLinkContext, OpenGLView.self).renderFrame()
                return kCVReturnSuccess
        }
        CVDisplayLinkCreateWithActiveCGDisplays(&self.displayLink)
        if let displayLink = self.displayLink {
            CVDisplayLinkSetOutputCallback(displayLink, displayLinkOutputCallback, UnsafeMutablePointer<Void>(unsafeAddressOf(self)))
            
            self.startDisplayLink(displayLink)
        }
    }
    /**
    Sets up (or rather attempts to set up) a `CVDisplayLink` using new 10.11 hotness `CVDisplayLinkSetOutputHandler`.
    This ends up failing.
    */
    func setupDisplayLinkWithBlock() {
        CVDisplayLinkCreateWithActiveCGDisplays(&self.displayLink)
        if let displayLink = self.displayLink {
            errorCheck(CVDisplayLinkSetOutputHandler(displayLink) { [weak self] _,_,_,_,_ in
                if let strongSelf = self {
                    strongSelf.renderFrame()
                }
                return kCVReturnSuccess
            })
            startDisplayLink(displayLink)
        }
    }
}


