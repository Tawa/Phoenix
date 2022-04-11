//
//  PhoenixApp.swift
//  Phoenix
//
//  Created by Tawa Nicolas on 11.04.22.
//

import SwiftUI

@main
struct PhoenixApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: PhoenixDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}
