//
//  EquipmentModelTests.swift
//  ITLabTests
//
//  Created by Даниил on 11.07.2021.
//

import XCTest
@testable import ITLab

extension EquipmentModel: Equatable {
    public static func == (lhs: EquipmentModel, rhs: EquipmentModel) -> Bool {
        return (
            lhs.id == rhs.id &&
            lhs.description == rhs.description &&
            lhs.serialNumber == rhs.serialNumber &&
            lhs.number == rhs.number &&
            lhs.equipmentTypeId == rhs.equipmentTypeId &&
            lhs.equipmentType == rhs.equipmentType &&
            lhs.ownerId == rhs.ownerId &&
            lhs.parentId == rhs.parentId
        )
    }
    
    
}

class EquipmentModelTests: XCTestCase {

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
    
    func testCodable() throws {
        let model = EquipmentModel(id: "some_id", serialNumber: "some_serial_number", description: "some_description", number: 12, equipmentTypeId: "some_id", equipmentType: EquipmentTypeModel(id: "some_id", title: "some_title", description: "some_description", shortTitle: "some_short_title"), ownerId: "some_owner_id", parentId: "some_parent_id")
        
        let jsonEncoder = JSONEncoder()
        
        let data = try jsonEncoder.encode(model)
        
        let jsonDecoder = JSONDecoder()
        
        let decodedModel = try jsonDecoder.decode(EquipmentModel.self, from: data)
        
        XCTAssertEqual(model, decodedModel)
    }
    
    func testCodableOptionalNil() throws {
        let model = EquipmentModel(id: "some_id", serialNumber: "some_serial_number", description: "some_description", number: 12, equipmentTypeId: "some_id", equipmentType: EquipmentTypeModel(id: "some_id", title: "some_title", description: "some_description", shortTitle: "some_short_title"))
        
        let jsonEncoder = JSONEncoder()
        
        let data = try jsonEncoder.encode(model)
        
        let jsonDecoder = JSONDecoder()
        
        let decodedModel = try jsonDecoder.decode(EquipmentModel.self, from: data)
        
        XCTAssertEqual(model, decodedModel)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
