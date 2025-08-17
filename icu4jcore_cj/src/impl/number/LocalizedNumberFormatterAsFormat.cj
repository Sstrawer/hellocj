package icu4cj.impl.number


public class LocalizedNumberFormatterAsFormat <: Format {
    private static let serialVersionUID = 1

     private let formatter: LocalizedNumberFormatter

     private let locale: ULocale

    public init(formatter: LocalizedNumberFormatter, locale: ULocale) {
        Format()
        this.formatter = formatter
        this.locale = locale
    }

    public override func format(obj: Object, toAppendTo: StringBuffer, pos: FieldPosition): StringBuffer {
        if (!(checkOptionalIs<Number, Object>(obj))) {
            throw IllegalArgumentException()
        }
        let dq: DecimalQuantity = DecimalQuantity_DualStorageBCD(obj)
        let string = FormattedStringBuilder()
        formatter.formatImpl(dq, string)
        pos.setBeginIndex(0)
        pos.setEndIndex(0)
        let found = FormattedValueStringBuilderImpl.nextFieldPosition(string, pos)
        if (found && Int32(toAppendTo.size) != 0) {
            pos.setBeginIndex(pos.getBeginIndex() + Int32(toAppendTo.size))
            pos.setEndIndex(pos.getEndIndex() + Int32(toAppendTo.size))
        }
        Utility.appendTo(string, toAppendTo)
        return toAppendTo
    }

    public override func formatToCharacterIterator(obj: Object): AttributedCharacterIterator {
        if (!(checkOptionalIs<Number, Object>(obj))) {
            throw IllegalArgumentException()
        }
        return formatter.format(obj).toCharacterIterator()
    }

    public override func parseObject(source: String, pos: ParsePosition): Object {
        throw UnsupportedOperationException()
    }

    public func getNumberFormatter(): LocalizedNumberFormatter {
        return formatter
    }

    public override func hashCode(): Int64 {
        return formatter.hashCode()
    }

    public override func equals(other: Object): Bool {
        if (refEq(this, other)) {
            return true
        }
        if (other.isNone()) {
            return false
        }
        if (!(checkOptionalIs<LocalizedNumberFormatterAsFormat, Object>(other))) {
            return false
        }
        return formatter.equals(other.getNumberFormatter())
    }

    private func writeReplace(): Object {
        let proxy = LocalizedNumberFormatterAsFormat_Proxy()
        proxy.languageTag = locale.toLanguageTag()
        proxy.skeleton = formatter.toSkeleton()
        return proxy
    }
}


class LocalizedNumberFormatterAsFormat_Proxy <: Externalizable {
    private static let serialVersionUID = 1

    var languageTag: String

    var skeleton: String


    public override func writeExternal(out: ObjectOutput): Unit {
        out.writeByte(0)
        out.writeUTF(languageTag)
        out.writeUTF(skeleton)
    }

    public override func readExternal(input: ObjectInput): Unit {
        input.readByte()
        languageTag = input.readUTF()
        skeleton = input.readUTF()
    }

    private func readResolve(): Object {
        return NumberFormatter.forSkeleton(skeleton).locale(ULocale.forLanguageTag(languageTag)).toFormat()
    }
}
