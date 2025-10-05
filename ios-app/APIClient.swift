import Foundation
import Combine

public struct APIClient {
    public let baseURL: URL
    public let session: URLSession
    public let tokenProvider: () -> String?

    public init(baseURL: URL, session: URLSession = .shared, tokenProvider: @escaping () -> String? ) {
        self.baseURL = baseURL
        self.session = session
        self.tokenProvider = tokenProvider
    }

    public func upload(mood: MoodUpload) -> AnyPublisher<Void, Error> {
        guard let token = tokenProvider() else {
            return Fail(error: URLError(.userAuthenticationRequired)).eraseToAnyPublisher()
        }

        var req = URLRequest(url: baseURL.appendingPathComponent("/api/moods"))
        req.httpMethod = "POST"
        req.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            req.httpBody = try JSONEncoder().encode(mood)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }

        return session.dataTaskPublisher(for: req)
            .tryMap { data, response in
                guard let http = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }
                if (200..<300).contains(http.statusCode) { return () }
                if (400..<500).contains(http.statusCode) {
                    throw APIError.clientError(status: http.statusCode)
                }
                throw APIError.serverError(status: http.statusCode)
            }
            .eraseToAnyPublisher()
    }

    public enum APIError: Error {
        case clientError(status: Int)
        case serverError(status: Int)
    }

    public struct MoodUpload: Codable {
        public let id: UUID
        public let timestamp: Date
        public let rating: Int
        public let note: String?
    }
}
