import Foundation
import NIO
import NIOExtras
import NIOHTTP1
import NIOWebSocket
import NIOCore
import NIOConcurrencyHelpers
import WebSocketKit

@main
struct Server {
    static func main() throws {
        print("server hello!")

        let eventloop = MultiThreadedEventLoopGroup.singleton
        let promise = eventloop.next().makePromise(of: Void.self)
        let count: NIOLockedValueBox<Int> = .init(0)
        do {
            try ServerBootstrap.webSocket(on: eventloop) { _, ws in

                ws.onBinary { _, binary in
                    print("received \(binary.readableBytes) bytes")
                    count.withLockedValue {
                        $0 += 1
                        if $0 == 100 {
                            ws.close().cascade(to: promise)
                        }
                    }
                }

                ws.onText { _, text in
                    print("received text: \(text)")
                }

                ws.onClose.cascade(to: promise)

            }.bind(host: "localhost", port: 8080).wait()
        } catch {
            promise.fail(error)
        }

        try promise.futureResult.wait()
    }
}

extension ServerBootstrap {
    static func webSocket(
        on eventLoopGroup: EventLoopGroup,
        tls: Bool = false,
        onUpgrade: @escaping (HTTPRequestHead, WebSocket) -> Void
    ) -> ServerBootstrap {
        return ServerBootstrap(group: eventLoopGroup).childChannelInitializer { channel in
            let webSocket = NIOWebSocketServerUpgrader(
                maxFrameSize: 1 << 26,
                shouldUpgrade: { channel, _ in
                    return channel.eventLoop.makeSucceededFuture([:])
                },
                upgradePipelineHandler: { channel, req in
                    return WebSocket.server(on: channel) { ws in
                        onUpgrade(req, ws)
                    }
                }
            )
            return channel.pipeline.configureHTTPServerPipeline(
                withServerUpgrade: (
                    upgraders: [webSocket],
                    completionHandler: { _ in
                        // complete
                    }
                )
            )
        }
    }
}
