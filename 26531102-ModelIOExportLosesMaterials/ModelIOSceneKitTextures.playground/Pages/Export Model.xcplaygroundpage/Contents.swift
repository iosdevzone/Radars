/*:
 
 ## Model I/O loses materials on asset export to .OBJ format.
 */

import Cocoa
import SceneKit
import ModelIO
import SceneKit.ModelIO
import XCPlayground

/*:
 First create a scene with some materials
 */
let diffuse = createImage(30,50,NSColor.greenColor())
let emission = createImage(50,50,NSColor.redColor())
let specular = createImage(40,50,NSColor.whiteColor())

func createScene() -> SCNScene {
    let geometry = SCNPlane(width: 1.0, height: 1.0)
    let node = SCNNode(geometry: geometry)
    node.geometry!.firstMaterial!.diffuse.contents = diffuse
    node.geometry!.firstMaterial!.specular.contents = specular
    node.geometry!.firstMaterial!.emission.contents = emission
    let scene = SCNScene()
    scene.rootNode.addChildNode(node)
    return scene
}

/*:
 Creates a scene view to view results.
 */
 
func createSceneViewWithScene(scene: SCNScene) -> SCNView {
    let api = NSNumber(unsignedLong:SCNRenderingAPI.OpenGLCore32.rawValue)
    let sceneView = SCNView(frame:NSRect(x:0, y:0, width: 200, height:200), options: [SCNPreferredRenderingAPIKey:api])
    sceneView.scene = scene
    sceneView.allowsCameraControl = true
    sceneView.autoenablesDefaultLighting = true
    return sceneView
}


/*:
 Exports a scene.
 Have to double-check that a file was really produced because <rdar://26530184>
 */
func exportScene(scene: SCNScene, toURL url: NSURL)  {
    let asset = MDLAsset(SCNScene: scene)
    var success = asset.exportAssetToURL(url)
    if !success {
        fatalError("FATAL ERROR: Failed to export scene.")
    }
    let fm = NSFileManager.defaultManager()
    success = fm.fileExistsAtPath(url.path!)
    if (!success) {
        fatalError("FATAL ERROR: Export returned true, but no output file was found.")
    }
    
}
/*:
 Imports the scene
 */
func importScene(fileURL:NSURL) -> SCNScene {
    let asset = MDLAsset(URL: fileURL)
    return SCNScene(MDLAsset: asset)
}

/*:
 We'll need a suitable URL to read and write to.
 We use a directory named "ModelIOTests" in the user's Documents directory.
 
*/
let docsURL = documentsDirectoryURL()
let exportDirURL = docsURL.URLByAppendingPathComponent("ModelIOTests")
ensureDirectoryExists(exportDirURL)
let sceneURL = exportDirURL.URLByAppendingPathComponent("model.obj")

let originalScene = createScene()
exportScene(originalScene, toURL: sceneURL)
let importedScene = importScene(sceneURL)

print("Scene URL: \(sceneURL)")

/*:
Create scene view with the original and imported scenes and stack them into a container view to show the results.
 */
let originalSceneView = createSceneViewWithScene(originalScene)
let importedSceneView = createSceneViewWithScene(importedScene)

let containerView = NSView(frame: NSMakeRect(0,0,200,400))
containerView.addSubview(originalSceneView)
originalSceneView.frame =  NSMakeRect(0,0,200,200)
containerView.addSubview(importedSceneView)
originalSceneView.frame =  NSMakeRect(0,200,200,200)

XCPlaygroundPage.currentPage.liveView = containerView

