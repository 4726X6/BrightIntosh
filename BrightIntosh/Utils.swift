//
//  Utils.swift
//  BrightIntosh
//
//  Created by Niklas Rousset on 01.01.24.
//

import IOKit
import Cocoa

func getXDRDisplays() -> [NSScreen] {
    var xdrScreens: [NSScreen] = []
    for screen in NSScreen.screens {
        if ((isBuiltInScreen(screen: screen) && isDeviceSupported()) || (externalXdrDisplays.contains(screen.localizedName) && !Settings.shared.brightIntoshOnlyOnBuiltIn)) {
            xdrScreens.append(screen)
        }
    }
    return xdrScreens
}

func isBuiltInScreen(screen: NSScreen) -> Bool {
    let screenNumber = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")]
    let displayId: CGDirectDisplayID = screenNumber as! CGDirectDisplayID
    return CGDisplayIsBuiltin(displayId) != 0
}

func getModelIdentifier() -> String? {
    let service = IOServiceGetMatchingService(
        kIOMainPortDefault, IOServiceMatching("IOPlatformExpertDevice"))
    var modelIdentifier: String?
    if let modelData = IORegistryEntryCreateCFProperty(
        service, "model" as CFString, kCFAllocatorDefault, 0
    ).takeRetainedValue() as? Data {
        modelIdentifier = String(data: modelData, encoding: .utf8)?.trimmingCharacters(
            in: .controlCharacters)
    }

    IOObjectRelease(service)
    return modelIdentifier
}

func isDeviceSupported() -> Bool {
    if let device = getModelIdentifier(), supportedDevices.contains(device) {
        return true
    }
    return false
}

func getDeviceMaxBrightness() -> Float {
    if let device = getModelIdentifier(),
        sdr600nitsDevices.contains(device)
    {
        return 1.535
    }
    return 1.59
}

func generateReport() async -> String {
    var report = "BrightIntosh Report:\n"
    report += "OS-Version: \(ProcessInfo.processInfo.operatingSystemVersionString)\n"
    #if STORE
        report += "Version: BrightIntosh SE v\(appVersion)\n"
    #else
        report += "Version: BrightIntosh v\(appVersion)\n"
    #endif
    report += "Model Identifier: \(getModelIdentifier() ?? "N/A")\n"

    report += "Screens: \(NSScreen.screens.map{$0.localizedName}.joined(separator: ", "))\n"
    for screen in NSScreen.screens {
        report += " - Screen \(NSScreen.screens.map{$0.localizedName}): \(screen.frame.width)x\(screen.frame.height)px\n"
    }
    return report
}
