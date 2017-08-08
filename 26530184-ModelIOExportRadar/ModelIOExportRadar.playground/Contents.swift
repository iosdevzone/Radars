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
func verifyExportOfScene(_ scene:SCNScene, toURL url:URL) -> Bool {
    let asset = MDLAsset(scnScene: scene)
    do {
        try asset.export(to: url)
        let reallyWorked = FileManager.default.fileExists(atPath: url.path)
        if reallyWorked {
            return true
        }
        else {
            fatalError("Just kidding! I didn't write your file, but did not throw an error!")
        }
    }
    catch let e {
        print("Caught expected error \(e)")
        return false
    }
}

/*:
 Construct two URLs, one to an existent directory and one to a non-existent directory.
*/
let docDirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
let validURL = docDirURL.appendingPathComponent("model.obj")
let invalidURL = docDirURL.appendingPathComponent("\(NSUUID().uuidString)/model.obj")

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




