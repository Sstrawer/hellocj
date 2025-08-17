package icu4cj.text


public class RuleBasedCollator <: Collator {
    public init(rules: String) {
        super()
        if (rules.isNone()) {
            throw IllegalArgumentException("Collation rules can not be null")
        }
        validLocale = ULocale.ROOT
        internalBuildTailoring(rules)
    }

    private func internalBuildTailoring(rules: String): Unit {
        let base = CollationRoot.getRoot()
        let classLoader = ClassLoaderUtil.getClassLoader(TypeInfo.of(this))
        let t: CollationTailoring
        try {
            let builderClass = classLoader.loadClass("com.ibm.icu.impl.coll.CollationBuilder")
            Object builder = builderClass.getConstructor(new Class<>(CollationTailoring.class)).newInstance(new Object(base))
            let parseAndBuild = builderClass.getMethod("parseAndBuild", [TypeInfo.of<String>() as ClassTypeInfo])
            t = parseAndBuild.invoke(builder, [rules])
        } catch (e: InvocationTargetException) {
            throw e.getTargetException()
        }
        t.actualLocale = None
        adoptTailoring(t)
    }

    public override func clone(): Object {
        if (isFrozen()) {
            return this
        }
        return cloneAsThawed()
    }

    private func initMaxExpansions(): Unit {
        synchronized (getMonitorByObject(tailoring)) {
            if (tailoring.maxExpansions.isNone()) {
                tailoring.maxExpansions = CollationElementIterator.computeMaxExpansions(tailoring.data)
            }
        }
    }

    public func getCollationElementIterator(source: String): CollationElementIterator {
        initMaxExpansions()
        return CollationElementIterator(source, this)
    }

    public func getCollationElementIterator(source: CharacterIterator): CollationElementIterator {
        initMaxExpansions()
        let newsource = source.clone()
        return CollationElementIterator(newsource, this)
    }

    public func getCollationElementIterator(source: UCharacterIterator): CollationElementIterator {
        initMaxExpansions()
        return CollationElementIterator(source, this)
    }

    public override func isFrozen(): Bool {
        return frozenLock.isSome()
    }

    public override func freeze(): Collator {
        if (!isFrozen()) {
            frozenLock = ReentrantMutex() as Lock
            if (collationBuffer.isNone()) {
                collationBuffer = RuleBasedCollator_CollationBuffer(data)
            }
        }
        return this
    }

    public override func cloneAsThawed(): RuleBasedCollator {
        try {
            let result = super.clone()
            result.settings = settings.clone()
            result.collationBuffer = None
            result.frozenLock = None
            return result
        } catch (e: CloneNotSupportedException) {
            return None
        }
    }

    private func checkNotFrozen(): Unit {
        if (isFrozen()) {
            throw UnsupportedOperationException("Attempt to modify frozen RuleBasedCollator")
        }
    }

    private func getOwnedSettings(): CollationSettings {
        return settings.copyOnWrite()
    }

    private func getDefaultSettings(): CollationSettings {
        return tailoring.settings.readOnly()
    }

    
    public func setHiraganaQuaternary(flag: Bool): Unit {
        checkNotFrozen()
    }

    
    public func setHiraganaQuaternaryDefault(): Unit {
        checkNotFrozen()
    }

    public func setUpperCaseFirst(upperfirst: Bool): Unit {
        checkNotFrozen()
        if (upperfirst == isUpperCaseFirst()) {
            return
        }
        let ownedSettings = getOwnedSettings()
        ownedSettings.setCaseFirst(if (upperfirst) { CollationSettings.CASE_FIRST_AND_UPPER_MASK } else { 0 })
        setFastLatinOptions(ownedSettings)
    }

    public func setLowerCaseFirst(lowerfirst: Bool): Unit {
        checkNotFrozen()
        if (lowerfirst == isLowerCaseFirst()) {
            return
        }
        let ownedSettings = getOwnedSettings()
        ownedSettings.setCaseFirst(if (lowerfirst) { CollationSettings.CASE_FIRST } else { 0 })
        setFastLatinOptions(ownedSettings)
    }

    public func setCaseFirstDefault(): Unit {
        checkNotFrozen()
        let defaultSettings = getDefaultSettings()
        if (refEq(settings.readOnly(), defaultSettings)) {
            return
        }
        let ownedSettings = getOwnedSettings()
        ownedSettings.setCaseFirstDefault(defaultSettings.options)
        setFastLatinOptions(ownedSettings)
    }

    public func setAlternateHandlingDefault(): Unit {
        checkNotFrozen()
        let defaultSettings = getDefaultSettings()
        if (refEq(settings.readOnly(), defaultSettings)) {
            return
        }
        let ownedSettings = getOwnedSettings()
        ownedSettings.setAlternateHandlingDefault(defaultSettings.options)
        setFastLatinOptions(ownedSettings)
    }

    public func setCaseLevelDefault(): Unit {
        checkNotFrozen()
        let defaultSettings = getDefaultSettings()
        if (refEq(settings.readOnly(), defaultSettings)) {
            return
        }
        let ownedSettings = getOwnedSettings()
        ownedSettings.setFlagDefault(CollationSettings.CASE_LEVEL, defaultSettings.options)
        setFastLatinOptions(ownedSettings)
    }

    public func setDecompositionDefault(): Unit {
        checkNotFrozen()
        let defaultSettings = getDefaultSettings()
        if (refEq(settings.readOnly(), defaultSettings)) {
            return
        }
        let ownedSettings = getOwnedSettings()
        ownedSettings.setFlagDefault(CollationSettings.CHECK_FCD, defaultSettings.options)
        setFastLatinOptions(ownedSettings)
    }

    public func setFrenchCollationDefault(): Unit {
        checkNotFrozen()
        let defaultSettings = getDefaultSettings()
        if (refEq(settings.readOnly(), defaultSettings)) {
            return
        }
        let ownedSettings = getOwnedSettings()
        ownedSettings.setFlagDefault(CollationSettings.BACKWARD_SECONDARY, defaultSettings.options)
        setFastLatinOptions(ownedSettings)
    }

    public func setStrengthDefault(): Unit {
        checkNotFrozen()
        let defaultSettings = getDefaultSettings()
        if (refEq(settings.readOnly(), defaultSettings)) {
            return
        }
        let ownedSettings = getOwnedSettings()
        ownedSettings.setStrengthDefault(defaultSettings.options)
        setFastLatinOptions(ownedSettings)
    }

    public func setNumericCollationDefault(): Unit {
        checkNotFrozen()
        let defaultSettings = getDefaultSettings()
        if (refEq(settings.readOnly(), defaultSettings)) {
            return
        }
        let ownedSettings = getOwnedSettings()
        ownedSettings.setFlagDefault(CollationSettings.NUMERIC, defaultSettings.options)
        setFastLatinOptions(ownedSettings)
    }

    public func setFrenchCollation(flag: Bool): Unit {
        checkNotFrozen()
        if (flag == isFrenchCollation()) {
            return
        }
        let ownedSettings = getOwnedSettings()
        ownedSettings.setFlag(CollationSettings.BACKWARD_SECONDARY, flag)
        setFastLatinOptions(ownedSettings)
    }

    public func setAlternateHandlingShifted(shifted: Bool): Unit {
        checkNotFrozen()
        if (shifted == isAlternateHandlingShifted()) {
            return
        }
        let ownedSettings = getOwnedSettings()
        ownedSettings.setAlternateHandlingShifted(shifted)
        setFastLatinOptions(ownedSettings)
    }

    public func setCaseLevel(flag: Bool): Unit {
        checkNotFrozen()
        if (flag == isCaseLevel()) {
            return
        }
        let ownedSettings = getOwnedSettings()
        ownedSettings.setFlag(CollationSettings.CASE_LEVEL, flag)
        setFastLatinOptions(ownedSettings)
    }

    public override func setDecomposition(decomposition: Int32): Unit {
        checkNotFrozen()
        let flag: Bool
        match (decomposition) {
            case 16 => flag = false
            case 17 => flag = true
            case _ => throw IllegalArgumentException("Wrong decomposition mode.")
        }
        if (flag == settings.readOnly().getFlag(CollationSettings.CHECK_FCD)) {
            return
        }
        let ownedSettings = getOwnedSettings()
        ownedSettings.setFlag(CollationSettings.CHECK_FCD, flag)
        setFastLatinOptions(ownedSettings)
    }

    public override func setStrength(newStrength: Int32): Unit {
        checkNotFrozen()
        if (newStrength == getStrength()) {
            return
        }
        let ownedSettings = getOwnedSettings()
        ownedSettings.setStrength(newStrength)
        setFastLatinOptions(ownedSettings)
    }

    public override func setMaxVariable(group: Int32): RuleBasedCollator {
        var tempgroup = group
        let value: Int32
        if (tempgroup == Collator_ReorderCodes.DEFAULT) {
            value = -1
        } else if (Collator_ReorderCodes.FIRST <= tempgroup && tempgroup <= Collator_ReorderCodes.CURRENCY) {
            value = tempgroup - Collator_ReorderCodes.FIRST
        } else {
            throw IllegalArgumentException("illegal max variable group " + tempgroup.toString())
        }
        let oldValue = settings.readOnly().getMaxVariable()
        if (value == oldValue) {
            return this
        }
        let defaultSettings = getDefaultSettings()
        if (refEq(settings.readOnly(), defaultSettings)) {
            if (value < 0) {
                return this
            }
        }
        let ownedSettings = getOwnedSettings()
        if (tempgroup == Collator_ReorderCodes.DEFAULT) {
            tempgroup = Collator_ReorderCodes.FIRST + defaultSettings.getMaxVariable()
        }
        let varTop = data.getLastPrimaryForGroup(tempgroup)
        if (!(varTop != 0)) {
            throw AssertionError()
        }
        ownedSettings.setMaxVariable(value, defaultSettings.options)
        ownedSettings.variableTop = varTop
        setFastLatinOptions(ownedSettings)
        return this
    }

    public override func getMaxVariable(): Int32 {
        return Collator_ReorderCodes.FIRST + settings.readOnly().getMaxVariable()
    }

    
    public override func setVariableTop(varTop: String): Int32 {
        checkNotFrozen()
        if (varTop.isNone() || Int32(varTop.size) == 0) {
            throw IllegalArgumentException("Variable top argument string can not be null or zero in length.")
        }
        let numeric = settings.readOnly().isNumeric()
        let ce1: Int64
        let ce2: Int64
        if (settings.readOnly().dontCheckFCD()) {
            let ci = UTF16CollationIterator(data, numeric, varTop, 0)
            ce1 = ci.nextCE()
            ce2 = ci.nextCE()
        } else {
            let ci = FCDUTF16CollationIterator(data, numeric, varTop, 0)
            ce1 = ci.nextCE()
            ce2 = ci.nextCE()
        }
        if (ce1 == Collation.NO_CE || ce2 != Collation.NO_CE) {
            throw IllegalArgumentException("Variable top argument string must map to exactly one collation element")
        }
        internalSetVariableTop(ushr(ce1, 32))
        return Int32(settings.readOnly().variableTop)
    }

    
    public override func setVariableTop(varTop: Int32): Unit {
        checkNotFrozen()
        internalSetVariableTop(Int64(varTop) & 4294967295)
    }

    private func internalSetVariableTop(varTop: Int64): Unit {
        var tempvarTop = varTop
        if (tempvarTop != settings.readOnly().variableTop) {
            let group = data.getGroupForPrimary(tempvarTop)
            if (group < Collator_ReorderCodes.FIRST || Collator_ReorderCodes.CURRENCY < group) {
                throw IllegalArgumentException("The variable top must be a primary weight in the space/punctuation/symbols/currency symbols range")
            }
            let v = data.getLastPrimaryForGroup(group)
            if (!(v != 0 && v >= tempvarTop)) {
                throw AssertionError()
            }
            tempvarTop = v
            if (tempvarTop != settings.readOnly().variableTop) {
                let ownedSettings = getOwnedSettings()
                ownedSettings.setMaxVariable(group - Collator_ReorderCodes.FIRST, getDefaultSettings().options)
                ownedSettings.variableTop = tempvarTop
                setFastLatinOptions(ownedSettings)
            }
        }
    }

    public func setNumericCollation(flag: Bool): Unit {
        checkNotFrozen()
        if (flag == getNumericCollation()) {
            return
        }
        let ownedSettings = getOwnedSettings()
        ownedSettings.setFlag(CollationSettings.NUMERIC, flag)
        setFastLatinOptions(ownedSettings)
    }

    public override func setReorderCodes(order: Array<Int32>): Unit {
        checkNotFrozen()
        var length = if (order.isSome()) { Int32(order.size) } else { 0 }
        if (length == 1 && order[0] == Collator_ReorderCodes.NONE) {
            length = 0
        }
        if (if (length == 0) { Int32(settings.readOnly().reorderCodes.size) == 0 } else { order == settings.readOnly(.reorderCodes) }) {
            return
        }
        let defaultSettings = getDefaultSettings()
        if (length == 1 && order[0] == Collator_ReorderCodes.DEFAULT) {
            if (!refEq(settings.readOnly(), defaultSettings)) {
                let ownedSettings = getOwnedSettings()
                ownedSettings.copyReorderingFrom(defaultSettings)
                setFastLatinOptions(ownedSettings)
            }
            return
        }
        let ownedSettings = getOwnedSettings()
        if (length == 0) {
            ownedSettings.resetReordering()
        } else {
            ownedSettings.setReordering(data, order.clone())
        }
        setFastLatinOptions(ownedSettings)
    }

    private func setFastLatinOptions(ownedSettings: CollationSettings): Unit {
        ownedSettings.fastLatinOptions = CollationFastLatin.getOptions(data, ownedSettings, ownedSettings.fastLatinPrimaries)
    }

    public func getRules(): String {
        return tailoring.getRules()
    }

    public func getRules(fullrules: Bool): String {
        if (!fullrules) {
            return tailoring.getRules()
        }
        return (CollationLoader.getRootRules()) + (tailoring.getRules())
    }

    public override func getTailoredSet(): UnicodeSet {
        let tailored = UnicodeSet()
        if (data.base.isSome()) {
            TailoredSet(tailored).forData(data)
        }
        return tailored
    }

    public func getContractionsAndExpansions(contractions: UnicodeSet, expansions: UnicodeSet, addPrefixes: Bool): Unit {
        if (contractions.isSome()) {
            contractions.clear()
        }
        if (expansions.isSome()) {
            expansions.clear()
        }
        ContractionsAndExpansions(contractions, expansions, None, addPrefixes).forData(data)
    }

    
    public func internalAddContractions(c: Int32, set: UnicodeSet): Unit {
        ContractionsAndExpansions(set, None, None, false).forCodePoint(data, c)
    }

    public override func getCollationKey(source: String): CollationKey {
        if (source.isNone()) {
            return None
        }
        var buffer: RuleBasedCollator_CollationBuffer
        try {
            buffer = getCollationBuffer()
            return getCollationKey(source, buffer)
        } finally {
            releaseCollationBuffer(buffer)
        }
    }

    private func getCollationKey(source: String, buffer: RuleBasedCollator_CollationBuffer): CollationKey {
        buffer.rawCollationKey = getRawCollationKey(source, buffer.rawCollationKey, buffer)
        return CollationKey(source, buffer.rawCollationKey)
    }

    public override func getRawCollationKey(source: String, key: RawCollationKey): RawCollationKey {
        if (source.isNone()) {
            return None
        }
        var buffer: RuleBasedCollator_CollationBuffer
        try {
            buffer = getCollationBuffer()
            return getRawCollationKey(source, key, buffer)
        } finally {
            releaseCollationBuffer(buffer)
        }
    }

    private func getRawCollationKey(source: String, key: RawCollationKey, buffer: RuleBasedCollator_CollationBuffer): RawCollationKey {
        var tempkey = key
        if (tempkey.isNone()) {
            tempkey = RawCollationKey(simpleKeyLengthEstimate(source))
        } else if (tempkey.bytes.isNone()) {
            tempkey.bytes = Array<UInt8>(Int64(simpleKeyLengthEstimate(source))) { _ => 0 }
        }
        let sink = RuleBasedCollator_CollationKeyByteSink(tempkey)
        writeSortKey(source, sink, buffer)
        tempkey.size = sink.NumberOfBytesAppended()
        return tempkey
    }

    private func simpleKeyLengthEstimate(source: String): Int32 {
        return 2 * source.size + 10
    }

    private func writeSortKey(s: String, sink: RuleBasedCollator_CollationKeyByteSink, buffer: RuleBasedCollator_CollationBuffer): Unit {
        let numeric = settings.readOnly().isNumeric()
        if (settings.readOnly().dontCheckFCD()) {
            buffer.leftUTF16CollIter.setText(numeric, s, 0)
            CollationKeys.writeSortKeyUpToQuaternary(buffer.leftUTF16CollIter, data.compressibleBytes, settings.readOnly(), sink, Collation.PRIMARY_LEVEL, CollationKeys.SIMPLE_LEVEL_FALLBACK, true)
        } else {
            buffer.leftFCDUTF16Iter.setText(numeric, s, 0)
            CollationKeys.writeSortKeyUpToQuaternary(buffer.leftFCDUTF16Iter, data.compressibleBytes, settings.readOnly(), sink, Collation.PRIMARY_LEVEL, CollationKeys.SIMPLE_LEVEL_FALLBACK, true)
        }
        if (settings.readOnly().getStrength() == IDENTICAL) {
            writeIdenticalLevel(s, sink)
        }
        sink.Append(Collation.TERMINATOR_BYTE)
    }

    private func writeIdenticalLevel(s: String, sink: RuleBasedCollator_CollationKeyByteSink): Unit {
        let nfdQCYesLimit = data.nfcImpl.decompose(s, 0, s.size, None)
        sink.Append(Collation.LEVEL_SEPARATOR_BYTE)
        sink.key_.size = sink.NumberOfBytesAppended()
        var prev = 0
        if (nfdQCYesLimit != 0) {
            prev = BOCSU.writeIdenticalLevelRun(prev, s, 0, nfdQCYesLimit, sink.key_)
        }
        if (nfdQCYesLimit < s.size) {
            let destLengthEstimate = s.size - nfdQCYesLimit
            let nfd = StringBuilder()
            data.nfcImpl.decompose(s, nfdQCYesLimit, s.size, nfd, destLengthEstimate)
            BOCSU.writeIdenticalLevelRun(prev, nfd.toString(), 0, Int32(nfd.size), sink.key_)
        }
        sink.setBufferAndAppended(sink.key_.bytes, sink.key_.size)
    }

    
    public func internalGetCEs(str: String): Array<Int64> {
        var buffer: RuleBasedCollator_CollationBuffer
        try {
            buffer = getCollationBuffer()
            let numeric = settings.readOnly().isNumeric()
            let iter: CollationIterator
            if (settings.readOnly().dontCheckFCD()) {
                buffer.leftUTF16CollIter.setText(numeric, str, 0)
                iter = buffer.leftUTF16CollIter
            } else {
                buffer.leftFCDUTF16Iter.setText(numeric, str, 0)
                iter = buffer.leftFCDUTF16Iter
            }
            let length = iter.fetchCEs() - 1
            if (!(length >= 0 && iter.getCE(length) == Collation.NO_CE)) {
                throw AssertionError()
            }
            let ces = Array<Int64>(Int64(length)) { _ => 0 }
            arraycopy(iter.getCEs(), 0, ces, 0, Int64(length))
            return ces
        } finally {
            releaseCollationBuffer(buffer)
        }
    }

    public override func getStrength(): Int32 {
        return settings.readOnly().getStrength()
    }

    public override func getDecomposition(): Int32 {
        return if ((settings.readOnly().options & CollationSettings.CHECK_FCD) != 0) { CANONICAL_DECOMPOSITION } else { NO_DECOMPOSITION }
    }

    public func isUpperCaseFirst(): Bool {
        return (settings.readOnly().getCaseFirst() == CollationSettings.CASE_FIRST_AND_UPPER_MASK)
    }

    public func isLowerCaseFirst(): Bool {
        return (settings.readOnly().getCaseFirst() == CollationSettings.CASE_FIRST)
    }

    public func isAlternateHandlingShifted(): Bool {
        return settings.readOnly().getAlternateHandling()
    }

    public func isCaseLevel(): Bool {
        return (settings.readOnly().options & CollationSettings.CASE_LEVEL) != 0
    }

    public func isFrenchCollation(): Bool {
        return (settings.readOnly().options & CollationSettings.BACKWARD_SECONDARY) != 0
    }

    
    public func isHiraganaQuaternary(): Bool {
        return false
    }

    public override func getVariableTop(): Int32 {
        return Int32(settings.readOnly().variableTop)
    }

    public func getNumericCollation(): Bool {
        return (settings.readOnly().options & CollationSettings.NUMERIC) != 0
    }

    public override func getReorderCodes(): Array<Int32> {
        return settings.readOnly().reorderCodes.clone()
    }

    public override func equals(obj: Object): Bool {
        if (refEq(this, obj)) {
            return true
        }
        if (!super.equals(obj)) {
            return false
        }
        let o = obj
        if (!settings.readOnly().equals(o.settings.readOnly())) {
            return false
        }
        if (refEq(data, o.data)) {
            return true
        }
        let thisIsRoot = data.base.isNone()
        let otherIsRoot = o.data.base.isNone()
        if (!(!thisIsRoot || !otherIsRoot)) {
            throw AssertionError()
        }
        if (thisIsRoot != otherIsRoot) {
            return false
        }
        let theseRules = tailoring.getRules()
        let otherRules = o.tailoring.getRules()
        if ((thisIsRoot || Int32(theseRules.size) != 0) && (otherIsRoot || Int32(otherRules.size) != 0)) {
            if (theseRules.equals(otherRules)) {
                return true
            }
        }
        let thisTailored = getTailoredSet()
        let otherTailored = o.getTailoredSet()
        if (!thisTailored.equals(otherTailored)) {
            return false
        }
        return true
    }

    public override func hashCode(): Int64 {
        var h = Int32(settings.readOnly().hashCode())
        if (data.base.isNone()) {
            return Int64(h)
        }
        let set = getTailoredSet()
        let iter = UnicodeSetIterator(set)
        while (iter.next() && iter.codepoint != UnicodeSetIterator.IS_STRING) {
            h ^= data.getCE32(iter.codepoint)
        }
        return Int64(h)
    }

    public override func compare(source: String, target: String): Int32 {
        return doCompare(source, target)
    }

    private static func compareNFDIter(nfcImpl: Normalizer2Impl, left: RuleBasedCollator_NFDIterator, right: RuleBasedCollator_NFDIterator): Int32 {
        while (true) {
            var leftCp = left.nextCodePoint()
            var rightCp = right.nextCodePoint()
            if (leftCp == rightCp) {
                if (leftCp < 0) {
                    break
                }
                continue
            }
            if (leftCp < 0) {
                leftCp = -2
            } else if (leftCp == 65534) {
                leftCp = -1
            } else {
                leftCp = left.nextDecomposedCodePoint(nfcImpl, leftCp)
            }
            if (rightCp < 0) {
                rightCp = -2
            } else if (rightCp == 65534) {
                rightCp = -1
            } else {
                rightCp = right.nextDecomposedCodePoint(nfcImpl, rightCp)
            }
            if (leftCp < rightCp) {
                return Collation.LESS
            }
            if (leftCp > rightCp) {
                return Collation.GREATER
            }
        }
        return Collation.EQUAL
    }

    
    override protected func doCompare(left: String, right: String): Int32 {
        if (refEq(left, right)) {
            return Collation.EQUAL
        }
        var equalPrefixLength = 0
        while (true) {
            if (equalPrefixLength == left.size) {
                if (equalPrefixLength == right.size) {
                    return Collation.EQUAL
                }
                break
            } else if (equalPrefixLength == right.size || left[equalPrefixLength] != right[equalPrefixLength]) {
                break
            }
            equalPrefixLength++
        }
        let roSettings = settings.readOnly()
        let numeric = roSettings.isNumeric()
        if (equalPrefixLength > 0) {
            if ((equalPrefixLength != left.size && data.isUnsafeBackward(Int32(UInt32(left[equalPrefixLength])), numeric)) || (equalPrefixLength != right.size && data.isUnsafeBackward(Int32(UInt32(right[equalPrefixLength])), numeric))) {
                while (match (0) { case _ => equalPrefixLength--; equalPrefixLength } > 0 && data.isUnsafeBackward(Int32(UInt32(left[equalPrefixLength])), numeric)) { }
            }
        }
        var result: Int32 = 0
        let fastLatinOptions = roSettings.fastLatinOptions
        if (fastLatinOptions >= 0 && (equalPrefixLength == left.size || Int32(UInt32(left[equalPrefixLength])) <= CollationFastLatin.LATIN_MAX) && (equalPrefixLength == right.size || Int32(UInt32(right[equalPrefixLength])) <= CollationFastLatin.LATIN_MAX)) {
            result = CollationFastLatin.compareUTF16(data.fastLatinTable, roSettings.fastLatinPrimaries, fastLatinOptions, left, right, equalPrefixLength)
        } else {
            result = CollationFastLatin.BAIL_OUT_RESULT
        }
        if (result == CollationFastLatin.BAIL_OUT_RESULT) {
            var buffer: RuleBasedCollator_CollationBuffer
            try {
                buffer = getCollationBuffer()
                if (roSettings.dontCheckFCD()) {
                    buffer.leftUTF16CollIter.setText(numeric, left, equalPrefixLength)
                    buffer.rightUTF16CollIter.setText(numeric, right, equalPrefixLength)
                    result = CollationCompare.compareUpToQuaternary(buffer.leftUTF16CollIter, buffer.rightUTF16CollIter, roSettings)
                } else {
                    buffer.leftFCDUTF16Iter.setText(numeric, left, equalPrefixLength)
                    buffer.rightFCDUTF16Iter.setText(numeric, right, equalPrefixLength)
                    result = CollationCompare.compareUpToQuaternary(buffer.leftFCDUTF16Iter, buffer.rightFCDUTF16Iter, roSettings)
                }
            } finally {
                releaseCollationBuffer(buffer)
            }
        }
        if (result != Collation.EQUAL || roSettings.getStrength() < Collator.IDENTICAL) {
            return result
        }
        var buffer: RuleBasedCollator_CollationBuffer
        try {
            buffer = getCollationBuffer()
            let nfcImpl = data.nfcImpl
            if (roSettings.dontCheckFCD()) {
                buffer.leftUTF16NFDIter.setText(left, equalPrefixLength)
                buffer.rightUTF16NFDIter.setText(right, equalPrefixLength)
                return compareNFDIter(nfcImpl, buffer.leftUTF16NFDIter, buffer.rightUTF16NFDIter)
            } else {
                buffer.leftFCDUTF16NFDIter.setText(nfcImpl, left, equalPrefixLength)
                buffer.rightFCDUTF16NFDIter.setText(nfcImpl, right, equalPrefixLength)
                return compareNFDIter(nfcImpl, buffer.leftFCDUTF16NFDIter, buffer.rightFCDUTF16NFDIter)
            }
        } finally {
            releaseCollationBuffer(buffer)
        }
    }

    init(t: CollationTailoring, vl: ULocale) {
        super()
        data = t.data
        settings = t.settings.clone()
        tailoring = t
        validLocale = vl
        actualLocaleIsSameAsValid = false
    }

    private func adoptTailoring(t: CollationTailoring): Unit {
        if (!(settings.isNone() && data.isNone() && tailoring.isNone())) {
            throw AssertionError()
        }
        data = t.data
        settings = t.settings.clone()
        tailoring = t
        validLocale = t.actualLocale
        actualLocaleIsSameAsValid = false
    }

    func isUnsafe(c: Int32): Bool {
        return data.isUnsafeBackward(c, settings.readOnly().isNumeric())
    }

    private var frozenLock: Lock = None

    public override func getVersion(): VersionInfo {
        let version = tailoring.version
        let rtVersion = VersionInfo.UCOL_RUNTIME_VERSION.getMajor()
        return VersionInfo.getInstance((ushr(version, 24)) + (shl(rtVersion, 4)) + (shr(rtVersion, 4)), ((shr(version, 16)) & 255), ((shr(version, 8)) & 255), (version & 255))
    }

    public override func getUCAVersion(): VersionInfo {
        let v = getVersion()
        return VersionInfo.getInstance(shr(v.getMinor(), 3), v.getMinor() & 7, shr(v.getMilli(), 6), 0)
    }

    private var collationBuffer: RuleBasedCollator_CollationBuffer

    private func getCollationBuffer(): RuleBasedCollator_CollationBuffer {
        if (isFrozen()) {
            frozenLock.lock()
        } else if (collationBuffer.isNone()) {
            collationBuffer = RuleBasedCollator_CollationBuffer(data)
        }
        return collationBuffer
    }

    private func releaseCollationBuffer(buffer: RuleBasedCollator_CollationBuffer): Unit {
        if (isFrozen()) {
            frozenLock.unlock()
        }
    }

    public override func getLocale(Type: ULocale_Type): ULocale {
        if (refEq(Type, ULocale.ACTUAL_LOCALE)) {
            return if (actualLocaleIsSameAsValid) { validLocale } else { tailoring.actualLocale }
        } else if (refEq(Type, ULocale.VALID_LOCALE)) {
            return validLocale
        } else {
            throw IllegalArgumentException("unknown ULocale.Type " + Type.asString())
        }
    }

    public override func setLocale(valid: ULocale, actual: ULocale): Unit {
        if (!((valid.isNone()) == (actual.isNone()))) {
            throw AssertionError()
        }
        if (Objects.equals(actual, tailoring.actualLocale)) {
            actualLocaleIsSameAsValid = false
        } else {
            if (!(Objects.equals(actual, valid))) {
                throw AssertionError()
            }
            actualLocaleIsSameAsValid = true
        }
        validLocale = valid
    }

    var data: CollationData

    var settings: SharedObject_Reference<CollationSettings>

    var tailoring: CollationTailoring

    private var validLocale: ULocale

    private var actualLocaleIsSameAsValid: Bool = false
}


class RuleBasedCollator_CollationKeyByteSink <: CollationKeys_SortKeyByteSink {
    init(key: RawCollationKey) {
        super(key.bytes)
        key_ = key
    }

    override protected func AppendBeyondCapacity(bytes: Array<UInt8>, start: Int32, n: Int32, length: Int32): Unit {
        if (Resize(n, length)) {
            arraycopy(bytes, Int64(start), buffer_, Int64(length), Int64(n))
        }
    }

    override protected func Resize(appendCapacity: Int32, length: Int32): Bool {
        var newCapacity = 2 * Int32(buffer_.size)
        let altCapacity = length + 2 * appendCapacity
        if (newCapacity < altCapacity) {
            newCapacity = altCapacity
        }
        if (newCapacity < 200) {
            newCapacity = 200
        }
        let newBytes = Array<UInt8>(Int64(newCapacity)) { _ => 0 }
        arraycopy(buffer_, 0, newBytes, 0, Int64(length))
        buffer_ = match (0) { case _ => key_.bytes = newBytes; key_.bytes }
        return true
    }

    var key_: RawCollationKey
}


abstract class RuleBasedCollator_NFDIterator {

    func reset(): Unit {
        index = -1
    }

    func nextCodePoint(): Int32 {
        if (index >= 0) {
            if (index == Int32(decomp.size)) {
                index = -1
            } else {
                let c = Character.codePointAt(decomp, index)
                index += Character.charCount(c)
                return c
            }
        }
        return nextRawCodePoint()
    }

    func nextDecomposedCodePoint(nfcImpl: Normalizer2Impl, c: Int32): Int32 {
        var tempc = c
        if (index >= 0) {
            return tempc
        }
        decomp = nfcImpl.getDecomposition(tempc)
        if (decomp.isNone()) {
            return tempc
        }
        tempc = Character.codePointAt(decomp, 0)
        index = Character.charCount(tempc)
        return tempc
    }

    protected func nextRawCodePoint(): Int32

    private var decomp: String

    private var index: Int32 = 0
}


class RuleBasedCollator_UTF16NFDIterator <: RuleBasedCollator_NFDIterator {
    init() {
        super()
    }

    public func setText(seq: String, start: Int32): Unit {
        reset()
        s = seq
        pos = start
    }

    override protected func nextRawCodePoint(): Int32 {
        if (pos == s.size) {
            return Collation.SENTINEL_CP
        }
        let c = Character.codePointAt(s, pos)
        pos += Character.charCount(c)
        return c
    }

    protected var s: String

    protected var pos: Int32 = 0
}


class RuleBasedCollator_FCDUTF16NFDIterator <: RuleBasedCollator_UTF16NFDIterator {
    init() {
        super()
    }

    public func setText(nfcImpl: Normalizer2Impl, seq: String, start: Int32): Unit {
        reset()
        let spanLimit = nfcImpl.makeFCD(seq, start, seq.size, None)
        if (spanLimit == seq.size) {
            s = seq
            pos = start
        } else {
            if (str.isNone()) {
                str = StringBuilder()
            } else {
                str.setLength(0)
            }
            str.append(seq, start, spanLimit)
            let buffer = Normalizer2Impl_ReorderingBuffer(nfcImpl, str, seq.size - start)
            nfcImpl.makeFCD(seq, spanLimit, seq.size, buffer)
            s = str.asString()
            pos = 0
        }
    }

    private var str: StringBuilder
}


class RuleBasedCollator_CollationBuffer {
    init(data: CollationData) {
        leftUTF16CollIter = UTF16CollationIterator(data)
        rightUTF16CollIter = UTF16CollationIterator(data)
        leftFCDUTF16Iter = FCDUTF16CollationIterator(data)
        rightFCDUTF16Iter = FCDUTF16CollationIterator(data)
        leftUTF16NFDIter = RuleBasedCollator_UTF16NFDIterator()
        rightUTF16NFDIter = RuleBasedCollator_UTF16NFDIterator()
        leftFCDUTF16NFDIter = RuleBasedCollator_FCDUTF16NFDIterator()
        rightFCDUTF16NFDIter = RuleBasedCollator_FCDUTF16NFDIterator()
    }

    var leftUTF16CollIter: UTF16CollationIterator

    var rightUTF16CollIter: UTF16CollationIterator

    var leftFCDUTF16Iter: FCDUTF16CollationIterator

    var rightFCDUTF16Iter: FCDUTF16CollationIterator

    var leftUTF16NFDIter: RuleBasedCollator_UTF16NFDIterator

    var rightUTF16NFDIter: RuleBasedCollator_UTF16NFDIterator

    var leftFCDUTF16NFDIter: RuleBasedCollator_FCDUTF16NFDIterator

    var rightFCDUTF16NFDIter: RuleBasedCollator_FCDUTF16NFDIterator

    var rawCollationKey: RawCollationKey
}
