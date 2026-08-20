import Foundation

public struct CurrencyFormatter {
    private static let formatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .currency
        nf.locale = Locale(identifier: "nl_NL")
        nf.currencySymbol = "€"
        nf.minimumFractionDigits = 2
        nf.maximumFractionDigits = 2
        return nf
    }()

    private static let compactFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .currency
        nf.locale = Locale(identifier: "nl_NL")
        nf.currencySymbol = "€"
        nf.maximumFractionDigits = 0
        return nf
    }()

    public static func format(_ amount: Double) -> String {
        formatter.string(from: NSNumber(value: amount)) ?? String(format: "€ %.2f", amount)
    }

    public static func formatCompact(_ amount: Double) -> String {
        compactFormatter.string(from: NSNumber(value: amount)) ?? String(format: "€ %.0f", amount)
    }

    public static func formatSigned(_ amount: Double, isIncome: Bool) -> String {
        let formatted = format(abs(amount))
        return isIncome ? "+\(formatted)" : "-\(formatted)"
    }
}
