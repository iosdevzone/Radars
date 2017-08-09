//
//  ModelIOExportRadarTests.swift
//  ModelIOExportRadarTests
//
//  Created by idz on 8/8/17.
//  Copyright © 2017 iOS Developer Zone. All rights reserved.
//

import XCTest
import ModelIO
import SceneKit
import SceneKit.ModelIO

let verbose = true

func createSimpleScene() -> SCNScene {
    let scene = SCNScene()
    scene.rootNode.addChildNode(SCNNode(geometry: SCNSphere(radius: 1.0)))
    return scene
}

func verifyExportOfScene(_ scene:SCNScene, toURL url:URL) -> (fileWritten: Bool, exceptionThrown: Bool) {
    let asset = MDLAsset(scnScene: scene)
    var fileWritten = false, exceptionThrown = false
    do {
        try asset.export(to: url)
        fileWritten = FileManager.default.fileExists(atPath: url.path)
    }
    catch let e {
        if verbose {
            print("Caught exception: \(e)")
        }
        exceptionThrown = true
    }
    return (fileWritten: fileWritten, exceptionThrown: exceptionThrown)
}

func verifyExportOfString(_ string: String, toURL url: URL) -> (fileWritten: Bool, exceptionThrown: Bool) {
    
    var fileWritten = false, exceptionThrown = false
    do {
        try string.write(to: url, atomically: true, encoding: .utf8)
        fileWritten = FileManager.default.fileExists(atPath: url.path)
    }
    catch let e {
        if verbose {
            print("Caught exception: \(e)")
        }
        exceptionThrown = true
    }
    return (fileWritten: fileWritten, exceptionThrown: exceptionThrown)
}

class ModelIOExportRadarTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testModelExport() {
        let docDirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let validURL = docDirURL.appendingPathComponent("model.obj")
        let invalidURL = docDirURL.appendingPathComponent("\(NSUUID().uuidString)/model.obj")
        
        let scene = createSimpleScene()
        
        let result = verifyExportOfScene(scene, toURL:validURL)
        XCTAssert(result.fileWritten == true && result.exceptionThrown == false)
        
        let expectFalse = verifyExportOfScene(scene, toURL:invalidURL)
        XCTAssert(expectFalse.fileWritten == false && expectFalse.exceptionThrown == true,
                  "expected result (fileWritten: false, exceptionThrown: true) acutal result \(expectFalse)")
        
    }
    
    func testMeaningfulError() {
        let docDirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let invalidURL = docDirURL.appendingPathComponent("\(NSUUID().uuidString)/model.obj")
        
        let scene = createSimpleScene()
        do {
            let asset = MDLAsset(scnScene: scene)
            try asset.export(to: invalidURL)
            XCTAssert(false, "Should not get here. Error should be thrown.")
        }
        catch let e {
            let errorString = "\(e)"
            XCTAssert(errorString != "nilError", "Error should be meaningful; nilError is not.")
        }
    }
    
    func testStringExport() {
        let testString = "The quick brown fox jumped over the laxy dog."
        let fileName = "string.txt"
        let docDirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let validURL = docDirURL.appendingPathComponent(fileName)
        let invalidURL = docDirURL.appendingPathComponent("\(NSUUID().uuidString)/\(fileName)")
        
        var result = verifyExportOfString(testString, toURL: validURL)
        XCTAssert(result.fileWritten == true && result.exceptionThrown == false)
        
        result = verifyExportOfString(testString, toURL: invalidURL)
        XCTAssert(result.fileWritten == false && result.exceptionThrown == true)
    }
}
