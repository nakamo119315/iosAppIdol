//
//  MeetAndGreetUITests.swift
//  MeetAndGreetUITests
//
//  Created by 中本竣介 on 2025/12/14.
//

import XCTest

class MeetAndGreetUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Tab Navigation Tests

    func testTabBarExists() throws {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.exists)
    }

    func testAllTabsExist() throws {
        XCTAssertTrue(app.tabBars.buttons["スケジュール"].exists)
        XCTAssertTrue(app.tabBars.buttons["家計簿"].exists)
        XCTAssertTrue(app.tabBars.buttons["リハーサル"].exists)
        XCTAssertTrue(app.tabBars.buttons["レポ"].exists)
    }

    func testTabNavigation() throws {
        // Navigate to 家計簿
        app.tabBars.buttons["家計簿"].tap()
        XCTAssertTrue(app.navigationBars["家計簿"].exists)

        // Navigate to リハーサル
        app.tabBars.buttons["リハーサル"].tap()
        XCTAssertTrue(app.navigationBars["リハーサル"].exists)

        // Navigate to レポ
        app.tabBars.buttons["レポ"].tap()
        XCTAssertTrue(app.navigationBars["レポ"].exists)

        // Navigate back to スケジュール
        app.tabBars.buttons["スケジュール"].tap()
        XCTAssertTrue(app.navigationBars["スケジュール"].exists)
    }

    // MARK: - Schedule Tests

    func testScheduleAddButton() throws {
        app.tabBars.buttons["スケジュール"].tap()

        let addButton = app.navigationBars.buttons.element(boundBy: 0)
        XCTAssertTrue(addButton.exists)
    }

    func testScheduleAddFlow() throws {
        app.tabBars.buttons["スケジュール"].tap()

        // Tap add button
        app.navigationBars.buttons.element(boundBy: 0).tap()

        // Check editor appears
        XCTAssertTrue(app.navigationBars["新規イベント"].waitForExistence(timeout: 2))

        // Fill in title
        let titleField = app.textFields["イベント名"]
        if titleField.exists {
            titleField.tap()
            titleField.typeText("テストライブ")
        }

        // Cancel
        app.buttons["キャンセル"].tap()

        // Verify we're back to list
        XCTAssertTrue(app.navigationBars["スケジュール"].exists)
    }

    // MARK: - Budget Tests

    func testBudgetScreenElements() throws {
        app.tabBars.buttons["家計簿"].tap()

        // Check navigation bar exists
        XCTAssertTrue(app.navigationBars["家計簿"].exists)
    }

    func testBudgetAddFlow() throws {
        app.tabBars.buttons["家計簿"].tap()

        // Tap add button
        app.navigationBars.buttons.element(boundBy: 0).tap()

        // Check editor appears
        XCTAssertTrue(app.navigationBars["新規支出"].waitForExistence(timeout: 2))

        // Cancel
        app.buttons["キャンセル"].tap()
    }

    // MARK: - Practice Tests

    func testPracticeScreenElements() throws {
        app.tabBars.buttons["リハーサル"].tap()
        XCTAssertTrue(app.navigationBars["リハーサル"].exists)
    }

    func testPracticeAddFlow() throws {
        app.tabBars.buttons["リハーサル"].tap()

        // Tap add button
        app.navigationBars.buttons.element(boundBy: 0).tap()

        // Check editor appears
        XCTAssertTrue(app.navigationBars["新規スクリプト"].waitForExistence(timeout: 2))

        // Cancel
        app.buttons["キャンセル"].tap()
    }

    // MARK: - Report Tests

    func testReportScreenElements() throws {
        app.tabBars.buttons["レポ"].tap()
        XCTAssertTrue(app.navigationBars["レポ"].exists)
    }

    func testReportAddFlow() throws {
        app.tabBars.buttons["レポ"].tap()

        // Tap add button
        app.navigationBars.buttons.element(boundBy: 0).tap()

        // Check editor appears
        XCTAssertTrue(app.navigationBars["新規レポート"].waitForExistence(timeout: 2))

        // Cancel
        app.buttons["キャンセル"].tap()
    }

    // MARK: - Empty State Tests

    func testScheduleEmptyState() throws {
        app.tabBars.buttons["スケジュール"].tap()

        // If empty, should show empty state message
        let emptyMessage = app.staticTexts["イベントがありません"]
        if emptyMessage.exists {
            XCTAssertTrue(app.buttons["イベントを追加"].exists)
        }
    }

    func testBudgetEmptyState() throws {
        app.tabBars.buttons["家計簿"].tap()

        let emptyMessage = app.staticTexts["この月の支出はありません"]
        if emptyMessage.exists {
            XCTAssertTrue(app.buttons["支出を追加"].exists)
        }
    }

    // MARK: - Launch Performance

    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
