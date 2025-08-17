package icu4cj.text


public abstract class BreakIterator <: Cloneable {
    private static let GeneratedStaticLockObject = Monitor()

    private static let DEBUG = ICUDebug.enabled("breakiterator")


    public override func clone(): Object {
        try {
            return super.toString()
        } catch (e: CloneNotSupportedException) {
            throw ICUCloneNotSupportedException(e as Exception)
        }
    }

    public static let DONE = -1

    public func first(): Int32

    public func last(): Int32

    public func next(n: Int32): Int32

    public func next(): Int32

    public func previous(): Int32

    public func following(offset: Int32): Int32

    public func preceding(offset: Int32): Int32 {
        var pos = following(offset)
        while (pos >= offset && pos != DONE) {
            pos = previous()
        }
        return pos
    }

    public func isBoundary(offset: Int32): Bool {
        if (offset == 0) {
            return true
        } else {
            return following(offset - 1) == offset
        }
    }

    public func current(): Int32

    public static let WORD_NONE = 0

    public static let WORD_NONE_LIMIT = 100

    public static let WORD_NUMBER = 100

    public static let WORD_NUMBER_LIMIT = 200

    public static let WORD_LETTER = 200

    public static let WORD_LETTER_LIMIT = 300

    public static let WORD_KANA = 300

    public static let WORD_KANA_LIMIT = 400

    public static let WORD_IDEO = 400

    public static let WORD_IDEO_LIMIT = 500

    public func getRuleStatus(): Int32 {
        return 0
    }

    public func getRuleStatusVec(fillInArray: Array<Int32>): Int32 {
        if (fillInArray.isSome() && Int32(fillInArray.size) > 0) {
            fillInArray[0] = 0
        }
        return 1
    }

    public func getText(): CharacterIterator

    public func setText(newText: String): Unit {
        setText(StringCharacterIterator(newText))
    }

    public func setText(newText: String): Unit {
        setText(CSCharacterIterator(newText))
    }

    public func setText(newText: CharacterIterator): Unit

    public static let KIND_CHARACTER = 0

    public static let KIND_WORD = 1

    public static let KIND_LINE = 2

    public static let KIND_SENTENCE = 3

    
    public static let KIND_TITLE = 4

    private static let KIND_COUNT = 5

    private static let iterCache = Array<CacheValue<Object>>(5)

    public static func getWordInstance(): BreakIterator {
        return getWordInstance(ULocale.getDefault())
    }

    public static func getWordInstance(`where`: Locale): BreakIterator {
        return getBreakInstance(ULocale.forLocale(`where`), KIND_WORD)
    }

    public static func getWordInstance(`where`: ULocale): BreakIterator {
        return getBreakInstance(`where`, KIND_WORD)
    }

    public static func getLineInstance(): BreakIterator {
        return getLineInstance(ULocale.getDefault())
    }

    public static func getLineInstance(`where`: Locale): BreakIterator {
        return getBreakInstance(ULocale.forLocale(`where`), KIND_LINE)
    }

    public static func getLineInstance(`where`: ULocale): BreakIterator {
        return getBreakInstance(`where`, KIND_LINE)
    }

    public static func getCharacterInstance(): BreakIterator {
        return getCharacterInstance(ULocale.getDefault())
    }

    public static func getCharacterInstance(`where`: Locale): BreakIterator {
        return getBreakInstance(ULocale.forLocale(`where`), KIND_CHARACTER)
    }

    public static func getCharacterInstance(`where`: ULocale): BreakIterator {
        return getBreakInstance(`where`, KIND_CHARACTER)
    }

    public static func getSentenceInstance(): BreakIterator {
        return getSentenceInstance(ULocale.getDefault())
    }

    public static func getSentenceInstance(`where`: Locale): BreakIterator {
        return getBreakInstance(ULocale.forLocale(`where`), KIND_SENTENCE)
    }

    public static func getSentenceInstance(`where`: ULocale): BreakIterator {
        return getBreakInstance(`where`, KIND_SENTENCE)
    }

    
    public static func getTitleInstance(): BreakIterator {
        return getTitleInstance(ULocale.getDefault())
    }

    
    public static func getTitleInstance(`where`: Locale): BreakIterator {
        return getBreakInstance(ULocale.forLocale(`where`), KIND_TITLE)
    }

    
    public static func getTitleInstance(`where`: ULocale): BreakIterator {
        return getBreakInstance(`where`, KIND_TITLE)
    }

    public static func registerInstance(iter: BreakIterator, locale: Locale, kind: Int32): Object {
        return registerInstance(iter, ULocale.forLocale(locale), kind)
    }

    public static func registerInstance(iter: BreakIterator, locale: ULocale, kind: Int32): Object {
        if (iterCache[Int64(kind)].isSome()) {
            let cache = iterCache[Int64(kind)].get()
            if (cache.isSome()) {
                if (cache.getLocale().equals(locale)) {
                    iterCache[Int64(kind)] = None
                }
            }
        }
        return getShim().registerInstance(iter, locale, kind)
    }

    public static func unregister(key: Object): Bool {
        if (key.isNone()) {
            throw IllegalArgumentException("registry key must not be null")
        }
        if (shim.isSome()) {
            var kind = 0
            while (kind < KIND_COUNT) {
                iterCache[Int64(kind)] = None
                kind++
            }
            return shim.unregister(key)
        }
        return false
    }

    
    public static func getBreakInstance(`where`: ULocale, kind: Int32): BreakIterator {
        if (`where`.isNone()) {
            throw NoneValueException("Specified locale is null")
        }
        if (iterCache[Int64(kind)].isSome()) {
            let cache = iterCache[Int64(kind)].get()
            if (cache.isSome()) {
                if (cache.getLocale().equals(`where`)) {
                    return cache.createBreakInstance()
                }
            }
        }
        let result = getShim().createBreakIterator(`where`, kind)
        let cache = BreakIterator_BreakIteratorCache(`where`, result)
        iterCache[Int64(kind)] = CacheValue.getInstance(cache)
        return result
    }

    public static func getAvailableLocales(): Array<Locale> {
        synchronized (GeneratedStaticLockObject) {
            return getShim().getAvailableLocales()
        }
    }

    public static func getAvailableULocales(): Array<ULocale> {
        synchronized (GeneratedStaticLockObject) {
            return getShim().getAvailableULocales()
        }
    }

    private static var shim: BreakIterator_BreakIteratorServiceShim

    private static func getShim(): BreakIterator_BreakIteratorServiceShim {
        if (shim.isNone()) {
            try {
                let cls: ClassTypeInfo = TypeInfo.get("com.ibm.icu.text.BreakIteratorFactory") as ClassTypeInfo
                shim = cls.construct([0]) as BreakIterator_BreakIteratorServiceShim
            } catch (e: MissingResourceException) {
                throw e
            } catch (e: Exception) {
                if (DEBUG) {
                    e.printStackTrace()
                }
                throw Exception(e.message)
            }
        }
        return shim
    }

    public func getLocale(Type: ULocale_Type): ULocale {
        return if (refEq(Type, ULocale.ACTUAL_LOCALE)) { this.actualLocale } else { this.validLocale }
    }

    func setLocale(valid: ULocale, actual: ULocale): Unit {
        if ((valid.isNone()) != (actual.isNone())) {
            throw IllegalArgumentException()
        }
        this.validLocale = valid
        this.actualLocale = actual
    }

    private var validLocale: ULocale

    private var actualLocale: ULocale
}


class BreakIterator_BreakIteratorCache {
    private var iter: BreakIterator

    private var `where`: ULocale

    init(`where`: ULocale, iter: BreakIterator) {
        this.`where` = `where`
        this.iter = iter.clone()
    }

    public func getLocale(): ULocale {
        return `where`
    }

    public func createBreakInstance(): BreakIterator {
        return iter.clone()
    }
}


abstract class BreakIterator_BreakIteratorServiceShim {

    public func registerInstance(iter: BreakIterator, l: ULocale, k: Int32): Object

    public func unregister(key: Object): Bool

    public func getAvailableLocales(): Array<Locale>

    public func getAvailableULocales(): Array<ULocale>

    public func createBreakIterator(l: ULocale, k: Int32): BreakIterator
}
