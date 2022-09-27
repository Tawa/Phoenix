//
//  Menus.swift
//  Phoenix
//
//  Created by Mohamed Nouri on 26.09.22.
//

import SwiftUI

struct Menus: Commands {
  var body: some Commands {
    SidebarCommands()

    CommandGroup(after: .textEditing) {
      Button("Flip Image") {
        NotificationCenter.default.post(name: .flipImage, object: nil)
      }
      .keyboardShortcut("f")
    }

 
    CommandGroup(replacing: .help) {
      Button("Read Accompanying Article at troz.net") {
        let articleUrl = URL(string: "https://troz.net/post/2022/swiftui-mac-2022/")!
        NSWorkspace.shared.open(articleUrl)
      }
    }
  }
}

extension Notification.Name {
  static let flipImage = Notification.Name("flipImage")
}
