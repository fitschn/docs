#!/usr/bin/env swift

import Foundation

class ScreenLockObserver {
    init() {
        let dnc = DistributedNotificationCenter.default()

        // listen for screen lock
        let _ = dnc.addObserver(forName: NSNotification.Name("com.apple.screenIsLocked"), object: nil, queue: .main) { _ in
            NSLog("Screen Locked")
            self.shell("/opt/homebrew/bin/gpgconf", "--reload", "gpg-agent")
        }

        // listen for screen unlock
        let _ = dnc.addObserver(forName: NSNotification.Name("com.apple.screenIsUnlocked"), object: nil, queue: .main) { _ in
            NSLog("Screen Unlocked")
        }

        RunLoop.main.run()
    }

    @discardableResult
    func shell(_ args: String...) -> Int32 {
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = args
        task.launch()
        task.waitUntilExit()
        return task.terminationStatus
    }
}

let _ = ScreenLockObserver()
