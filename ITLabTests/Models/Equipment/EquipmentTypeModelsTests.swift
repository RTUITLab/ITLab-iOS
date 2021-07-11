//
//  EquipmentTypeModelsTests.swift
//  ITLabTests
//
//  Created by Даниил on 11.07.2021.
//

import XCTest
@testable import ITLab

extension EquipmentTypeModel: Equatable {
    public static func == (lhs: EquipmentTypeModel, rhs: EquipmentTypeModel) -> Bool {
        return (
            lhs.id == rhs.id &&
            lhs.description == rhs.description &&
            lhs.title == rhs.title &&
            lhs.shortTitle == rhs.shortTitle &&
            lhs.rootId == rhs.rootId &&
            lhs.parentId == rhs.parentId
        )
    }
    
    
}


class EquipmentTypeModelsTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testCoding() throws {
        let model = EquipmentTypeModel(id: "some_id", title: "some_title", description: "some_description", shortTitle: "some_shot_title", rootId: "some_root_id", parentId: "some_parent_id")
        
        let jsonEncoder = JSONEncoder()
        
        var data = try jsonEncoder.encode(model)
        
        let jsonDecoder = JSONDecoder()
        
        let decodedModel = try jsonDecoder.decode(EquipmentTypeModel.self, from: data)
        
        XCTAssertEqual(model, decodedModel)
    }
    
    func testCodingOptionalNils() throws {
        let model = EquipmentTypeModel(id: "some_id", title: "some_title", description: "some_description", shortTitle: "some_shot_title", rootId: nil, parentId: nil)
        
        let jsonEncoder = JSONEncoder()
        
        var data = try jsonEncoder.encode(model)
        
        let jsonDecoder = JSONDecoder()
        
        let decodedModel = try jsonDecoder.decode(EquipmentTypeModel.self, from: data)
        
        XCTAssertEqual(model, decodedModel)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
