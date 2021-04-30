//
//  ITLabUITests.swift
//  ITLabUITests
//
//  Created by Mikhail Ivanov on 30.04.2021.
//

import XCTest

class ITLabUITests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.

        XCUIApplication().launch()
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
        
    }
    
    func testAuthorize() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        
        if (app.buttons["Войти"].exists) {
            app.buttons["Войти"].tap()
        } else {
            XCTFail("Приложение уже авторизированно")
        }
        if (app.webViews.webViews.webViews.textFields["Username"].waitForExistence(timeout: 15)) {
                app.webViews.webViews.webViews.textFields["Username"].tap()
                app.webViews.webViews.webViews.textFields["Username"].typeText("") //TODO need secrets file
        } else {
            XCTFail("Не нашел элемент с логином")
        }
        
        if (app.webViews.webViews.webViews.secureTextFields["Password"].exists) {
                app.webViews.webViews.webViews.secureTextFields["Password"].tap()
                app.webViews.webViews.webViews.secureTextFields["Password"].typeText("") //TODO need secrets file
        } else {
            XCTFail("Не нашел элемент с паролем")
        }
        
        if (app.toolbars.matching(identifier: "Toolbar").buttons["Done"].exists) {
            app.toolbars.matching(identifier: "Toolbar").buttons["Done"].tap()
        }
        
        if (app.webViews.webViews.webViews.buttons["dismiss cookie message"].exists) {
            app.webViews.webViews.webViews.buttons["dismiss cookie message"].tap()
        }
        
        if (app.webViews.webViews.webViews.buttons["Login"].exists) {
                app.webViews.webViews.webViews.buttons["Login"].tap()
        } else {
            XCTFail("Не нашел элемент с входом")
        }
        
        if (app.webViews.webViews.webViews.staticTexts["Invalid username or password"].waitForExistence(timeout: 5)) {
            XCTFail("Неправильный логин или пароль")
        }
        
        if (!app.navigationBars["События"].waitForExistence(timeout: 10)) {
            XCTFail("Не смог войти в приложение")
        }
        
        addUIInterruptionMonitor(withDescription: "Contacs permission") { (alert) -> Bool in
            if (alert.buttons["OK"].exists) {
                alert.buttons["OK"].tap()
                return true
            }
            
            return false
        }
        
        app.navigationBars["События"].tap()
    }
    
    func testExit() throws {
        let app = XCUIApplication()
                                
        if (app.buttons["Войти"].exists) {
           try testAuthorize()
        }
        
        if (!app.tabBars.buttons["Профиль"].exists) {
            XCTFail("Нет нижнего бара с кнопкой Профиль")
        }
        app.tabBars.buttons["Профиль"].tap()
        app.tables.buttons["Выход"].tap()
        app.alerts["Выход из аккаунта"].buttons["Да"].tap()
        
        if (!app.buttons["Войти"].waitForExistence(timeout: 10)) {
            XCTFail("Не удалось выйти из приложения")
        }
    }
    
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
