package icu4cj.impl


public class ICUCurrencyMetaInfo <: CurrencyMetaInfo {
    private var regionInfo: ICUResourceBundle

    private var digitInfo: ICUResourceBundle

    public init() {
        super()
        let bundle = ICUResourceBundle.getBundleInstance(ICUData.ICU_CURR_BASE_NAME, "supplementalData", ICUResourceBundle.ICU_DATA_CLASS_LOADER)
        regionInfo = bundle.findTopLevel("CurrencyMap")
        digitInfo = bundle.findTopLevel("CurrencyMeta")
    }

    public override func currencyInfo(filter: CurrencyMetaInfo_CurrencyFilter): ArrayList<CurrencyMetaInfo_CurrencyInfo> {
        return collect(ICUCurrencyMetaInfo_InfoCollector() as ICUCurrencyMetaInfo_Collector<T>, filter)
    }

    public override func currencies(filter: CurrencyMetaInfo_CurrencyFilter): ArrayList<String> {
        return collect(ICUCurrencyMetaInfo_CurrencyCollector() as ICUCurrencyMetaInfo_Collector<T>, filter)
    }

    public override func regions(filter: CurrencyMetaInfo_CurrencyFilter): ArrayList<String> {
        return collect(ICUCurrencyMetaInfo_RegionCollector() as ICUCurrencyMetaInfo_Collector<T>, filter)
    }

    public override func currencyDigits(isoCode: String): CurrencyMetaInfo_CurrencyDigits {
        return currencyDigits(isoCode, Currency_CurrencyUsage.STANDARD)
    }

    public override func currencyDigits(isoCode: String, currencyPurpose: Currency_CurrencyUsage): CurrencyMetaInfo_CurrencyDigits {
        var b = digitInfo.findWithFallback(isoCode)
        if (b.isNone()) {
            b = digitInfo.findWithFallback("DEFAULT")
        }
        let data = b.getIntVector()
        if (refEq(currencyPurpose, Currency_CurrencyUsage.CASH)) {
            return CurrencyMetaInfo_CurrencyDigits(data[2], data[3])
        } else if (refEq(currencyPurpose, Currency_CurrencyUsage.STANDARD)) {
            return CurrencyMetaInfo_CurrencyDigits(data[0], data[1])
        } else {
            return CurrencyMetaInfo_CurrencyDigits(data[0], data[1])
        }
    }

    private func collect<T>(collector: ICUCurrencyMetaInfo_Collector<T>, filter: CurrencyMetaInfo_CurrencyFilter): ArrayList<T> {
        var tempfilter = filter
        if (tempfilter.isNone()) {
            tempfilter = CurrencyMetaInfo_CurrencyFilter.all()
        }
        var needed = collector.collects()
        if (tempfilter.region.isSome()) {
            needed |= Region
        }
        if (tempfilter.currency.isSome()) {
            needed |= Currency
        }
        if (tempfilter.comefrom != Int64.Min || tempfilter.to != Int64.Max) {
            needed |= Date
        }
        if (tempfilter.tenderOnly) {
            needed |= Tender
        }
        if (needed != 0) {
            if (tempfilter.region.isSome()) {
                let b = regionInfo.findWithFallback(tempfilter.region)
                if (b.isSome()) {
                    collectRegion(collector, tempfilter, needed, b)
                }
            } else {
                var i = 0
                while (i < regionInfo.getSize()) {
                    collectRegion(collector, tempfilter, needed, regionInfo.at(i))
                    i++
                }
            }
        }
        return collector.getList()
    }

    private func collectRegion<T>(collector: ICUCurrencyMetaInfo_Collector<T>, filter: CurrencyMetaInfo_CurrencyFilter, needed: Int32, b: ICUResourceBundle): Unit {
        let region = b.getKey()
        if (needed == Region) {
            collector.collect(b.getKey(), None, 0, 0, -1, false)
            return
        }
        var i = 0
        while (i < b.getSize()) {
            let r = b.at(i)
            if (r.getSize() == 0) {
                continue
            }
            var currency: String
            var comefrom = Int64.Min
            var to = Int64.Max
            var tender = true
            if ((needed & Currency) != 0) {
                let currBundle = r.at("id")
                currency = currBundle.getString()
                if (filter.currency.isSome() && !filter.currency.equals(currency)) {
                    continue
                }
            }
            if ((needed & Date) != 0) {
                comefrom = getDate(r.at("from"), Int64.Min, false)
                to = getDate(r.at("to"), Int64.Max, true)
                if (filter.comefrom > to) {
                    continue
                }
                if (filter.to < comefrom) {
                    continue
                }
            }
            if ((needed & Tender) != 0) {
                let tenderBundle = r.at("tender")
                tender = tenderBundle.isNone() || "true".equals(tenderBundle.getString())
                if (filter.tenderOnly && !tender) {
                    continue
                }
            }
            collector.collect(region, currency, comefrom, to, i, tender)
            i++
        }
    }

    private static let MASK = 4294967295

    private func getDate(b: ICUResourceBundle, defaultValue: Int64, endOfDay: Bool): Int64 {
        if (b.isNone()) {
            return defaultValue
        }
        let values = b.getIntVector()
        return (shl(Int64(values[0]), 32)) | ((Int64(values[1])) & MASK)
    }

    static let Region = 1

    static let Currency = 2

    private static let Date = 4

    private static let Tender = 8

    static let Everything = Int32.Max
}


class ICUCurrencyMetaInfo_UniqueList<T> {

    private var seen: Set<T> = HashSet<T>() as Set<T>

    private var list: ArrayList<T> = ArrayList<T>()

    static func create<T>(): ICUCurrencyMetaInfo_UniqueList<T> {
        return ICUCurrencyMetaInfo_UniqueList<T>()
    }

    public func add(value: T): Unit {
        if (!seen.contains(value)) {
            list.append(value)
            seen.put(value)
        }
    }

    public func listMethod(): ArrayList<T> {
        return Collections.unmodifiableList(list)
    }
}

class ICUCurrencyMetaInfo_InfoCollector <: ICUCurrencyMetaInfo_Collector<CurrencyMetaInfo_CurrencyInfo> {

    private var result: ArrayList<CurrencyMetaInfo_CurrencyInfo> = ArrayList<CurrencyMetaInfo_CurrencyInfo>()

    public override func collect(region: String, currency: String, comefrom: Int64, to: Int64, priority: Int32, tender: Bool): Unit {
        result.append(CurrencyMetaInfo_CurrencyInfo(region, currency, comefrom, to, priority, tender))
    }

    public override func getList(): ArrayList<CurrencyMetaInfo_CurrencyInfo> {
        return Collections.unmodifiableList(result)
    }

    public override func collects(): Int32 {
        return ICUCurrencyMetaInfo.Everything
    }
}


class ICUCurrencyMetaInfo_RegionCollector <: ICUCurrencyMetaInfo_Collector<String> {

    private let result = ICUCurrencyMetaInfo_UniqueList.create()

    public override func collect(region: String, currency: String, comefrom: Int64, to: Int64, priority: Int32, tender: Bool): Unit {
        result.add(region)
    }

    public override func collects(): Int32 {
        return ICUCurrencyMetaInfo.Region
    }

    public override func getList(): ArrayList<String> {
        return result.listMethod()
    }
}


class ICUCurrencyMetaInfo_CurrencyCollector <: ICUCurrencyMetaInfo_Collector<String> {

    private let result = ICUCurrencyMetaInfo_UniqueList.create()

    public override func collect(region: String, currency: String, comefrom: Int64, to: Int64, priority: Int32, tender: Bool): Unit {
        result.add(currency)
    }

    public override func collects(): Int32 {
        return ICUCurrencyMetaInfo.Currency
    }

    public override func getList(): ArrayList<String> {
        return result.listMethod()
    }
}


interface ICUCurrencyMetaInfo_Collector<T> {
    func collects(): Int32

    func collect(region: String, currency: String, comefrom: Int64, to: Int64, priority: Int32, tender: Bool): Unit

    func getList(): ArrayList<T>
}