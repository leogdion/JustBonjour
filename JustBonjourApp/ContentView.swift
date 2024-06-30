//
//  ContentView.swift
//  JustBonjourApp
//
//  Created by Leo Dion on 6/29/24.
//

import SwiftUI
import Network

struct ContentView: View {
  @State var text = ""
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text(text)
        }
        .padding()
        .onAppear {
          let browser = NWBrowser(for: .bonjour(type: "_sublimation._tcp", domain: "local."), using: .tcp)
          browser.browseResultsChangedHandler = { results, changes in
            for result in results {
              let connection = NWConnection(to: result.endpoint, using: .tcp)
              connection.receiveMessage { content, contentContext, isComplete, error in
                if let error {
                  dump(error)
                  return
                }
                guard let content else {
                  dump(contentContext)
                  print(isComplete)
                  return
                }
                let text = String(decoding: content, as: UTF8.self)
                Task { @MainActor in
                  self.text = text
                }
              }
              connection.start(queue: .global())
            }
          }
          browser.start(queue: .global())
        }
    }
}

#Preview {
    ContentView()
}
