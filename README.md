# WebSocket Performance Testing Prototype

## Running Testing Client and Server
Run Testing Client
```swift
swift run Client
```

Run Testing Server. Server will bind to `localhost` at port `8080`
```swift
swift run Server
```

## Note
- If caller set `useSmallerWrites` to `true`, then `BufferWritableMonitorHandler` will be added to the channel pipeline, enabling smaller, consecutive writes to the socket. 
- This demo uses a custom build of Vapor's WebSocket Library.
