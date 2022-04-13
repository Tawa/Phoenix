//
//  ContentView.swift
//  Phoenix
//
//  Created by Tawa Nicolas on 11.04.22.
//

import SwiftUI

class ViewModel: ObservableObject {
    func onAddFamilyName() {
        print("Add")
    }
}

struct ContentView: View {
    @Binding var document: PhoenixDocument
    @StateObject private var viewModel: ViewModel = .init()

    var body: some View {
        HSplitView {
            VStack {
                HStack {
                    Text("Hello, World")
                    Spacer()
                }
                Spacer()
            }

            VStack {
                ScrollView {
                    VStack {
                        ForEach(document.fileStructure.familyNames) { familyName in
                            HStack {
                                Text(familyName.singular)
                                Text(familyName.plural)
                            }
                        }
                        Button(action: viewModel.onAddFamilyName) {
                            Text("Add Family Name")
                        }.padding()
                    }
                }
                Spacer()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(PhoenixDocument()))
    }
}
