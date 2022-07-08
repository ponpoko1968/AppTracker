//
//  ViewController.swift
//  AppTracker
//
//  Created by 越智修司 on 2022/07/07.
//

import Cocoa

extension Date {
    var slashFormatted:String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd' 'HH:mm:ss"
        formatter.timeZone = TimeZone.current
        return formatter.string(from:self)
    }

}

struct TimeEntry:CustomStringConvertible {
    var description: String {
        let duration = end == nil ? "-" : String(format:"%.0f",start.distance(to: end!))
        return "\(name): \(start.slashFormatted) \(duration) sec."
    }

    var name: String
    var bundleIdentifier: String
    var start: Date
    var end: Date?
}

class MDAppController: NSObject {
    var currentApp: NSRunningApplication?
    var activeHandler : ((NSRunningApplication?)->Void)?
    var deactiveHandler : ((NSRunningApplication?)->Void)?

    override init() {
        super.init()
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(activeAppDidChange(_:)),
            name: NSWorkspace.didActivateApplicationNotification,
            object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(activeAppDidDeactivate(_:)),
            name: NSWorkspace.didDeactivateApplicationNotification,
            object: nil)
    }

    deinit {
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }

    @objc func activeAppDidChange(_ notification: Notification?) {
        currentApp = notification?.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
        activeHandler?(currentApp)

    }
    @objc func activeAppDidDeactivate(_ notification: Notification?) {
        currentApp = notification?.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
        deactiveHandler?(currentApp)

    }
}


class ViewController: NSViewController {

    @IBOutlet var textView: NSTextView!
    let appController = MDAppController()
    var timeEntries: [String:TimeEntry] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        appController.activeHandler  = { app in
            print("\(app)")
            if let currentApp = app,
                let bundleId = app?.bundleIdentifier {
                let entry = TimeEntry(name:currentApp.localizedName  ?? (currentApp.bundleIdentifier  ?? "??"),
                                                  bundleIdentifier: (currentApp.bundleIdentifier ?? "\(UUID().description)"),
                                                  start: Date(),
                                                  end: nil
                )
                self.timeEntries[bundleId] = entry
            }
        }

        appController.deactiveHandler  = { app in

            if let currentApp = app,
               let bundleId = currentApp.bundleIdentifier,
               var entry = self.timeEntries[bundleId]  {
                entry.end = Date()
                let newString  = NSAttributedString(string: entry.description + "\n")
                self.textView.textStorage?.append(newString)
                self.textView.scrollRangeToVisible(NSMakeRange(self.textView.string.count,0))
                self.timeEntries.removeValue(forKey: bundleId)

            }
        }
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

