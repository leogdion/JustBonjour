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
  
  func receiveMessage(from connection: NWConnection, _ content: Data?, _ contentContext: NWConnection.ContentContext?, _ isComplete: Bool, _ error: Error?) {
    if let error {
      dump(error)
      return
    }
    guard let content else {
      print("isFinal", contentContext?.isFinal == true)
      print("isComplete", isComplete)
      
      return
    }
    
    guard let configuration = try? ServerConfiguration(serializedData: content) else {
      print(String(bytes: content, encoding: .utf8))
      return
    }
    Task { @MainActor in
      dump(configuration)
      self.text = configuration.hosts.first ?? "NONE"
    }
  }
  private func newConnectionEndpoint(from endpoint: NWEndpoint) -> NWEndpoint? {
    switch endpoint {
    case .service(let name, let type, let domain, _):
        print("Found service: \(name) \(type) \(domain)")
        return NWEndpoint.service(name: name, type: type, domain: domain, interface: nil)
    default:
      print("Unsupported Endpoint: \(endpoint.debugDescription)")
        return nil
    }
  }
  fileprivate func beginConnectionTo(_ endpoint: NWEndpoint) {
    guard let newEndpoint = newConnectionEndpoint(from: endpoint) else {
      return
    }
    let parameters = NWParameters.tcp
    //parameters.includePeerToPeer = true
    let connection = NWConnection(to: newEndpoint, using: parameters)
    
    connection.stateUpdateHandler = { state in
      switch state {
      case .waiting(let error):
        
          print("Connection Waiting error: \(error)")
        
      case .failed(let error):
        print("Connection Failure: \(error)")
      
      case .ready:
        print("Connection ready")
        connection.receiveMessage { content, contentContext, isComplete, error in
          self.receiveMessage(from: connection, content, contentContext, isComplete, error)
        }
        default:
          print("Connection state updated: \(state)")

      }
    }
    
    connection.start(queue: .main)
    print("connection started")
  }
  
  var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text(text)
        }
        .padding()
        .onAppear {
          let browser = NWBrowser(for: .bonjour(type: "_sublimation._tcp", domain: nil), using: .tcp)
          browser.browseResultsChangedHandler = { results, changes in
            
            for result in results {
              beginConnectionTo(result.endpoint)
            }
          }
          browser.start(queue: .main)
          print("browser started")
        }
    }
}

#Preview {
    ContentView()
}
