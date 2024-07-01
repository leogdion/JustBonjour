//
//  BonjourListener.swift
//  
//
//  Created by Leo Dion on 6/29/24.
//

import ServiceLifecycle
import NIOTransportServices
import NIOCore
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
    let bootstrap = NIOTSListenerBootstrap(group: NIOTSEventLoopGroup.singleton)

    let hosts = Host.current().addresses
    let serverConfiguration = ServerConfiguration(
      isSecure: false,
      port: 8080,
      hosts: hosts
    )
    
    let data = try serverConfiguration.serializedData()
    //let data = Data("Hello World".utf8)
//    let addresses = await self.addresses()
//
//    let configuration = ServerConfiguration(isSecure: false, port: 8_080, hosts: addresses)

    let channel = try await bootstrap.bind(endpoint: .service(name: "Sublimation", type: Self.httpTCPServiceType, domain: "local.", interface: nil)) { channel in
      channel.eventLoop.makeCompletedFuture {
        
        try NIOAsyncChannel<ByteBuffer, ByteBuffer>(
          wrappingChannelSynchronously: channel
        )
      }
    }
    print("Starting Service")
    await withDiscardingTaskGroup { group in
      do {
        try await channel.executeThenClose { clients in
          // dump(inbound)

          for try await childChannel in clients {
            //dump(childChannel)
            print("Received Client")
            //dump(childChannel)
              do {

                  try await childChannel.executeThenClose { inbound, outbound in

                    print("Writing \(data.count) bytes")

                    //try await outbound.write(.init(data: Data()))
                    try await outbound.write(.init(data: data))
                    //try await outbound.write(.init(data: Data()))
                    print("Finishing")
                    //outbound.finish()
                    //try!  await Task.sleep(for: .seconds(1.0))
                    print("Closing Child Channel")
                    //outbound.finish()
                  }
              } catch {
                dump(error)
              }
              // print(String(decoding: data, as: UTF8.self))
            
            // outbound.write(data)
          }
          print("Closing Main Channel")
        }
      } catch {
        print("Waiting on child channel: \(error)")
      }
    }

    print("Closing out")
    // let channel = try await bootstrap.withNWListener(listener)
    // try await channel.closeFuture.get()
  
  }
  
  init () {
    
  }
}
