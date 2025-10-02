#!/usr/bin/env swift

import Cocoa

class SleepApp: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.willSleepNotification,
            object: nil,
            queue: .main
        ) { _ in
            let task = Process()
            task.launchPath = "/usr/bin/env"
            task.arguments = ["bash", "/Users/hannesdiercks/dotfiles/sleep/sleep.sh"]
            try? task.run()
        }
    }
}

let delegate = SleepApp()
NSApplication.shared.delegate = delegate
NSApplication.shared.run()
