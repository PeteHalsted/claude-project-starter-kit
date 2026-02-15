import AppKit

let stateFile = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".cpl-picker-state").path

func getProjects() -> [String] {
    let home = FileManager.default.homeDirectoryForCurrentUser
    let dir = home.appendingPathComponent("projects")
    guard let entries = try? FileManager.default.contentsOfDirectory(atPath: dir.path) else { return [] }
    return entries
        .filter { name in
            guard !name.hasPrefix(".") else { return false }
            var isDir: ObjCBool = false
            return FileManager.default.fileExists(atPath: dir.appendingPathComponent(name).path, isDirectory: &isDir) && isDir.boolValue
        }
        .sorted { a, b in
            let attrA = try? FileManager.default.attributesOfItem(atPath: dir.appendingPathComponent(a).path)
            let attrB = try? FileManager.default.attributesOfItem(atPath: dir.appendingPathComponent(b).path)
            let dateA = attrA?[.modificationDate] as? Date ?? .distantPast
            let dateB = attrB?[.modificationDate] as? Date ?? .distantPast
            return dateA > dateB
        }
}

func loadLastTerminalDir() -> String? {
    guard let data = FileManager.default.contents(atPath: stateFile),
          let str = String(data: data, encoding: .utf8) else { return nil }
    let trimmed = str.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? nil : trimmed
}

func saveLastTerminalDir(_ dir: String) {
    try? dir.write(toFile: stateFile, atomically: true, encoding: .utf8)
}

let projects = getProjects()
guard !projects.isEmpty else {
    fputs("No projects found in ~/projects\n", stderr)
    exit(1)
}

let app = NSApplication.shared
app.setActivationPolicy(.regular)

// Project dropdown
let popup = NSPopUpButton(frame: NSRect(x: 0, y: 104, width: 300, height: 26), pullsDown: false)
projects.forEach { popup.addItem(withTitle: $0) }

// Launch mode radio buttons
let matrix = NSMatrix(
    frame: NSRect(x: 0, y: 0, width: 300, height: 92),
    mode: .radioModeMatrix,
    cellClass: NSButtonCell.self,
    numberOfRows: 4,
    numberOfColumns: 1
)
matrix.cellSize = NSSize(width: 300, height: 22)
for (i, title) in ["Claude + Zed", "Claude Only", "Zed Only", "Terminal Only"].enumerated() {
    guard let cell = matrix.cell(atRow: i, column: 0) as? NSButtonCell else { continue }
    cell.title = title
    cell.setButtonType(.radio)
    if i == 0 { cell.state = .on }
}

// Dynamic dropdown update when mode changes
class ModeHandler: NSObject {
    let popup: NSPopUpButton
    let projects: [String]
    let terminalDirs = ["~ (Home)", "~/projects"]

    init(popup: NSPopUpButton, projects: [String]) {
        self.popup = popup
        self.projects = projects
    }

    @objc func modeChanged(_ sender: NSMatrix) {
        let selected = popup.titleOfSelectedItem
        let isTerminal = sender.selectedRow == 3

        popup.removeAllItems()
        if isTerminal {
            terminalDirs.forEach { popup.addItem(withTitle: $0) }
            popup.menu?.addItem(.separator())
        }
        projects.forEach { popup.addItem(withTitle: $0) }

        if isTerminal {
            // Restore last-used terminal dir, or default to first project
            if let last = loadLastTerminalDir(), popup.itemTitles.contains(last) {
                popup.selectItem(withTitle: last)
            }
        } else if let selected = selected, popup.itemTitles.contains(selected) {
            popup.selectItem(withTitle: selected)
        }
    }
}

let handler = ModeHandler(popup: popup, projects: projects)
matrix.target = handler
matrix.action = #selector(ModeHandler.modeChanged(_:))

// Container
let container = NSView(frame: NSRect(x: 0, y: 0, width: 300, height: 137))
container.addSubview(popup)
container.addSubview(matrix)

// Alert dialog
let alert = NSAlert()
alert.messageText = "CPL"
alert.addButton(withTitle: "Launch")
alert.addButton(withTitle: "Cancel")
alert.accessoryView = container

NSApp.activate(ignoringOtherApps: true)
alert.layout()
alert.window.level = .floating
let response = alert.runModal()
guard response == .alertFirstButtonReturn else { exit(1) }

let project = popup.titleOfSelectedItem ?? projects[0]
let mode: String
switch matrix.selectedRow {
case 1: mode = "claude"
case 2: mode = "zed"
case 3: mode = "terminal"
default: mode = "both"
}

// Persist selection for terminal mode
if mode == "terminal" {
    saveLastTerminalDir(project)
}

print("\(project)\t\(mode)")
