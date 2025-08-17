package icu4cj.text

interface RBNFPostProcessor {
    func initself(formatter: RuleBasedNumberFormat, rules: String): Unit

    func process(output: StringBuilder, ruleSet: NFRuleSet): Unit
}