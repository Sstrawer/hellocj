package icu4cj.text


public class ListFormatter {
    private let start: String

    private let middle: String

    private let locale: ULocale

    private let patternHandler: ListFormatter_PatternHandler

    
    public init(two: String, start: String, middle: String, end: String) {
        this(compilePattern(two, StringBuilder()), compilePattern(start, StringBuilder()), compilePattern(middle, StringBuilder()), compilePattern(end, StringBuilder()), None)
    }

    init(two: String, start: String, middle: String, end: String, locale: ULocale) {
        this.start = start
        this.middle = middle
        this.locale = locale
        this.patternHandler = createPatternHandler(two, end)
    }

    static func compilePattern(pattern: String, sb: StringBuilder): String {
        return SimpleFormatterImpl.compileToStringMinMaxArguments(pattern, sb, 2, 2)
    }

    public static func getInstance(locale: ULocale, Type: ListFormatter_Type, width: ListFormatter_Width): ListFormatter {
        let styleName = typeWidthToStyleString(Type, width)
        if (styleName.isNone()) {
            throw IllegalArgumentException("Invalid list format type/width")
        }
        return cache.get(locale, styleName)
    }

    public static func getInstance(locale: Locale, Type: ListFormatter_Type, width: ListFormatter_Width): ListFormatter {
        return getInstance(ULocale.forLocale(locale), Type, width)
    }

    public static func getInstance(locale: ULocale): ListFormatter {
        return getInstance(locale, ListFormatter_Type.AND, ListFormatter_Width.WIDE)
    }

    public static func getInstance(locale: Locale): ListFormatter {
        return getInstance(ULocale.forLocale(locale), ListFormatter_Type.AND, ListFormatter_Width.WIDE)
    }

    public static func getInstance(): ListFormatter {
        return getInstance(ULocale.getDefault(ULocale_Category.FORMAT))
    }

    public func format(items: Array<Object>): String {
        return format(items)
    }

    public func format(items: Collection<Object>): String {
        return formatImpl(items, false).toString()
    }

    public func formatToValue(items: Array<Object>): ListFormatter_FormattedList {
        return formatToValue(items)
    }

    public func formatToValue(items: Collection<Object>): ListFormatter_FormattedList {
        return formatImpl(items, true).toValue()
    }

    public func formatImpl(items: Collection<Object>, needsFields: Bool): ListFormatter_FormattedListBuilder {
        let it: Iterator<Object> = items.iterator()
        let count = Int32(items.size)
        match (count) {
            case 0 => return ListFormatter_FormattedListBuilder("", needsFields)
            case 1 => return ListFormatter_FormattedListBuilder(it.next(), needsFields)
            case 2 =>
                let first = it.next()
                let second = it.next()
                return ListFormatter_FormattedListBuilder(first, needsFields).append(patternHandler.getTwoPattern(String.valueOf(second)), second, 1)
            case _ => ()
        }
        let builder = ListFormatter_FormattedListBuilder(it.next(), needsFields)
        builder.append(start, it.next(), 1)
        var idx = 2
        while (idx < count - 1) {
            builder.append(middle, it.next(), idx)
            idx++
        }
        let last = it.next()
        return builder.append(patternHandler.getEndPattern(String.valueOf(last)), last, count - 1)
    }

    private static let compiledY = compilePattern("{0} y {1}", StringBuilder())

    private static let compiledE = compilePattern("{0} e {1}", StringBuilder())

    private static let compiledO = compilePattern("{0} o {1}", StringBuilder())

    private static let compiledU = compilePattern("{0} u {1}", StringBuilder())

    private static let changeToE = Pattern.compile("(i.*|hi|hi[^ae].*)", Pattern.CASE_INSENSITIVE)

    private static let changeToU = Pattern.compile("((o|ho|8).*|11)", Pattern.CASE_INSENSITIVE)

    private static let compiledVav = compilePattern("{0} \u{05d5}{1}", StringBuilder())

    private static let compiledVavDash = compilePattern("{0} \u{05d5}-{1}", StringBuilder())

    private static let changeToVavDash = Pattern.compile("^[\\P{InHebrew}].*$")

    private func createPatternHandler(two: String, end: String): ListFormatter_PatternHandler {
        if (this.locale.isSome()) {
            let language = this.locale.getLanguage()
            if (language == "es") {
                let twoIsY = two.equals(compiledY)
                let endIsY = end.equals(compiledY)
                if (twoIsY || endIsY) {
                    return ListFormatter_ContextualHandler(changeToE, if (twoIsY) { compiledE } else { two }, two, if (endIsY) { compiledE } else { end }, end)
                }
                let twoIsO = two.equals(compiledO)
                let endIsO = end.equals(compiledO)
                if (twoIsO || endIsO) {
                    return ListFormatter_ContextualHandler(changeToU, if (twoIsO) { compiledU } else { two }, two, if (endIsO) { compiledU } else { end }, end)
                }
            } else if (language == "he" || language == "iw") {
                let twoIsVav = two.equals(compiledVav)
                let endIsVav = end.equals(compiledVav)
                if (twoIsVav || endIsVav) {
                    return ListFormatter_ContextualHandler(changeToVavDash, if (twoIsVav) { compiledVavDash } else { two }, two, if (endIsVav) { compiledVavDash } else { end }, end)
                }
            }
        }
        return ListFormatter_StaticHandler(two, end)
    }

    public func getPatternForNumItems(count: Int32): String {
        if (count <= 0) {
            throw IllegalArgumentException("count must be > 0")
        }
        let list = ArrayList<String>()
        var i = 0
        while (i < count) {
            list.append(String.format("{%d}", [i]))
            i++
        }
        return format(list as Collection<Object>)
    }

    
    public func getLocale(): ULocale {
        return locale
    }

    static var cache: ListFormatter_Cache = ListFormatter_Cache()

    static func typeWidthToStyleString(Type: ListFormatter_Type, width: ListFormatter_Width): String {
        match (Type) {
            case ListFormatter_Type.AND => match (width) {
                case ListFormatter_Width.WIDE => return "standard"
                case ListFormatter_Width.SHORT => return "standard-short"
                case ListFormatter_Width.NARROW => return "standard-narrow"
                case _ => ()
            }
            case ListFormatter_Type.OR => match (width) {
                case ListFormatter_Width.WIDE => return "or"
                case ListFormatter_Width.SHORT => return "or-short"
                case ListFormatter_Width.NARROW => return "or-narrow"
                case _ => ()
            }
            case ListFormatter_Type.UNITS => match (width) {
                case ListFormatter_Width.WIDE => return "unit"
                case ListFormatter_Width.SHORT => return "unit-short"
                case ListFormatter_Width.NARROW => return "unit-narrow"
                case _ => ()
            }
            case _ => ()
        }
        return None
    }
}


interface ListFormatter_PatternHandler {
    public func getTwoPattern(text: String): String

    public func getEndPattern(text: String): String
}

public class ListFormatter_Type <: Enum<ListFormatter_Type> {
    public static let AND = ListFormatter_Type("AND", 0)

    public static let OR = ListFormatter_Type("OR", 1)

    public static let UNITS = ListFormatter_Type("UNITS", 2)

    private static func _values(): Array<ListFormatter_Type> {
        return [ListFormatter_Type.AND, ListFormatter_Type.OR, ListFormatter_Type.UNITS]
    }

    private static let _VALUES = ListFormatter_Type._values()

    public static func values(): Array<ListFormatter_Type> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): ListFormatter_Type {
        return (TypeInfo.of<ListFormatter_Type>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as ListFormatter_Type
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


public class ListFormatter_Width <: Enum<ListFormatter_Width> {
    public static let WIDE = ListFormatter_Width("WIDE", 0)

    public static let SHORT = ListFormatter_Width("SHORT", 1)

    public static let NARROW = ListFormatter_Width("NARROW", 2)

    private static func _values(): Array<ListFormatter_Width> {
        return [ListFormatter_Width.WIDE, ListFormatter_Width.SHORT, ListFormatter_Width.NARROW]
    }

    private static let _VALUES = ListFormatter_Width._values()

    public static func values(): Array<ListFormatter_Width> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): ListFormatter_Width {
        return (TypeInfo.of<ListFormatter_Width>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as ListFormatter_Width
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


public class ListFormatter_SpanField <: UFormat_SpanField {
    private static let serialVersionUID = 3563544214705634403

    public static let LIST_SPAN = ListFormatter_SpanField("list-span")

    private init(name: String) {
        super(name)
    }

    
    override protected func readResolve(): Object {
        if (this.getName().equals(LIST_SPAN.getName())) {
            return LIST_SPAN
        }
        throw InvalidObjectException("An invalid object.")
    }
}


public class ListFormatter_Field <: Format_Field {
    private static let serialVersionUID = -8071145668708265437

    public static var LITERAL: ListFormatter_Field = ListFormatter_Field("literal")

    public static var ELEMENT: ListFormatter_Field = ListFormatter_Field("element")

    private init(name: String) {
        Format_Field(name)
    }

    
    override protected func readResolve(): Object {
        if (this.getName().equals(LITERAL.getName())) {
            return LITERAL
        }
        if (this.getName().equals(ELEMENT.getName())) {
            return ELEMENT
        }
        throw InvalidObjectException("An invalid object.")
    }
}


public class ListFormatter_FormattedList <: FormattedValue {
    private let string: FormattedStringBuilder

    init(string: FormattedStringBuilder) {
        this.string = string
    }

    public override func toString(): String {
        return string.toString()
    }

    public override func length(): Int32 {
        return string.lengthMethod()
    }

    public override func charAt(index: Int32): Char {
        return string.toRuneArray()[index]
    }

    public override func subSequence(start: Int32, end: Int32): String {
        return string.subString(start, end)
    }

    public override func appendTo<A>(appendable: A): A {
        return Utility.appendTo(string, appendable)
    }

    public override func nextPosition(cfpos: ConstrainedFieldPosition): Bool {
        return FormattedValueStringBuilderImpl.nextPosition(string, cfpos, None)
    }

    public override func toCharacterIterator(): AttributedCharacterIterator {
        return FormattedValueStringBuilderImpl.toCharacterIterator(string, None)
    }
}


class ListFormatter_StaticHandler <: ListFormatter_PatternHandler {
    init(two: String, end: String) {
        twoPattern = two
        endPattern = end
    }

    public override func getTwoPattern(text: String): String {
        return twoPattern
    }

    public override func getEndPattern(text: String): String {
        return endPattern
    }

    private let twoPattern: String

    private let endPattern: String
}


class ListFormatter_ContextualHandler <: ListFormatter_PatternHandler {
    init(regexp: Pattern, thenTwo: String, elseTwo: String, thenEnd: String, elseEnd: String) {
        this.regexp = regexp
        thenTwoPattern = thenTwo
        elseTwoPattern = elseTwo
        thenEndPattern = thenEnd
        elseEndPattern = elseEnd
    }

    public override func getTwoPattern(text: String): String {
        if (regexp.matcher(text).matches()) {
            return thenTwoPattern
        } else {
            return elseTwoPattern
        }
    }

    public override func getEndPattern(text: String): String {
        if (regexp.matcher(text).matches()) {
            return thenEndPattern
        } else {
            return elseEndPattern
        }
    }

    private let regexp: Pattern

    private let thenTwoPattern: String

    private let elseTwoPattern: String

    private let thenEndPattern: String

    private let elseEndPattern: String
}


class ListFormatter_FormattedListBuilder {
    private var string: FormattedStringBuilder

    var needsFields: Bool = false

    public init(start: Object, needsFields: Bool) {
        string = FormattedStringBuilder()
        this.needsFields = needsFields
        string.setAppendableField(ListFormatter_Field.LITERAL)
        appendElement(start, 0)
    }

    public func append(compiledPattern: String, next: Object, position: Int32): ListFormatter_FormattedListBuilder {
        if (!(SimpleFormatterImpl.getArgumentLimit(compiledPattern) == 2)) {
            throw AssertionError()
        }
        string.setAppendIndex(0)
        var state = 0
        while (true) {
            state = SimpleFormatterImpl_IterInternal.step(state, compiledPattern, string)
            if (state == SimpleFormatterImpl_IterInternal.DONE) {
                break
            }
            let argIndex = SimpleFormatterImpl_IterInternal.getArgIndex(state)
            if (argIndex == 0) {
                string.setAppendIndex(string.lengthMethod())
            } else {
                appendElement(next, position)
            }
        }
        return this
    }

    private func appendElement(element: Object, position: Int32): Unit {
        let elementString: String = toString(element)
        if (needsFields) {
            let field = FormattedValueStringBuilderImpl_SpanFieldPlaceholder()
            field.spanField = ListFormatter_SpanField.LIST_SPAN
            field.normalField = ListFormatter_Field.ELEMENT
            field.value = position
            field.start = -1
            field.length = Int32(elementString.size)
            string.append(elementString, field)
        } else {
            string.append(elementString, None)
        }
    }

    public func appendTo(appendable: Appendable): Unit {
        Utility.appendTo(string, appendable)
    }

    public func getOffset(fieldPositionFoundIndex: Int32): Int32 {
        return FormattedValueStringBuilderImpl.findSpan(string, fieldPositionFoundIndex)
    }

    public override func toString(): String {
        return string.toString()
    }

    public func toValue(): ListFormatter_FormattedList {
        return ListFormatter_FormattedList(string)
    }
}


class ListFormatter_Cache {

    private let cache: ICUCache<String, ListFormatter> = SimpleCache<String, ListFormatter>()

    public func get(locale: ULocale, style: String): ListFormatter {
        let key = String.format("%s:%s", [locale.toString(), style])
        var result = cache.get(key)
        if (result.isNone()) {
            result = load(locale, style)
            cache.put(key, result)
        }
        return result
    }

    private static func load(ulocale: ULocale, style: String): ListFormatter {
        let r = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, ulocale)
        let sb = StringBuilder()
        return ListFormatter(ListFormatter.compilePattern(r.getWithFallback("listPattern/" + (style) + "/2").getString(), sb), ListFormatter.compilePattern(r.getWithFallback("listPattern/" + (style) + "/start").getString(), sb), ListFormatter.compilePattern(r.getWithFallback("listPattern/" + (style) + "/middle").getString(), sb), ListFormatter.compilePattern(r.getWithFallback("listPattern/" + (style) + "/end").getString(), sb), ulocale)
    }
}
