package icu4cj.impl.duration.impl


public class DataRecord {

    var pl: UInt8 = 0

    var pluralNames: Array<Array<String>>

    var genders: Array<UInt8>

    var singularNames: Array<String>

    var halfNames: Array<String>

    var numberNames: Array<String>

    var mediumNames: Array<String>

    var shortNames: Array<String>

    var measures: Array<String>

    var rqdSuffixes: Array<String>

    var optSuffixes: Array<String>

    var halves: Array<String>

    var halfPlacements: Array<UInt8>

    var halfSupport: Array<UInt8>

    var fifteenMinutes: String

    var fiveMinutes: String

    var requiresDigitSeparator: Bool = false

    var digitPrefix: String

    var countSep: String

    var shortUnitSep: String

    var unitSep: Array<String>

    var unitSepRequiresDP: Array<Bool>

    var requiresSkipMarker: Array<Bool>

    var numberSystem: UInt8 = 0

    var zero: Char = '\u{0000}'

    var decimalSep: Char = '\u{0000}'

    var omitSingularCount: Bool = false

    var omitDualCount: Bool = false

    var zeroHandling: UInt8 = 0

    var decimalHandling: UInt8 = 0

    var fractionHandling: UInt8 = 0

    var skippedUnitMarker: String

    var allowZero: Bool = false

    var weeksAloneOnly: Bool = false

    var useMilliseconds: UInt8 = 0

    var scopeData: Array<DataRecord_ScopeData>

    public static func read(ln: String, input: RecordReader): DataRecord {
        if (input.open("DataRecord")) {
            let record = DataRecord()
            record.pl = input.namedIndex("pl", DataRecord_EPluralization.names)
            record.pluralNames = input.stringTable("pluralName")
            record.genders = input.namedIndexArray("gender", DataRecord_EGender.names)
            record.singularNames = input.stringArray("singularName")
            record.halfNames = input.stringArray("halfName")
            record.numberNames = input.stringArray("numberName")
            record.mediumNames = input.stringArray("mediumName")
            record.shortNames = input.stringArray("shortName")
            record.measures = input.stringArray("measure")
            record.rqdSuffixes = input.stringArray("rqdSuffix")
            record.optSuffixes = input.stringArray("optSuffix")
            record.halves = input.stringArray("halves")
            record.halfPlacements = input.namedIndexArray("halfPlacement", DataRecord_EHalfPlacement.names)
            record.halfSupport = input.namedIndexArray("halfSupport", DataRecord_EHalfSupport.names)
            record.fifteenMinutes = input.string("fifteenMinutes")
            record.fiveMinutes = input.string("fiveMinutes")
            record.requiresDigitSeparator = input.bool("requiresDigitSeparator")
            record.digitPrefix = input.string("digitPrefix")
            record.countSep = input.string("countSep")
            record.shortUnitSep = input.string("shortUnitSep")
            record.unitSep = input.stringArray("unitSep")
            record.unitSepRequiresDP = input.boolArray("unitSepRequiresDP")
            record.requiresSkipMarker = input.boolArray("requiresSkipMarker")
            record.numberSystem = input.namedIndex("numberSystem", DataRecord_ENumberSystem.names)
            record.zero = input.character("zero")
            record.decimalSep = input.character("decimalSep")
            record.omitSingularCount = input.bool("omitSingularCount")
            record.omitDualCount = input.bool("omitDualCount")
            record.zeroHandling = input.namedIndex("zeroHandling", DataRecord_EZeroHandling.names)
            record.decimalHandling = input.namedIndex("decimalHandling", DataRecord_EDecimalHandling.names)
            record.fractionHandling = input.namedIndex("fractionHandling", DataRecord_EFractionHandling.names)
            record.skippedUnitMarker = input.string("skippedUnitMarker")
            record.allowZero = input.bool("allowZero")
            record.weeksAloneOnly = input.bool("weeksAloneOnly")
            record.useMilliseconds = input.namedIndex("useMilliseconds", DataRecord_EMilliSupport.names)
            if (input.open("ScopeDataList")) {
                let list = ArrayList<DataRecord_ScopeData>()
                var data: DataRecord_ScopeData
                while ((match (0) { case _ => data = DataRecord_ScopeData.read(input); data }).isSome()) {
                    list.append(data)
                }
                if (input.close()) {
                    record.scopeData = list.toArray(size))
                }
            }
            if (input.close()) {
                return record
            }
        } else {
            throw InternalError("did not find DataRecord while reading " + (ln))
        }
        throw InternalError("null data read while reading " + (ln))
    }

    public func write(out: RecordWriter): Unit {
        out.open("DataRecord")
        out.namedIndex("pl", DataRecord_EPluralization.names, Int32(pl))
        out.stringTable("pluralName", pluralNames)
        out.namedIndexArray("gender", DataRecord_EGender.names, genders)
        out.stringArray("singularName", singularNames)
        out.stringArray("halfName", halfNames)
        out.stringArray("numberName", numberNames)
        out.stringArray("mediumName", mediumNames)
        out.stringArray("shortName", shortNames)
        out.stringArray("measure", measures)
        out.stringArray("rqdSuffix", rqdSuffixes)
        out.stringArray("optSuffix", optSuffixes)
        out.stringArray("halves", halves)
        out.namedIndexArray("halfPlacement", DataRecord_EHalfPlacement.names, halfPlacements)
        out.namedIndexArray("halfSupport", DataRecord_EHalfSupport.names, halfSupport)
        out.string("fifteenMinutes", fifteenMinutes)
        out.string("fiveMinutes", fiveMinutes)
        out.bool("requiresDigitSeparator", requiresDigitSeparator)
        out.string("digitPrefix", digitPrefix)
        out.string("countSep", countSep)
        out.string("shortUnitSep", shortUnitSep)
        out.stringArray("unitSep", unitSep)
        out.boolArray("unitSepRequiresDP", unitSepRequiresDP)
        out.boolArray("requiresSkipMarker", requiresSkipMarker)
        out.namedIndex("numberSystem", DataRecord_ENumberSystem.names, Int32(numberSystem))
        out.character("zero", zero)
        out.character("decimalSep", decimalSep)
        out.bool("omitSingularCount", omitSingularCount)
        out.bool("omitDualCount", omitDualCount)
        out.namedIndex("zeroHandling", DataRecord_EZeroHandling.names, Int32(zeroHandling))
        out.namedIndex("decimalHandling", DataRecord_EDecimalHandling.names, Int32(decimalHandling))
        out.namedIndex("fractionHandling", DataRecord_EFractionHandling.names, Int32(fractionHandling))
        out.string("skippedUnitMarker", skippedUnitMarker)
        out.bool("allowZero", allowZero)
        out.bool("weeksAloneOnly", weeksAloneOnly)
        out.namedIndex("useMilliseconds", DataRecord_EMilliSupport.names, Int32(useMilliseconds))
        if (scopeData.isSome()) {
            out.open("ScopeDataList")
            var i = 0
            while (i < Int32(scopeData.size)) {
                scopeData[Int64(i)].write(out)
                i++
            }
            out.close()
        }
        out.close()
    }
}


public class DataRecord_ScopeData {

    var prefix: String

    var requiresDigitPrefix: Bool = false

    var suffix: String

    public func write(out: RecordWriter): Unit {
        out.open("ScopeData")
        out.string("prefix", prefix)
        out.bool("requiresDigitPrefix", requiresDigitPrefix)
        out.string("suffix", suffix)
        out.close()
    }

    public static func read(input: RecordReader): DataRecord_ScopeData {
        if (input.open("ScopeData")) {
            let scope = DataRecord_ScopeData()
            scope.prefix = input.string("prefix")
            scope.requiresDigitPrefix = input.bool("requiresDigitPrefix")
            scope.suffix = input.string("suffix")
            if (input.close()) {
                return scope
            }
        }
        return None
    }
}


public interface DataRecord_ETimeLimit {
    let NOLIMIT = 0u8

    let LT = 1u8

    let MT = 2u8

    let names: Array<String> = ["NOLIMIT", "LT", "MT"]
}

public interface DataRecord_ETimeDirection {
    let NODIRECTION = 0u8

    let PAST = 1u8

    let FUTURE = 2u8

    let names: Array<String> = ["NODIRECTION", "PAST", "FUTURE"]
}

public interface DataRecord_EUnitVariant {
    let PLURALIZED = 0u8

    let MEDIUM = 1u8

    let SHORT = 2u8

    let names: Array<String> = ["PLURALIZED", "MEDIUM", "SHORT"]
}

public interface DataRecord_ECountVariant {
    let INTEGER = 0u8

    let INTEGER_CUSTOM = 1u8

    let HALF_FRACTION = 2u8

    let DECIMAL1 = 3u8

    let DECIMAL2 = 4u8

    let DECIMAL3 = 5u8

    let names: Array<String> = ["INTEGER", "INTEGER_CUSTOM", "HALF_FRACTION", "DECIMAL1", "DECIMAL2", "DECIMAL3"]
}

public interface DataRecord_EPluralization {
    let NONE = 0u8

    let PLURAL = 1u8

    let DUAL = 2u8

    let PAUCAL = 3u8

    let HEBREW = 4u8

    let ARABIC = 5u8

    let names: Array<String> = ["NONE", "PLURAL", "DUAL", "PAUCAL", "HEBREW", "ARABIC"]
}

public interface DataRecord_EHalfPlacement {
    let PREFIX = 0u8

    let AFTER_FIRST = 1u8

    let LAST = 2u8

    let names: Array<String> = ["PREFIX", "AFTER_FIRST", "LAST"]
}

public interface DataRecord_ENumberSystem {
    let DEFAULT = 0u8

    let CHINESE_TRADITIONAL = 1u8

    let CHINESE_SIMPLIFIED = 2u8

    let KOREAN = 3u8

    let names: Array<String> = ["DEFAULT", "CHINESE_TRADITIONAL", "CHINESE_SIMPLIFIED", "KOREAN"]
}

public interface DataRecord_EZeroHandling {
    let ZPLURAL = 0u8

    let ZSINGULAR = 1u8

    let names: Array<String> = ["ZPLURAL", "ZSINGULAR"]
}

public interface DataRecord_EDecimalHandling {
    let DPLURAL = 0u8

    let DSINGULAR = 1u8

    let DSINGULAR_SUBONE = 2u8

    let DPAUCAL = 3u8

    let names: Array<String> = ["DPLURAL", "DSINGULAR", "DSINGULAR_SUBONE", "DPAUCAL"]
}

public interface DataRecord_EFractionHandling {
    let FPLURAL = 0u8

    let FSINGULAR_PLURAL = 1u8

    let FSINGULAR_PLURAL_ANDAHALF = 2u8

    let FPAUCAL = 3u8

    let names: Array<String> = ["FPLURAL", "FSINGULAR_PLURAL", "FSINGULAR_PLURAL_ANDAHALF", "FPAUCAL"]
}

public interface DataRecord_EHalfSupport {
    let YES = 0u8

    let NO = 1u8

    let ONE_PLUS = 2u8

    let names: Array<String> = ["YES", "NO", "ONE_PLUS"]
}

public interface DataRecord_EMilliSupport {
    let YES = 0u8

    let NO = 1u8

    let WITH_SECONDS = 2u8

    let names: Array<String> = ["YES", "NO", "WITH_SECONDS"]
}

public interface DataRecord_ESeparatorVariant {
    let NONE = 0u8

    let SHORT = 1u8

    let FULL = 2u8

    let names: Array<String> = ["NONE", "SHORT", "FULL"]
}

public interface DataRecord_EGender {
    let M = 0u8

    let F = 1u8

    let N = 2u8

    let names: Array<String> = ["M", "F", "N"]
}