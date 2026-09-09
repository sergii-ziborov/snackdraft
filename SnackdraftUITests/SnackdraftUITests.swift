import XCTest

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
        app.buttons["Themes"].tap()
        XCTAssertTrue(app.staticTexts["Tea & Treats"].waitForExistence(timeout: 5))
        saveShot("worlds")
        app.buttons["back-button"].tap()
        XCTAssertTrue(app.buttons["play-button"].waitForExistence(timeout: 5))
        app.buttons["Recipes"].tap()
        XCTAssertTrue(app.staticTexts["Berry Boost"].waitForExistence(timeout: 5))
        saveShot("collection")
        app.buttons["back-button"].tap()
        app.buttons["Settings"].tap()
        XCTAssertTrue(app.staticTexts["Settings"].waitForExistence(timeout: 5))
        saveShot("settings")
    }

    private func saveShot(_ name: String) {
        let shot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: shot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
