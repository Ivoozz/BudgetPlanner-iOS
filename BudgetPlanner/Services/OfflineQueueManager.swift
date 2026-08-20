import Foundation

public struct QueuedTransaction: Codable {
    public let id: String
    public let date: String
    public let amount: Double
    public let type: String
    public let categoryId: Int?
    public let accountId: Int?
    public let destinationAccountId: Int?
    public let payee: String
    public let description: String
    public let notes: String
    public let tags: String
    public let createdAt: Date
}

public class OfflineQueueManager {
    public static let shared = OfflineQueueManager()
    private let key = "offline_queued_transactions"

    private init() {}

    public func getQueue() -> [QueuedTransaction] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([QueuedTransaction].self, from: data)) ?? []
    }

    public func enqueue(_ tx: QueuedTransaction) {
        var queue = getQueue()
        queue.append(tx)
        saveQueue(queue)
    }

    public func remove(id: String) {
        var queue = getQueue()
        queue.removeAll { $0.id == id }
        saveQueue(queue)
    }

    private func saveQueue(_ queue: [QueuedTransaction]) {
        if let data = try? JSONEncoder().encode(queue) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    public func flushQueue() async {
        let queue = getQueue()
        guard !queue.isEmpty else { return }

        for item in queue {
            do {
                _ = try await APIService.shared.createTransaction(
                    date: item.date,
                    amount: item.amount,
                    type: item.type,
                    categoryId: item.categoryId,
                    accountId: item.accountId,
                    destinationAccountId: item.destinationAccountId,
                    payee: item.payee,
                    description: item.description,
                    notes: item.notes,
                    tags: item.tags
                )
                remove(id: item.id)
            } catch {
                print("Failed to sync offline item: \(error)")
                break // Wait for next sync attempt
            }
        }
    }
}
