package icu4cj.text


public class AlphabeticIndex<V> {
    private static let BASE = "\u{fdd0}"

    private static let CGJ = '\u{034f}'

    private static let binaryCmp = UTF16_StringComparator(true, false, 0)

    let collatorOriginal: RuleBasedCollator

    private let collatorPrimaryOnly: RuleBasedCollator

    private var collatorExternal: RuleBasedCollator

    private let recordComparator = AlphabeticIndex_1(this)

    private let firstCharsInScripts: ArrayList<String>

    private let initialLabels = UnicodeSet()

    private var inputList: ArrayList<AlphabeticIndex_Record<V>>

    private var buckets: AlphabeticIndex_BucketList<V>

    private var overflowLabel: String = "\u{2026}"

    private var underflowLabel: String = "\u{2026}"

    private var inflowLabel: String = "\u{2026}"

    public init(locale: ULocale) {
        this(locale, None)
    }

    public init(locale: Locale) {
        this(ULocale.forLocale(locale), None)
    }

    public init(collator: RuleBasedCollator) {
        this(None, collator)
    }

    private init(locale: ULocale, collator: RuleBasedCollator) {
        collatorOriginal = if (collator.isSome()) { collator } else { Collator.getInstance(locale) }
        try {
            collatorPrimaryOnly = collatorOriginal.cloneAsThawed()
        } catch (e: Exception) {
            throw Exception("Collator cannot be cloned")
        }
        collatorPrimaryOnly.setStrength(Collator.PRIMARY)
        collatorPrimaryOnly.freeze()
        firstCharsInScripts = getFirstCharactersInScripts()
        Collections.sort(firstCharsInScripts, collatorPrimaryOnly)
        while (true) {
            if (firstCharsInScripts.isEmpty()) {
                throw IllegalArgumentException("AlphabeticIndex requires some non-ignorable script boundary strings")
            }
            if (collatorPrimaryOnly.compare(firstCharsInScripts[0], "") == 0) {
                firstCharsInScripts.remove(0)
            } else {
                break
            }
        }
        if (!addChineseIndexCharacters() && locale.isSome()) {
            addIndexExemplars(locale)
        }
    }

    public func addLabels(additions: UnicodeSet): AlphabeticIndex<V> {
        initialLabels.addAll(additions)
        buckets = None
        return this
    }

    public func addLabels(additions: Array<ULocale>): AlphabeticIndex<V> {
        for (addition in additions) {
            addIndexExemplars(addition)
        }
        buckets = None
        return this
    }

    public func addLabels(additions: Array<Locale>): AlphabeticIndex<V> {
        for (addition in additions) {
            addIndexExemplars(ULocale.forLocale(addition))
        }
        buckets = None
        return this
    }

    public func setOverflowLabel(overflowLabel: String): AlphabeticIndex<V> {
        this.overflowLabel = overflowLabel
        buckets = None
        return this
    }

    public func getUnderflowLabel(): String {
        return underflowLabel
    }

    public func setUnderflowLabel(underflowLabel: String): AlphabeticIndex<V> {
        this.underflowLabel = underflowLabel
        buckets = None
        return this
    }

    public func getOverflowLabel(): String {
        return overflowLabel
    }

    public func setInflowLabel(inflowLabel: String): AlphabeticIndex<V> {
        this.inflowLabel = inflowLabel
        buckets = None
        return this
    }

    public func getInflowLabel(): String {
        return inflowLabel
    }

    public func getMaxLabelCount(): Int32 {
        return maxLabelCount
    }

    public func setMaxLabelCount(maxLabelCount: Int32): AlphabeticIndex<V> {
        this.maxLabelCount = maxLabelCount
        buckets = None
        return this
    }

    private func initLabels(): ArrayList<String> {
        let nfkdNormalizer = Normalizer2.getNFKDInstance()
        let indexCharacters = ArrayList<String>()
        let firstScriptBoundary = firstCharsInScripts[0]
        let overflowBoundary = firstCharsInScripts[Int64(Int32(firstCharsInScripts.size) - 1)]
        for (item in initialLabels) {
            let checkDistinct: Bool
            if (!UTF16.hasMoreCodePointsThan(item, 1)) {
                checkDistinct = false
            } else if (Char(item[Int64(Int32(item.size) - 1)]) == '*' && Char(item[Int64(Int32(item.size) - 2)]) != '*') {
                item = item[0..Int64(Int32(item.size) - 1)]
                checkDistinct = false
            } else {
                checkDistinct = true
            }
            if (collatorPrimaryOnly.compare(item, firstScriptBoundary) < 0) { } else if (collatorPrimaryOnly.compare(item, overflowBoundary) >= 0) { } else if (checkDistinct && collatorPrimaryOnly.compare(item, separated(item)) == 0) { } else {
                let insertionPoint = Collections.binarySearch(indexCharacters, item, collatorPrimaryOnly)
                if (insertionPoint < 0) {
                    indexCharacters.add(, item)
                } else {
                    let itemAlreadyIn = indexCharacters[Int64(insertionPoint)]
                    if (isOneLabelBetterThanOther(nfkdNormalizer, item, itemAlreadyIn)) {
                        indexCharacters.set(Int64(insertionPoint), item)
                    }
                }
            }
        }
        let size = Int32(indexCharacters.size) - 1
        if (size > maxLabelCount) {
            var count = 0
            var old = -1
            let it: Iterator<String> = indexCharacters.iterator()
            while (it.hasNext()) {
                count++
                it.next()
                let bump = count * maxLabelCount / size
                if (bump == old) {
                    it.remove()
                } else {
                    old = bump
                }
            }
        }
        return indexCharacters
    }

    private static func fixLabel(current: String): String {
        if (!current.startsWith(BASE)) {
            return current
        }
        let rest = Int32(UInt32(Char(current[BASE.size])))
        if (10240 < rest && rest <= 10495) {
            return ((rest - 10240).toString()) + "\u{5283}"
        }
        return current[BASE.size..]
    }

    private func addIndexExemplars(locale: ULocale): Unit {
        var exemplars = LocaleData.getExemplarSetStatic(locale, 0, LocaleData.ES_INDEX)
        if (exemplars.isSome() && !exemplars.isEmpty()) {
            initialLabels.addAll(exemplars)
            return
        }
        exemplars = LocaleData.getExemplarSetStatic(locale, 0, LocaleData.ES_STANDARD)
        exemplars = exemplars.cloneAsThawed()
        if (exemplars.containsSome(Int32(UInt32('a')), Int32(UInt32('z'))) || exemplars.isEmpty()) {
            exemplars.addAll(Int32(UInt32('a')), Int32(UInt32('z')))
        }
        if (exemplars.containsSome(44032, 55203)) {
            exemplars.remove(44032, 55203).add(44032).add(45208).add(45796).add(46972).add(47560).add(48148).add(49324).add(50500).add(51088).add(52264).add(52852).add(53440).add(54028).add(54616)
        }
        if (exemplars.containsSome(4608, 4991)) {
            let ethiopic = UnicodeSet("[\u{1200}\u{1208}\u{1210}\u{1218}\u{1220}\u{1228}\u{1230}\u{1238}\u{1240}\u{1248}\u{1250}\u{1258}\u{1260}\u{1268}\u{1270}\u{1278}\u{1280}\u{1288}\u{1290}\u{1298}\u{12a0}\u{12a8}\u{12b0}\u{12b8}\u{12c0}\u{12c8}\u{12d0}\u{12d8}\u{12e0}\u{12e8}\u{12f0}\u{12f8}\u{1300}\u{1308}\u{1310}\u{1318}\u{1320}\u{1328}\u{1330}\u{1338}\u{1340}\u{1348}\u{1350}\u{1358}]")
            ethiopic.retainAll(exemplars)
            exemplars.remove(Int32(UInt32('\u{1200}')), 4991).addAll(ethiopic)
        }
        for (item in exemplars) {
            initialLabels.add(UCharacter.toUpperCase(locale, item))
        }
    }

    private func addChineseIndexCharacters(): Bool {
        let contractions = UnicodeSet()
        try {
            collatorPrimaryOnly.internalAddContractions(Int32(UInt32(Char(BASE[0]))), contractions)
        } catch (e: Exception) {
            return false
        }
        if (contractions.isEmpty()) {
            return false
        }
        initialLabels.addAll(contractions)
        for (s in contractions) {
            if (!(s.startsWith(BASE))) {
                throw AssertionError()
            }
            let c = Char(s[Int64(Int32(s.size) - 1)])
            if (65 <= Int32(UInt32(c)) && Int32(UInt32(c)) <= 90) {
                initialLabels.add(65, 90)
                break
            }
        }
        return true
    }

    private func separated(item: String): String {
        let result = StringBuilder()
        var last = Char(item[0])
        result.append(last)
        var i = 1
        while (i < Int32(item.size)) {
            let ch = Char(item[Int64(i)])
            if (!UCharacter.isHighSurrogate(Int32(UInt32(last))) || !UCharacter.isLowSurrogate(Int32(UInt32(ch)))) {
                result.append(CGJ)
            }
            result.append(ch)
            last = ch
            i++
        }
        return result.toString()
    }

    public func buildImmutableIndex(): AlphabeticIndex_ImmutableIndex<V> {
        let immutableBucketList: AlphabeticIndex_BucketList<V>
        if (inputList.isSome() && !inputList.isEmpty()) {
            immutableBucketList = createBucketList()
        } else {
            if (buckets.isNone()) {
                buckets = createBucketList()
            }
            immutableBucketList = buckets
        }
        return AlphabeticIndex_ImmutableIndex<V>(immutableBucketList, collatorPrimaryOnly)
    }

    public func getBucketLabels(): ArrayList<String> {
        initBuckets()
        let result = ArrayList<String>()
        for (bucket in buckets) {
            result.append(bucket.getLabel())
        }
        return result
    }

    public func getCollator(): RuleBasedCollator {
        if (collatorExternal.isNone()) {
            try {
                collatorExternal = collatorOriginal.clone()
            } catch (e: Exception) {
                throw Exception("Collator cannot be cloned")
            }
        }
        return collatorExternal
    }

    public func addRecord(name: String, data: V): AlphabeticIndex<V> {
        buckets = None
        if (inputList.isNone()) {
            inputList = ArrayList<AlphabeticIndex_Record<V>>()
        }
        inputList.append(AlphabeticIndex_Record<V>(name, data))
        return this
    }

    public func getBucketIndex(name: String): Int32 {
        initBuckets()
        return buckets.getBucketIndex(name, collatorPrimaryOnly)
    }

    public func clearRecords(): AlphabeticIndex<V> {
        if (inputList.isSome() && !inputList.isEmpty()) {
            inputList.clear()
            buckets = None
        }
        return this
    }

    public func getBucketCount(): Int32 {
        initBuckets()
        return buckets.getBucketCount()
    }

    public func getRecordCount(): Int32 {
        return if (inputList.isSome()) { Int32(inputList.size) } else { 0 }
    }

    public override func iterator(): Iterator<AlphabeticIndex_Bucket<V>> {
        initBuckets()
        return buckets.iterator()
    }

    private func initBuckets(): Unit {
        if (buckets.isSome()) {
            return
        }
        buckets = createBucketList()
        if (inputList.isNone() || inputList.isEmpty()) {
            return
        }
        Collections.sort(inputList, recordComparator as Comparator)
        let bucketIterator = buckets.fullIterator()
        var currentBucket = bucketIterator.next()
        var nextBucket: AlphabeticIndex_Bucket<V>
        var upperBoundary: String
        if (bucketIterator.hasNext()) {
            nextBucket = bucketIterator.next()
            upperBoundary = nextBucket.lowerBoundary
        } else {
            nextBucket = None
            upperBoundary = None
        }
        for (r in inputList) {
            while (upperBoundary.isSome() && collatorPrimaryOnly.compare(r.name, upperBoundary) >= 0) {
                currentBucket = nextBucket
                if (bucketIterator.hasNext()) {
                    nextBucket = bucketIterator.next()
                    upperBoundary = nextBucket.lowerBoundary
                } else {
                    upperBoundary = None
                }
            }
            var bucket = currentBucket
            if (bucket.displayBucket.isSome()) {
                bucket = bucket.displayBucket
            }
            if (bucket.records.isNone()) {
                bucket.records = ArrayList<AlphabeticIndex_Record<V>>()
            }
            bucket.records.append(r)
        }
    }

    private var maxLabelCount = 99

    private static func isOneLabelBetterThanOther(nfkdNormalizer: Normalizer2, one: String, other: String): Bool {
        let n1 = nfkdNormalizer.normalize(one)
        let n2 = nfkdNormalizer.normalize(other)
        var result = n1.codePointCount(0, Int32(n1.size)) - n2.codePointCount(0, Int32(n2.size))
        if (result != 0) {
            return result < 0
        }
        result = binaryCmp.compare(n1, n2)
        if (result != 0) {
            return result < 0
        }
        return binaryCmp.compare(one, other) < 0
    }

    private func createBucketList(): AlphabeticIndex_BucketList<V> {
        let indexCharacters = initLabels()
        let variableTop: Int64
        if (collatorPrimaryOnly.isAlternateHandlingShifted()) {
            variableTop = Int64(collatorPrimaryOnly.getVariableTop()) & 4294967295
        } else {
            variableTop = 0
        }
        var hasInvisibleBuckets = false
        let asciiBuckets = Array<AlphabeticIndex_Bucket<Any>>(26)
        let pinyinBuckets = Array<AlphabeticIndex_Bucket<Any>>(26)
        var hasPinyin = false
        let bucketList = ArrayList<AlphabeticIndex_Bucket<V>>()
        bucketList.append(AlphabeticIndex_Bucket<V>(getUnderflowLabel(), "", AlphabeticIndex_Bucket_LabelType.UNDERFLOW))
        var scriptIndex = -1
        var scriptUpperBoundary: String = ""
        for (current in indexCharacters) {
            if (collatorPrimaryOnly.compare(current, scriptUpperBoundary) >= 0) {
                let inflowBoundary = scriptUpperBoundary
                var skippedScript = false
                while (true) {
                    scriptUpperBoundary = firstCharsInScripts[Int64(match (0) { case _ => scriptIndex++; scriptIndex })]
                    if (collatorPrimaryOnly.compare(current, scriptUpperBoundary) < 0) {
                        break
                    }
                    skippedScript = true
                }
                if (skippedScript && Int32(bucketList.size) > 1) {
                    bucketList.append(AlphabeticIndex_Bucket<V>(getInflowLabel(), inflowBoundary, AlphabeticIndex_Bucket_LabelType.INFLOW))
                }
            }
            var bucket: AlphabeticIndex_Bucket<V> = AlphabeticIndex_Bucket<V>(fixLabel(current), current, AlphabeticIndex_Bucket_LabelType.NORMAL)
            bucketList.append(bucket)
            var c: Char = '\u{0000}'
            if (Int32(current.size) == 1 && 'A' <= (match (0) { case _ => c = Char(current[0]); c }) && c <= 'Z') {
                asciiBuckets[0] = bucket
            } else if (Int32(current.size) == Int32(BASE.size) + 1 && current.startsWith(BASE) && 'A' <= (match (0) { case _ => c = Char(current[BASE.size]); c }) && c <= 'Z') {
                pinyinBuckets[0] = bucket
                hasPinyin = true
            }
            if (!current.startsWith(BASE) && hasMultiplePrimaryWeights(collatorPrimaryOnly, variableTop, current) && !current.endsWith("\u{ffff}")) {
                        if (singleBucket.displayBucket.isNone() && !hasMultiplePrimaryWeights(collatorPrimaryOnly, variableTop, singleBucket.lowerBoundary)) {
                            bucket = AlphabeticIndex_Bucket<V>("", (current) + "\u{ffff}", AlphabeticIndex_Bucket_LabelType.NORMAL)
                            bucket.displayBucket = singleBucket
                            bucketList.append(bucket)
                            hasInvisibleBuckets = true
                            break
                        }
                        i--
                    }
                } while (false)
            }
        }
        if (Int32(bucketList.size) == 1) {
            return AlphabeticIndex_BucketList<V>(bucketList, bucketList)
        }
        bucketList.append(AlphabeticIndex_Bucket<V>(getOverflowLabel(), scriptUpperBoundary, AlphabeticIndex_Bucket_LabelType.OVERFLOW))
        if (hasPinyin) {
            var asciiBucket: AlphabeticIndex_Bucket<V>
                    if (pinyinBuckets[Int64(i)].isSome() && asciiBucket.isSome()) {
                        pinyinBuckets[Int64(i)].displayBucket = asciiBucket
                        hasInvisibleBuckets = true
                    }
                    i++
                }
            } while (false)
        }
        if (!hasInvisibleBuckets) {
            return AlphabeticIndex_BucketList<V>(bucketList, bucketList)
        }
        var i = Int32(bucketList.size) - 1
        var nextBucket = bucketList[Int64(i)]
        while (match (0) { case _ => i--; i } > 0) {
            let bucket = bucketList[Int64(i)]
            if (bucket.displayBucket.isSome()) {
                continue
            }
            if (refEq(bucket.labelType, AlphabeticIndex_Bucket_LabelType.INFLOW)) {
                if (!refEq(nextBucket.labelType, AlphabeticIndex_Bucket_LabelType.NORMAL)) {
                    bucket.displayBucket = nextBucket
                    continue
                }
            }
            nextBucket = bucket
        }
        let publicBucketList = ArrayList<AlphabeticIndex_Bucket<V>>()
        for (bucket in bucketList) {
            if (bucket.displayBucket.isNone()) {
                publicBucketList.append(bucket)
            }
        }
        return AlphabeticIndex_BucketList<V>(bucketList, publicBucketList)
    }

    private static func hasMultiplePrimaryWeights(coll: RuleBasedCollator, variableTop: Int64, s: String): Bool {
        let ces = coll.internalGetCEs(s)
        var seenPrimary = false
        var i = 0
        while (i < Int32(ces.size)) {
            let ce = ces[Int64(i)]
            let p = ushr(ce, 32)
            if (p > variableTop) {
                if (seenPrimary) {
                    return true
                }
                seenPrimary = true
            }
            i++
        }
        return false
    }

    private static let GC_LU_MASK = shl(1, Int32(UCharacter.UPPERCASE_LETTER))

    private static let GC_LL_MASK = shl(1, Int32(UCharacter.LOWERCASE_LETTER))

    private static let GC_LT_MASK = shl(1, Int32(UCharacter.TITLECASE_LETTER))

    private static let GC_LM_MASK = shl(1, Int32(UCharacter.MODIFIER_LETTER))

    private static let GC_LO_MASK = shl(1, Int32(UCharacter.OTHER_LETTER))

    private static let GC_L_MASK = GC_LU_MASK | GC_LL_MASK | GC_LT_MASK | GC_LM_MASK | GC_LO_MASK

    private static let GC_CN_MASK = shl(1, Int32(UCharacter.GENERAL_OTHER_TYPES))

    
    public func getFirstCharactersInScripts(): ArrayList<String> {
        let dest = ArrayList<String>(200)
        let set = UnicodeSet()
        collatorPrimaryOnly.internalAddContractions(64977, set)
        if (set.isEmpty()) {
            throw UnsupportedOperationException("AlphabeticIndex requires script-first-primary contractions")
        }
        for (boundary in set) {
            let gcMask = shl(1, UCharacter.getType(boundary.codePointAt(1)))
            if ((gcMask & (GC_L_MASK | GC_CN_MASK)) == 0) {
                continue
            }
            dest.append(boundary)
        }
        return dest
    }
}

class AlphabeticIndex_1 {
    let this_0: AlphabeticIndex<Any>

    init(this_0: AlphabeticIndex<Any>) {
        this.this_0 = this_0
    }

    public override func compare(o1: AlphabeticIndex_Record<V>, o2: AlphabeticIndex_Record<V>): Int32 {
        return this_0.collatorOriginal.compare(o1.name, o2.name)
    }
}


public class AlphabeticIndex_ImmutableIndex<V> {
    private let buckets: AlphabeticIndex_BucketList<V>

    private let collatorPrimaryOnly: Collator

    init(bucketList: AlphabeticIndex_BucketList<V>, collatorPrimaryOnly: Collator) {
        this.buckets = bucketList
        this.collatorPrimaryOnly = collatorPrimaryOnly
    }

    public func getBucketCount(): Int32 {
        return buckets.getBucketCount()
    }

    public func getBucketIndex(name: String): Int32 {
        return buckets.getBucketIndex(name, collatorPrimaryOnly)
    }

    public func getBucket(index: Int32): AlphabeticIndex_Bucket<V> {
        if (0 <= index && index < buckets.getBucketCount()) {
            return buckets.immutableVisibleList[Int64(index)]
        } else {
            return None
        }
    }

    public override func iterator(): Iterator<AlphabeticIndex_Bucket<V>> {
        return buckets.iterator()
    }
}

public class AlphabeticIndex_Record<V> {
    let name: String

    private let data: V

    init(name: String, data: V) {
        this.name = name
        this.data = data
    }

    public func getName(): String {
        return name
    }

    public func getData(): V {
        return data
    }

    public override func toString(): String {
        return (name) + "=" + toString(data)
    }
}

public class AlphabeticIndex_Bucket<V> {
    private let label: String

    let lowerBoundary: String

    let labelType: AlphabeticIndex_Bucket_LabelType

    var displayBucket: AlphabeticIndex_Bucket<V>

    var displayIndex: Int32 = 0

    var records: ArrayList<AlphabeticIndex_Record<V>>

    init(label: String, lowerBoundary: String, labelType: AlphabeticIndex_Bucket_LabelType) {
        this.label = label
        this.lowerBoundary = lowerBoundary
        this.labelType = labelType
    }

    public func getLabel(): String {
        return label
    }

    public func getLabelType(): AlphabeticIndex_Bucket_LabelType {
        return labelType
    }

    public func size(): Int32 {
        return if (records.isNone()) { 0 } else { Int32(records.size) }
    }

    public override func iterator(): Iterator<AlphabeticIndex_Record<V>> {
        if (records.isNone()) {
            return Array<String>(0, { _ => "" }).iterator()
        }
        return records.iterator()
    }

    public override func toString(): String {
        return "{labelType=" + labelType.asString() + ", lowerBoundary=" + (lowerBoundary) + ", label=" + (label) + "}"
    }
}

public class AlphabeticIndex_Bucket_LabelType <: Enum<AlphabeticIndex_Bucket_LabelType> {
    public static let NORMAL = AlphabeticIndex_Bucket_LabelType("NORMAL", 0)

    public static let UNDERFLOW = AlphabeticIndex_Bucket_LabelType("UNDERFLOW", 1)

    public static let INFLOW = AlphabeticIndex_Bucket_LabelType("INFLOW", 2)

    public static let OVERFLOW = AlphabeticIndex_Bucket_LabelType("OVERFLOW", 3)

    private static func _values(): Array<AlphabeticIndex_Bucket_LabelType> {
        return [AlphabeticIndex_Bucket_LabelType.NORMAL, AlphabeticIndex_Bucket_LabelType.UNDERFLOW, AlphabeticIndex_Bucket_LabelType.INFLOW, AlphabeticIndex_Bucket_LabelType.OVERFLOW]
    }

    private static let _VALUES = AlphabeticIndex_Bucket_LabelType._values()

    public static func values(): Array<AlphabeticIndex_Bucket_LabelType> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): AlphabeticIndex_Bucket_LabelType {
        return (TypeInfo.of<AlphabeticIndex_Bucket_LabelType>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as AlphabeticIndex_Bucket_LabelType
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


class AlphabeticIndex_BucketList<V> {
    private let bucketList: ArrayList<AlphabeticIndex_Bucket<V>>

    let immutableVisibleList: ArrayList<AlphabeticIndex_Bucket<V>>

    init(bucketList: ArrayList<AlphabeticIndex_Bucket<V>>, publicBucketList: ArrayList<AlphabeticIndex_Bucket<V>>) {
        this.bucketList = bucketList
        var displayIndex = 0
        for (bucket in publicBucketList) {
            bucket.displayIndex = match (0) { case _ => displayIndex++; displayIndex - 1 }
        }
        immutableVisibleList = Collections.unmodifiableList(publicBucketList)
    }

    public func getBucketCount(): Int32 {
        return Int32(immutableVisibleList.size)
    }

    public func getBucketIndex(name: String, collatorPrimaryOnly: Collator): Int32 {
        var start = 0
        var limit = Int32(bucketList.size)
        while ((start + 1) < limit) {
            let i = (start + limit) / 2
            let bucket = bucketList[Int64(i)]
            let nameVsBucket = collatorPrimaryOnly.compare(name, bucket.lowerBoundary)
            if (nameVsBucket < 0) {
                limit = i
            } else {
                start = i
            }
        }
        var bucket = bucketList[Int64(start)]
        if (bucket.displayBucket.isSome()) {
            bucket = bucket.displayBucket
        }
        return bucket.displayIndex
    }

    public func fullIterator(): Iterator<AlphabeticIndex_Bucket<V>> {
        return bucketList.iterator()
    }

    public override func iterator(): Iterator<AlphabeticIndex_Bucket<V>> {
        return immutableVisibleList.iterator()
    }
}