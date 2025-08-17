package icu4cj.text


class NumberFormatServiceShim <: NumberFormat_NumberFormatShim {
    init() {
        super()
    }

    public override func getAvailableLocales(): Array<Locale> {
        if (service.isDefault()) {
            return ICUResourceBundle.getAvailableLocales()
        }
        return service.getAvailableLocales()
    }

    public override func getAvailableULocales(): Array<ULocale> {
        if (service.isDefault()) {
            return ICUResourceBundle.getAvailableULocales()
        }
        return service.getAvailableULocales()
    }

    public override func registerFactory(factory: NumberFormat_NumberFormatFactory): Object {
        return service.registerFactory(NumberFormatServiceShim_NFFactory(factory))
    }

    public override func unregister(registryKey: Object): Bool {
        return service.unregisterFactory(registryKey)
    }

    public override func createInstance(desiredLocale: ULocale, choice: Int32): NumberFormat {
        let actualLoc = Array<ULocale>(1)
        var fmt = service.get(desiredLocale, choice, actualLoc)
        if (fmt.isNone()) {
            throw MissingResourceException("Unable to construct NumberFormat", "", "")
        }
        fmt = fmt.clone()
        if (choice == NumberFormat.CURRENCYSTYLE || choice == NumberFormat.ISOCURRENCYSTYLE || choice == NumberFormat.PLURALCURRENCYSTYLE || choice == NumberFormat.ACCOUNTINGCURRENCYSTYLE || choice == NumberFormat.CASHCURRENCYSTYLE || choice == NumberFormat.STANDARDCURRENCYSTYLE) {
            fmt.setCurrency(Currency.getInstance(desiredLocale))
        }
        let uloc = actualLoc[0]
        fmt.setLocale(uloc, uloc)
        return fmt
    }

    private static var service: ICULocaleService = NumberFormatServiceShim_NFService()
}


class NumberFormatServiceShim_NFFactory <: ICULocaleService_LocaleKeyFactory {
    private var delegate: NumberFormat_NumberFormatFactory

    init(delegate: NumberFormat_NumberFormatFactory) {
        super(if (delegate.visible()) { VISIBLE } else { INVISIBLE })
        this.delegate = delegate
    }

    public override func create(key: ICUService_Key, srvc: ICUService): Object {
        if (!handlesKey(key) || !(checkOptionalIs<ICULocaleService_LocaleKey, ICUService_Key>(key))) {
            return None
        }
        let lkey = key
        var result = delegate.createFormat(lkey.canonicalLocale(), lkey.kindMethod())
        if (result.isNone()) {
            result = srvc.getKey(key, None, this)
        }
        return result
    }

    override protected func getSupportedIDs(): Set<String> {
        return delegate.getSupportedLocaleNames()
    }
}


class NumberFormatServiceShim_NFService <: ICULocaleService {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    init() {
        super("NumberFormat")
        this.registerFactory(NumberFormatServiceShim_NFService_1RBNumberFormatFactory(this))
        markDefault()
    }
}


class NumberFormatServiceShim_NFService_1RBNumberFormatFactory <: ICULocaleService_ICUResourceBundleFactory {
    init(this_0: NumberFormatServiceShim_NFService) {
        super()
    }

    override protected func handleCreate(loc: ULocale, kind: Int32, srvc: ICUService): Object {
        return NumberFormat.createInstance(loc, kind)
    }
}
