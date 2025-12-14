//
//  MeetAndGreetUITestsLaunchTests.swift
//  MeetAndGreetUITests
//
//  Created by 中本竣介 on 2025/12/14.
//

import XCTest

class MeetAndGreetUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testScheduleTabScreenshot() throws {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["スケジュール"].tap()

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Schedule Tab"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testBudgetTabScreenshot() throws {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["家計簿"].tap()

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Budget Tab"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testPracticeTabScreenshot() throws {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["リハーサル"].tap()

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Practice Tab"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testReportTabScreenshot() throws {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["レポ"].tap()

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Report Tab"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
