//
//  NetworkService.swift
//  TradeNetTest
//
//  Created by Julia Smirnova on 15.12.2022.
//

import Foundation

protocol QuotesService {
    func subscribe(
        toQuotes: [String],
        onMessage: @escaping (String) -> Void,
        onError: @escaping (Error) -> Void
    )
}

class QuotesServiceImpl: NSObject, QuotesService {
    private lazy var service = WebSoketService(baseURL: "wss://wss.tradernet.ru")
    
    func subscribe(
        toQuotes quotes: [String],
        onMessage: @escaping (String) -> Void,
        onError: @escaping (Error) -> Void
    ) {
        service.onMessage = onMessage
        service.sendMessage(text: ["quotes", quotes])
    }
}

class WebSoketService: NSObject, URLSessionWebSocketDelegate {
    
    enum Errors: LocalizedError {
        case network(original: Error? = nil)
        case sendingMessage
    }

    private let baseURL: String
    private lazy var session = URLSession(
        configuration: .default,
        delegate: self,
        delegateQueue: nil
    )
    
    private var isConnected: Bool {
        switch webSocketTask?.state ?? .completed {
        case .running:
            return true
        case .suspended, .canceling, .completed:
            return false
        @unknown default:
            return false
        }
    }
    
    var onMessage: ((String) -> Void)?
    var onData: ((Data) -> Void)?
    var onError: ((Error) -> Void)?
        
    private var webSocketTask: URLSessionWebSocketTask?

    init(baseURL: String) {
        self.baseURL = baseURL
        super.init()
        connect()
    }
    
    private func connect() {
        reCreateWebSocketTask()
    }
    
    private func reConnect() {
        guard webSocketTask?.state != .running else { return }
        webSocketTask?.cancel()
        reCreateWebSocketTask()
    }
    
    private func reCreateWebSocketTask() {
        guard webSocketTask?.state != .running else { return }
        webSocketTask = session.webSocketTask(with: URL(string: baseURL)!)
        setupReceving()
        webSocketTask?.resume()
    }
    
    func sendMessage(text: Any) {
        if let theJSONData = try? JSONSerialization.data(
            withJSONObject: text as! [Any],
            options: []
        ),
           let theJSONText = String(
            data: theJSONData,
            encoding: .ascii
           ) {
            webSocketTask?.send(.string(theJSONText)) { [weak self] error in
                guard let error = error else { return }
                self?.handleError(error)
            }
        }
    }
    
    private func setupReceving() {
        Task {
            do {
                let message = try await webSocketTask?.receive()
                guard let message = message else { return }
                switch message {
                case .string(let text):
                    onMessage?(text)
                case .data(let data):
                    onData?(data)
                default:
                    return
                }
                setupReceving()
            } catch {
                handleError(error)
                setupReceving()
            }
        }
    }
    
    private func handleError(_ error: Error) {
        onError?(error)
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 5) { [weak self] in
            self?.reConnect()
        }
    }
    
    // MARK: URLSessionWebSocketDelegate
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        self.webSocketTask = webSocketTask
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        guard closeCode != .normalClosure else { return }
        handleError(Errors.network(original: webSocketTask.error))
    }
}


