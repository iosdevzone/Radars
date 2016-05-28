/*:
 
## Model I/O exportAssetToUrl() returns true even when it fails
 
See: <http://openradar.appspot.com/26530184>
*/

import Cocoa
import ModelIO
import SceneKit
import SceneKit.ModelIO

/*:
 First a few convenience functions:
 
 
 Creates a minimal scene
*/
func createSimpleScene() -> SCNScene {
    let scene = SCNScene()
    scene.rootNode.addChildNode(SCNNode(geometry: SCNSphere(radius: 1.0)))
    return scene
}

/*:
 Checks whether the scene really was exported.
 */
func verifyExportOfScene(scene:SCNScene, toURL url:NSURL) -> Bool {
    let asset = MDLAsset(SCNScene: scene)
    if asset.exportAssetToURL(url) {
        print("Checking for file at URL = \(url)")
        let reallyWorked = NSFileManager.defaultManager().fileExistsAtPath(url.path!)
        if reallyWorked {
            return true
        }
        else {
            fatalError("Just kidding! Although I returned true I didn't real save your file!")
        }
    } else {
        return false
    }
}

/*:
 Construct two URLs, one to an existent directory and one to a non-existent directory.
*/
let docDirURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
let validURL = docDirURL.URLByAppendingPathComponent("model.obj")
let invalidURL = docDirURL.URLByAppendingPathComponent("\(NSUUID().UUIDString)/model.obj")

let scene = createSimpleScene()
/*:
 This should succeed and indeed does.
 */
let expectTrue = verifyExportOfScene(scene, toURL:validURL)
assert(expectTrue == true)
/*:
 This will fatalError in the verification routine because `exportAssetToURL()` returned `true` but did not write a file.
*/
let expectFalse = verifyExportOfScene(scene, toURL:invalidURL)
assert(expectFalse == false)




