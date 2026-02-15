import AppKit

let args = CommandLine.arguments
guard args.count > 1 else {
    fputs("Usage: cpl-close-zed <project-name>\n", stderr)
    exit(1)
}
let project = args[1]

// Find Zed Preview process
guard let zedApp = NSWorkspace.shared.runningApplications.first(where: {
    $0.localizedName == "Zed Preview"
}) else {
    exit(0)
}

let appElement = AXUIElementCreateApplication(zedApp.processIdentifier)
var windowsValue: CFTypeRef?
guard AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &windowsValue) == .success,
      let windows = windowsValue as? [AXUIElement] else {
    exit(0)
}

for window in windows {
    var titleValue: CFTypeRef?
    guard AXUIElementCopyAttributeValue(window, kAXTitleAttribute as CFString, &titleValue) == .success,
          let title = titleValue as? String else { continue }

    if title.contains(project) {
        var closeButton: CFTypeRef?
        guard AXUIElementCopyAttributeValue(window, kAXCloseButtonAttribute as CFString, &closeButton) == .success else { continue }
        AXUIElementPerformAction(closeButton as! AXUIElement, kAXPressAction as CFString)
    }
}
