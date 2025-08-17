package icu4cj.text


public class CurrencyMetaInfo {
    private static let impl: CurrencyMetaInfo

    private static let hasData: Bool

    public static func getInstance(): CurrencyMetaInfo {
        return impl
    }

    public static func getInstance(noSubstitute: Bool): CurrencyMetaInfo {
        return if (hasData) { impl } else { None }
    }

    
    public static func hasDataStatic(): Bool {
        return hasData
    }

    

    public func currencyInfo(filter: CurrencyMetaInfo_CurrencyFilter): ArrayList<CurrencyMetaInfo_CurrencyInfo> {
        return Array<String>(0, { _ => "" })
    }

    public func currencies(filter: CurrencyMetaInfo_CurrencyFilter): ArrayList<String> {
        return Array<String>(0, { _ => "" })
    }

    public func regions(filter: CurrencyMetaInfo_CurrencyFilter): ArrayList<String> {
        return Array<String>(0, { _ => "" })
    }

    public func currencyDigits(isoCode: String): CurrencyMetaInfo_CurrencyDigits {
        return currencyDigits(isoCode, Currency_CurrencyUsage.STANDARD)
    }

    public func currencyDigits(isoCode: String, currencyUsage: Currency_CurrencyUsage): CurrencyMetaInfo_CurrencyDigits {
        return defaultDigits
    }

    
    protected static let defaultDigits = CurrencyMetaInfo_CurrencyDigits(2, 0)


    private static func dateString(date: Int64): String {
        if (date == Int64.Max || date == Int64.Min) {
            return None
        }
        return Grego.timeToString(date)
    }

    static func debugString(o: Object): String {
        let sb = StringBuilder()
        try {
            for (f in TypeInfo.of(o).getFields()) {
                let v = f.get(o)
                if (v.isSome()) {
                    let s: String
                    if (checkOptionalIs<Date, Object>(v)) {
                        s = dateString(v.getTime())
                    } else if (v) {
                        s = dateString(v)
                    } else {
                        s = String.valueOf(v)
                    }
                    if (s.isNone()) {
                        continue
                    }
                    if (Int32(sb.size) > 0) {
                        sb.append(",")
                    }
                    sb.append(f.getName()).append("='").append(s).append("'")
                }
            }
        } catch (t: Exception) { }
        sb.insert(0, (TypeInfo.of(o).getSimpleName()) + "(")
        sb.append(")")
        return sb.toString()
    }
}


public class CurrencyMetaInfo_CurrencyFilter {
    public let region: String

    public let currency: String

    public let comefrom: Int64

    public let to: Int64

    
    public let tenderOnly: Bool

    private init(region: String, currency: String, comefrom: Int64, to: Int64, tenderOnly: Bool) {
        this.region = region
        this.currency = currency
        this.comefrom = comefrom
        this.to = to
        this.tenderOnly = tenderOnly
    }

    private static let ALL = CurrencyMetaInfo_CurrencyFilter(None, None, Int64.Min, Int64.Max, false)

    public static func all(): CurrencyMetaInfo_CurrencyFilter {
        return ALL
    }

    public static func now(): CurrencyMetaInfo_CurrencyFilter {
        return ALL.withDate(Date())
    }

    public static func onRegion(region: String): CurrencyMetaInfo_CurrencyFilter {
        return ALL.withRegion(region)
    }

    public static func onCurrency(currency: String): CurrencyMetaInfo_CurrencyFilter {
        return ALL.withCurrency(currency)
    }

    public static func onDate(date: DateTime): CurrencyMetaInfo_CurrencyFilter {
        return ALL.withDate(date)
    }

    public static func onDateRange(comefrom: DateTime, to: DateTime): CurrencyMetaInfo_CurrencyFilter {
        return ALL.withDateRange(comefrom, to)
    }

    public static func onDate(date: Int64): CurrencyMetaInfo_CurrencyFilter {
        return ALL.withDate(date)
    }

    public static func onDateRange(comefrom: Int64, to: Int64): CurrencyMetaInfo_CurrencyFilter {
        return ALL.withDateRange(comefrom, to)
    }

    public static func onTender(): CurrencyMetaInfo_CurrencyFilter {
        return ALL.withTender()
    }

    public func withRegion(region: String): CurrencyMetaInfo_CurrencyFilter {
        return CurrencyMetaInfo_CurrencyFilter(region, this.currency, this.comefrom, this.to, this.tenderOnly)
    }

    public func withCurrency(currency: String): CurrencyMetaInfo_CurrencyFilter {
        return CurrencyMetaInfo_CurrencyFilter(this.region, currency, this.comefrom, this.to, this.tenderOnly)
    }

    public func withDate(date: DateTime): CurrencyMetaInfo_CurrencyFilter {
        return CurrencyMetaInfo_CurrencyFilter(this.region, this.currency, date.getTime(), date.getTime(), this.tenderOnly)
    }

    public func withDateRange(comefrom: DateTime, to: DateTime): CurrencyMetaInfo_CurrencyFilter {
        let fromLong = if (comefrom.isNone()) { Int64.Min } else { comefrom.getTime() }
        let toLong = if (to.isNone()) { Int64.Max } else { to.getTime() }
        return CurrencyMetaInfo_CurrencyFilter(this.region, this.currency, fromLong, toLong, this.tenderOnly)
    }

    public func withDate(date: Int64): CurrencyMetaInfo_CurrencyFilter {
        return CurrencyMetaInfo_CurrencyFilter(this.region, this.currency, date, date, this.tenderOnly)
    }

    public func withDateRange(comefrom: Int64, to: Int64): CurrencyMetaInfo_CurrencyFilter {
        return CurrencyMetaInfo_CurrencyFilter(this.region, this.currency, comefrom, to, this.tenderOnly)
    }

    public func withTender(): CurrencyMetaInfo_CurrencyFilter {
        return CurrencyMetaInfo_CurrencyFilter(this.region, this.currency, this.comefrom, this.to, true)
    }

    public override func equals(rhs: Object): Bool {
        return checkOptionalIs<CurrencyMetaInfo_CurrencyFilter, Object>(rhs) && equals(rhs)
    }

    public func equals(rhs: CurrencyMetaInfo_CurrencyFilter): Bool {
        return Utility.sameObjects(this, rhs) || (rhs.isSome() && equalsStatic(this.region, rhs.region) && equalsStatic(this.currency, rhs.currency) && this.comefrom == rhs.comefrom && this.to == rhs.to && this.tenderOnly == rhs.tenderOnly)
    }

    public override func hashCode(): Int64 {
        var hc = 0
        if (region.isSome()) {
            hc = Int32(region.hashCode())
        }
        if (currency.isSome()) {
            hc = hc * 31 + Int32(currency.hashCode())
        }
        hc = hc * 31 + Int32(comefrom)
        hc = hc * 31 + Int32(ushr(comefrom, 32))
        hc = hc * 31 + Int32(to)
        hc = hc * 31 + Int32(ushr(to, 32))
        hc = hc * 31 + (if (tenderOnly) { 1 } else { 0 })
        return Int64(hc)
    }

    public override func toString(): String {
        return CurrencyMetaInfo.debugString(this)
    }

    private static func equalsStatic(lhs: String, rhs: String): Bool {
        return (Utility.sameObjects(lhs, rhs) || (lhs.isSome() && lhs.equals(rhs)))
    }
}


public class CurrencyMetaInfo_CurrencyDigits {
    public let fractionDigits: Int32

    public let roundingIncrement: Int32

    public init(fractionDigits: Int32, roundingIncrement: Int32) {
        this.fractionDigits = fractionDigits
        this.roundingIncrement = roundingIncrement
    }

    public override func toString(): String {
        return CurrencyMetaInfo.debugString(this)
    }
}


public class CurrencyMetaInfo_CurrencyInfo {
    public let region: String

    public let code: String

    public let comefrom: Int64

    public let to: Int64

    public let priority: Int32

    private let tender: Bool

    
    public init(region: String, code: String, comefrom: Int64, to: Int64, priority: Int32) {
        this(region, code, comefrom, to, priority, true)
    }

    
    public init(region: String, code: String, comefrom: Int64, to: Int64, priority: Int32, tender: Bool) {
        this.region = region
        this.code = code
        this.comefrom = comefrom
        this.to = to
        this.priority = priority
        this.tender = tender
    }

    public override func toString(): String {
        return CurrencyMetaInfo.debugString(this)
    }

    public func isTender(): Bool {
        return tender
    }
}
