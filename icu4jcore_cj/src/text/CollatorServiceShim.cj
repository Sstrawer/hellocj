package icu4cj.text

class CollatorServiceShim <: Collator_ServiceShim {
    init() {
        super()
    }

    public override func getInstance(locale: ULocale): Collator {
        try {
            let actualLoc = Array<ULocale>(1)
            let coll = service.get(locale, actualLoc)
            if (coll.isNone()) {
                throw MissingResourceException("Could not locate Collator data", "", "")
            }
            return coll.clone()
        } catch (e: CloneNotSupportedException) {
            throw ICUCloneNotSupportedException(e as Exception)
        }
    }

    public override func registerInstance(collator: Collator, locale: ULocale): Object {
        collator.setLocale(locale, locale)
        return service.registerObject(collator, locale)
    }

    public override func registerFactory(f: Collator_CollatorFactory): Object {
        return service.registerFactory(CollatorServiceShim_1CFactory(this, f))
    }

    public override func unregister(registryKey: Object): Bool {
        return service.unregisterFactory(registryKey)
    }

    public override func getAvailableLocales(): Array<Locale> {
        let result: Array<Locale>
        if (service.isDefault()) {
            result = ICUResourceBundle.getAvailableLocales(ICUData.ICU_COLLATION_BASE_NAME, ICUResourceBundle.ICU_DATA_CLASS_LOADER)
        } else {
            result = service.getAvailableLocales()
        }
        return result
    }

    public override func getAvailableULocales(): Array<ULocale> {
        let result: Array<ULocale>
        if (service.isDefault()) {
            result = ICUResourceBundle.getAvailableULocales(ICUData.ICU_COLLATION_BASE_NAME, ICUResourceBundle.ICU_DATA_CLASS_LOADER)
        } else {
            result = service.getAvailableULocales()
        }
        return result
    }

    public override func getDisplayName(objectLocale: ULocale, displayLocale: ULocale): String {
        let id = objectLocale.getName()
        return service.getDisplayName(id, displayLocale)
    }

    static func makeInstance(desiredLocale: ULocale): Collator {
        let validLocale = Output<ULocale>(ULocale.ROOT)
        let t = CollationLoader.loadTailoring(desiredLocale, validLocale)
        return RuleBasedCollator(t, validLocale.value)
    }

    private static var service: ICULocaleService = CollatorServiceShim_CService()
}


class CollatorServiceShim_1CFactory <: ICULocaleService_LocaleKeyFactory {
    var delegate: Collator_CollatorFactory

    init(this_0: CollatorServiceShim, fctry: Collator_CollatorFactory) {
        super(fctry.visible())
        this.delegate = fctry
    }

    public override func handleCreate(loc: ULocale, kind: Int32, srvc: ICUService): Object {
        let coll = delegate.createCollator(loc)
        return coll
    }

    public override func getDisplayName(id: String, displayLocale: ULocale): String {
        let objectLocale = ULocale(id)
        return delegate.getDisplayName(objectLocale, displayLocale)
    }

    public override func getSupportedIDs(): Set<String> {
        return delegate.getSupportedLocaleIDs()
    }
}


class CollatorServiceShim_CService <: ICULocaleService {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    init() {
        super("Collator")
        this.registerFactory(CollatorServiceShim_CService_1CollatorFactory(this))
        markDefault()
    }

    public override func validateFallbackLocale(): String {
        return ""
    }

    override protected func handleDefault(key: ICUService_Key, actualIDReturn: Array<String>): Object {
        if (actualIDReturn.isSome()) {
            actualIDReturn[0] = "root"
        }
        try {
            return CollatorServiceShim.makeInstance(ULocale.ROOT)
        } catch (e: MissingResourceException) {
            return None
        }
    }
}


class CollatorServiceShim_CService_1CollatorFactory <: ICULocaleService_ICUResourceBundleFactory {
    init(this_0: CollatorServiceShim_CService) {
        super(ICUData.ICU_COLLATION_BASE_NAME)
    }

    override protected func handleCreate(uloc: ULocale, kind: Int32, srvc: ICUService): Object {
        return CollatorServiceShim.makeInstance(uloc)
    }
}
