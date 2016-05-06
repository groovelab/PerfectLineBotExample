//
//  PerfectLineBotExampleTests.swift
//  PerfectLineBotExampleTests
//
//  Created by Takeo Namba on 2016/04/16.
//  Copyright GrooveLab
//

import XCTest
@testable import PerfectLineBotExample

class PerfectLineBotExampleTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testHmacSHA256() {
        let key = "Password"
        let message = "Filename"
        let digest = message.hmacSHA256(key: key)
        XCTAssertEqual(digest, "X+KuBv+YKLM/4wRUUomj9ZC/2UjKmrcxyYA3mZLvQfE=")
    }
    
}
