package icu4cj.util


public class GlobalizationPreferences <: Freezable<GlobalizationPreferences> {

    public static let NF_NUMBER = 0

    public static let NF_CURRENCY = 1

    public static let NF_PERCENT = 2

    public static let NF_SCIENTIFIC = 3

    public static let NF_INTEGER = 4

    private static let NF_LIMIT = NF_INTEGER + 1

    public static let DF_FULL = DateFormat.FULL

    public static let DF_LONG = DateFormat.LONG

    public static let DF_MEDIUM = DateFormat.MEDIUM

    public static let DF_SHORT = DateFormat.SHORT

    public static let DF_NONE = 4

    private static let DF_LIMIT = DF_NONE + 1

    public static let ID_LOCALE = 0

    public static let ID_LANGUAGE = 1

    public static let ID_SCRIPT = 2

    public static let ID_TERRITORY = 3

    public static let ID_VARIANT = 4

    public static let ID_KEYWORD = 5

    public static let ID_KEYWORD_VALUE = 6

    public static let ID_CURRENCY = 7

    public static let ID_CURRENCY_SYMBOL = 8

    public static let ID_TIMEZONE = 9

    public static let BI_CHARACTER = BreakIterator.KIND_CHARACTER

    public static let BI_WORD = BreakIterator.KIND_WORD

    public static let BI_LINE = BreakIterator.KIND_LINE

    public static let BI_SENTENCE = BreakIterator.KIND_SENTENCE

    public static let BI_TITLE = BreakIterator.KIND_TITLE

    private static let BI_LIMIT = BI_TITLE + 1

    public func setLocales(inputLocales: ArrayList<ULocale>): GlobalizationPreferences {
        if (isFrozen()) {
            throw UnsupportedOperationException("Attempt to modify immutable object")
        }
        locales = processLocales(inputLocales)
        return this
    }

    public func getLocales(): ArrayList<ULocale> {
        let result: ArrayList<ULocale>
        if (locales.isNone()) {
            result = guessLocales()
        } else {
            result = ArrayList<ULocale>()
            result.appendAll(locales)
        }
        return result
    }

    public func getLocale(index: Int32): ULocale {
        var lcls = locales
        if (lcls.isNone()) {
            lcls = guessLocales()
        }
        if (index >= 0 && index < Int32(lcls.size)) {
            return lcls[Int64(index)]
        }
        return None
    }

    public func setLocales(uLocales: Array<ULocale>): GlobalizationPreferences {
        if (isFrozen()) {
            throw UnsupportedOperationException("Attempt to modify immutable object")
        }
        return setLocales(ArrayList(uLocales))
    }

    public func setLocale(uLocale: ULocale): GlobalizationPreferences {
        if (isFrozen()) {
            throw UnsupportedOperationException("Attempt to modify immutable object")
        }
        return setLocales([uLocale])
    }

    public func setLocales(acceptLanguageString: String): GlobalizationPreferences {
        if (isFrozen()) {
            throw UnsupportedOperationException("Attempt to modify immutable object")
        }
        let acceptSet = LocalePriorityList.add(acceptLanguageString).build().getULocales()
        locales = processLocales(ArrayList<ULocale>(acceptSet))
        return this
    }

    public func getResourceBundle(baseName: String): ResourceBundle {
        return getResourceBundle(baseName, None)
    }

    public func getResourceBundle(baseName: String, loader: ClassLoader): ResourceBundle {
        var urb: UResourceBundle
        var candidate: UResourceBundle
        var actualLocaleName: String
        let fallbacks = getLocales()
        var i = 0
        while (i < Int32(fallbacks.size)) {
            let localeName: String = (fallbacks[Int64(i)]).toString()
            if (actualLocaleName.isSome() && localeName.equals(actualLocaleName)) {
                urb = candidate
                break
            }
            try {
                if (loader.isNone()) {
                    candidate = UResourceBundle.getBundleInstance(baseName, localeName)
                } else {
                    candidate = UResourceBundle.getBundleInstance(baseName, localeName, loader)
                }
                if (candidate.isSome()) {
                    actualLocaleName = candidate.getULocale().getName()
                    if (actualLocaleName.equals(localeName)) {
                        urb = candidate
                        break
                    }
                    if (urb.isNone()) {
                        urb = candidate
                    }
                }
            } catch (mre: MissingResourceException) {
                actualLocaleName = None
                continue
            }
            i++
        }
        if (urb.isNone()) {
            throw MissingResourceException("Can't find bundle for base name " + (baseName), baseName, "")
        }
        return urb
    }

    public func setTerritory(territory: String): GlobalizationPreferences {
        if (isFrozen()) {
            throw UnsupportedOperationException("Attempt to modify immutable object")
        }
        this.territory = territory
        return this
    }

    public func getTerritory(): String {
        if (territory.isNone()) {
            return guessTerritory()
        }
        return territory
    }

    public func setCurrency(currency: Currency): GlobalizationPreferences {
        if (isFrozen()) {
            throw UnsupportedOperationException("Attempt to modify immutable object")
        }
        this.currency = currency
        return this
    }

    public func getCurrency(): Currency {
        if (currency.isNone()) {
            return guessCurrency()
        }
        return currency
    }

    public func setCalendar(calendar: Calendar): GlobalizationPreferences {
        if (isFrozen()) {
            throw UnsupportedOperationException("Attempt to modify immutable object")
        }
        this.calendar = calendar.clone()
        return this
    }

    public func getCalendar(): Calendar {
        if (calendar.isNone()) {
            return guessCalendar()
        }
        let temp = calendar.clone()
        temp.setTimeZone(getTimeZone())
        temp.setTimeInMillis(DateTime.now().toUnixTimeStamp().toMilliseconds())
        return temp
    }

    public func setTimeZone(timezone: TimeZone): GlobalizationPreferences {
        if (isFrozen()) {
            throw UnsupportedOperationException("Attempt to modify immutable object")
        }
        this.timezone = timezone.clone()
        return this
    }

    public func getTimeZone(): TimeZone {
        if (timezone.isNone()) {
            return guessTimeZone()
        }
        return timezone.cloneAsThawed()
    }

    public func getCollator(): Collator {
        if (collator.isNone()) {
            return guessCollator()
        }
        try {
            return collator.clone()
        } catch (e: CloneNotSupportedException) {
            throw ICUCloneNotSupportedException("Error in cloning collator", e as Exception)
        }
    }

    public func setCollator(collator: Collator): GlobalizationPreferences {
        if (isFrozen()) {
            throw UnsupportedOperationException("Attempt to modify immutable object")
        }
        try {
            this.collator = collator.clone()
        } catch (e: CloneNotSupportedException) {
            throw ICUCloneNotSupportedException("Error in cloning collator", e as Exception)
        }
        return this
    }

    public func getBreakIterator(Type: Int32): BreakIterator {
        if (Type < BI_CHARACTER || Type >= BI_LIMIT) {
            throw IllegalArgumentException("Illegal break iterator type")
        }
        if (breakIterators.isNone() || breakIterators[Int64(Type)].isNone()) {
            return guessBreakIterator(Type)
        }
        return breakIterators[Int64(Type)].clone()
    }

    public func setBreakIterator(Type: Int32, iterator: BreakIterator): GlobalizationPreferences {
        if (Type < BI_CHARACTER || Type >= BI_LIMIT) {
            throw IllegalArgumentException("Illegal break iterator type")
        }
        if (isFrozen()) {
            throw UnsupportedOperationException("Attempt to modify immutable object")
        }
        if (breakIterators.isNone()) {
            breakIterators = Array<BreakIterator>(Int64(BI_LIMIT))
        }
        breakIterators[Int64(Type)] = iterator.clone()
        return this
    }

    public func getDisplayName(id: String, Type: Int32): String {
        var result = id
        for (locale in getLocales()) {
            if (!isAvailableLocale(locale, TYPE_GENERIC)) {
                continue
            }
            match (Type) {
                case 0 => result = ULocale.getDisplayNameStatic(id, locale)
                case 1 => result = ULocale.getDisplayLanguageStatic(id, locale)
                case 2 => result = ULocale.getDisplayScriptStatic("und-" + (id), locale)
                case 3 => result = ULocale.getDisplayCountryStatic("und-" + (id), locale)
                case 4 => result = ULocale.getDisplayVariantStatic("und-QQ-" + (id), locale)
                case 5 => result = ULocale.getDisplayKeyword(id, locale)
                case 6 =>
                    let parts = Array<String>(2)
                    Utility.split(id, '=', parts)
                    result = ULocale.getDisplayKeywordValueStatic("und@" + (id), parts[0], locale)
                    if (result.equals(parts[1])) {
                        continue
                    }
                case 8 | 7 =>
                    let temp = Currency(id)
                    result = temp.getName(locale, if (Type == ID_CURRENCY) { Currency.LONG_NAME } else { Currency.SYMBOL_NAME }, None)
                case 9 =>
                    let dtf = SimpleDateFormat("vvvv", locale)
                    dtf.setTimeZone(TimeZone.getFrozenTimeZone(id))
                    result = dtf.format(Date())
                    var isBadStr = false
                    var teststr = result
                    let sidx = indexOfWrap(result.indexOf(UInt8(UInt32('('))))
                    let eidx = indexOfWrap(result.indexOf(UInt8(UInt32(')'))))
                    if (sidx != -1 && eidx != -1 && (eidx - sidx) == 3) {
                        teststr = result[Int64(sidx + 1)..Int64(eidx)]
                    }
                    if (Int32(teststr.size) == 2) {
                        isBadStr = true
                        var i = 0
                        while (i < 2) {
                            let c = Char(teststr[Int64(i)])
                            if (c < 'A' || 'Z' < c) {
                                isBadStr = false
                                break
                            }
                            i++
                        }
                    }
                    if (isBadStr) {
                        continue
                    }
                case _ => throw IllegalArgumentException("Unknown type: " + Type.toString())
            }
            if (!id.equals(result)) {
                return result
            }
        }
        return result
    }

    public func setDateFormat(dateStyle: Int32, timeStyle: Int32, format: DateFormat): GlobalizationPreferences {
        if (isFrozen()) {
            throw UnsupportedOperationException("Attempt to modify immutable object")
        }
        if (dateFormats.isNone()) {
            dateFormats = Array<Array<DateFormat>>(Int64(DF_LIMIT)) { _ => Array<DateFormat>(Int64(DF_LIMIT)) }
        }
        dateFormats[Int64(dateStyle)][Int64(timeStyle)] = format.clone()
        return this
    }

    public func getDateFormat(dateStyle: Int32, timeStyle: Int32): DateFormat {
        if (dateStyle == DF_NONE && timeStyle == DF_NONE || dateStyle < 0 || dateStyle >= DF_LIMIT || timeStyle < 0 || timeStyle >= DF_LIMIT) {
            throw IllegalArgumentException("Illegal date format style arguments")
        }
        var result: DateFormat
        if (dateFormats.isSome()) {
            result = dateFormats[Int64(dateStyle)][Int64(timeStyle)]
        }
        if (result.isSome()) {
            result = result.clone()
            result.setTimeZone(getTimeZone())
        } else {
            result = guessDateFormat(dateStyle, timeStyle)
        }
        return result
    }

    public func getNumberFormat(style: Int32): NumberFormat {
        if (style < 0 || style >= NF_LIMIT) {
            throw IllegalArgumentException("Illegal number format type")
        }
        var result: NumberFormat
        if (numberFormats.isSome()) {
            result = numberFormats[Int64(style)]
        }
        if (result.isSome()) {
            result = result.clone()
        } else {
            result = guessNumberFormat(style)
        }
        return result
    }

    public func setNumberFormat(style: Int32, format: NumberFormat): GlobalizationPreferences {
        if (isFrozen()) {
            throw UnsupportedOperationException("Attempt to modify immutable object")
        }
        if (numberFormats.isNone()) {
            numberFormats = Array<NumberFormat>(Int64(NF_LIMIT))
        }
        numberFormats[Int64(style)] = format.clone()
        return this
    }

    public func reset(): GlobalizationPreferences {
        if (isFrozen()) {
            throw UnsupportedOperationException("Attempt to modify immutable object")
        }
        locales = None
        territory = None
        calendar = None
        collator = None
        breakIterators = None
        timezone = None
        currency = None
        dateFormats = None
        numberFormats = None
        implicitLocales = None
        return this
    }

    protected func processLocales(inputLocales: ArrayList<ULocale>): ArrayList<ULocale> {
        let result = ArrayList<ULocale>()
        for (uloc in inputLocales) {
            let language = uloc.getLanguage()
            let script = uloc.getScript()
            let country = uloc.getCountry()
            let variant = uloc.getVariant()
            var bInserted = false
            var j = 0
            while (j < Int32(result.size)) {
                let u = result[Int64(j)]
                if (!u.getLanguage().equals(language)) {
                    continue
                }
                let s = u.getScript()
                let c = u.getCountry()
                let v = u.getVariant()
                if (!s.equals(script)) {
                    if (Int32(s.size) == 0 && Int32(c.size) == 0 && Int32(v.size) == 0) {
                        result.insert(Int64(j), uloc)
                        bInserted = true
                        break
                    } else if (Int32(s.size) == 0 && c.equals(country)) {
                        result.insert(Int64(j), uloc)
                        bInserted = true
                        break
                    } else if (Int32(script.size) == 0 && Int32(country.size) > 0 && Int32(c.size) == 0) {
                        result.insert(Int64(j), uloc)
                        bInserted = true
                        break
                    }
                    continue
                }
                if (!c.equals(country)) {
                    if (Int32(c.size) == 0 && Int32(v.size) == 0) {
                        result.insert(Int64(j), uloc)
                        bInserted = true
                        break
                    }
                }
                if (!v.equals(variant) && Int32(v.size) == 0) {
                    result.insert(Int64(j), uloc)
                    bInserted = true
                    break
                }
                j++
            }
            if (!bInserted) {
                result.append(uloc)
            }
        }
        var index = 0
        while (index < Int32(result.size)) {
            var uloc = result[Int64(index)]
            while ((match (0) { case _ => uloc = uloc.getFallback(); uloc }).isSome()) {
                if (Int32(uloc.getLanguage().size) == 0) {
                    break
                }
                index++
                result.insert(Int64(index), uloc)
            }
            index++
        }
        index = 0
        while (index < Int32(result.size) - 1) {
            let uloc = result[Int64(index)]
            var bRemoved = false
            var i = index + 1
            while (i < Int32(result.size)) {
                if (uloc.equals(result[Int64(i)])) {
                    result.remove(Int64(index))
                    bRemoved = true
                    break
                }
                i++
            }
            if (!bRemoved) {
                index++
            }
        }
        return result
    }

    protected func guessDateFormat(dateStyle: Int32, timeStyle: Int32): DateFormat {
        let result: DateFormat
        var dfLocale = getAvailableLocale(TYPE_DATEFORMAT)
        if (dfLocale.isNone()) {
            dfLocale = ULocale.ROOT
        }
        if (timeStyle == DF_NONE) {
            result = DateFormat.getDateInstance(getCalendar(), dateStyle, dfLocale)
        } else if (dateStyle == DF_NONE) {
            result = DateFormat.getTimeInstance(getCalendar(), timeStyle, dfLocale)
        } else {
            result = DateFormat.getDateTimeInstance(getCalendar(), dateStyle, timeStyle, dfLocale)
        }
        return result
    }

    protected func guessNumberFormat(style: Int32): NumberFormat {
        let result: NumberFormat
        var nfLocale = getAvailableLocale(TYPE_NUMBERFORMAT)
        if (nfLocale.isNone()) {
            nfLocale = ULocale.ROOT
        }
        match (style) {
            case 0 => result = NumberFormat.getInstance(nfLocale)
            case 3 => result = NumberFormat.getScientificInstance(nfLocale)
            case 4 => result = NumberFormat.getIntegerInstance(nfLocale)
            case 2 => result = NumberFormat.getPercentInstance(nfLocale)
            case 1 =>
                result = NumberFormat.getCurrencyInstance(nfLocale)
                result.setCurrency(getCurrency())
            case _ => throw IllegalArgumentException("Unknown number format style")
        }
        return result
    }

    protected func guessTerritory(): String {
        var result: String
        for (locale in getLocales()) {
            result = locale.getCountry()
            if (Int32(result.size) != 0) {
                return result
            }
        }
        let firstLocale = getLocale(0)
        let language = firstLocale.getLanguage()
        let script = firstLocale.getScript()
        result = None
        if (Int32(script.size) != 0) {
            result = language_territory_hack_map.get((language) + "_" + (script))
        }
        if (result.isNone()) {
            result = language_territory_hack_map.get(language)
        }
        if (result.isNone()) {
            result = "US"
        }
        return result
    }

    protected func guessCurrency(): Currency {
        return Currency.getInstance(ULocale("und-" + (getTerritory())))
    }

    protected func guessLocales(): ArrayList<ULocale> {
        if (implicitLocales.isNone()) {
            let result = ArrayList<ULocale>(1)
            result.append(ULocale.getDefault())
            implicitLocales = processLocales(result)
        }
        return implicitLocales
    }

    protected func guessCollator(): Collator {
        var collLocale = getAvailableLocale(TYPE_COLLATOR)
        if (collLocale.isNone()) {
            collLocale = ULocale.ROOT
        }
        return Collator.getInstance(collLocale)
    }

    protected func guessBreakIterator(Type: Int32): BreakIterator {
        var bitr: BreakIterator
        var brkLocale = getAvailableLocale(TYPE_BREAKITERATOR)
        if (brkLocale.isNone()) {
            brkLocale = ULocale.ROOT
        }
        match (Type) {
            case 0 => bitr = BreakIterator.getCharacterInstance(brkLocale)
            case 4 => bitr = BreakIterator.getTitleInstance(brkLocale)
            case 1 => bitr = BreakIterator.getWordInstance(brkLocale)
            case 2 => bitr = BreakIterator.getLineInstance(brkLocale)
            case 3 => bitr = BreakIterator.getSentenceInstance(brkLocale)
            case _ => throw IllegalArgumentException("Unknown break iterator type")
        }
        return bitr
    }

    protected func guessTimeZone(): TimeZone {
        var timezoneString = territory_tzid_hack_map.get(getTerritory())
        if (timezoneString.isNone()) {
            let attempt = TimeZone.getAvailableIDs(getTerritory())
            if (Int32(attempt.size) == 0) {
                timezoneString = "Etc/GMT"
            } else {
                var i: Int32 = 0
                i = 0
                while (i < Int32(attempt.size)) {
                    if (indexOfWrap(attempt[Int64(i)].indexOf("/")) >= 0) {
                        break
                    }
                    i++
                }
                if (i > Int32(attempt.size)) {
                    i = 0
                }
                timezoneString = attempt[Int64(i)]
            }
        }
        return TimeZone.getTimeZone(timezoneString)
    }

    protected func guessCalendar(): Calendar {
        var calLocale = getAvailableLocale(TYPE_CALENDAR)
        if (calLocale.isNone()) {
            calLocale = ULocale.US
        }
        return Calendar.getInstance(getTimeZone(), calLocale)
    }

    private var locales: ArrayList<ULocale>

    private var territory: String

    private var currency: Currency

    private var timezone: TimeZone

    private var calendar: Calendar

    private var collator: Collator

    private var breakIterators: Array<BreakIterator>

    private var dateFormats: Array<Array<DateFormat>>

    private var numberFormats: Array<NumberFormat>

    private var implicitLocales: ArrayList<ULocale>


    private func getAvailableLocale(Type: Int32): ULocale {
        let locs = getLocales()
        var result: ULocale
        var i = 0
        while (i < Int32(locs.size)) {
            let l = locs[Int64(i)]
            if (isAvailableLocale(l, Type)) {
                result = l
                break
            }
            i++
        }
        return result
    }

    private func isAvailableLocale(loc: ULocale, Type: Int32): Bool {
        let bits = available_locales.get(loc)
        if (bits.isSome() && bits.get(Type)) {
            return true
        }
        return false
    }

    private static let available_locales = HashMap<ULocale, BitSet>()

    private static let TYPE_GENERIC = 0

    private static let TYPE_CALENDAR = 1

    private static let TYPE_DATEFORMAT = 2

    private static let TYPE_NUMBERFORMAT = 3

    private static let TYPE_COLLATOR = 4

    private static let TYPE_BREAKITERATOR = 5

    private static let TYPE_LIMIT = TYPE_BREAKITERATOR + 1


    private static let language_territory_hack_map: Map<String, String> = HashMap<String, String>()

    private static let language_territory_hack: Array<Array<String>> = [["af", "ZA"], ["am", "ET"], ["ar", "SA"], ["as", "IN"], ["ay", "PE"], ["az", "AZ"], ["bal", "PK"], ["be", "BY"], ["bg", "BG"], ["bn", "IN"], ["bs", "BA"], ["ca", "ES"], ["ch", "MP"], ["cpe", "SL"], ["cs", "CZ"], ["cy", "GB"], ["da", "DK"], ["de", "DE"], ["dv", "MV"], ["dz", "BT"], ["el", "GR"], ["en", "US"], ["es", "ES"], ["et", "EE"], ["eu", "ES"], ["fa", "IR"], ["fi", "FI"], ["fil", "PH"], ["fj", "FJ"], ["fo", "FO"], ["fr", "FR"], ["ga", "IE"], ["gd", "GB"], ["gl", "ES"], ["gn", "PY"], ["gu", "IN"], ["gv", "GB"], ["ha", "NG"], ["he", "IL"], ["hi", "IN"], ["ho", "PG"], ["hr", "HR"], ["ht", "HT"], ["hu", "HU"], ["hy", "AM"], ["id", "ID"], ["is", "IS"], ["it", "IT"], ["ja", "JP"], ["ka", "GE"], ["kk", "KZ"], ["kl", "GL"], ["km", "KH"], ["kn", "IN"], ["ko", "KR"], ["kok", "IN"], ["ks", "IN"], ["ku", "TR"], ["ky", "KG"], ["la", "VA"], ["lb", "LU"], ["ln", "CG"], ["lo", "LA"], ["lt", "LT"], ["lv", "LV"], ["mai", "IN"], ["men", "GN"], ["mg", "MG"], ["mh", "MH"], ["mk", "MK"], ["ml", "IN"], ["mn", "MN"], ["mni", "IN"], ["mo", "MD"], ["mr", "IN"], ["ms", "MY"], ["mt", "MT"], ["my", "MM"], ["na", "NR"], ["nb", "NO"], ["nd", "ZA"], ["ne", "NP"], ["niu", "NU"], ["nl", "NL"], ["nn", "NO"], ["no", "NO"], ["nr", "ZA"], ["nso", "ZA"], ["ny", "MW"], ["om", "KE"], ["or", "IN"], ["pa", "IN"], ["pau", "PW"], ["pl", "PL"], ["ps", "PK"], ["pt", "BR"], ["qu", "PE"], ["rn", "BI"], ["ro", "RO"], ["ru", "RU"], ["rw", "RW"], ["sd", "IN"], ["sg", "CF"], ["si", "LK"], ["sk", "SK"], ["sl", "SI"], ["sm", "WS"], ["so", "DJ"], ["sq", "CS"], ["sr", "CS"], ["ss", "ZA"], ["st", "ZA"], ["sv", "SE"], ["sw", "KE"], ["ta", "IN"], ["te", "IN"], ["tem", "SL"], ["tet", "TL"], ["th", "TH"], ["ti", "ET"], ["tg", "TJ"], ["tk", "TM"], ["tkl", "TK"], ["tvl", "TV"], ["tl", "PH"], ["tn", "ZA"], ["to", "TO"], ["tpi", "PG"], ["tr", "TR"], ["ts", "ZA"], ["uk", "UA"], ["ur", "IN"], ["uz", "UZ"], ["ve", "ZA"], ["vi", "VN"], ["wo", "SN"], ["xh", "ZA"], ["zh", "CN"], ["zh_Hant", "TW"], ["zu", "ZA"], ["aa", "ET"], ["byn", "ER"], ["eo", "DE"], ["gez", "ET"], ["haw", "US"], ["iu", "CA"], ["kw", "GB"], ["sa", "IN"], ["sh", "HR"], ["sid", "ET"], ["syr", "SY"], ["tig", "ER"], ["tt", "RU"], ["wal", "ET"]]


    static let territory_tzid_hack_map: Map<String, String> = HashMap<String, String>()

    static let territory_tzid_hack: Array<Array<String>> = [["AQ", "Antarctica/McMurdo"], ["AR", "America/Buenos_Aires"], ["AU", "Australia/Sydney"], ["BR", "America/Sao_Paulo"], ["CA", "America/Toronto"], ["CD", "Africa/Kinshasa"], ["CL", "America/Santiago"], ["CN", "Asia/Shanghai"], ["EC", "America/Guayaquil"], ["ES", "Europe/Madrid"], ["GB", "Europe/London"], ["GL", "America/Godthab"], ["ID", "Asia/Jakarta"], ["ML", "Africa/Bamako"], ["MX", "America/Mexico_City"], ["MY", "Asia/Kuala_Lumpur"], ["NZ", "Pacific/Auckland"], ["PT", "Europe/Lisbon"], ["RU", "Europe/Moscow"], ["UA", "Europe/Kiev"], ["US", "America/New_York"], ["UZ", "Asia/Tashkent"], ["PF", "Pacific/Tahiti"], ["FM", "Pacific/Kosrae"], ["KI", "Pacific/Tarawa"], ["KZ", "Asia/Almaty"], ["MH", "Pacific/Majuro"], ["MN", "Asia/Ulaanbaatar"], ["SJ", "Arctic/Longyearbyen"], ["UM", "Pacific/Midway"]]


     private var frozen: Bool = false

    public override func isFrozen(): Bool {
        return frozen
    }

    public override func freeze(): GlobalizationPreferences {
        frozen = true
        return this
    }

    public override func cloneAsThawed(): GlobalizationPreferences {
        try {
            let result = // Мapping is present but failed: clone()
            result.frozen = false
            return result
        } catch (e: CloneNotSupportedException) {
            return None
        }
    }
}
