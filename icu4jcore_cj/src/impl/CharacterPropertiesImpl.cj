package icu4cj.impl

public class CharacterPropertiesImpl {
    private static let GeneratedStaticLockObject = Monitor()


    private static let NUM_INCLUSIONS = UCharacterProperty.SRC_COUNT + UProperty.INT_LIMIT - UProperty.INT_START

    private static let inclusions = Array<UnicodeSet>(Int64(NUM_INCLUSIONS))

    public static func clear(): Unit {
        synchronized (GeneratedStaticLockObject) {
            var i = 0
            while (i < Int32(inclusions.size)) {
                inclusions[Int64(i)] = None
                i++
            }
        }
    }

    private static func getInclusionsForSource(src: Int32): UnicodeSet {
        if (inclusions[Int64(src)].isNone()) {
            let incl = UnicodeSet()
            match (src) {
                case 1 => UCharacterProperty.INSTANCE.addPropertyStarts(incl)
                case 2 => UCharacterProperty.INSTANCE.upropsvec_addPropertyStarts(incl)
                case 6 =>
                    UCharacterProperty.INSTANCE.addPropertyStarts(incl)
                    UCharacterProperty.INSTANCE.upropsvec_addPropertyStarts(incl)
                case 7 =>
                    Norm2AllModes.getNFCInstance().impl.addPropertyStarts(incl)
                    UCaseProps.INSTANCE.addPropertyStarts(incl)
                case 8 => Norm2AllModes.getNFCInstance().impl.addPropertyStarts(incl)
                case 9 => Norm2AllModes.getNFKCInstance().impl.addPropertyStarts(incl)
                case 10 => Norm2AllModes.getNFKC_CFInstance().impl.addPropertyStarts(incl)
                case 11 => Norm2AllModes.getNFCInstance().impl.addCanonIterPropertyStarts(incl)
                case 4 => UCaseProps.INSTANCE.addPropertyStarts(incl)
                case 5 => UBiDiProps.INSTANCE.addPropertyStarts(incl)
                case 12 | 13 | 14 => UCharacterProperty.ulayout_addPropertyStarts(src, incl)
                case 15 =>
                    EmojiProps.INSTANCE.addPropertyStarts(incl)
                    break
                case 16 =>
                    incl.add(12286)
                    incl.add(12287 + 1)
                case 17 => UCharacterProperty.mathCompat_addPropertyStarts(incl)
                case _ => throw Exception("getInclusions(unknown src " + src.toString() + ")")
            }
            inclusions[Int64(src)] = incl.compact()
        }
        return inclusions[Int64(src)]
    }

    private static func getIntPropInclusions(property: Int32): UnicodeSet {
        if (!(UProperty.INT_START <= property && property < UProperty.INT_LIMIT)) {
            throw AssertionError()
        }
        let inclIndex = UCharacterProperty.SRC_COUNT + property - UProperty.INT_START
        if (inclusions[Int64(inclIndex)].isSome()) {
            return inclusions[Int64(inclIndex)]
        }
        let src = UCharacterProperty.INSTANCE.getSource(property)
        let incl = getInclusionsForSource(src)
        let intPropIncl = UnicodeSet(0, 0)
        let numRanges = incl.getRangeCount()
        var prevValue = 0
        var i = 0
        while (i < numRanges) {
            let rangeEnd = incl.getRangeEnd(i)
            var c = incl.getRangeStart(i)
            while (c <= rangeEnd) {
                let value = UCharacter.getIntPropertyValue(c, property)
                if (value != prevValue) {
                    intPropIncl.add(c)
                    prevValue = value
                }
                c++
            }
            i++
        }
        return match (0) { case _ => inclusions[Int64(inclIndex)] = intPropIncl.compact(); inclusions[Int64(inclIndex)] }
    }

    public static func getInclusionsForProperty(property: Int32): UnicodeSet {
        synchronized (GeneratedStaticLockObject) {
            if (UProperty.INT_START <= property && property < UProperty.INT_LIMIT) {
                return getIntPropInclusions(property)
            } else {
                let src = UCharacterProperty.INSTANCE.getSource(property)
                return getInclusionsForSource(src)
            }
        }
    }
}
