//
//  ClipboardViewController.swift
//  StatusBarNotes
//
//  Created by Filippo Pellolio on 7/14/18.
//  Copyright © 2018 pll. All rights reserved.
//

import Cocoa

let kStoryboardId : String = "ClipboardViewController"
let kEmptyStateString = "0/0"

class ClipboardViewController: NSViewController {

  @IBOutlet weak var selectedHistoryLabel: NSTextField!
  @IBOutlet weak var selectedHistoryTextView: NSTextView!
  @IBOutlet weak var nextItemButton: NSButton!
  @IBOutlet weak var previousItemButton: NSButton!


  var clipboardHistory : [String] = []
  fileprivate var _lastCheckedChangeCount = -1


  fileprivate var _activeHistoryIndex = -1
  var activeHistoryIndex : Int {
    get {
      return _activeHistoryIndex
    }
    set {
      _activeHistoryIndex = newValue
      updateSelectedHistoryItem()
    }
  }

  var activeHistoryItem : String? {
    get{
      if (clipboardHistory.indices.contains(activeHistoryIndex)) {
        return clipboardHistory[activeHistoryIndex]
      }
      return nil
    }
  }

  @IBAction func nextItemButtonPressed(_ sender: Any) {
    if (activeHistoryIndex + 1 < clipboardHistory.count) {
      activeHistoryIndex += 1
    }
  }

  @IBAction func previousItemButtonPressed(_ sender: Any) {
    if (activeHistoryIndex > 0) {
      activeHistoryIndex -= 1
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(checkForClipboardContent), userInfo: nil, repeats: true)

  }

  override func viewDidAppear() {
    checkForClipboardContent()
    if (activeHistoryIndex < 0 && clipboardHistory.count > 0) {
      activeHistoryIndex = clipboardHistory.count - 1
    }
  }

  @objc func checkForClipboardContent() {
    objc_sync_enter(self)
    defer{objc_sync_exit(self)}

    if (NSPasteboard.general.changeCount > _lastCheckedChangeCount) {
      var shouldUpdateSelectedAfterPopulate = false
      if (activeHistoryIndex == clipboardHistory.count - 1) {
        shouldUpdateSelectedAfterPopulate = true;
      }

      populateClipboardHistory()
      _lastCheckedChangeCount = NSPasteboard.general.changeCount

      if shouldUpdateSelectedAfterPopulate {
        activeHistoryIndex = clipboardHistory.count - 1
      } else {
        updateSelectedHistoryItem()
      }
    }
  }

  func populateClipboardHistory() {
    let pasteboard = NSPasteboard.general

    for element in pasteboard.pasteboardItems! {
      if let str = processClipboardElement(element: element) {
        clipboardHistory.append(str)
      }
    }
  }

  func processClipboardElement(element: NSPasteboardItem) -> String? {
    if element.types.contains(.fileURL) {
      if let data = element.data(forType: .fileURL) {
        if let url = URL(dataRepresentation: data, relativeTo: nil) {
          return url.path
        }
      }
    }

    return element.string(forType: .string)
  }

  func updateSelectedHistoryItem() {
    updateActiveHistoryItem()
    updateActiveHistoryTitle()
    updateButtonsState()
  }

  func updateActiveHistoryItem() {
    if let item = activeHistoryItem {
      selectedHistoryTextView.string = item
    }
  }

  func updateActiveHistoryTitle() {
    if (activeHistoryIndex < 0) {
      selectedHistoryLabel.stringValue = kEmptyStateString
    } else {
      selectedHistoryLabel.stringValue = "\(activeHistoryIndex + 1)/\(clipboardHistory.count)"
    }
  }

  func updateButtonsState() {
    previousItemButton.isEnabled = activeHistoryIndex > 0
    nextItemButton.isEnabled = (activeHistoryIndex + 1) < clipboardHistory.count
  }
}

extension ClipboardViewController {
  // MARK: Storyboard instantiation
  static func freshController() -> ClipboardViewController {
    let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
    let identifier = NSStoryboard.SceneIdentifier(rawValue: kStoryboardId)
    guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? ClipboardViewController else {
      fatalError("Why cant i find ClipboardViewController? - Check Main.storyboard")
    }
    return viewcontroller
  }
}
