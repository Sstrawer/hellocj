package icu4cj.text

class PluralRulesSerialProxy <: Serializable {
    private static let serialVersionUID = 42

    private let data: String

    init(rules: String) {
        data = rules
    }

    private func readResolve(): Object {
        return PluralRules.createRules(data)
    }
}
