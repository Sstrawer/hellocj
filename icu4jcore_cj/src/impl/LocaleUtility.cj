package icu4cj.impl

public class LocaleUtility {

    public static func getLocaleFromName(name: String): Locale {
        var language: String = ""
        var country: String = ""
        var variant: String = ""
        var i1 = indexOfWrap(name.indexOf(UInt8(UInt32('_'))))
        if (i1 < 0) {
            language = name
        } else {
            language = name[0..Int64(i1)]
            i1++
            let i2 = indexOfWrap(name.indexOf(UInt8(UInt32('_')), Int64(i1)))
            if (i2 < 0) {
                country = name[Int64(i1)..]
            } else {
                country = name[Int64(i1)..Int64(i2)]
                variant = name[Int64(i2 + 1)..]
            }
        }
        return Locale(language, country, variant)
    }

    public static func isFallbackOf(parent: String, child: String): Bool {
        if (!child.startsWith(parent)) {
            return false
        }
        let i = Int32(parent.size)
        return (i == Int32(child.size) || Char(child[Int64(i)]) == '_')
    }

    public static func isFallbackOf(parent: Locale, child: Locale): Bool {
        return isFallbackOf(toString(parent), toString(child))
    }

    public static func fallback(loc: Locale): Locale {
        let parts = [loc.getLanguage(), loc.getCountry(), loc.getVariant()]
        var i: Int32 = 0
        i = 2
        while (i >= 0) {
            if (Int32(parts[Int64(i)].size) != 0) {
                parts[Int64(i)] = ""
                break
            }
            i--
        }
        if (i < 0) {
            return None
        }
        return Locale(parts[0], parts[1], parts[2])
    }
}
