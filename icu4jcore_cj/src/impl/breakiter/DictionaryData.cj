package icu4cj.impl.breakiter


class DictionaryData {

    public static let TRIE_TYPE_BYTES = 0

    public static let TRIE_TYPE_UCHARS = 1

    public static let TRIE_TYPE_MASK = 7

    public static let TRIE_HAS_VALUES = 8

    public static let TRANSFORM_NONE = 0

    public static let TRANSFORM_TYPE_OFFSET = 16777216

    public static let TRANSFORM_TYPE_MASK = 2130706432

    public static let TRANSFORM_OFFSET_MASK = 2097151

    public static let IX_STRING_TRIE_OFFSET = 0

    public static let IX_RESERVED1_OFFSET = 1

    public static let IX_RESERVED2_OFFSET = 2

    public static let IX_TOTAL_SIZE = 3

    public static let IX_TRIE_TYPE = 4

    public static let IX_TRANSFORM = 5

    public static let IX_RESERVED6 = 6

    public static let IX_RESERVED7 = 7

    public static let IX_COUNT = 8

    private static let DATA_FORMAT_ID = 1147757428

    public static func loadDictionaryFor(dictType: String): DictionaryMatcher {
        let rb = UResourceBundle.getBundleInstance(ICUData.ICU_BRKITR_BASE_NAME)
        var dictFileName = rb.getStringWithFallback("dictionaries/" + (dictType))
        dictFileName = ICUData.ICU_BRKITR_NAME + '/'.toString() + (dictFileName)
        let bytes = ICUBinary.getRequiredData(dictFileName)
        ICUBinary.readHeader(bytes, DATA_FORMAT_ID, None)
        let indexes = Array<Int32>(Int64(IX_COUNT)) { _ => 0 }
        var i = 0
        while (i < IX_COUNT) {
            indexes[Int64(i)] = bytes.getInt()
            i++
        }
        let offset = indexes[Int64(IX_STRING_TRIE_OFFSET)]
        Assert.assrt(offset >= (4 * IX_COUNT))
        if (offset > (4 * IX_COUNT)) {
            let diff = offset - (4 * IX_COUNT)
            ICUBinary.skipBytes(bytes, diff)
        }
        let trieType = indexes[Int64(IX_TRIE_TYPE)] & TRIE_TYPE_MASK
        let totalSize = indexes[Int64(IX_TOTAL_SIZE)] - offset
        var m: DictionaryMatcher
        if (trieType == TRIE_TYPE_BYTES) {
            let transform = indexes[Int64(IX_TRANSFORM)]
            let data = Array<UInt8>(Int64(totalSize)) { _ => 0 }
            bytes.get(data)
            m = BytesDictionaryMatcher(data, transform)
        } else if (trieType == TRIE_TYPE_UCHARS) {
            Assert.assrt(totalSize % 2 == 0)
            let data = ICUBinary.getString(bytes, totalSize / 2, totalSize & 1)
            m = CharsDictionaryMatcher(data)
        } else {
            m = None
        }
        return m
    }
}
