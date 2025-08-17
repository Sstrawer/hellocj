package icu4cj.text


public class StringPrep {
    public static let DEFAULT = 0

    public static let ALLOW_UNASSIGNED = 1

    public static let RFC3491_NAMEPREP = 0

    public static let RFC3530_NFS4_CS_PREP = 1

    public static let RFC3530_NFS4_CS_PREP_CI = 2

    public static let RFC3530_NFS4_CIS_PREP = 3

    public static let RFC3530_NFS4_MIXED_PREP_PREFIX = 4

    public static let RFC3530_NFS4_MIXED_PREP_SUFFIX = 5

    public static let RFC3722_ISCSI = 6

    public static let RFC3920_NODEPREP = 7

    public static let RFC3920_RESOURCEPREP = 8

    public static let RFC4011_MIB = 9

    public static let RFC4013_SASLPREP = 10

    public static let RFC4505_TRACE = 11

    public static let RFC4518_LDAP = 12

    public static let RFC4518_LDAP_CI = 13

    private static let MAX_PROFILE = RFC4518_LDAP_CI

    private static let PROFILE_NAMES: Array<String> = ["rfc3491", "rfc3530cs", "rfc3530csci", "rfc3491", "rfc3530mixp", "rfc3491", "rfc3722", "rfc3920node", "rfc3920res", "rfc4011", "rfc4013", "rfc4505", "rfc4518", "rfc4518ci"]

    private static let CACHE: Array<WeakReference> = Array<WeakReference>(Int64(MAX_PROFILE + 1))

    private static let UNASSIGNED = 0

    private static let MAP = 1

    private static let PROHIBITED = 2

    private static let DELETE = 3

    private static let TYPE_LIMIT = 4

    private static let NORMALIZATION_ON = 1

    private static let CHECK_BIDI_ON = 2

    private static let TYPE_THRESHOLD = 65520

    private static let MAX_INDEX_VALUE = 16319

    private static let INDEX_MAPPING_DATA_SIZE = 1

    private static let NORM_CORRECTNS_LAST_UNI_VERSION = 2

    private static let ONE_UCHAR_MAPPING_INDEX_START = 3

    private static let TWO_UCHARS_MAPPING_INDEX_START = 4

    private static let THREE_UCHARS_MAPPING_INDEX_START = 5

    private static let FOUR_UCHARS_MAPPING_INDEX_START = 6

    private static let OPTIONS = 7

    private static let INDEX_TOP = 16

    private var sprepTrie: CharTrie

    private var indexes: Array<Int32>

    private var mappingData: Array<Char>

    private var sprepUniVer: VersionInfo

    private var normCorrVer: VersionInfo

    private var doNFKC: Bool = false

    private var checkBiDi: Bool = false

    private var bdp: UBiDiProps

    private func getCodePointValue(ch: Int32): Char {
        return sprepTrie.getCodePointValue(ch)
    }

    private static func getVersionInfo(comp: Int32): VersionInfo {
        let micro = comp & 255
        let milli = (shr(comp, 8)) & 255
        let minor = (shr(comp, 16)) & 255
        let major = (shr(comp, 24)) & 255
        return VersionInfo.getInstance(major, minor, milli, micro)
    }

    private static func getVersionInfo(version: Array<UInt8>): VersionInfo {
        if (Int32(version.size) != 4) {
            return None
        }
        return VersionInfo.getInstance(Int32(version[0]), Int32(version[1]), Int32(version[2]), Int32(version[3]))
    }

    public init(inputStream: InputStream) {
        this(ICUBinary.getByteBufferFromInputStreamAndCloseStream(inputStream))
    }

    private init(bytes: ByteArrayStream) {
        let reader = StringPrepDataReader(bytes)
        indexes = reader.readIndexes(INDEX_TOP)
        sprepTrie = CharTrie(bytes, None)
        mappingData = reader.read(indexes[Int64(INDEX_MAPPING_DATA_SIZE)] / 2)
        doNFKC = ((indexes[Int64(OPTIONS)] & NORMALIZATION_ON) > 0)
        checkBiDi = ((indexes[Int64(OPTIONS)] & CHECK_BIDI_ON) > 0)
        sprepUniVer = getVersionInfo(reader.getUnicodeVersion())
        normCorrVer = getVersionInfo(indexes[Int64(NORM_CORRECTNS_LAST_UNI_VERSION)])
        let normUniVer = UCharacter.getUnicodeVersion()
        if (normUniVer.compareTo(sprepUniVer) < 0 && normUniVer.compareTo(normCorrVer) < 0 && ((indexes[Int64(OPTIONS)] & NORMALIZATION_ON) > 0)) {
            throw IOException("Normalization Correction version not supported")
        }
        if (checkBiDi) {
            bdp = UBiDiProps.INSTANCE
        }
    }

    public static func getInstance(profile: Int32): StringPrep {
        if (profile < 0 || profile > MAX_PROFILE) {
            throw IllegalArgumentException("Bad profile type")
        }
        var instance: StringPrep
        synchronized (getMonitorByObject(CACHE)) {
            let ref = CACHE[Int64(profile)]
            if (ref.isSome()) {
                instance = ref.get()
            }
            if (instance.isNone()) {
                let bytes = ICUBinary.getRequiredData((PROFILE_NAMES[Int64(profile)]) + ".spp")
                if (bytes.isSome()) {
                    try {
                        instance = StringPrep(bytes)
                    } catch (e: IOException) {
                        throw ICUUncheckedIOException(e)
                    }
                }
                if (instance.isSome()) {
                    CACHE[Int64(profile)] = WeakReference(instance)
                }
            }
        }
        return instance
    }

    private static func getValues(trieWord: Char, values: StringPrep_Values): Unit {
        values.reset()
        if (Int32(UInt32(trieWord)) == 0) {
            values.Type = TYPE_LIMIT
        } else if (Int32(UInt32(trieWord)) >= TYPE_THRESHOLD) {
            values.Type = (Int32(UInt32(trieWord)) - TYPE_THRESHOLD)
        } else {
            values.Type = MAP
            if ((Int32(UInt32(trieWord)) & 2) > 0) {
                values.isIndex = true
                values.value = shr(Int32(UInt32(trieWord)), 2)
            } else {
                values.isIndex = false
                values.value = shr((shl(Int32(UInt32(trieWord)), 16)), 16)
                values.value = (shr(values.value, 2))
            }
            if ((shr(Int32(UInt32(trieWord)), 2)) == MAX_INDEX_VALUE) {
                values.Type = DELETE
                values.isIndex = false
                values.value = 0
            }
        }
    }

    private func map(iter: UCharacterIterator, options: Int32): StringBuffer {
        let val = StringPrep_Values()
        var result = Char(0)
        var ch = UCharacterIterator.DONE
        let dest = StringBuffer()
        let allowUnassigned = ((options & ALLOW_UNASSIGNED) > 0)
        while ((match (0) { case _ => ch = iter.nextCodePoint(); ch }) != UCharacterIterator.DONE) {
            result = getCodePointValue(ch)
            getValues(result, val)
            if (val.Type == UNASSIGNED && allowUnassigned == false) {
                throw StringPrepParseException("An unassigned code point was found in the input", StringPrepParseException.UNASSIGNED_ERROR, iter.getText(), iter.getIndex())
            } else if (val.Type == MAP) {
                var index: Int32 = 0
                let length: Int32
                if (val.isIndex) {
                    index = val.value
                    if (index >= indexes[Int64(ONE_UCHAR_MAPPING_INDEX_START)] && index < indexes[Int64(TWO_UCHARS_MAPPING_INDEX_START)]) {
                        length = 1
                    } else if (index >= indexes[Int64(TWO_UCHARS_MAPPING_INDEX_START)] && index < indexes[Int64(THREE_UCHARS_MAPPING_INDEX_START)]) {
                        length = 2
                    } else if (index >= indexes[Int64(THREE_UCHARS_MAPPING_INDEX_START)] && index < indexes[Int64(FOUR_UCHARS_MAPPING_INDEX_START)]) {
                        length = 3
                    } else {
                        length = Int32(UInt32(mappingData[Int64(match (0) { case _ => index++; index - 1 })]))
                    }
                    dest.append(mappingData, index, length)
                    continue
                } else {
                    ch -= val.value
                }
            } else if (val.Type == DELETE) {
                continue
            }
            UTF16.append(dest, ch)
        }
        return dest
    }

    private func normalize(src: StringBuffer): StringBuffer {
        return StringBuffer(Normalizer.normalize(toString(src), Normalizer.NFKC, Normalizer.UNICODE_3_2))
    }

    public func prepare(src: UCharacterIterator, options: Int32): StringBuffer {
        let mapOut = map(src, options)
        var normOut = mapOut
        if (doNFKC) {
            normOut = normalize(mapOut)
        }
        var ch: Int32 = 0
        var result: Char = '\u{0000}'
        let iter = UCharacterIterator.getInstance(normOut)
        let val = StringPrep_Values()
        var direction = UCharacterDirection.CHAR_DIRECTION_COUNT
        var firstCharDir = UCharacterDirection.CHAR_DIRECTION_COUNT
        var rtlPos = -1
        var ltrPos = -1
        var rightToLeft = false
        var leftToRight = false
        while ((match (0) { case _ => ch = iter.nextCodePoint(); ch }) != UCharacterIterator.DONE) {
            result = getCodePointValue(ch)
            getValues(result, val)
            if (val.Type == PROHIBITED) {
                throw StringPrepParseException("A prohibited code point was found in the input", StringPrepParseException.PROHIBITED_ERROR, iter.getText(), val.value)
            }
            if (checkBiDi) {
                direction = bdp.getClass(ch)
                if (firstCharDir == UCharacterDirection.CHAR_DIRECTION_COUNT) {
                    firstCharDir = direction
                }
                if (direction == UCharacterDirection.LEFT_TO_RIGHT) {
                    leftToRight = true
                    ltrPos = iter.getIndex() - 1
                }
                if (direction == UCharacterDirection.RIGHT_TO_LEFT || direction == UCharacterDirection.RIGHT_TO_LEFT_ARABIC) {
                    rightToLeft = true
                    rtlPos = iter.getIndex() - 1
                }
            }
        }
        if (checkBiDi == true) {
            if (leftToRight == true && rightToLeft == true) {
                throw StringPrepParseException("The input does not conform to the rules for BiDi code points.", StringPrepParseException.CHECK_BIDI_ERROR, iter.getText(), if (rtlPos > ltrPos) { rtlPos } else { ltrPos })
            }
            if (rightToLeft == true && !((firstCharDir == UCharacterDirection.RIGHT_TO_LEFT || firstCharDir == UCharacterDirection.RIGHT_TO_LEFT_ARABIC) && (direction == UCharacterDirection.RIGHT_TO_LEFT || direction == UCharacterDirection.RIGHT_TO_LEFT_ARABIC))) {
                throw StringPrepParseException("The input does not conform to the rules for BiDi code points.", StringPrepParseException.CHECK_BIDI_ERROR, iter.getText(), if (rtlPos > ltrPos) { rtlPos } else { ltrPos })
            }
        }
        return normOut
    }

    public func prepare(src: String, options: Int32): String {
        let result = prepare(UCharacterIterator.getInstance(src), options)
        return toString(result)
    }
}


class StringPrep_Values {

    var isIndex: Bool = false

    var value: Int32 = 0

    var Type: Int32 = 0

    public func reset(): Unit {
        isIndex = false
        value = 0
        Type = -1
    }
}
