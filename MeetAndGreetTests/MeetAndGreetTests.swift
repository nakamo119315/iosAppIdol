//
//  MeetAndGreetTests.swift
//  MeetAndGreetTests
//
//  Created by 中本竣介 on 2025/12/14.
//

import XCTest
import CoreData
@testable import MeetAndGreet

class MeetAndGreetTests: XCTestCase {

    var testContext: NSManagedObjectContext!

    override func setUpWithError() throws {
        // In-memory Core Data stack for testing
        let container = NSPersistentContainer(name: "MeetAndGreet", managedObjectModel: CoreDataStack.managedObjectModel)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]

        let expectation = self.expectation(description: "Load stores")
        container.loadPersistentStores { _, error in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5)

        testContext = container.viewContext
    }

    override func tearDownWithError() throws {
        testContext = nil
    }

    // MARK: - Schedule Entity Tests

    func testScheduleEntityCreation() throws {
        let schedule = ScheduleEntity.create(in: testContext)

        XCTAssertNotNil(schedule.id)
        XCTAssertEqual(schedule.wrappedTitle, "")
        XCTAssertEqual(schedule.wrappedCategory, "ライブ")
        XCTAssertFalse(schedule.isCompleted)
        XCTAssertNotNil(schedule.createdAt)
    }

    func testScheduleEntityUpdate() throws {
        let schedule = ScheduleEntity.create(in: testContext)
        schedule.title = "推しのライブ"
        schedule.location = "東京ドーム"
        schedule.category = EventCategory.live.rawValue

        XCTAssertEqual(schedule.wrappedTitle, "推しのライブ")
        XCTAssertEqual(schedule.wrappedLocation, "東京ドーム")
        XCTAssertEqual(schedule.wrappedCategory, "ライブ")
    }

    func testScheduleCompletionToggle() throws {
        let schedule = ScheduleEntity.create(in: testContext)
        XCTAssertFalse(schedule.isCompleted)

        schedule.isCompleted = true
        XCTAssertTrue(schedule.isCompleted)

        schedule.isCompleted = false
        XCTAssertFalse(schedule.isCompleted)
    }

    // MARK: - Expense Entity Tests

    func testExpenseEntityCreation() throws {
        let expense = ExpenseEntity.create(in: testContext)

        XCTAssertNotNil(expense.id)
        XCTAssertEqual(expense.wrappedTitle, "")
        XCTAssertEqual(expense.amount, 0)
        XCTAssertEqual(expense.wrappedCategory, "チケット")
        XCTAssertFalse(expense.isPaid)
    }

    func testExpenseEntityUpdate() throws {
        let expense = ExpenseEntity.create(in: testContext)
        expense.title = "チケット代"
        expense.amount = 8000
        expense.category = ExpenseCategory.ticket.rawValue
        expense.isPaid = true

        XCTAssertEqual(expense.wrappedTitle, "チケット代")
        XCTAssertEqual(expense.amount, 8000)
        XCTAssertTrue(expense.isPaid)
    }

    // MARK: - PracticeScript Entity Tests

    func testPracticeScriptCreation() throws {
        let script = PracticeScriptEntity.create(in: testContext)

        XCTAssertNotNil(script.id)
        XCTAssertEqual(script.wrappedTitle, "")
        XCTAssertEqual(script.practiceCount, 0)
        XCTAssertFalse(script.isFavorite)
    }

    func testPracticeDialogueCreation() throws {
        let script = PracticeScriptEntity.create(in: testContext)
        script.title = "握手会リハ"

        let dialogue1 = PracticeDialogueEntity.create(in: testContext, script: script)
        dialogue1.content = "こんにちは！"
        dialogue1.speakerType = "oshi"
        dialogue1.order = 0

        let dialogue2 = PracticeDialogueEntity.create(in: testContext, script: script)
        dialogue2.content = "初めまして！"
        dialogue2.speakerType = "user"
        dialogue2.order = 1

        try testContext.save()

        XCTAssertEqual(script.dialoguesArray.count, 2)
        XCTAssertEqual(script.dialoguesArray[0].wrappedContent, "こんにちは！")
        XCTAssertFalse(script.dialoguesArray[0].isUserSpeaker)
        XCTAssertTrue(script.dialoguesArray[1].isUserSpeaker)
    }

    // MARK: - Report Entity Tests

    func testReportCreation() throws {
        let report = ReportEntity.create(in: testContext)

        XCTAssertNotNil(report.id)
        XCTAssertEqual(report.wrappedTitle, "")
        XCTAssertEqual(report.rating, 5)
    }

    func testReportWithMessages() throws {
        let report = ReportEntity.create(in: testContext)
        report.title = "ライブレポ"

        let message1 = ChatMessageEntity.create(in: testContext, report: report)
        message1.content = "最高だった！"
        message1.order = 0

        let message2 = ChatMessageEntity.create(in: testContext, report: report)
        message2.content = "また行きたい"
        message2.order = 1

        try testContext.save()

        XCTAssertEqual(report.messagesArray.count, 2)
        XCTAssertEqual(report.messagesArray[0].wrappedContent, "最高だった！")
    }

    // MARK: - Enum Tests

    func testEventCategoryIcon() throws {
        XCTAssertEqual(EventCategory.live.icon, "music.mic")
        XCTAssertEqual(EventCategory.meetAndGreet.icon, "hand.wave")
        XCTAssertEqual(EventCategory.festival.icon, "sparkles")
    }

    func testExpenseCategoryIcon() throws {
        XCTAssertEqual(ExpenseCategory.ticket.icon, "ticket")
        XCTAssertEqual(ExpenseCategory.transportation.icon, "tram")
        XCTAssertEqual(ExpenseCategory.goods.icon, "bag")
    }

    func testPracticeEventTypeIcon() throws {
        XCTAssertEqual(PracticeEventType.handshake.icon, "hand.raised")
        XCTAssertEqual(PracticeEventType.photoSession.icon, "camera")
    }

    // MARK: - Date Formatting Tests

    func testDateFormatting() throws {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let date = formatter.date(from: "2025-12-25 14:30")!

        // Test that formatting doesn't crash
        XCTAssertFalse(date.shortDate.isEmpty)
        XCTAssertFalse(date.shortDateTime.isEmpty)
        XCTAssertFalse(date.fullDate.isEmpty)
        XCTAssertFalse(date.fullDateTime.isEmpty)
    }

    // MARK: - Number Formatting Tests

    func testIntFormatting() throws {
        XCTAssertEqual(1000.withComma, "1,000")
        XCTAssertEqual(1000000.withComma, "1,000,000")
        XCTAssertEqual(0.withComma, "0")
    }

    func testInt32Formatting() throws {
        let value: Int32 = 50000
        XCTAssertEqual(value.withComma, "50,000")
    }

    // MARK: - Core Data Save Tests

    func testSaveAndFetch() throws {
        let schedule = ScheduleEntity.create(in: testContext)
        schedule.title = "テストイベント"
        schedule.eventDate = Date()

        try testContext.save()

        let request: NSFetchRequest<ScheduleEntity> = NSFetchRequest(entityName: "ScheduleEntity")
        let results = try testContext.fetch(request)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.wrappedTitle, "テストイベント")
    }

    func testDeleteEntity() throws {
        let expense = ExpenseEntity.create(in: testContext)
        expense.title = "削除テスト"
        try testContext.save()

        testContext.delete(expense)
        try testContext.save()

        let request: NSFetchRequest<ExpenseEntity> = NSFetchRequest(entityName: "ExpenseEntity")
        let results = try testContext.fetch(request)

        XCTAssertEqual(results.count, 0)
    }
}
