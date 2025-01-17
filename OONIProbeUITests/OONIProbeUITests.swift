import XCTest

class OONIProbeUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        let app = XCUIApplication()
        setupSnapshot(app)

        // Solution taken rom https://blog.codecentric.de/en/2018/06/resetting-ios-application-state-userdefaults-ui-tests/
        //Preventing Informed Consent to appear
        app.launchArguments += ["-first_run", "ok"]
        app.launchArguments += ["-analytics_popup", "ok"]
        app.launchArguments += ["-notification_popup_disable", "ok"]
        app.launchArguments += ["enable_ui_testing"]
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    /*
     * This test execute the app with a preloaded database, navigate in the dashboard,
     * TestResult screen and TestDetails and takes screenshots for the app store.
     * This should be always the first test to run due to the preloaded db.
     */
    func testMakeScreenshots() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let app = XCUIApplication()

        let tabBarsQuery = app.tabBars
        let tablesQuery = app.tables

        let dashboardButton = tabBarsQuery.buttons.element(boundBy: 0)
        let resultsButton = tabBarsQuery.buttons.element(boundBy: 1)
        
        dashboardButton.tap()
        snapshot("01Dashboard")

        resultsButton.tap()
        snapshot("02TestResults")
        //Websites cell
        tablesQuery.cells.element(boundBy: 3).tap()
        
        //thepiratebay row (cell 0)
        let thepiratebayStaticText = tablesQuery.staticTexts["http://thepiratebay.org"]
        thepiratebayStaticText.tap()
        snapshot("03WebsiteBlocked")
        
        // We make the assumption the first button in the navigationbar hierarchy is the back button
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()

        resultsButton.tap()
        
        //Performance cell
        tablesQuery.cells.element(boundBy: 1).tap()
        tablesQuery.cells.element(boundBy: 1).tap()
        snapshot("04SpeedTest")

        // We make the assumption the first button in the navigationbar hierarchy is the back button
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()

        dashboardButton.tap()
        tablesQuery.cells.element(boundBy: 0).tap()
        app.buttons["ConfigureButton"].tap()
        tablesQuery.cells.children(matching: .textField).element.tap()
        
        app.typeText("ooni.io")

        tablesQuery.children(matching: .other).element.children(matching: .button).element.tap()
        tablesQuery.children(matching: .cell).element(boundBy: 1).children(matching: .textField).element.tap()
        snapshot("05ChooseWebsite")
    }
    
    /*
     * This test open the custom website screen, input "ooni.io" and run the test,
     * wait 60 seconds for the test to complete then navigate to the test result screen
     * to check if the website is accessible.
     */
    func testRunCustomURL() {
        let app = XCUIApplication()

        let tabBarsQuery = app.tabBars
        let tablesQuery = app.tables

        let dashboardButton = tabBarsQuery.buttons.element(boundBy: 0)
        let resultsButton = tabBarsQuery.buttons.element(boundBy: 1)
        
        dashboardButton.tap()
        tablesQuery.cells.element(boundBy: 0).tap()
        app.buttons["ConfigureButton"].tap()
        tablesQuery.cells.children(matching: .textField).element.tap()
        
        app.typeText("ooni.io")

        tablesQuery.children(matching: .other).element.children(matching: .button).element.tap()
        tablesQuery.children(matching: .cell).element(boundBy: 1).children(matching: .textField).element.tap()

        let runButton = app.buttons["Run"]
        XCTAssertTrue(runButton.exists)

        runButton.tap()
        
        XCTAssertTrue(resultsButton.waitForExistence(timeout: 50))

        resultsButton.tap()
        XCTAssertFalse(tablesQuery.cells.element(boundBy: 0).images["exclamation_point"].waitForExistence(timeout: 10))
        tablesQuery.cells.element(boundBy: 0).tap()
        
        //Taps on ooni.io row
        tablesQuery.cells.element(boundBy: 0).tap()

        //Check the URL is what was tested and accessible
        let urlLabel = app.staticTexts["TestResults.Details.Hero.TestName"]
        XCTAssertTrue(urlLabel.label == "http://ooni.io")

        let descriptionLabel = app.staticTexts["TestResults.Details.Hero.Status"]
        XCTAssertTrue(descriptionLabel.label == "Accessible")
    }
    
    /*
     * This test navigate into settings, disable the automatic publish results
     * then runs a IM test and verify that the test result haven't been uploaded.
     * TODO add more checks
     */
    func testSettings() {
        let app = XCUIApplication()

        let tabBarsQuery = app.tabBars
        let tablesQuery = app.tables

        let dashboardButton = tabBarsQuery.buttons.element(boundBy: 0)
        let resultsButton = tabBarsQuery.buttons.element(boundBy: 1)
        let settingsButton = tabBarsQuery.buttons.element(boundBy: 2)

        resultsButton.tap()

        XCTAssertFalse(tablesQuery.cells.element(boundBy: 0).images["not_uploaded_icon"].exists)
        
        settingsButton.tap()
        tablesQuery.cells.element(boundBy: 2).tap() // Privacy Settings
        let resultSwitch = tablesQuery.cells.element(boundBy: 0).children(matching: .switch).element // Automatically publish results
        
        if ((resultSwitch.value as? String) == "1"){
            resultSwitch.tap() // turn off automatic publishing of results
        }
        
        //From https://stackoverflow.com/questions/44222966/from-an-xcuitest-how-can-i-check-the-on-off-state-of-a-uiswitch
        XCTAssert((resultSwitch.value as? String) == "0")
        app.navigationBars.buttons.element(boundBy: 0).tap()
        dashboardButton.tap()
        
        //Run IM test
        tablesQuery.cells.element(boundBy: 1).tap()
        let runButton = app.buttons["Run"]
        XCTAssertTrue(runButton.exists)
        runButton.tap()

        app.navigationBars.buttons.element(boundBy: 0).tap()

        XCTAssertTrue(resultsButton.waitForExistence(timeout: 50))

        //Check results
        resultsButton.tap()
        XCTAssertTrue(tablesQuery.cells.element(boundBy: 0).images["not_uploaded_icon"].waitForExistence(timeout: 90))

    }
}
