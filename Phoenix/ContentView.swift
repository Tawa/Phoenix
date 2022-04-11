//
//  ContentView.swift
//  Phoenix
//
//  Created by Tawa Nicolas on 11.04.22.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: PhoenixDocument

    var body: some View {
        TextEditor(text: $document.text)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(PhoenixDocument()))
    }
}
