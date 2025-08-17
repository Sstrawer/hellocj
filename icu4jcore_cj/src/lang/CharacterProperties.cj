package icu4cj.lang


public class CharacterProperties {

    private static let sets = Array<UnicodeSet>(Int64(UProperty.BINARY_LIMIT))

    private static let maps = Array<CodePointMap>(Int64(UProperty.INT_LIMIT - UProperty.INT_START))

    private static func makeSet(property: Int32): UnicodeSet {
        let set = UnicodeSet()
        if (UProperty.BASIC_EMOJI <= property && property <= UProperty.RGI_EMOJI) {
            EmojiProps.INSTANCE.addStrings(property, set)
            if (property != UProperty.BASIC_EMOJI && property != UProperty.RGI_EMOJI) {
                return set.freeze()
            }
        }
        let inclusions = CharacterPropertiesImpl.getInclusionsForProperty(property)
        let numRanges = inclusions.getRangeCount()
        var startHasProperty = -1
        var i = 0
        while (i < numRanges) {
            let rangeEnd = inclusions.getRangeEnd(i)
            var c = inclusions.getRangeStart(i)
            while (c <= rangeEnd) {
                if (UCharacter.hasBinaryProperty(c, property)) {
                    if (startHasProperty < 0) {
                        startHasProperty = c
                    }
                } else if (startHasProperty >= 0) {
                    set.add(startHasProperty, c - 1)
                    startHasProperty = -1
                }
                c++
            }
            i++
        }
        if (startHasProperty >= 0) {
            set.add(startHasProperty, 1114111)
        }
        return set.freeze()
    }

    private static func makeMap(property: Int32): CodePointMap {
        let nullValue = if (property == UProperty.SCRIPT) { UScript.UNKNOWN } else { 0 }
        let mutableTrie = MutableCodePointTrie(nullValue, nullValue)
        let inclusions = CharacterPropertiesImpl.getInclusionsForProperty(property)
        let numRanges = inclusions.getRangeCount()
        var start = 0
        var value = nullValue
        var i = 0
        while (i < numRanges) {
            let rangeEnd = inclusions.getRangeEnd(i)
            var c = inclusions.getRangeStart(i)
            while (c <= rangeEnd) {
                let nextValue = UCharacter.getIntPropertyValue(c, property)
                if (value != nextValue) {
                    if (value != nullValue) {
                        mutableTrie.setRange(start, c - 1, value)
                    }
                    start = c
                    value = nextValue
                }
                c++
            }
            i++
        }
        if (value != 0) {
            mutableTrie.setRange(start, 1114111, value)
        }
        let Type: CodePointTrie_Type
        if (property == UProperty.BIDI_CLASS || property == UProperty.GENERAL_CATEGORY) {
            Type = CodePointTrie_Type.FAST
        } else {
            Type = CodePointTrie_Type.SMALL
        }
        let valueWidth: CodePointTrie_ValueWidth
        let max = UCharacter.getIntPropertyMaxValue(property)
        if (max <= 255) {
            valueWidth = CodePointTrie_ValueWidth.BITS_8
        } else if (max <= 65535) {
            valueWidth = CodePointTrie_ValueWidth.BITS_16
        } else {
            valueWidth = CodePointTrie_ValueWidth.BITS_32
        }
        return mutableTrie.buildImmutable(Type, valueWidth)
    }

    public static func getBinaryPropertySet(property: Int32): UnicodeSet {
        if (property < 0 || UProperty.BINARY_LIMIT <= property) {
            throw IllegalArgumentException("" + property.toString() + " is not a constant for a UProperty binary property")
        }
        synchronized (getMonitorByObject(sets)) {
            var set = sets[Int64(property)]
            if (set.isNone()) {
                sets[Int64(property)] = match (0) { case _ => set = makeSet(property); set }
            }
            return set
        }
    }

    public static func getIntPropertyMap(property: Int32): CodePointMap {
        if (property < UProperty.INT_START || UProperty.INT_LIMIT <= property) {
            throw IllegalArgumentException("" + property.toString() + " is not a constant for a UProperty int property")
        }
        synchronized (getMonitorByObject(maps)) {
            var map = maps[Int64(property - UProperty.INT_START)]
            if (map.isNone()) {
                maps[Int64(property - UProperty.INT_START)] = match (0) { case _ => map = makeMap(property); map }
            }
            return map
        }
    }
}
