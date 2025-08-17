package icu4cj.text


public abstract class LocaleDisplayNames {
    public static func getInstance(locale: ULocale): LocaleDisplayNames {
        return getInstance(locale, LocaleDisplayNames_DialectHandling.STANDARD_NAMES)
    }

    public static func getInstance(locale: Locale): LocaleDisplayNames {
        return getInstance(ULocale.forLocale(locale))
    }

    public static func getInstance(locale: ULocale, dialectHandling: LocaleDisplayNames_DialectHandling): LocaleDisplayNames {
        var result: LocaleDisplayNames
        if (FACTORY_DIALECTHANDLING.isSome()) {
            try {
                result = FACTORY_DIALECTHANDLING.invoke(None, [locale, dialectHandling])
            } catch (e: InvocationTargetException) { } catch (e: IllegalAccessException) { }
        }
        if (result.isNone()) {
            result = LocaleDisplayNames_LastResortLocaleDisplayNames(locale, dialectHandling)
        }
        return result
    }

    public static func getInstance(locale: ULocale, contexts: Array<DisplayContext>): LocaleDisplayNames {
        var result: LocaleDisplayNames
        if (FACTORY_DISPLAYCONTEXT.isSome()) {
            try {
                result = FACTORY_DISPLAYCONTEXT.invoke(None, [locale, contexts])
            } catch (e: InvocationTargetException) { } catch (e: IllegalAccessException) { }
        }
        if (result.isNone()) {
            result = LocaleDisplayNames_LastResortLocaleDisplayNames(locale, contexts)
        }
        return result
    }

    public static func getInstance(locale: Locale, contexts: Array<DisplayContext>): LocaleDisplayNames {
        return getInstance(ULocale.forLocale(locale), contexts)
    }

    public func getLocale(): ULocale

    public func getDialectHandling(): LocaleDisplayNames_DialectHandling

    public func getContext(Type: DisplayContext_Type): DisplayContext

    public func localeDisplayName(locale: ULocale): String

    public func localeDisplayName(locale: Locale): String

    public func localeDisplayName(localeId: String): String

    public func languageDisplayName(lang: String): String

    public func scriptDisplayName(script: String): String

    
    public func scriptDisplayNameInContext(script: String): String {
        return scriptDisplayName(script)
    }

    public func scriptDisplayName(scriptCode: Int32): String

    public func regionDisplayName(region: String): String

    public func variantDisplayName(variant: String): String

    public func keyDisplayName(key: String): String

    public func keyValueDisplayName(key: String, value: String): String

    public func getUiList(localeSet: Set<ULocale>, inSelf: Bool, collator: Comparator): ArrayList<LocaleDisplayNames_UiListItem> {
        return getUiListCompareWholeItems(localeSet, LocaleDisplayNames_UiListItem.getComparator(collator, inSelf))
    }

    public func getUiListCompareWholeItems(localeSet: Set<ULocale>, comparator: Comparator): ArrayList<LocaleDisplayNames_UiListItem>

    
    protected init() { }

    private static let FACTORY_DIALECTHANDLING: Method

    private static let FACTORY_DISPLAYCONTEXT: Method

}


public class LocaleDisplayNames_DialectHandling <: Enum<LocaleDisplayNames_DialectHandling> {
    public static let STANDARD_NAMES = LocaleDisplayNames_DialectHandling("STANDARD_NAMES", 0)

    public static let DIALECT_NAMES = LocaleDisplayNames_DialectHandling("DIALECT_NAMES", 1)

    private static func _values(): Array<LocaleDisplayNames_DialectHandling> {
        return [LocaleDisplayNames_DialectHandling.STANDARD_NAMES, LocaleDisplayNames_DialectHandling.DIALECT_NAMES]
    }

    private static let _VALUES = LocaleDisplayNames_DialectHandling._values()

    public static func values(): Array<LocaleDisplayNames_DialectHandling> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): LocaleDisplayNames_DialectHandling {
        return (TypeInfo.of<LocaleDisplayNames_DialectHandling>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as LocaleDisplayNames_DialectHandling
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


public class LocaleDisplayNames_UiListItem {
    public let minimized: ULocale

    public let modified: ULocale

    public let nameInDisplayLocale: String

    public let nameInSelf: String

    public init(minimized: ULocale, modified: ULocale, nameInDisplayLocale: String, nameInSelf: String) {
        this.minimized = minimized
        this.modified = modified
        this.nameInDisplayLocale = nameInDisplayLocale
        this.nameInSelf = nameInSelf
    }

    public override func equals(obj: Object): Bool {
        if (refEq(this, obj)) {
            return true
        }
        if (obj.isNone() || !(checkOptionalIs<LocaleDisplayNames_UiListItem, Object>(obj))) {
            return false
        }
        let other = obj
        return nameInDisplayLocale.equals(other.nameInDisplayLocale) && nameInSelf.equals(other.nameInSelf) && minimized.equals(other.minimized) && modified.equals(other.modified)
    }

    public override func hashCode(): Int64 {
        return Int64(Int32(modified.hashCode()) ^ Int32(nameInDisplayLocale.hashCode()))
    }

    public override func toString(): String {
        return "{" + minimized.asString() + ", " + modified.asString() + ", " + (nameInDisplayLocale) + ", " + (nameInSelf) + "}"
    }

    public static func getComparator(comparator: Comparator, inSelf: Bool): Comparator {
        return LocaleDisplayNames_UiListItem_UiListItemComparator(comparator, inSelf) as Comparator
    }
}


class LocaleDisplayNames_UiListItem_UiListItemComparator <: Comparator {
    private let collator: Comparator

    private let useSelf: Bool

    init(collator: Comparator, useSelf: Bool) {
        this.collator = collator
        this.useSelf = useSelf
    }

    public override func compare(o1: LocaleDisplayNames_UiListItem, o2: LocaleDisplayNames_UiListItem): Int32 {
        let result = if (useSelf) { collator.compare(o1.nameInSelf, o2.nameInSelf) } else { collator.compare(o1.nameInDisplayLocale, o2.nameInDisplayLocale) }
        return if (result != 0) { result } else { o1.modified.compareTo(o2.modified) }
    }
}


class LocaleDisplayNames_LastResortLocaleDisplayNames <: LocaleDisplayNames {
    private var locale: ULocale

    private var contexts: Array<DisplayContext>

    init(locale: ULocale, dialectHandling: LocaleDisplayNames_DialectHandling) {
        super()
        this.locale = locale
        let context: DisplayContext = if (refEq(dialectHandling, LocaleDisplayNames_DialectHandling.DIALECT_NAMES)) { DisplayContext.DIALECT_NAMES } else { DisplayContext.STANDARD_NAMES }
        this.contexts = [context]
    }

    init(locale: ULocale, contexts: Array<DisplayContext>) {
        super()
        this.locale = locale
        this.contexts = Array<DisplayContext>(contexts.size)
        arraycopy(contexts, 0, this.contexts, 0, contexts.size)
    }

    public override func getLocale(): ULocale {
        return locale
    }

    public override func getDialectHandling(): LocaleDisplayNames_DialectHandling {
        var result: LocaleDisplayNames_DialectHandling = LocaleDisplayNames_DialectHandling.STANDARD_NAMES
        for (context in contexts) {
            if (refEq(context.typeMethod(), DisplayContext_Type.DIALECT_HANDLING)) {
                if (context.valueMethod() == DisplayContext.DIALECT_NAMES.ordinal) {
                    result = LocaleDisplayNames_DialectHandling.DIALECT_NAMES
                    break
                }
            }
        }
        return result
    }

    public override func getContext(Type: DisplayContext_Type): DisplayContext {
        var result: DisplayContext = DisplayContext.STANDARD_NAMES
        for (context in contexts) {
            if (refEq(context.typeMethod(), Type)) {
                result = context
                break
            }
        }
        return result
    }

    public override func localeDisplayName(locale: ULocale): String {
        return locale.getName()
    }

    public override func localeDisplayName(locale: Locale): String {
        return ULocale.forLocale(locale).getName()
    }

    public override func localeDisplayName(localeId: String): String {
        return ULocale(localeId).getName()
    }

    public override func languageDisplayName(lang: String): String {
        return lang
    }

    public override func scriptDisplayName(script: String): String {
        return script
    }

    public override func scriptDisplayName(scriptCode: Int32): String {
        return UScript.getShortName(scriptCode)
    }

    public override func regionDisplayName(region: String): String {
        return region
    }

    public override func variantDisplayName(variant: String): String {
        return variant
    }

    public override func keyDisplayName(key: String): String {
        return key
    }

    public override func keyValueDisplayName(key: String, value: String): String {
        return value
    }

    public override func getUiListCompareWholeItems(localeSet: Set<ULocale>, comparator: Comparator): ArrayList<LocaleDisplayNames_UiListItem> {
        return Array<String>(0, { _ => "" })
    }
}
