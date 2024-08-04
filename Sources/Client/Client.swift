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

        let start = NIODeadline.now()
        try run(url: url, eventloop: eventloop, usingSmallWrites: false)
        let end = NIODeadline.now()
        print("Time: \((end - start).nanoseconds / 1_000_000) ms")
    }

    private static func run(url: URL, eventloop: EventLoopGroup, usingSmallWrites: Bool) throws {
        let promise = eventloop.next().makePromise(of: Void.self)
        do {
            try WebSocket.connect(to: url, queueSize: usingSmallWrites ? 1 << 30 : nil, on: eventloop) { ws in
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
        } catch {
            promise.fail(error)
        }

        try promise.futureResult.wait()
    }
}
