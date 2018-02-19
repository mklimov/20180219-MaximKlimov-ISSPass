//
//  ISS_PassesTests.swift
//  ISS PassesTests
//
//  Created by Maxim Klimov on 2/17/18.
//  Copyright © 2018 IBM. All rights reserved.
//

import XCTest
@testable import ISS_Passes

class ISS_PassesTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // testOpenNotifyAPI_endpoint
    func testOpenNotifyAPI_endpoint() {
        let latitude = "45.0"
        let longitude = "-122.3"
        let altitude = "20"
        let passes = "10"
        
        let url = ISS_Passes.OpenNotifyAPIManager.endpointForISSPassInfo(latitude, longitude, altitude, passes)
        
        XCTAssertNotEqual(url, "", "URL can't be empty")
    }
    
    // testOpenNotifyAPI_retrieveISSPasses_Valid_data
    func testOpenNotifyAPI_retrieveISSPasses_Valid_data() {
        // create expectation object
        let expectation = self.expectation(description: "Testing OpenNotifyAPIManager with Valid data")
        
        let latitude = "45.0"
        let longitude = "-122.3"
        let altitude = "20"
        let passes = "10"
        
        // make API call
        ISS_Passes.OpenNotifyAPIManager.retrieveISSPasses(latitude, longitude, altitude, passes) { (passesInfo, error) in
            XCTAssert(error == nil)
            XCTAssert(passesInfo != nil)
            XCTAssert(passesInfo?.response != nil)
            XCTAssert(passesInfo!.response.count > 0)
            
            // fulfill expectation
            expectation.fulfill()
        }
        
        // wait for the expectation to be fulfilled
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectations errored: \(error)")
            }
        }

    }
    
    // testOpenNotifyAPI_retrieveISSPasses_Invalid_data
    func testOpenNotifyAPI_retrieveISSPasses_Invalid_data() {
        // create expectation object
        let expectation = self.expectation(description: "Testing OpenNotifyAPIManager with Invalid data")
        
        let latitude = "145.0"  // invalid
        let longitude = "-122.3"
        let altitude = "-20"    // invalid
        let passes = "10"
        
        // make API call
        ISS_Passes.OpenNotifyAPIManager.retrieveISSPasses(latitude, longitude, altitude, passes) { (passesInfo, error) in
            XCTAssert(error != nil)
            XCTAssert(passesInfo == nil)
            
            // fulfill expectation
            expectation.fulfill()
        }
        
        // wait for the expectation to be fulfilled
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectations errored: \(error)")
            }
        }
        
    }
    
}
