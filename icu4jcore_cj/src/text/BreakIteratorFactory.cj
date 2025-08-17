package icu4cj.text


class BreakIteratorFactory <: BreakIterator_BreakIteratorServiceShim {
    init() {
        super()
    }

    public override func registerInstance(iter: BreakIterator, locale: ULocale, kind: Int32): Object {
        iter.setText(StringCharacterIterator(""))
        return service.registerObject(iter, locale, kind)
    }

    public override func unregister(key: Object): Bool {
        if (service.isDefault()) {
            return false
        }
        return service.unregisterFactory(key)
    }

    public override func getAvailableLocales(): Array<Locale> {
        if (Some(service).isNone()) {
            return ICUResourceBundle.getAvailableLocales()
        } else {
            return service.getAvailableLocales()
        }
    }

    public override func getAvailableULocales(): Array<ULocale> {
        if (Some(service).isNone()) {
            return ICUResourceBundle.getAvailableULocales()
        } else {
            return service.getAvailableULocales()
        }
    }

    public override func createBreakIterator(locale: ULocale, kind: Int32): BreakIterator {
        if (service.isDefault()) {
            return createBreakInstance(locale, kind)
        }
        let actualLoc = Array<ULocale>(1)
        let iter = service.get(locale, kind, actualLoc)
        iter.setLocale(actualLoc[0], actualLoc[0])
        return iter
    }

    static let service: ICULocaleService = BreakIteratorFactory_BFService()

    private static let KIND_NAMES: Array<String> = ["grapheme", "word", "line", "sentence", "title"]

    static func createBreakInstance(locale: ULocale, kind: Int32): BreakIterator {
        var iter: RuleBasedBreakIterator
        let rb = ICUResourceBundle.getBundleInstance(ICUData.ICU_BRKITR_BASE_NAME, locale, ICUResourceBundle_OpenType.LOCALE_ROOT)
        var bytes: ByteArrayStream = None
        var typeKeyExt: String = ""
        if (kind == BreakIterator.KIND_LINE) {
            var keyValue = locale.getKeywordValue("lb")
            if (keyValue.isSome() && (keyValue == "strict" || keyValue == "normal" || keyValue == "loose")) {
                typeKeyExt = "_" + (keyValue)
            }
            let language = locale.getLanguage()
            if (language.isSome() && (language == "ja" || language == "ko")) {
                keyValue = locale.getKeywordValue("lw")
                if (keyValue.isSome() && keyValue == "phrase") {
                    typeKeyExt += "_" + (keyValue)
                }
            }
        }
        let brkfname: String
        try {
            let typeKey = if (typeKeyExt.isEmpty()) { KIND_NAMES[Int64(kind)] } else { Some((KIND_NAMES[Int64(kind)]) + (typeKeyExt)) }
            brkfname = rb.getStringWithFallback("boundaries/" + (typeKey))
            let rulesFileName: String = ICUData.ICU_BRKITR_NAME + '/'.toString() + (brkfname)
            bytes = ICUBinary.getData(rulesFileName)
        } catch (e: Exception) {
            throw MissingResourceException(e.toString(), "", "")
        }
        try {
            let isPhraseBreaking = (brkfname.isSome()) && brkfname.contains("phrase")
            iter = RuleBasedBreakIterator.getInstanceFromCompiledRules(bytes, isPhraseBreaking)
        } catch (e: IOException) {
            Assert.fail(e)
        }
        let uloc = ULocale.forLocale(rb.getLocale())
        iter.setLocale(uloc, uloc)
        if (kind == BreakIterator.KIND_SENTENCE) {
            let ssKeyword = locale.getKeywordValue("ss")
            if (ssKeyword.isSome() && ssKeyword == "standard") {
                let base = ULocale(locale.getBaseName())
                return FilteredBreakIteratorBuilder.getInstance(base).wrapIteratorWithFilter(iter)
            }
        }
        return iter
    }
}


class BreakIteratorFactory_BFService <: ICULocaleService {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    init() {
        super("BreakIterator")
        registerFactory(BreakIteratorFactory_BFService_1RBBreakIteratorFactory(this))
        markDefault()
    }

    public override func validateFallbackLocale(): String {
        return ""
    }
}


class BreakIteratorFactory_BFService_1RBBreakIteratorFactory <: ICULocaleService_ICUResourceBundleFactory {
    init(this_0: BreakIteratorFactory_BFService) {
        super()
    }

    override protected func handleCreate(loc: ULocale, kind: Int32, srvc: ICUService): Object {
        return BreakIteratorFactory.createBreakInstance(loc, kind)
    }
}
