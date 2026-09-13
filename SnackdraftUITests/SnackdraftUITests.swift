import XCTest

@MainActor
final class SnackdraftUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunchHomeAndPlayATray() throws {
        let app = XCUIApplication()
        app.launchArguments = ["ui-testing"]
        app.launch()
        XCTAssertTrue(app.staticTexts["Snackdraft"].waitForExistence(timeout: 5))
        saveShot("home")
        XCTAssertTrue(app.buttons["play-button"].exists)
        app.buttons["play-button"].tap()
        XCTAssertTrue(app.buttons["offer-0"].waitForExistence(timeout: 5))
        saveShot("play")

        for _ in 0..<16 {
            let offer = app.buttons["offer-0"]
            XCTAssertTrue(offer.waitForExistence(timeout: 3))
            offer.tap()
            var placed = false
            for row in 0..<4 {
                for col in 0..<4 {
                    let cell = app.buttons["cell-\(row)-\(col)"]
                    if cell.exists && cell.isEnabled {
                        cell.tap()
                        placed = true
                        break
                    }
                }
                if placed { break }
            }
            XCTAssertTrue(placed, "Could not place a snack")
        }

        XCTAssertTrue(app.staticTexts["result-title"].waitForExistence(timeout: 12))
        saveShot("result")
        XCTAssertTrue(app.buttons["next-tray-button"].exists)
    }

    func testThemesAndSettings() throws {
        let app = XCUIApplication()
        app.launchArguments = ["ui-testing"]
        app.launch()
        XCTAssertTrue(app.buttons["play-button"].waitForExistence(timeout: 5))
        app.buttons["Journey"].tap()
        XCTAssertTrue(app.staticTexts["Tea & Treats"].waitForExistence(timeout: 5))
        saveShot("worlds")
        app.buttons["back-button"].tap()
        XCTAssertTrue(app.buttons["play-button"].waitForExistence(timeout: 5))
        app.buttons["Cookbook"].tap()
        XCTAssertTrue(app.staticTexts["Connect ingredients. Serve when ready."].waitForExistence(timeout: 5))
        saveShot("collection")
        app.buttons["back-button"].tap()
        app.buttons["Settings"].tap()
        XCTAssertTrue(app.staticTexts["Settings"].waitForExistence(timeout: 5))
        saveShot("settings")
    }

    func testExpandedWorldsAreReachable() throws {
        let app = XCUIApplication()
        app.launchArguments = ["ui-testing"]
        app.launch()
        XCTAssertTrue(app.buttons["play-button"].waitForExistence(timeout: 5))
        app.buttons["Journey"].tap()

        let indian = app.staticTexts["Indian Spice House"]
        for _ in 0..<8 where !indian.isHittable {
            app.swipeUp()
        }
        XCTAssertTrue(indian.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Mexican Mercado"].exists)
        saveShot("expanded-worlds")
    }

    func testFreePlayUsesAnUnlockedKitchen() throws {
        let app = XCUIApplication()
        app.launchArguments = ["ui-testing"]
        app.launch()
        XCTAssertTrue(app.buttons["Free Play"].waitForExistence(timeout: 5))
        app.buttons["Free Play"].tap()
        XCTAssertTrue(app.staticTexts["Your kitchen, your pace"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["free-world-tea"].exists)
        let cookFreely = app.staticTexts["Cook freely"].firstMatch
        XCTAssertTrue(cookFreely.waitForExistence(timeout: 5))
        cookFreely.tap()
        XCTAssertTrue(app.buttons["offer-0"].waitForExistence(timeout: 5))
        saveShot("free-play")
    }

    func testPlayControlsFitPhoneSafeAreas() throws {
        let app = XCUIApplication()
        app.launchArguments = ["ui-testing"]
        app.launch()
        XCTAssertTrue(app.buttons["play-button"].waitForExistence(timeout: 5))
        saveShot("layout-home")

        app.buttons["play-button"].tap()
        let back = app.buttons["back-button"]
        let undo = app.buttons["undo-button"]
        let tip = app.buttons["tips-button"]
        XCTAssertTrue(back.waitForExistence(timeout: 5))
        XCTAssertTrue(undo.isHittable)
        XCTAssertTrue(tip.isHittable)
        XCTAssertGreaterThan(back.frame.minY, app.frame.minY + 30)
        XCTAssertLessThan(undo.frame.maxY, app.frame.maxY - 24)
        XCTAssertLessThan(tip.frame.maxY, app.frame.maxY - 24)
        saveShot("layout-play")

        app.buttons["offer-0"].press(forDuration: 0.2, thenDragTo: app.buttons["cell-0-0"])
        XCTAssertTrue(app.staticTexts["1/16"].waitForExistence(timeout: 5))
    }

    func testRecipeGuideExplainsShapesAndMultipleRecipes() throws {
        let app = XCUIApplication()
        app.launchArguments = ["ui-testing", "ui-testing-onboarding"]
        app.launch()
        app.buttons["play-button"].tap()

        XCTAssertTrue(app.staticTexts["Pick one, then place it"].waitForExistence(timeout: 5))
        saveShot("recipe-guide-pick")
        app.buttons["guide-next-button"].tap()
        XCTAssertTrue(app.staticTexts["Recipes can bend"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Touching sides ✓     Corners only ✕"].exists)
        XCTAssertTrue(app.staticTexts["L shape → 2 recipes ready!"].waitForExistence(timeout: 5))
        saveShot("recipe-guide-shape")
        app.buttons["guide-next-button"].tap()
        XCTAssertTrue(app.staticTexts["One tray, several recipes"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Afternoon Tea"].exists)
        XCTAssertTrue(app.staticTexts["Strawberry Tea Set"].exists)
        XCTAssertTrue(app.staticTexts["2 recipes ready on one tray!"].waitForExistence(timeout: 5))
        saveShot("recipe-guide-many")
        app.buttons["guide-next-button"].tap()

        XCTAssertTrue(app.buttons["offer-0"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["recipe-guide-button"].exists)
        app.buttons["recipe-guide-button"].tap()
        XCTAssertTrue(app.staticTexts["Pick one, then place it"].waitForExistence(timeout: 5))
    }

    func testAllMadeRecipesAreRevealed() throws {
        let app = XCUIApplication()
        app.launchArguments = ["ui-testing", "ui-testing-multiple-recipes"]
        app.launch()

        XCTAssertTrue(app.staticTexts["Recipe 1 of 2"].waitForExistence(timeout: 5))
        app.buttons["next-recipe-button"].tap()
        XCTAssertTrue(app.staticTexts["Recipe 2 of 2"].waitForExistence(timeout: 5))
        saveShot("second-recipe")
        app.buttons["next-recipe-button"].tap()
        XCTAssertTrue(app.staticTexts["Recipes made"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Afternoon Tea"].exists)
        XCTAssertTrue(app.staticTexts["Strawberry Tea Set"].exists)
        saveShot("all-recipes-result")

        app.buttons["Home"].tap()
        app.buttons["Cookbook"].tap()
        app.buttons["Made"].tap()
        let madeCount = app.staticTexts["recipes-made-count"]
        XCTAssertTrue(madeCount.waitForExistence(timeout: 5))
        XCTAssertGreaterThanOrEqual(Int(madeCount.label.split(separator: " ").first ?? "") ?? 0, 2)
        XCTAssertTrue(app.staticTexts["Afternoon Tea"].exists)
        XCTAssertTrue(app.staticTexts["Strawberry Tea Set"].exists)
        saveShot("made-recipes-cookbook")
    }

    private func saveShot(_ name: String) {
        let shot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: shot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
