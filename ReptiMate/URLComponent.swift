
import Foundation



    enum Endpoint {
        case path(path: String)
    }

    extension Endpoint {
        var url: String {
            switch self {
            case .path(let path):
                return .makeForEndpoint("/\(path)")
            }
        }
    }

    private extension String {
        static let baseURL = "https://api.reptimate.store"
        static func makeForEndpoint(_ endpoint: String) -> String {
            baseURL + endpoint
        }
    }
    





