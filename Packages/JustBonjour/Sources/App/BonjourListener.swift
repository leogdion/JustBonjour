//
//  BonjourListener.swift
//  
//
//  Created by Leo Dion on 6/29/24.
//

import ServiceLifecycle
import Foundation
import JBKit
import Network

extension ServerConfiguration {
  init(isSecure: Bool? = nil, port: Int? = nil, hosts: [String] = []) {
    self.init()
    self.isSecure = isSecure ?? false
    self.port = port.map(UInt32.init) ?? 8_080
    self.hosts = hosts
  }
}

struct BonjourListener : Service {
  public static let httpTCPServiceType = "_sublimation._tcp"
  
  func run() async throws {
        let hosts = Host.current().addresses
        let serverConfiguration = ServerConfiguration(
          isSecure: false,
          port: 8080,
          hosts: hosts
        )
    let data = try serverConfiguration.serializedData()
    
    
    let parameters = NWParameters.tcp
    //parameters.includePeerToPeer = true

    
      let listener = try NWListener(using: .tcp)
    listener.service = .init(name: "Sublimation", type: Self.httpTCPServiceType)
      
      listener.newConnectionHandler = { connection in
        connection.stateUpdateHandler = { state in
          switch state {
            
          case .waiting(let error):
            
              print("Connection Waiting error: \(error)")
            
          case .ready:
            print("Connection Ready ")
            print("Sending \(data.count) bytes")
              connection.send(content: data, completion: .contentProcessed({ error in
                print("content sent")
                dump(error)
                connection.cancel()
              }))
          case .failed(let error):
            print("Connection Failure: \(error)")
          
          default:
            print("Connection state updated: \(state)")
          }
        }
        connection.start(queue: .global())
        
      }
      
      listener.start(queue: .global())
      
    return try await withCheckedThrowingContinuation { continuation in
      listener.stateUpdateHandler = { state in
        switch state {
          
        case .waiting(let error):
          
            print("Listener Waiting error: \(error)")
          continuation.resume(throwing: error)
        
        case .failed(let error):
          print("Listener Failure: \(error)")
          continuation.resume(throwing: error)
        case .cancelled:
          continuation.resume()
        default:
          print("Listener state updated: \(state)")
        }
      }
    }

    
  
  }
  
  init () {
    
  }
}
