package icu4cj.text

class QuantityFormatter {
    private let templates = Array<SimpleFormatter>(Int64(StandardPlural.COUNT))


    public func addIfAbsent(variant: String, template: String): Unit {
        let idx = StandardPlural.indexFromString(variant)
        if (templates[Int64(idx)].isSome()) {
            return
        }
        templates[Int64(idx)] = SimpleFormatter.compileMinMaxArguments(template, 0, 1)
    }

    public func isValid(): Bool {
        return templates[Int64(StandardPlural.OTHER_INDEX)].isSome()
    }

    public func format(number: Float64, numberFormat: NumberFormat, pluralRules: PluralRules): String {
        let formatStr = numberFormat.format(number)
        let p = selectPlural(number, numberFormat, pluralRules)
        var formatter = templates[Int64(p.ordinal)]
        if (formatter.isNone()) {
            formatter = templates[Int64(StandardPlural.OTHER_INDEX)]
            if (!formatter.isSome()) {
                throw AssertionError()
            }
        }
        return formatter.format([formatStr])
    }

    public func getByVariant(variant: String): SimpleFormatter {
        if (!isValid()) {
            throw AssertionError()
        }
        let idx = StandardPlural.indexOrOtherIndexFromString(variant)
        let template = templates[Int64(idx)]
        return if (template.isNone() && idx != StandardPlural.OTHER_INDEX) { templates[Int64(StandardPlural.OTHER_INDEX)] } else { template }
    }

    public static func selectPlural(number: Float64, numberFormat: NumberFormat, rules: PluralRules): StandardPlural {
        let pluralKeyword: String
        if (checkOptionalIs<DecimalFormat, NumberFormat>(numberFormat)) {
            pluralKeyword = rules.select(numberFormat.getFixedDecimal(number))
        } else {
            pluralKeyword = rules.select(number)
        }
        return StandardPlural.orOtherFromString(pluralKeyword)
    }

    public static func formatStatic(compiledPattern: String, value: String, appendTo: StringBuilder, pos: FieldPosition): StringBuilder {
        let offsets = Array<Int32>(1) { _ => 0 }
        SimpleFormatterImpl.formatAndAppend(compiledPattern, appendTo, offsets, [value])
        if (pos.getBeginIndex() != 0 || pos.getEndIndex() != 0) {
            if (offsets[0] >= 0) {
                pos.setBeginIndex(pos.getBeginIndex() + offsets[0])
                pos.setEndIndex(pos.getEndIndex() + offsets[0])
            } else {
                pos.setBeginIndex(0)
                pos.setEndIndex(0)
            }
        }
        return appendTo
    }
}
