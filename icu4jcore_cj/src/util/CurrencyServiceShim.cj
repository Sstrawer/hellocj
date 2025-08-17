package icu4cj.util


class CurrencyServiceShim <: Currency_ServiceShim {
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

    public override func createInstance(loc: ULocale): Currency {
        if (service.isDefault()) {
            return Currency.createCurrency(loc)
        }
        let curr = service.get(loc)
        return curr
    }

    public override func registerInstance(currency: Currency, locale: ULocale): Object {
        return service.registerObject(currency, locale)
    }

    public override func unregister(registryKey: Object): Bool {
        return service.unregisterFactory(registryKey)
    }

    static let service: ICULocaleService = CurrencyServiceShim_CFService()
}


class CurrencyServiceShim_CFService <: ICULocaleService {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    init() {
        super("Currency")
        registerFactory(CurrencyServiceShim_CFService_1CurrencyFactory(this))
        markDefault()
    }
}


class CurrencyServiceShim_CFService_1CurrencyFactory <: ICULocaleService_ICUResourceBundleFactory {
    init(this_0: CurrencyServiceShim_CFService) {
        super()
    }

    override protected func handleCreate(loc: ULocale, kind: Int32, srvc: ICUService): Object {
        return Currency.createCurrency(loc)
    }
}
