////////////////////////////////////////////////////////////////////////////////
//
//  DependencyContainerTests.swift
//  CoreTests
//
//  Created by Iurii Khomiak on 8/28/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import XCTest
@testable import Core

////////////////////////////////////////////////////////////////////////////////
class DependencyContainerTests: XCTestCase
{
    func testDependencyContainerUnique() throws
    {
        let container = DependencyContainer()
        
        //! Registration
        container.register(StubDependency3.self) { _ in StubDependency3Imp() }
        container.register(StubDependency2.self)
            { StubDependency2Imp(dependency3: try $0.resolve(StubDependency3.self)) }
        container.register(StubDependency1.self) { _ in StubDependency1Imp() }
        container.register(StubService.self)
        {
            try StubServiceImp(dependency1: $0.resolve(StubDependency1.self),
                dependency2: $0.resolve(StubDependency2.self))
        }
        
        //! MARK: - Resolve
        let service1: StubService = try container.resolve(StubService.self)
        let service2: StubService = try container.resolve(StubService.self)
        XCTAssertFalse(service1 === service2)
    }
    
    func testDependencyContainerSingleton() throws
    {
        let container = DependencyContainer()
        
        //! Registration
        container.register(StubDependency3.self) { _ in StubDependency3Imp() }
        container.register(StubDependency2.self)
            { StubDependency2Imp(dependency3: try $0.resolve(StubDependency3.self)) }
        container.register(StubDependency1.self) { _ in StubDependency1Imp() }
        container.register(StubService.self, in: .singleton)
        {
            try StubServiceImp(dependency1: $0.resolve(StubDependency1.self),
                dependency2: $0.resolve(StubDependency2.self))
        }
        
        //! MARK: - Resolve
        let service1: StubService = try container.resolve(StubService.self)
        let service2: StubService = try container.resolve(StubService.self)
        XCTAssertTrue(service1 === service2)
    }    
}
