//
//  AppDelegate.swift
//  BrightIntosh
//
//  Created by Niklas Rousset on 12.07.23.
//

import Cocoa
import KeyboardShortcuts
import ServiceManagement
import CoreSpotlight


class AppDelegate: NSObject, NSApplicationDelegate {

    private var overlayAvailable: Bool = false

    let settingsWindowController = SettingsWindowController()

    var statusBarMenu: StatusBarMenu?
    var brightnessManager: BrightnessManager?
    var automationManager: AutomationManager?
    var supportedDevice: Bool = false

    @MainActor
    func application(
        _ application: NSApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([any NSUserActivityRestoring]) -> Void
    ) -> Bool {
        if userActivity.activityType == CSSearchableItemActionType,
           let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
            if uniqueIdentifier == "de.brightintosh.app.settings" {
                self.showSettingsWindow()
                return true
            }
        }
        return false
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        supportedDevice = isDeviceSupported()

        if UserDefaults.standard.object(forKey: "agreementAccepted") == nil || !UserDefaults.standard.bool(forKey: "agreementAccepted") {
            welcomeWindow()
        }

        if !supportedDevice {
            Settings.shared.brightIntoshOnlyOnBuiltIn = false
        }

        brightnessManager = BrightnessManager()
        automationManager = AutomationManager()
        statusBarMenu = StatusBarMenu(supportedDevice: supportedDevice, automationManager: automationManager!, settingsWindowController: settingsWindowController, toggleBrightIntosh: toggleBrightIntosh)

        // Register global hotkeys
        addKeyListeners()

        addSettingsToIndex()
    }

    @objc func increaseBrightness() {
        Settings.shared.brightness = min(getDeviceMaxBrightness(), Settings.shared.brightness + 0.05)
    }

    @objc func decreaseBrightness() {
        Settings.shared.brightness = max(1.0, Settings.shared.brightness - 0.05)
    }

    func addKeyListeners() {
        KeyboardShortcuts.onKeyUp(for: .toggleBrightIntosh) {
            self.toggleBrightIntosh()
        }
        KeyboardShortcuts.onKeyUp(for: .increaseBrightness) {
            self.increaseBrightness()
        }
        KeyboardShortcuts.onKeyUp(for: .decreaseBrightness) {
            self.decreaseBrightness()
        }
        KeyboardShortcuts.onKeyUp(for: .openSettings, action: {
            self.showSettingsWindow()
        })
    }

    @objc func toggleBrightIntosh() {
        if !Settings.shared.brightintoshActive && !checkBatteryAutomationContradiction() {
            return
        }

        Settings.shared.brightintoshActive.toggle()
    }

    func welcomeWindow() {
        NSApplication.shared.activate(ignoringOtherApps: true)
        let controller = WelcomeWindowController(supportedDevice: supportedDevice)
        NSApp.runModal(for: controller.window!)
        UserDefaults.standard.set(true, forKey: "agreementAccepted")
    }

    func showSettingsWindow() {
        self.settingsWindowController.showWindow(nil)
    }


    func addSettingsToIndex() {
        let attributeSet = CSSearchableItemAttributeSet(contentType: UTType.application)
        attributeSet.title = NSLocalizedString("BrightIntosh Settings", comment: "")
        attributeSet.contentDescription = "Open the settings of BrightIntosh"
        attributeSet.thumbnailData = URL(string: "https://brightintosh.de/brightintosh_sm.png")!.dataRepresentation
        attributeSet.alternateNames = ["BrightIntosh Settings", "BrightIntosh", "Settings", "brightness"]

        let item = CSSearchableItem(uniqueIdentifier: "de.brightintosh.app.settings", domainIdentifier: "de.brightintosh.app", attributeSet: attributeSet)

        CSSearchableIndex.default().indexSearchableItems([item]) { error in
            if error != nil {
                print(error?.localizedDescription ?? "An error occured while indexing the item.")
            } else {
                print("BrightIntosh settings item indexed.")
            }
        }
    }
}
