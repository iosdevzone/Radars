//
//  ModelIOExportRadarTestsObjC.m
//  ModelIOExportRadarTests
//
//  Created by Danny Keogan on 8/8/17.
//  Copyright © 2017 iOS Developer Zone. All rights reserved.
//

#import <XCTest/XCTest.h>
@import SceneKit;
@import ModelIO;
@import SceneKit.ModelIO;


static SCNScene* createSimpleScene() {
    SCNScene*  scene = [SCNScene new];
    [scene.rootNode addChildNode:[SCNNode nodeWithGeometry:[SCNSphere sphereWithRadius:1.0]]];
    return scene;
}

static NSURL* documentDirectoryURL() {
    return [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
}

@interface ModelIOExportRadarTestsObjC : XCTestCase

@end

@implementation ModelIOExportRadarTestsObjC

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testModelExportObjC {
    SCNScene *scene = createSimpleScene();
    MDLAsset *asset = [MDLAsset assetWithSCNScene:scene];
    NSError *error = nil;
    NSURL *docDirURL = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
    NSURL *validURL = [docDirURL URLByAppendingPathComponent:@"model.obj"];
    NSURL *invalidURL = [docDirURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@/model.obj", [NSUUID new]]];
    NSLog(@"Generated invalidURL is %@", invalidURL);
    BOOL bSuccess = [asset exportAssetToURL:validURL error:&error];
    BOOL bFileExists = [NSFileManager.defaultManager fileExistsAtPath:[validURL path] isDirectory:nil];
    XCTAssert(bFileExists == YES && bSuccess == YES && error == nil);
    
    bSuccess = [asset exportAssetToURL:invalidURL error:&error];
    bFileExists = [NSFileManager.defaultManager fileExistsAtPath:[invalidURL path] isDirectory:nil];
    XCTAssert(bFileExists == NO, @"Not expecting file to exist");
    XCTAssert(bSuccess == NO, @"Call should return NO indicating file was not written.");
    XCTAssert(error != nil, @"Error should provide information about what went wrong.");
    NSLog(@"Error is %@", error);
}

- (void)testStringExportObjC {
    NSString *testString = @"The quick brown fox jumped over the lazy dog.";
    NSError *error = nil;
    NSURL *docDirURL = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
    NSURL *validURL = [docDirURL URLByAppendingPathComponent:@"string.txt"];
    NSURL *invalidURL = [docDirURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@/string.txt", [NSUUID new]]];
    
    /* Control: this should succeed */
    BOOL bSuccess = [testString writeToURL:validURL atomically:YES encoding:NSUTF8StringEncoding error:&error];
    XCTAssert(bSuccess == YES && error == nil);
    
    bSuccess = [testString writeToURL:invalidURL atomically:YES encoding:NSUTF8StringEncoding error:&error];
    XCTAssert(bSuccess == NO && error != nil);
    
    NSLog(@"Error was %@", error);
    
}



@end
