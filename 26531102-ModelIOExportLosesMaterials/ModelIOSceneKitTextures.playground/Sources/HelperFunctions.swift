import Cocoa

//MARK: - File utilities
/*:
 Retrieves the URL of the user's documents directory.
 */
public func documentsDirectoryURL() -> NSURL {
    let fm = NSFileManager.defaultManager()
    let url = fm.URLsForDirectory(
        .DocumentDirectory,
        inDomains: .UserDomainMask)[0]
    
    return url
}
/*:
 Creates a directory (and any intermediates) if directory does not exist.
 */
public func ensureDirectoryExists(directoryURL: NSURL) {
    let fm = NSFileManager.defaultManager()
    do {
        try fm.createDirectoryAtURL(directoryURL, withIntermediateDirectories: true, attributes: [:])
        var isDirectory:ObjCBool = false
        let success = fm.fileExistsAtPath(directoryURL.path!, isDirectory: &isDirectory)
        assert(success && isDirectory)
    }
    catch let e {
        fatalError("Failed to create directory \(directoryURL): \(e)")
    }
}

//MARK: - Image Utilities
/**
 Uses a block to render an image.
 */
public func renderImage(size: CGSize, opaque: Bool, scale: CGFloat, render : (context: CGContext, bounds: CGRect, scale: CGFloat) -> ()) -> NSImage {
    
    let image = NSImage(size: size)
    image.lockFocus()
    let nsContext = NSGraphicsContext.currentContext()!
    let ctx = nsContext.CGContext
    let bounds = CGRect(origin: CGPointZero, size: size)
    render(context:ctx, bounds:bounds, scale:scale)
    image.unlockFocus()
    return image
}
/**
 Renders a "house" at a given position with a given color.
 */
public func createImage(x: CGFloat, _ y:CGFloat, _ color:NSColor) -> NSImage {
    let image = renderImage(CGSizeMake(100,100), opaque: true, scale:1.0) { ctx, bounds, scale in
        let r = bounds.insetBy(dx: 10, dy: 20)
        
        CGContextFillRect(ctx, r)
        let path = house(x,y,10,10)
        color.setFill()
        path.fill()
    }
    return image
}
/**
 Creates a "house" path.
 */
public func house( x:CGFloat, _ y:CGFloat, _ dx: CGFloat, _ dy:CGFloat) -> NSBezierPath {
    var x = x
    var y = y
    let path = NSBezierPath()

    path.moveToPoint(NSMakePoint(x,y))
    y += dy
    path.lineToPoint(NSMakePoint(x,y))
    x += dx
    y += dy
    path.lineToPoint(NSMakePoint(x,y))
    x += dx
    y -= dy
    path.lineToPoint(NSMakePoint(x,y))
    y-=dy
    path.lineToPoint(NSMakePoint(x,y))
    return path
}



