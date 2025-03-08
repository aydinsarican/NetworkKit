# NetworkKit
Network layer
Usage

// 🌍 Let's specify the network configuration at application startup:
let config = NetworkConfiguration(
    baseURL: "https://api.example.com",
    globalHeaders: ["Authorization": "Bearer YOUR_TOKEN"],
    timeoutInterval: 15
)

// 📌 Set Config to NetworkManager:
NetworkManager.shared.setConfiguration(config)

// 📌 Create endpoint:
struct GetPopularRestaurants: Endpoint {
    var path: String { "/restaurants/popular" }
    var method: HTTPMethod { .GET }
}

// 📌 Create models:
struct Restaurant: Decodable {
    let id: Int
    let name: String
    let rating: Double
}

// ✅ Now we can make API calls:
Task {
    do {
        let restaurants: [Restaurant] = try await NetworkManager.shared.request(GetPopularRestaurants())
        print("Fetched Restaurants:", restaurants)
    } catch {
        print("Error:", error.localizedDescription)
    }
}
