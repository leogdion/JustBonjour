//
//  ContentView.swift
//  JustBonjourApp
//
//  Created by Leo Dion on 6/29/24.
//

import SwiftUI
import Network
import JBKit

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
                
                guard let configuration = try? ServerConfiguration(serializedData: content) else {
                  return
                }
                Task { @MainActor in
                  dump(configuration)
                  self.text = configuration.hosts.first ?? "NONE"
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
