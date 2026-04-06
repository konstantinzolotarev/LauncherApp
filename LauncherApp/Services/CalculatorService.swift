import Foundation

struct CalculatorService {
    private static let mathPattern = try! NSRegularExpression(
        pattern: #"^[\d\s\+\-\*\/\.\(\)\^]+$"#
    )

    // Must end with a digit or closing paren to be a valid expression
    private static let validEnding = try! NSRegularExpression(
        pattern: #"[\d\)]$"#
    )

    static func evaluate(_ input: String) -> String? {
        let trimmed = input.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }

        let range = NSRange(trimmed.startIndex..., in: trimmed)
        guard mathPattern.firstMatch(in: trimmed, range: range) != nil else {
            return nil
        }

        // Reject expressions that end with an operator (e.g. "2+")
        guard validEnding.firstMatch(in: trimmed, range: range) != nil else {
            return nil
        }

        // Replace ^ with ** for power operations
        let expression = trimmed.replacingOccurrences(of: "^", with: "**")

        let nsExpression = NSExpression(format: expression)
        guard let result = nsExpression.expressionValue(with: nil, context: nil) as? NSNumber else {
            return nil
        }
        let doubleVal = result.doubleValue
        if doubleVal == doubleVal.rounded() && abs(doubleVal) < 1e15 {
            return String(format: "%.0f", doubleVal)
        }
        return String(doubleVal)
    }
}
