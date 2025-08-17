package icu4cj.impl.duration


public class BasicPeriodFormatterFactory <: PeriodFormatterFactory {
    private let ds: PeriodFormatterDataService

    private var data: PeriodFormatterData

    private var customizations: BasicPeriodFormatterFactory_Customizations

    private var customizationsInUse: Bool = false

    private var localeName: String

    init(ds: PeriodFormatterDataService) {
        this.ds = ds
        this.customizations = BasicPeriodFormatterFactory_Customizations()
        this.localeName = toString(Locale.getDefault())
    }

    public static func getDefault(): BasicPeriodFormatterFactory {
        return BasicPeriodFormatterService.getInstance().newPeriodFormatterFactory()
    }

    public override func setLocale(localeName: String): PeriodFormatterFactory {
        data = None
        this.localeName = localeName
        return this
    }

    public override func setDisplayLimit(display: Bool): PeriodFormatterFactory {
        updateCustomizations().displayLimit = display
        return this
    }

    public func getDisplayLimit(): Bool {
        return customizations.displayLimit
    }

    public override func setDisplayPastFuture(display: Bool): PeriodFormatterFactory {
        updateCustomizations().displayDirection = display
        return this
    }

    public func getDisplayPastFuture(): Bool {
        return customizations.displayDirection
    }

    public override func setSeparatorVariant(variant: Int32): PeriodFormatterFactory {
        updateCustomizations().separatorVariant = UInt8(variant)
        return this
    }

    public func getSeparatorVariant(): Int32 {
        return Int32(customizations.separatorVariant)
    }

    public override func setUnitVariant(variant: Int32): PeriodFormatterFactory {
        updateCustomizations().unitVariant = UInt8(variant)
        return this
    }

    public func getUnitVariant(): Int32 {
        return Int32(customizations.unitVariant)
    }

    public override func setCountVariant(variant: Int32): PeriodFormatterFactory {
        updateCustomizations().countVariant = UInt8(variant)
        return this
    }

    public func getCountVariant(): Int32 {
        return Int32(customizations.countVariant)
    }

    public override func getFormatter(): PeriodFormatter {
        customizationsInUse = true
        return BasicPeriodFormatter(this, localeName, getData(), customizations)
    }

    private func updateCustomizations(): BasicPeriodFormatterFactory_Customizations {
        if (customizationsInUse) {
            customizations = customizations.copy()
            customizationsInUse = false
        }
        return customizations
    }

    public func getData(): PeriodFormatterData {
        if (data.isNone()) {
            data = ds.get(localeName)
        }
        return data
    }

    public func getData(locName: String): PeriodFormatterData {
        return ds.get(locName)
    }
}


class BasicPeriodFormatterFactory_Customizations {

    var displayLimit = true

    var displayDirection = true

    var separatorVariant = DataRecord_ESeparatorVariant.FULL

    var unitVariant = DataRecord_EUnitVariant.PLURALIZED

    var countVariant = DataRecord_ECountVariant.INTEGER

    public func copy(): BasicPeriodFormatterFactory_Customizations {
        let result = BasicPeriodFormatterFactory_Customizations()
        result.displayLimit = displayLimit
        result.displayDirection = displayDirection
        result.separatorVariant = separatorVariant
        result.unitVariant = unitVariant
        result.countVariant = countVariant
        return result
    }
}
