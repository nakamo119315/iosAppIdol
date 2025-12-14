import CoreData

/// Core Data stack for iOS 14+
class CoreDataStack {
    static let shared = CoreDataStack()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MeetAndGreet", managedObjectModel: Self.managedObjectModel)
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }

    // MARK: - Managed Object Model (programmatic)
    static var managedObjectModel: NSManagedObjectModel = {
        let model = NSManagedObjectModel()

        // Schedule Entity
        let scheduleEntity = NSEntityDescription()
        scheduleEntity.name = "ScheduleEntity"
        scheduleEntity.managedObjectClassName = "ScheduleEntity"

        let scheduleId = NSAttributeDescription()
        scheduleId.name = "id"
        scheduleId.attributeType = .UUIDAttributeType

        let scheduleTitle = NSAttributeDescription()
        scheduleTitle.name = "title"
        scheduleTitle.attributeType = .stringAttributeType
        scheduleTitle.defaultValue = ""

        let scheduleDesc = NSAttributeDescription()
        scheduleDesc.name = "eventDescription"
        scheduleDesc.attributeType = .stringAttributeType
        scheduleDesc.defaultValue = ""

        let scheduleDate = NSAttributeDescription()
        scheduleDate.name = "eventDate"
        scheduleDate.attributeType = .dateAttributeType

        let scheduleLocation = NSAttributeDescription()
        scheduleLocation.name = "location"
        scheduleLocation.attributeType = .stringAttributeType
        scheduleLocation.defaultValue = ""

        let scheduleCategory = NSAttributeDescription()
        scheduleCategory.name = "category"
        scheduleCategory.attributeType = .stringAttributeType
        scheduleCategory.defaultValue = "ライブ"

        let scheduleCompleted = NSAttributeDescription()
        scheduleCompleted.name = "isCompleted"
        scheduleCompleted.attributeType = .booleanAttributeType
        scheduleCompleted.defaultValue = false

        let scheduleNotes = NSAttributeDescription()
        scheduleNotes.name = "notes"
        scheduleNotes.attributeType = .stringAttributeType
        scheduleNotes.defaultValue = ""

        let scheduleTicketDeadline = NSAttributeDescription()
        scheduleTicketDeadline.name = "ticketDeadline"
        scheduleTicketDeadline.attributeType = .dateAttributeType
        scheduleTicketDeadline.isOptional = true

        let schedulePaymentDeadline = NSAttributeDescription()
        schedulePaymentDeadline.name = "paymentDeadline"
        schedulePaymentDeadline.attributeType = .dateAttributeType
        schedulePaymentDeadline.isOptional = true

        let scheduleCreatedAt = NSAttributeDescription()
        scheduleCreatedAt.name = "createdAt"
        scheduleCreatedAt.attributeType = .dateAttributeType

        let scheduleImageData = NSAttributeDescription()
        scheduleImageData.name = "imageData"
        scheduleImageData.attributeType = .binaryDataAttributeType
        scheduleImageData.isOptional = true
        scheduleImageData.allowsExternalBinaryDataStorage = true

        scheduleEntity.properties = [
            scheduleId, scheduleTitle, scheduleDesc, scheduleDate,
            scheduleLocation, scheduleCategory, scheduleCompleted,
            scheduleNotes, scheduleTicketDeadline, schedulePaymentDeadline,
            scheduleCreatedAt, scheduleImageData
        ]

        // Expense Entity
        let expenseEntity = NSEntityDescription()
        expenseEntity.name = "ExpenseEntity"
        expenseEntity.managedObjectClassName = "ExpenseEntity"

        let expenseId = NSAttributeDescription()
        expenseId.name = "id"
        expenseId.attributeType = .UUIDAttributeType

        let expenseTitle = NSAttributeDescription()
        expenseTitle.name = "title"
        expenseTitle.attributeType = .stringAttributeType
        expenseTitle.defaultValue = ""

        let expenseAmount = NSAttributeDescription()
        expenseAmount.name = "amount"
        expenseAmount.attributeType = .integer32AttributeType
        expenseAmount.defaultValue = 0

        let expenseCategory = NSAttributeDescription()
        expenseCategory.name = "category"
        expenseCategory.attributeType = .stringAttributeType
        expenseCategory.defaultValue = "チケット"

        let expenseDate = NSAttributeDescription()
        expenseDate.name = "expenseDate"
        expenseDate.attributeType = .dateAttributeType

        let expensePayment = NSAttributeDescription()
        expensePayment.name = "paymentMethod"
        expensePayment.attributeType = .stringAttributeType
        expensePayment.defaultValue = "現金"

        let expensePaid = NSAttributeDescription()
        expensePaid.name = "isPaid"
        expensePaid.attributeType = .booleanAttributeType
        expensePaid.defaultValue = false

        let expenseNotes = NSAttributeDescription()
        expenseNotes.name = "notes"
        expenseNotes.attributeType = .stringAttributeType
        expenseNotes.defaultValue = ""

        let expenseCreatedAt = NSAttributeDescription()
        expenseCreatedAt.name = "createdAt"
        expenseCreatedAt.attributeType = .dateAttributeType

        expenseEntity.properties = [
            expenseId, expenseTitle, expenseAmount, expenseCategory,
            expenseDate, expensePayment, expensePaid, expenseNotes, expenseCreatedAt
        ]

        // PracticeScript Entity
        let scriptEntity = NSEntityDescription()
        scriptEntity.name = "PracticeScriptEntity"
        scriptEntity.managedObjectClassName = "PracticeScriptEntity"

        let scriptId = NSAttributeDescription()
        scriptId.name = "id"
        scriptId.attributeType = .UUIDAttributeType

        let scriptTitle = NSAttributeDescription()
        scriptTitle.name = "title"
        scriptTitle.attributeType = .stringAttributeType
        scriptTitle.defaultValue = ""

        let scriptDesc = NSAttributeDescription()
        scriptDesc.name = "scriptDescription"
        scriptDesc.attributeType = .stringAttributeType
        scriptDesc.defaultValue = ""

        let scriptEventType = NSAttributeDescription()
        scriptEventType.name = "eventType"
        scriptEventType.attributeType = .stringAttributeType
        scriptEventType.defaultValue = "接触イベント"

        let scriptPracticeCount = NSAttributeDescription()
        scriptPracticeCount.name = "practiceCount"
        scriptPracticeCount.attributeType = .integer32AttributeType
        scriptPracticeCount.defaultValue = 0

        let scriptLastPracticed = NSAttributeDescription()
        scriptLastPracticed.name = "lastPracticedAt"
        scriptLastPracticed.attributeType = .dateAttributeType
        scriptLastPracticed.isOptional = true

        let scriptFavorite = NSAttributeDescription()
        scriptFavorite.name = "isFavorite"
        scriptFavorite.attributeType = .booleanAttributeType
        scriptFavorite.defaultValue = false

        let scriptCreatedAt = NSAttributeDescription()
        scriptCreatedAt.name = "createdAt"
        scriptCreatedAt.attributeType = .dateAttributeType

        scriptEntity.properties = [
            scriptId, scriptTitle, scriptDesc, scriptEventType,
            scriptPracticeCount, scriptLastPracticed, scriptFavorite, scriptCreatedAt
        ]

        // PracticeDialogue Entity
        let dialogueEntity = NSEntityDescription()
        dialogueEntity.name = "PracticeDialogueEntity"
        dialogueEntity.managedObjectClassName = "PracticeDialogueEntity"

        let dialogueId = NSAttributeDescription()
        dialogueId.name = "id"
        dialogueId.attributeType = .UUIDAttributeType

        let dialogueContent = NSAttributeDescription()
        dialogueContent.name = "content"
        dialogueContent.attributeType = .stringAttributeType
        dialogueContent.defaultValue = ""

        let dialogueSpeaker = NSAttributeDescription()
        dialogueSpeaker.name = "speakerType"
        dialogueSpeaker.attributeType = .stringAttributeType
        dialogueSpeaker.defaultValue = "user"

        let dialogueOrder = NSAttributeDescription()
        dialogueOrder.name = "order"
        dialogueOrder.attributeType = .integer32AttributeType
        dialogueOrder.defaultValue = 0

        let dialogueNotes = NSAttributeDescription()
        dialogueNotes.name = "notes"
        dialogueNotes.attributeType = .stringAttributeType
        dialogueNotes.defaultValue = ""

        dialogueEntity.properties = [dialogueId, dialogueContent, dialogueSpeaker, dialogueOrder, dialogueNotes]

        // Relationship: PracticeScript <-> PracticeDialogue
        let scriptToDialogues = NSRelationshipDescription()
        scriptToDialogues.name = "dialogues"
        scriptToDialogues.destinationEntity = dialogueEntity
        scriptToDialogues.isOptional = true
        scriptToDialogues.deleteRule = .cascadeDeleteRule

        let dialogueToScript = NSRelationshipDescription()
        dialogueToScript.name = "script"
        dialogueToScript.destinationEntity = scriptEntity
        dialogueToScript.maxCount = 1
        dialogueToScript.isOptional = true
        dialogueToScript.deleteRule = .nullifyDeleteRule

        scriptToDialogues.inverseRelationship = dialogueToScript
        dialogueToScript.inverseRelationship = scriptToDialogues

        scriptEntity.properties.append(scriptToDialogues)
        dialogueEntity.properties.append(dialogueToScript)

        // Report Entity
        let reportEntity = NSEntityDescription()
        reportEntity.name = "ReportEntity"
        reportEntity.managedObjectClassName = "ReportEntity"

        let reportId = NSAttributeDescription()
        reportId.name = "id"
        reportId.attributeType = .UUIDAttributeType

        let reportTitle = NSAttributeDescription()
        reportTitle.name = "title"
        reportTitle.attributeType = .stringAttributeType
        reportTitle.defaultValue = ""

        let reportEventDate = NSAttributeDescription()
        reportEventDate.name = "eventDate"
        reportEventDate.attributeType = .dateAttributeType

        let reportEventName = NSAttributeDescription()
        reportEventName.name = "eventName"
        reportEventName.attributeType = .stringAttributeType
        reportEventName.defaultValue = ""

        let reportLocation = NSAttributeDescription()
        reportLocation.name = "location"
        reportLocation.attributeType = .stringAttributeType
        reportLocation.defaultValue = ""

        let reportRating = NSAttributeDescription()
        reportRating.name = "rating"
        reportRating.attributeType = .integer32AttributeType
        reportRating.defaultValue = 5

        let reportNotes = NSAttributeDescription()
        reportNotes.name = "notes"
        reportNotes.attributeType = .stringAttributeType
        reportNotes.defaultValue = ""

        let reportCreatedAt = NSAttributeDescription()
        reportCreatedAt.name = "createdAt"
        reportCreatedAt.attributeType = .dateAttributeType

        reportEntity.properties = [
            reportId, reportTitle, reportEventDate, reportEventName,
            reportLocation, reportRating, reportNotes, reportCreatedAt
        ]

        // ChatMessage Entity
        let messageEntity = NSEntityDescription()
        messageEntity.name = "ChatMessageEntity"
        messageEntity.managedObjectClassName = "ChatMessageEntity"

        let messageId = NSAttributeDescription()
        messageId.name = "id"
        messageId.attributeType = .UUIDAttributeType

        let messageContent = NSAttributeDescription()
        messageContent.name = "content"
        messageContent.attributeType = .stringAttributeType
        messageContent.defaultValue = ""

        let messageType = NSAttributeDescription()
        messageType.name = "messageType"
        messageType.attributeType = .stringAttributeType
        messageType.defaultValue = "user"

        let messageTimestamp = NSAttributeDescription()
        messageTimestamp.name = "timestamp"
        messageTimestamp.attributeType = .dateAttributeType

        let messageOrder = NSAttributeDescription()
        messageOrder.name = "order"
        messageOrder.attributeType = .integer32AttributeType
        messageOrder.defaultValue = 0

        messageEntity.properties = [messageId, messageContent, messageType, messageTimestamp, messageOrder]

        // Relationship: Report <-> ChatMessage
        let reportToMessages = NSRelationshipDescription()
        reportToMessages.name = "messages"
        reportToMessages.destinationEntity = messageEntity
        reportToMessages.isOptional = true
        reportToMessages.deleteRule = .cascadeDeleteRule

        let messageToReport = NSRelationshipDescription()
        messageToReport.name = "report"
        messageToReport.destinationEntity = reportEntity
        messageToReport.maxCount = 1
        messageToReport.isOptional = true
        messageToReport.deleteRule = .nullifyDeleteRule

        reportToMessages.inverseRelationship = messageToReport
        messageToReport.inverseRelationship = reportToMessages

        reportEntity.properties.append(reportToMessages)
        messageEntity.properties.append(messageToReport)

        // UiSettings Entity
        let settingsEntity = NSEntityDescription()
        settingsEntity.name = "UiSettingsEntity"
        settingsEntity.managedObjectClassName = "UiSettingsEntity"

        let settingsId = NSAttributeDescription()
        settingsId.name = "id"
        settingsId.attributeType = .UUIDAttributeType

        let settingsTheme = NSAttributeDescription()
        settingsTheme.name = "themeRawValue"
        settingsTheme.attributeType = .stringAttributeType
        settingsTheme.defaultValue = "apple"

        let settingsTtsRate = NSAttributeDescription()
        settingsTtsRate.name = "ttsRate"
        settingsTtsRate.attributeType = .floatAttributeType
        settingsTtsRate.defaultValue = 0.5

        let settingsTtsPitch = NSAttributeDescription()
        settingsTtsPitch.name = "ttsPitch"
        settingsTtsPitch.attributeType = .floatAttributeType
        settingsTtsPitch.defaultValue = 1.0

        let settingsTtsVolume = NSAttributeDescription()
        settingsTtsVolume.name = "ttsVolume"
        settingsTtsVolume.attributeType = .floatAttributeType
        settingsTtsVolume.defaultValue = 1.0

        let settingsAnimations = NSAttributeDescription()
        settingsAnimations.name = "animationsEnabled"
        settingsAnimations.attributeType = .booleanAttributeType
        settingsAnimations.defaultValue = true

        settingsEntity.properties = [
            settingsId, settingsTheme, settingsTtsRate, settingsTtsPitch,
            settingsTtsVolume, settingsAnimations
        ]

        model.entities = [
            scheduleEntity, expenseEntity, scriptEntity, dialogueEntity,
            reportEntity, messageEntity, settingsEntity
        ]

        return model
    }()
}
