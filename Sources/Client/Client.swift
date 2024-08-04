import Foundation
import NIO
import NIOCore
import NIOPosix
import WebSocketKit

@main
struct Client {
    static func main() throws {
        let eventloop = MultiThreadedEventLoopGroup(numberOfThreads: 4)
        let url = URL(string: "ws://localhost:8080")!
        try run(url: url, eventloop: eventloop, usingSmallBuffer: true)
    }

    private static func run(url: URL, eventloop: EventLoopGroup, usingSmallBuffer: Bool) throws {
        let promise = eventloop.next().makePromise(of: Void.self)
        do {
            try WebSocket.connect(to: url, queueSize: usingSmallBuffer ? 1 << 30 : nil, on: eventloop) { ws in
                var totalBytes: Int = 0

                var currentLoad: Int = 1 << 13
                for i in 0..<100 {
                    let loadSize: Int = (i > 0 && i % 8 == 0) ? currentLoad * 2 : currentLoad
                    ws.send(ByteBuffer(repeating: 0, count: loadSize))
                    currentLoad = loadSize
                    totalBytes += currentLoad
                }

                ws.onClose.cascade(to: promise)
            }.wait()
            print("DONE")
        } catch {
            promise.fail(error)
        }

        try promise.futureResult.wait()
    }
}
