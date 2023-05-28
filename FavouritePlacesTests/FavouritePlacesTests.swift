//
//  Assignment2WaheedTests.swift
//  Assignment2WaheedTests
//
//  Created by Waheed Hasan on 29/4/2023.
//

import XCTest
@testable import FavouritePlaces

final class FavouritePlacesTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    /// The testExample() function is a test case that verifies specific conditions using assertions.
    func testExample() throws {
        // Get the defaultPlaces array
        let p = defaultPlaces
        
        // Assert that the defaultPlaces array is not nil
        XCTAssertNotNil(p)
        
        // Assert that the first element of the first sublist in the defaultPlaces array is "Japan"
        XCTAssert(p[0][0] == "Japan")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
