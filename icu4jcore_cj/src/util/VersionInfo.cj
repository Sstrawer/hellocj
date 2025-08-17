package icu4cj.util


public class VersionInfo <: Comparable<VersionInfo> {
    public static let UNICODE_1_0: VersionInfo

    public static let UNICODE_1_0_1: VersionInfo

    public static let UNICODE_1_1_0: VersionInfo

    public static let UNICODE_1_1_5: VersionInfo

    public static let UNICODE_2_0: VersionInfo

    public static let UNICODE_2_1_2: VersionInfo

    public static let UNICODE_2_1_5: VersionInfo

    public static let UNICODE_2_1_8: VersionInfo

    public static let UNICODE_2_1_9: VersionInfo

    public static let UNICODE_3_0: VersionInfo

    public static let UNICODE_3_0_1: VersionInfo

    public static let UNICODE_3_1_0: VersionInfo

    public static let UNICODE_3_1_1: VersionInfo

    public static let UNICODE_3_2: VersionInfo

    public static let UNICODE_4_0: VersionInfo

    public static let UNICODE_4_0_1: VersionInfo

    public static let UNICODE_4_1: VersionInfo

    public static let UNICODE_5_0: VersionInfo

    public static let UNICODE_5_1: VersionInfo

    public static let UNICODE_5_2: VersionInfo

    public static let UNICODE_6_0: VersionInfo

    public static let UNICODE_6_1: VersionInfo

    public static let UNICODE_6_2: VersionInfo

    public static let UNICODE_6_3: VersionInfo

    public static let UNICODE_7_0: VersionInfo

    public static let UNICODE_8_0: VersionInfo

    public static let UNICODE_9_0: VersionInfo

    public static let UNICODE_10_0: VersionInfo

    public static let UNICODE_11_0: VersionInfo

    public static let UNICODE_12_0: VersionInfo

    public static let UNICODE_12_1: VersionInfo

    public static let UNICODE_13_0: VersionInfo

    public static let UNICODE_14_0: VersionInfo

    public static let UNICODE_15_0: VersionInfo

    public static let UNICODE_15_1: VersionInfo

    public static let ICU_VERSION: VersionInfo

    
    public static let ICU_DATA_VERSION_PATH = "75b"

    
    public static let ICU_DATA_VERSION: VersionInfo

    public static let UCOL_RUNTIME_VERSION: VersionInfo

    public static let UCOL_BUILDER_VERSION: VersionInfo

    
    public static let UCOL_TAILORINGS_VERSION: VersionInfo

    public static func getInstance(version: String): VersionInfo {
        let length = Int32(version.size)
        let array = [0, 0, 0, 0]
        var count = 0
        var index = 0
        while (count < 4 && index < length) {
            var c = Char(version[Int64(index)])
            if (c == '.') {
                count++
            } else {
                c -= '0'
                if (Int32(UInt32(c)) < 0 || Int32(UInt32(c)) > 9) {
                    throw IllegalArgumentException(INVALID_VERSION_NUMBER_)
                }
                array[Int64(count)] *= 10
                array[Int64(count)] += Int32(UInt32(c))
            }
            index++
        }
        if (index != length) {
            throw IllegalArgumentException("Invalid version number: String '" + (version) + "' exceeds version format")
        }
        var i = 0
        while (i < 4) {
            if (array[Int64(i)] < 0 || array[Int64(i)] > 255) {
                throw IllegalArgumentException(INVALID_VERSION_NUMBER_)
            }
            i++
        }
        return getInstance(array[0], array[1], array[2], array[3])
    }

    public static func getInstance(major: Int32, minor: Int32, milli: Int32, micro: Int32): VersionInfo {
        if (major < 0 || major > 255 || minor < 0 || minor > 255 || milli < 0 || milli > 255 || micro < 0 || micro > 255) {
            throw IllegalArgumentException(INVALID_VERSION_NUMBER_)
        }
        let version = getInt(major, minor, milli, micro)
        let key: Int32 = version
        var result = MAP_.get(key)
        if (result.isNone()) {
            result = VersionInfo(version)
            let tmpvi = MAP_.putIfAbsent(key, result)
            if (tmpvi.isSome()) {
                result = tmpvi
            }
        }
        return result
    }

    public static func getInstance(major: Int32, minor: Int32, milli: Int32): VersionInfo {
        return getInstance(major, minor, milli, 0)
    }

    public static func getInstance(major: Int32, minor: Int32): VersionInfo {
        return getInstance(major, minor, 0, 0)
    }

    public static func getInstance(major: Int32): VersionInfo {
        return getInstance(major, 0, 0, 0)
    }

    public override func toString(): String {
        let result = StringBuilder()
        result.append(getMajor())
        result.append('.')
        result.append(getMinor())
        result.append('.')
        result.append(getMilli())
        result.append('.')
        result.append(getMicro())
        return result.toString()
    }

    public func getMajor(): Int32 {
        return (shr(m_version_, 24)) & LAST_BYTE_MASK_
    }

    public func getMinor(): Int32 {
        return (shr(m_version_, 16)) & LAST_BYTE_MASK_
    }

    public func getMilli(): Int32 {
        return (shr(m_version_, 8)) & LAST_BYTE_MASK_
    }

    public func getMicro(): Int32 {
        return m_version_ & LAST_BYTE_MASK_
    }

    public override func equals(other: Object): Bool {
        return refEq(other, this)
    }

    public override func hashCode(): Int64 {
        return Int64(m_version_)
    }

    public override func compareTo(other: VersionInfo): Int32 {
        let diff = (ushr(m_version_, 1)) - (ushr(other.m_version_, 1))
        if (diff != 0) {
            return diff
        }
        return (m_version_ & 1) - (other.m_version_ & 1)
    }

    private static let UNICODE_VERSION: VersionInfo

    private var m_version_: Int32 = 0

    private static let MAP_ = ConcurrentHashMap()

    private static let LAST_BYTE_MASK_ = 255

    private static let INVALID_VERSION_NUMBER_ = "Invalid version number: Version number may be negative or greater than 255"


    private init(compactversion: Int32) {
        m_version_ = compactversion
    }

    private static func getInt(major: Int32, minor: Int32, milli: Int32, micro: Int32): Int32 {
        return (shl(major, 24)) | (shl(minor, 16)) | (shl(milli, 8)) | micro
    }

    public static func javaMain(args: Array<String>): Unit {
        let icuApiVer: String
        if (ICU_VERSION.getMajor() <= 4) {
            if (ICU_VERSION.getMinor() % 2 != 0) {
                var major = ICU_VERSION.getMajor()
                var minor = ICU_VERSION.getMinor() + 1
                if (minor >= 10) {
                    minor -= 10
                    major++
                }
                icuApiVer = "" + major.toString() + "." + minor.toString() + "M" + ICU_VERSION.getMilli().toString()
            } else {
                icuApiVer = ICU_VERSION.getVersionString(2, 2)
            }
        } else {
            if (ICU_VERSION.getMinor() == 0) {
                icuApiVer = "" + ICU_VERSION.getMajor().toString() + "M" + ICU_VERSION.getMilli().toString()
            } else {
                icuApiVer = ICU_VERSION.getVersionString(2, 2)
            }
        }
        println("International Components for Unicode for Java " + (icuApiVer))
        println("")
        println("Implementation Version: " + (ICU_VERSION.getVersionString(2, 4)))
        println("Unicode Data Version:   " + (UNICODE_VERSION.getVersionString(2, 4)))
        println("CLDR Data Version:      " + (LocaleData.getCLDRVersion().getVersionString(2, 4)))
        println("Time Zone Data Version: " + (getTZDataVersion()))
    }

    
    public func getVersionString(minDigits: Int32, maxDigits: Int32): String {
        if (minDigits < 1 || maxDigits < 1 || minDigits > 4 || maxDigits > 4 || minDigits > maxDigits) {
            throw IllegalArgumentException("Invalid min/maxDigits range")
        }
        let digits = Array<Int32>(4) { _ => 0 }
        digits[0] = getMajor()
        digits[1] = getMinor()
        digits[2] = getMilli()
        digits[3] = getMicro()
        var numDigits = maxDigits
        while (numDigits > minDigits) {
            if (digits[Int64(numDigits - 1)] != 0) {
                break
            }
            numDigits--
        }
        let verStr = StringBuilder()
        verStr.append(digits[0])
        var i = 1
        while (i < numDigits) {
            verStr.append(".")
            verStr.append(digits[Int64(i)])
            i++
        }
        return verStr.toString()
    }

     private static var TZDATA_VERSION: String

    static func getTZDataVersion(): String {
        if (TZDATA_VERSION.isNone()) {
            synchronized (getMonitorByObject(TypeInfo.of<VersionInfo>())) {
                if (TZDATA_VERSION.isNone()) {
                    let tzbundle = UResourceBundle.getBundleInstance("com/ibm/icu/impl/data/icudt" + VersionInfo.ICU_DATA_VERSION_PATH, "zoneinfo64")
                    TZDATA_VERSION = tzbundle.getString("TZVersion")
                }
            }
        }
        return TZDATA_VERSION
    }
}
