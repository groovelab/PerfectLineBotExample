//
//  PerfectLineBotExampleTests.swift
//  PerfectLineBotExampleTests
//
//  Created by Takeo Namba on 2016/04/16.
//  Copyright GrooveLab
//

import XCTest
@testable import PerfectLineBotExample
import PerfectLib

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
        XCTAssertEqual("Filename".hmacSHA256(key: "Password"), "X+KuBv+YKLM/4wRUUomj9ZC/2UjKmrcxyYA3mZLvQfE=")
        XCTAssertEqual("Message".hmacSHA256(key: "secret"), "qnR8UCqJggD55PohusaBNviGoOJ67HC6Btry4qXLVZc=")

        let file = File("Resources/requestBody.json")
        XCTAssert(file.exists())
        try! file.openRead()
        let requestBodyJson = try! file.readString()
        XCTAssertEqual(requestBodyJson.hmacSHA256(key: "testsecret"), "kPXp0nPWSzfWAapWHiesbcztpKnXJoX8krCa1CcTghk=")
    }
}
