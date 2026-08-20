import Foundation

public struct SFSymbolPicker {
    public static func mapIcon(_ name: String?) -> String {
        guard let name = name?.lowercased() else { return "tag.fill" }

        switch name {
        // Lucide to SF Symbols mapping
        case "shopping-cart", "shoppingcart", "cart", "boodschappen", "winkel":
            return "cart.fill"
        case "utensils", "food", "restaurant", "eten", "diner":
            return "fork.knife"
        case "coffee", "cafe":
            return "cup.and.saucer.fill"
        case "home", "house", "wonen", "huur", "hypotheek":
            return "house.fill"
        case "zap", "energy", "stroom", "energie", "gas":
            return "bolt.fill"
        case "wifi", "internet", "telecom":
            return "wifi"
        case "tv", "film", "netflix", "streaming":
            return "tv.fill"
        case "car", "auto", "vervoer", "brandstof", "benzine":
            return "car.fill"
        case "bus", "train", "ov", "trein":
            return "tram.fill"
        case "heart", "health", "zorg", "verzekering", "dokter":
            return "heart.fill"
        case "briefcase", "work", "salaris", "inkomsten", "loon":
            return "briefcase.fill"
        case "wallet", "portemonnee", "rekening":
            return "creditcard.fill"
        case "building-columns", "bank", "sparen", "spaarrekening":
            return "building.columns.fill"
        case "target", "goal", "spaardoel":
            return "target"
        case "gift", "cadeau":
            return "gift.fill"
        case "plane", "vakantie", "reis":
            return "airplane"
        case "gamepad-2", "gamepad", "games", "entertainment":
            return "gamecontroller.fill"
        case "smartphone", "telefoon", "mobiel":
            return "iphone"
        case "shield-check", "shield", "verzekeringen":
            return "shield.checkerboard"
        case "scissors", "kapper", "uiterlijk":
            return "scissors"
        case "graduation-cap", "studie", "opleiding":
            return "graduationcap.fill"
        case "arrow-left-right", "transfer", "overboeking":
            return "arrow.left.arrow.right"
        case "plus-circle", "plus":
            return "plus.circle.fill"
        default:
            if name.contains(".") {
                return name // Already an SF symbol
            }
            return "tag.fill"
        }
    }
}
