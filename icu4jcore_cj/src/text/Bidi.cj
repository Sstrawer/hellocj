package icu4cj.text


public class Bidi {
    public static let LEVEL_DEFAULT_LTR = 126u8

    public static let LEVEL_DEFAULT_RTL = 127u8

    public static let MAX_EXPLICIT_LEVEL = 125u8

    public static let LEVEL_OVERRIDE = 128u8

    public static let MAP_NOWHERE = -1

    public static let LTR = 0u8

    public static let RTL = 1u8

    public static let MIXED = 2u8

    public static let NEUTRAL = 3u8

    public static let KEEP_BASE_COMBINING = 1i16

    public static let DO_MIRRORING = 2i16

    public static let INSERT_LRM_FOR_NUMERIC = 4i16

    public static let REMOVE_BIDI_CONTROLS = 8i16

    public static let OUTPUT_REVERSE = 16i16

    public static let REORDER_DEFAULT = 0i16

    public static let REORDER_NUMBERS_SPECIAL = 1i16

    public static let REORDER_GROUP_NUMBERS_WITH_R = 2i16

    public static let REORDER_RUNS_ONLY = 3i16

    public static let REORDER_INVERSE_NUMBERS_AS_L = 4i16

    public static let REORDER_INVERSE_LIKE_DIRECT = 5i16

    public static let REORDER_INVERSE_FOR_NUMBERS_SPECIAL = 6i16

    static let REORDER_COUNT = 7i16

    static let REORDER_LAST_LOGICAL_TO_VISUAL = REORDER_NUMBERS_SPECIAL

    public static let OPTION_DEFAULT = 0

    public static let OPTION_INSERT_MARKS = 1

    public static let OPTION_REMOVE_CONTROLS = 2

    public static let OPTION_STREAMING = 4

    static let L = UInt8(UCharacterDirection.LEFT_TO_RIGHT)

    static let R = UInt8(UCharacterDirection.RIGHT_TO_LEFT)

    static let EN = UInt8(UCharacterDirection.EUROPEAN_NUMBER)

    static let ES = UInt8(UCharacterDirection.EUROPEAN_NUMBER_SEPARATOR)

    static let ET = UInt8(UCharacterDirection.EUROPEAN_NUMBER_TERMINATOR)

    static let AN = UInt8(UCharacterDirection.ARABIC_NUMBER)

    static let CS = UInt8(UCharacterDirection.COMMON_NUMBER_SEPARATOR)

    static let B = UInt8(UCharacterDirection.BLOCK_SEPARATOR)

    static let S = UInt8(UCharacterDirection.SEGMENT_SEPARATOR)

    static let WS = UInt8(UCharacterDirection.WHITE_SPACE_NEUTRAL)

    static let ON = UInt8(UCharacterDirection.OTHER_NEUTRAL)

    static let LRE = UInt8(UCharacterDirection.LEFT_TO_RIGHT_EMBEDDING)

    static let LRO = UInt8(UCharacterDirection.LEFT_TO_RIGHT_OVERRIDE)

    static let AL = UInt8(UCharacterDirection.RIGHT_TO_LEFT_ARABIC)

    static let RLE = UInt8(UCharacterDirection.RIGHT_TO_LEFT_EMBEDDING)

    static let RLO = UInt8(UCharacterDirection.RIGHT_TO_LEFT_OVERRIDE)

    static let PDF = UInt8(UCharacterDirection.POP_DIRECTIONAL_FORMAT)

    static let NSM = UInt8(UCharacterDirection.DIR_NON_SPACING_MARK)

    static let BN = UInt8(UCharacterDirection.BOUNDARY_NEUTRAL)

    static let FSI = UCharacterDirection.FIRST_STRONG_ISOLATE

    static let LRI = UCharacterDirection.LEFT_TO_RIGHT_ISOLATE

    static let RLI = UCharacterDirection.RIGHT_TO_LEFT_ISOLATE

    static let PDI = UCharacterDirection.POP_DIRECTIONAL_ISOLATE

    static let ENL = UInt8(Int32(PDI) + 1)

    static let ENR = UInt8(Int32(ENL) + 1)

    
    public static let CLASS_DEFAULT = UCharacterDirection.CHAR_DIRECTION_COUNT

    static let SIMPLE_PARAS_COUNT = 10

    static let SIMPLE_OPENINGS_COUNT = 20

    private static let CR = '\r'

    private static let LF = '\n'

    static let LRM_BEFORE = 1

    static let LRM_AFTER = 2

    static let RLM_BEFORE = 4

    static let RLM_AFTER = 8

    static let FOUND_L = UInt8(DirPropFlag(L))

    static let FOUND_R = UInt8(DirPropFlag(R))

    static let ISOLATE = 256

    var paraBidi: Bidi

    let bdp: UBiDiProps

    var text: Array<Char>

    var originalLength: Int32 = 0

    var length: Int32 = 0

    var resultLength: Int32 = 0

    var mayAllocateText: Bool = false

    var mayAllocateRuns: Bool = false

    var dirPropsMemory: Array<UInt8> = Array<UInt8>(1) { _ => 0 }

    var levelsMemory: Array<UInt8> = Array<UInt8>(1) { _ => 0 }

    var dirProps: Array<UInt8>

    var levels: Array<UInt8>

    var isInverse: Bool = false

    var reorderingMode: Int32 = 0

    var reorderingOptions: Int32 = 0

    var orderParagraphsLTR: Bool = false

    var paraLevel: UInt8 = 0

    var defaultParaLevel: UInt8 = 0

    var prologue: String

    var epilogue: String

    var impTabPair: Bidi_ImpTabPair

    var direction: UInt8 = 0

    var flags: Int32 = 0

    var lastArabicPos: Int32 = 0

    var trailingWSStart: Int32 = 0

    var paraCount: Int32 = 0

    var paras_limit: Array<Int32> = Array<Int32>(Int64(SIMPLE_PARAS_COUNT)) { _ => 0 }

    var paras_level: Array<UInt8> = Array<UInt8>(Int64(SIMPLE_PARAS_COUNT)) { _ => 0 }

    var runCount: Int32 = 0

    var runsMemory: Array<BidiRun> = Array<BidiRun>(0)

    var runs: Array<BidiRun>

    var simpleRuns: Array<BidiRun> = [BidiRun()]

    var isolates: Array<Bidi_Isolate>

    var isolateCount: Int32 = 0

    var logicalToVisualRunsMap: Array<Int32>

    var isGoodLogicalToVisualRunsMap: Bool = false

    var customClassifier: BidiClassifier

    var insertPoints: Bidi_InsertPoints = Bidi_InsertPoints()

    var controlCount: Int32 = 0

    static func DirPropFlag(dir: UInt8): Int32 {
        return (shl(1, Int32(dir)))
    }

    public func testDirPropFlagAt(flag: Int32, index: Int32): Bool {
        return ((DirPropFlag(dirProps[Int64(index)]) & flag) != 0)
    }

    static let DirPropFlagMultiRuns = DirPropFlag(31)

    static let DirPropFlagLR = [DirPropFlag(L), DirPropFlag(R)]

    static let DirPropFlagE = [DirPropFlag(LRE), DirPropFlag(RLE)]

    static let DirPropFlagO = [DirPropFlag(LRO), DirPropFlag(RLO)]

    static func DirPropFlagLRStatic(level: UInt8): Int32 {
        return DirPropFlagLR[Int64(Int32(level) & 1)]
    }

    static func DirPropFlagEStatic(level: UInt8): Int32 {
        return DirPropFlagE[Int64(Int32(level) & 1)]
    }

    static func DirPropFlagOStatic(level: UInt8): Int32 {
        return DirPropFlagO[Int64(Int32(level) & 1)]
    }

    static func DirFromStrong(strong: UInt8): UInt8 {
        return if (strong == L) { L } else { R }
    }

    static func NoOverride(level: UInt8): UInt8 {
        return UInt8(Int32(level) & )
    }

    static let MASK_LTR = DirPropFlag(L) | DirPropFlag(EN) | DirPropFlag(ENL) | DirPropFlag(ENR) | DirPropFlag(AN) | DirPropFlag(LRE) | DirPropFlag(LRO) | DirPropFlag(LRI)

    static let MASK_RTL = DirPropFlag(R) | DirPropFlag(AL) | DirPropFlag(RLE) | DirPropFlag(RLO) | DirPropFlag(RLI)

    static let MASK_R_AL = DirPropFlag(R) | DirPropFlag(AL)

    static let MASK_STRONG_EN_AN = DirPropFlag(L) | DirPropFlag(R) | DirPropFlag(AL) | DirPropFlag(EN) | DirPropFlag(AN)

    static let MASK_EXPLICIT = DirPropFlag(LRE) | DirPropFlag(LRO) | DirPropFlag(RLE) | DirPropFlag(RLO) | DirPropFlag(PDF)

    static let MASK_BN_EXPLICIT = DirPropFlag(BN) | MASK_EXPLICIT

    static let MASK_ISO = DirPropFlag(LRI) | DirPropFlag(RLI) | DirPropFlag(FSI) | DirPropFlag(PDI)

    static let MASK_B_S = DirPropFlag(B) | DirPropFlag(S)

    static let MASK_WS = MASK_B_S | DirPropFlag(WS) | MASK_BN_EXPLICIT | MASK_ISO

    static let MASK_POSSIBLE_N = DirPropFlag(ON) | DirPropFlag(CS) | DirPropFlag(ES) | DirPropFlag(ET) | MASK_WS

    static let MASK_EMBEDDING = DirPropFlag(NSM) | MASK_POSSIBLE_N

    static func GetLRFromLevel(level: UInt8): UInt8 {
        return UInt8(Int32(level) & 1)
    }

    static func IsDefaultLevel(level: UInt8): Bool {
        return ((level & LEVEL_DEFAULT_LTR) == Int32(LEVEL_DEFAULT_LTR))
    }

    static func IsBidiControlChar(c: Int32): Bool {
        return (((c & -4) == 8204) || ((c >= 8234) && (c <= 8238)) || ((c >= 8294) && (c <= 8297)))
    }

    public func verifyValidPara(): Unit {
        if (!(refEq(this, this.paraBidi))) {
            throw Exception()
        }
    }

    public func verifyValidParaOrLine(): Unit {
        let para = this.paraBidi
        if (refEq(this, para)) {
            return
        }
        if ((para.isNone()) || (!refEq(para, para.paraBidi))) {
            throw Exception()
        }
    }

    public func verifyRange(index: Int32, start: Int32, limit: Int32): Unit {
        if (index < start || index >= limit) {
            throw IllegalArgumentException("Value " + index.toString() + " is out of range " + start.toString() + " to " + limit.toString())
        }
    }

    public init() {
        this(0, 0)
    }

    public init(maxLength: Int32, maxRunCount: Int32) {
        if (maxLength < 0 || maxRunCount < 0) {
            throw IllegalArgumentException()
        }
        bdp = UBiDiProps.INSTANCE
        if (maxLength > 0) {
            getInitialDirPropsMemory(maxLength)
            getInitialLevelsMemory(maxLength)
        } else {
            mayAllocateText = true
        }
        if (maxRunCount > 0) {
            if (maxRunCount > 1) {
                getInitialRunsMemory(maxRunCount)
            }
        } else {
            mayAllocateRuns = true
        }
    }

    private func getMemory(label: String, array: Object, arrayClass: ClassTypeInfo, mayAllocate: Bool, sizeNeeded: Int32): Object {
        let len = Array.getLength(array)
        if (sizeNeeded == len) {
            return array
        }
        if (!mayAllocate) {
            if (sizeNeeded <= len) {
                return array
            }
            throw OutOfMemoryError("Failed to allocate memory for " + (label))
        }
        try {
            return Array.newInstance(arrayClass, sizeNeeded)
        } catch (e: Exception) {
            throw OutOfMemoryError("Failed to allocate memory for " + (label))
        }
    }

    private func getDirPropsMemory(mayAllocate: Bool, len: Int32): Unit {
        let array = getMemory("DirProps", dirPropsMemory, Int8.TYPE, mayAllocate, len)
        dirPropsMemory = array
    }

    public func getDirPropsMemory(len: Int32): Unit {
        getDirPropsMemory(mayAllocateText, len)
    }

    private func getLevelsMemory(mayAllocate: Bool, len: Int32): Unit {
        let array = getMemory("Levels", levelsMemory, Int8.TYPE, mayAllocate, len)
        levelsMemory = array
    }

    public func getLevelsMemory(len: Int32): Unit {
        getLevelsMemory(mayAllocateText, len)
    }

    private func getRunsMemory(mayAllocate: Bool, len: Int32): Unit {
        let array = getMemory("Runs", runsMemory, TypeInfo.of<BidiRun>() as ClassTypeInfo, mayAllocate, len)
        runsMemory = array
    }

    public func getRunsMemory(len: Int32): Unit {
        getRunsMemory(mayAllocateRuns, len)
    }

    private func getInitialDirPropsMemory(len: Int32): Unit {
        getDirPropsMemory(true, len)
    }

    private func getInitialLevelsMemory(len: Int32): Unit {
        getLevelsMemory(true, len)
    }

    private func getInitialRunsMemory(len: Int32): Unit {
        getRunsMemory(true, len)
    }

    public func setInverse(isInverse: Bool): Unit {
        this.isInverse = (isInverse)
        this.reorderingMode = if (isInverse) { Int32(REORDER_INVERSE_NUMBERS_AS_L) } else { Int32(REORDER_DEFAULT) }
    }

    public func isInverseMethod(): Bool {
        return isInverse
    }

    public func setReorderingMode(reorderingMode: Int32): Unit {
        if ((reorderingMode < Int32(REORDER_DEFAULT)) || (reorderingMode >= Int32(REORDER_COUNT))) {
            return
        }
        this.reorderingMode = reorderingMode
        this.isInverse = reorderingMode == Int32(REORDER_INVERSE_NUMBERS_AS_L)
    }

    public func getReorderingMode(): Int32 {
        return this.reorderingMode
    }

    public func setReorderingOptions(options: Int32): Unit {
        if ((options & OPTION_REMOVE_CONTROLS) != 0) {
            this.reorderingOptions = options & 
        } else {
            this.reorderingOptions = options
        }
    }

    public func getReorderingOptions(): Int32 {
        return this.reorderingOptions
    }

    public static func getBaseDirection(paragraph: String): UInt8 {
        if (paragraph.isNone() || paragraph.size == 0) {
            return NEUTRAL
        }
        let length = paragraph.size
        var c: Int32 = 0
        var direction: UInt8 = 0
        var i = 0
        while (i < length) {
            c = UCharacter.codePointAt(paragraph, i)
            direction = UCharacter.getDirectionality(c)
            if (Int32(direction) == UCharacterDirection.LEFT_TO_RIGHT) {
                return LTR
            } else if (Int32(direction) == UCharacterDirection.RIGHT_TO_LEFT || Int32(direction) == UCharacterDirection.RIGHT_TO_LEFT_ARABIC) {
                return RTL
            }
            i = UCharacter.offsetByCodePoints(paragraph, i, 1)
        }
        return NEUTRAL
    }

    private func firstL_R_AL(): UInt8 {
        var result = ON
        var i = 0
        while (i < Int32(prologue.size)) {
            let uchar = prologue.codePointAt(i)
            i += Character.charCount(uchar)
            let dirProp = UInt8(getCustomizedClass(uchar))
            if (result == ON) {
                if (dirProp == L || dirProp == R || dirProp == AL) {
                    result = dirProp
                }
            } else {
                if (dirProp == B) {
                    result = ON
                }
            }
        }
        return result
    }

    private func checkParaCount(): Unit {
        let saveLimits: Array<Int32>
        let saveLevels: Array<UInt8>
        let count = paraCount
        if (count <= Int32(paras_level.size)) {
            return
        }
        let oldLength = Int32(paras_level.size)
        saveLimits = paras_limit
        saveLevels = paras_level
        try {
            paras_limit = Array<Int32>(Int64(count * 2)) { _ => 0 }
            paras_level = Array<UInt8>(Int64(count * 2)) { _ => 0 }
        } catch (e: Exception) {
            throw OutOfMemoryError("Failed to allocate memory for paras")
        }
        arraycopy(saveLimits, 0, paras_limit, 0, Int64(oldLength))
        arraycopy(saveLevels, 0, paras_level, 0, Int64(oldLength))
    }

    static let NOT_SEEKING_STRONG = 0

    static let SEEKING_STRONG_FOR_PARA = 1

    static let SEEKING_STRONG_FOR_FSI = 2

    static let LOOKING_FOR_PDI = 3

    private func getDirProps(): Unit {
        var i = 0
        var i0: Int32 = 0
        var i1: Int32 = 0
        flags = 0
        var uchar: Int32 = 0
        var dirProp: UInt8 = 0
        var defaultParaLevel = 0u8
        let isDefaultLevel = IsDefaultLevel(paraLevel)
        let isDefaultLevelInverse = isDefaultLevel && (reorderingMode == Int32(REORDER_INVERSE_LIKE_DIRECT) || reorderingMode == Int32(REORDER_INVERSE_FOR_NUMBERS_SPECIAL))
        lastArabicPos = -1
        var controlCount = 0
        let removeBidiControls = (reorderingOptions & OPTION_REMOVE_CONTROLS) != 0
        var state: UInt8 = 0
        var lastStrong = ON
        let isolateStartStack = Array<Int32>(Int64(Int32(MAX_EXPLICIT_LEVEL) + 1)) { _ => 0 }
        let previousStateStack = Array<UInt8>(Int64(Int32(MAX_EXPLICIT_LEVEL) + 1)) { _ => 0 }
        var stackLast = -1
        if ((reorderingOptions & OPTION_STREAMING) != 0) {
            length = 0
        }
        defaultParaLevel = UInt8(Int32(paraLevel) & 1)
        if (isDefaultLevel) {
            paras_level[0] = defaultParaLevel
            lastStrong = defaultParaLevel
            if (prologue.isSome() && (match (0) { case _ => dirProp = firstL_R_AL(); dirProp }) != ON) {
                if (dirProp == L) {
                    paras_level[0] = 0
                } else {
                    paras_level[0] = 1
                }
                state = UInt8(NOT_SEEKING_STRONG)
            } else {
                state = UInt8(SEEKING_STRONG_FOR_PARA)
            }
        } else {
            paras_level[0] = paraLevel
            state = UInt8(NOT_SEEKING_STRONG)
        }
        i = 0
        while (i < originalLength) {
            i0 = i
            uchar = UTF16.toRuneArray()[text, 0, originalLength, i]
            i += UTF16.getCharCount(uchar)
            i1 = i - 1
            dirProp = UInt8(getCustomizedClass(uchar))
            flags |= DirPropFlag(dirProp)
            dirProps[Int64(i1)] = dirProp
            if (i1 > i0) {
                flags |= DirPropFlag(BN)
            }
            if (removeBidiControls && IsBidiControlChar(uchar)) {
                controlCount++
            }
            if (dirProp == L) {
                if (Int32(state) == SEEKING_STRONG_FOR_PARA) {
                    paras_level[Int64(paraCount - 1)] = 0
                    state = UInt8(NOT_SEEKING_STRONG)
                } else if (Int32(state) == SEEKING_STRONG_FOR_FSI) {
                    if (stackLast <= Int32(MAX_EXPLICIT_LEVEL)) {
                        flags |= DirPropFlag(LRI)
                    }
                    state = UInt8(LOOKING_FOR_PDI)
                }
                lastStrong = L
                continue
            }
            if (dirProp == R || dirProp == AL) {
                if (Int32(state) == SEEKING_STRONG_FOR_PARA) {
                    paras_level[Int64(paraCount - 1)] = 1
                    state = UInt8(NOT_SEEKING_STRONG)
                } else if (Int32(state) == SEEKING_STRONG_FOR_FSI) {
                    if (stackLast <= Int32(MAX_EXPLICIT_LEVEL)) {
                        dirProps[Int64(isolateStartStack[Int64(stackLast)])] = RLI
                        flags |= DirPropFlag(RLI)
                    }
                    state = UInt8(LOOKING_FOR_PDI)
                }
                lastStrong = R
                if (dirProp == AL) {
                    lastArabicPos = i - 1
                }
                continue
            }
            if (dirProp >= FSI && dirProp <= RLI) {
                stackLast++
                if (stackLast <= Int32(MAX_EXPLICIT_LEVEL)) {
                    isolateStartStack[Int64(stackLast)] = i - 1
                    previousStateStack[Int64(stackLast)] = state
                }
                if (dirProp == FSI) {
                    dirProps[Int64(i - 1)] = LRI
                    state = UInt8(SEEKING_STRONG_FOR_FSI)
                } else {
                    state = UInt8(LOOKING_FOR_PDI)
                }
                continue
            }
            if (dirProp == PDI) {
                if (Int32(state) == SEEKING_STRONG_FOR_FSI) {
                    if (stackLast <= Int32(MAX_EXPLICIT_LEVEL)) {
                        flags |= DirPropFlag(LRI)
                    }
                }
                if (stackLast >= 0) {
                    if (stackLast <= Int32(MAX_EXPLICIT_LEVEL)) {
                        state = previousStateStack[Int64(stackLast)]
                    }
                    stackLast--
                }
                continue
            }
            if (dirProp == B) {
                if (i < originalLength && uchar == Int32(UInt32(CR)) && text[Int64(i)] == LF) {
                    continue
                }
                paras_limit[Int64(paraCount - 1)] = i
                if (isDefaultLevelInverse && lastStrong == R) {
                    paras_level[Int64(paraCount - 1)] = 1
                }
                if ((reorderingOptions & OPTION_STREAMING) != 0) {
                    length = i
                    this.controlCount = controlCount
                }
                if (i < originalLength) {
                    paraCount++
                    checkParaCount()
                    if (isDefaultLevel) {
                        paras_level[Int64(paraCount - 1)] = defaultParaLevel
                        state = UInt8(SEEKING_STRONG_FOR_PARA)
                        lastStrong = defaultParaLevel
                    } else {
                        paras_level[Int64(paraCount - 1)] = paraLevel
                        state = UInt8(NOT_SEEKING_STRONG)
                    }
                    stackLast = -1
                }
                continue
            }
        }
        if (stackLast > Int32(MAX_EXPLICIT_LEVEL)) {
            stackLast = Int32(MAX_EXPLICIT_LEVEL)
            state = UInt8(SEEKING_STRONG_FOR_FSI)
        }
        while (stackLast >= 0) {
            if (Int32(state) == SEEKING_STRONG_FOR_FSI) {
                flags |= DirPropFlag(LRI)
                break
            }
            state = previousStateStack[Int64(stackLast)]
            stackLast--
        }
        if ((reorderingOptions & OPTION_STREAMING) != 0) {
            if (length < originalLength) {
                paraCount--
            }
        } else {
            paras_limit[Int64(paraCount - 1)] = originalLength
            this.controlCount = controlCount
        }
        if (isDefaultLevelInverse && lastStrong == R) {
            paras_level[Int64(paraCount - 1)] = 1
        }
        if (isDefaultLevel) {
            paraLevel = paras_level[0]
        }
        i = 0
        while (i < paraCount) {
            flags |= DirPropFlagLRStatic(paras_level[Int64(i)])
            i++
        }
        if (orderParagraphsLTR && (flags & DirPropFlag(B)) != 0) {
            flags |= DirPropFlag(L)
        }
    }

    public func GetParaLevelAt(pindex: Int32): UInt8 {
        if (Int32(defaultParaLevel) == 0 || pindex < paras_limit[0]) {
            return paraLevel
        }
        var i: Int32 = 0
        i = 1
        while (i < paraCount) {
            if (pindex < paras_limit[Int64(i)]) {
                break
            }
            i++
        }
        if (i >= paraCount) {
            i = paraCount - 1
        }
        return paras_level[Int64(i)]
    }

    private func bracketInit(bd: Bidi_BracketData): Unit {
        bd.isoRunLast = 0
        bd.isoRuns[0] = Bidi_IsoRun()
        bd.isoRuns[0].start = 0i16
        bd.isoRuns[0].limit = 0i16
        bd.isoRuns[0].level = GetParaLevelAt(0)
        bd.isoRuns[0].lastStrong = match (0) { case _ => bd.isoRuns[0].lastBase = match (0) { case _ => bd.isoRuns[0].contextDir = UInt8(Int32(GetParaLevelAt(0)) & 1); bd.isoRuns[0].contextDir }; bd.isoRuns[0].lastBase }
        bd.isoRuns[0].contextPos = 0
        bd.openings = Array<Bidi_Opening>(Int64(SIMPLE_OPENINGS_COUNT))
        bd.isNumbersSpecial = reorderingMode == Int32(REORDER_NUMBERS_SPECIAL) || reorderingMode == Int32(REORDER_INVERSE_FOR_NUMBERS_SPECIAL)
    }

    private func bracketProcessB(bd: Bidi_BracketData, level: UInt8): Unit {
        bd.isoRunLast = 0
        bd.isoRuns[0].limit = 0i16
        bd.isoRuns[0].level = level
        bd.isoRuns[0].lastStrong = match (0) { case _ => bd.isoRuns[0].lastBase = match (0) { case _ => bd.isoRuns[0].contextDir = UInt8(Int32(level) & 1); bd.isoRuns[0].contextDir }; bd.isoRuns[0].lastBase }
        bd.isoRuns[0].contextPos = 0
    }

    private func bracketProcessBoundary(bd: Bidi_BracketData, lastCcPos: Int32, contextLevel: UInt8, embeddingLevel: UInt8): Unit {
        var tempcontextLevel = contextLevel
        let pLastIsoRun = bd.isoRuns[Int64(bd.isoRunLast)]
        if ((DirPropFlag(dirProps[Int64(lastCcPos)]) & MASK_ISO) != 0) {
            return
        }
        if (NoOverride(embeddingLevel) > NoOverride(tempcontextLevel)) {
            tempcontextLevel = embeddingLevel
        }
        pLastIsoRun.limit = pLastIsoRun.start
        pLastIsoRun.level = embeddingLevel
        pLastIsoRun.lastStrong = match (0) { case _ => pLastIsoRun.lastBase = match (0) { case _ => pLastIsoRun.contextDir = UInt8(Int32(tempcontextLevel) & 1); pLastIsoRun.contextDir }; pLastIsoRun.lastBase }
        pLastIsoRun.contextPos = lastCcPos
    }

    private func bracketProcessLRI_RLI(bd: Bidi_BracketData, level: UInt8): Unit {
        var pLastIsoRun = bd.isoRuns[Int64(bd.isoRunLast)]
        let lastLimit: Int16
        pLastIsoRun.lastBase = ON
        lastLimit = pLastIsoRun.limit
        bd.isoRunLast++
        pLastIsoRun = bd.isoRuns[Int64(bd.isoRunLast)]
        if (pLastIsoRun.isNone()) {
            pLastIsoRun = match (0) { case _ => bd.isoRuns[Int64(bd.isoRunLast)] = Bidi_IsoRun(); bd.isoRuns[Int64(bd.isoRunLast)] }
        }
        pLastIsoRun.start = match (0) { case _ => pLastIsoRun.limit = lastLimit; pLastIsoRun.limit }
        pLastIsoRun.level = level
        pLastIsoRun.lastStrong = match (0) { case _ => pLastIsoRun.lastBase = match (0) { case _ => pLastIsoRun.contextDir = UInt8(Int32(level) & 1); pLastIsoRun.contextDir }; pLastIsoRun.lastBase }
        pLastIsoRun.contextPos = 0
    }

    private func bracketProcessPDI(bd: Bidi_BracketData): Unit {
        let pLastIsoRun: Bidi_IsoRun
        bd.isoRunLast--
        pLastIsoRun = bd.isoRuns[Int64(bd.isoRunLast)]
        pLastIsoRun.lastBase = ON
    }

    private func bracketAddOpening(bd: Bidi_BracketData, match: Char, position: Int32): Unit {
        let pLastIsoRun = bd.isoRuns[Int64(bd.isoRunLast)]
        var pOpening: Bidi_Opening
        if (Int32(pLastIsoRun.limit) >= Int32(bd.openings.size)) {
            let saveOpenings = bd.openings
            let count: Int32
            try {
                count = Int32(bd.openings.size)
                bd.openings = Array<Bidi_Opening>(Int64(count * 2))
            } catch (e: Exception) {
                throw OutOfMemoryError("Failed to allocate memory for openings")
            }
            arraycopy(saveOpenings, 0, bd.openings, 0, Int64(count))
        }
        pOpening = bd.openings[Int64(pLastIsoRun.limit)]
        if (pOpening.isNone()) {
            pOpening = match (0) { case _ => bd.openings[Int64(pLastIsoRun.limit)] = Bidi_Opening(); bd.openings[Int64(pLastIsoRun.limit)] }
        }
        pOpening.position = position
        pOpening.match = Int32(UInt32(match))
        pOpening.contextDir = pLastIsoRun.contextDir
        pOpening.contextPos = pLastIsoRun.contextPos
        pOpening.flags = 0i16
        pLastIsoRun.limit++
    }

    private func fixN0c(bd: Bidi_BracketData, openingIndex: Int32, newPropPosition: Int32, newProp: UInt8): Unit {
        let pLastIsoRun = bd.isoRuns[Int64(bd.isoRunLast)]
        var qOpening: Bidi_Opening
        var k: Int32 = 0
        var openingPosition: Int32 = 0
        var closingPosition: Int32 = 0
        k = openingIndex + 1
        while (k < Int32(pLastIsoRun.limit)) {
            qOpening = bd.openings[Int64(k)]
            if (qOpening.match >= 0) {
                continue
            }
            if (newPropPosition < qOpening.contextPos) {
                break
            }
            if (newPropPosition >= qOpening.position) {
                continue
            }
            if (newProp == qOpening.contextDir) {
                break
            }
            openingPosition = qOpening.position
            dirProps[Int64(openingPosition)] = newProp
            closingPosition = -(qOpening.match)
            dirProps[Int64(closingPosition)] = newProp
            qOpening.match = 0
            fixN0c(bd, k, openingPosition, newProp)
            fixN0c(bd, k, closingPosition, newProp)
            k++
        }
    }

    private func bracketProcessClosing(bd: Bidi_BracketData, openIdx: Int32, position: Int32): UInt8 {
        let pLastIsoRun = bd.isoRuns[Int64(bd.isoRunLast)]
        let pOpening: Bidi_Opening
        var qOpening: Bidi_Opening
        let direction: UInt8
        var stable: Bool = false
        let newProp: UInt8
        pOpening = bd.openings[Int64(openIdx)]
        direction = UInt8(Int32(pLastIsoRun.level) & 1)
        stable = true
        if ((Int32(direction) == 0 && (Int32(pOpening.flags) & Int32(FOUND_L)) > 0) || (Int32(direction) == 1 && (Int32(pOpening.flags) & Int32(FOUND_R)) > 0)) {
            newProp = direction
        } else if ((Int32(pOpening.flags) & (FOUND_L | FOUND_R)) != 0) {
            stable = (openIdx == Int32(pLastIsoRun.start))
            if (direction != pOpening.contextDir) {
                newProp = pOpening.contextDir
            } else {
                newProp = direction
            }
        } else {
            pLastIsoRun.limit = Int16(openIdx)
            return ON
        }
        dirProps[Int64(pOpening.position)] = newProp
        dirProps[Int64(position)] = newProp
        fixN0c(bd, openIdx, pOpening.position, newProp)
        if (stable) {
            pLastIsoRun.limit = Int16(openIdx)
            while (pLastIsoRun.limit > pLastIsoRun.start && bd.openings[Int64(Int32(pLastIsoRun.limit) - 1)].position == pOpening.position) {
                pLastIsoRun.limit--
            }
        } else {
            var k: Int32 = 0
            pOpening.match = -position
            k = openIdx - 1
            while (k >= Int32(pLastIsoRun.start) && bd.openings[Int64(k)].position == pOpening.position) {
                bd.openings[Int64(match (0) { case _ => k--; k + 1 })].match = 0
            }
            k = openIdx + 1
            while (k < Int32(pLastIsoRun.limit)) {
                qOpening = bd.openings[Int64(k)]
                if (qOpening.position >= position) {
                    break
                }
                if (qOpening.match > 0) {
                    qOpening.match = 0
                }
                k++
            }
        }
        return newProp
    }

    private func bracketProcessChar(bd: Bidi_BracketData, position: Int32): Unit {
        let pLastIsoRun = bd.isoRuns[Int64(bd.isoRunLast)]
        let dirProp: UInt8
        var newProp: UInt8 = 0
        let level: UInt8
        dirProp = dirProps[Int64(position)]
        if (dirProp == ON) {
            var c: Char = '\u{0000}'
            let match: Char
            var idx: Int32 = 0
            c = text[Int64(position)]
            idx = Int32(pLastIsoRun.limit) - 1
            while (idx >= Int32(pLastIsoRun.start)) {
                if (bd.openings[Int64(idx)].match != Int32(UInt32(c))) {
                    continue
                }
                newProp = bracketProcessClosing(bd, idx, position)
                if (newProp == ON) {
                    c = Char(0)
                    break
                }
                pLastIsoRun.lastBase = ON
                pLastIsoRun.contextDir = newProp
                pLastIsoRun.contextPos = position
                level = levels[Int64(position)]
                if ((level & LEVEL_OVERRIDE) != 0) {
                    let flag: Int16
                    var i: Int32 = 0
                    newProp = UInt8(Int32(level) & 1)
                    pLastIsoRun.lastStrong = newProp
                    flag = Int16(DirPropFlag(newProp))
                    i = Int32(pLastIsoRun.start)
                    while (i < idx) {
                        bd.openings[Int64(i)].flags |= flag
                        i++
                    }
                    levels[Int64(position)] &= 
                }
                levels[Int64(bd.openings[Int64(idx)].position)] &= 
                return
                idx--
            }
            if (Int32(UInt32(c)) != 0) {
                match = Char(UCharacter.getBidiPairedBracket(Int32(UInt32(c))))
            } else {
                match = Char(0)
            }
            if (match != c && UCharacter.getIntPropertyValue(Int32(UInt32(c)), UProperty.BIDI_PAIRED_BRACKET_TYPE) == UCharacter_BidiPairedBracketType.OPEN) {
                if (Int32(UInt32(match)) == 9002) {
                    bracketAddOpening(bd, Char(12297), position)
                } else if (Int32(UInt32(match)) == 12297) {
                    bracketAddOpening(bd, Char(9002), position)
                }
                bracketAddOpening(bd, match, position)
            }
        }
        level = levels[Int64(position)]
        if ((level & LEVEL_OVERRIDE) != 0) {
            newProp = UInt8(Int32(level) & 1)
            if (dirProp != S && dirProp != WS && dirProp != ON) {
                dirProps[Int64(position)] = newProp
            }
            pLastIsoRun.lastBase = newProp
            pLastIsoRun.lastStrong = newProp
            pLastIsoRun.contextDir = newProp
            pLastIsoRun.contextPos = position
        } else if (dirProp <= R || dirProp == AL) {
            newProp = DirFromStrong(dirProp)
            pLastIsoRun.lastBase = dirProp
            pLastIsoRun.lastStrong = dirProp
            pLastIsoRun.contextDir = newProp
            pLastIsoRun.contextPos = position
        } else if (dirProp == EN) {
            pLastIsoRun.lastBase = EN
            if (pLastIsoRun.lastStrong == L) {
                newProp = L
                if (!bd.isNumbersSpecial) {
                    dirProps[Int64(position)] = ENL
                }
                pLastIsoRun.contextDir = L
                pLastIsoRun.contextPos = position
            } else {
                newProp = R
                if (pLastIsoRun.lastStrong == AL) {
                    dirProps[Int64(position)] = AN
                } else {
                    dirProps[Int64(position)] = ENR
                }
                pLastIsoRun.contextDir = R
                pLastIsoRun.contextPos = position
            }
        } else if (dirProp == AN) {
            newProp = R
            pLastIsoRun.lastBase = AN
            pLastIsoRun.contextDir = R
            pLastIsoRun.contextPos = position
        } else if (dirProp == NSM) {
            newProp = pLastIsoRun.lastBase
            if (newProp == ON) {
                dirProps[Int64(position)] = newProp
            }
        } else {
            newProp = dirProp
            pLastIsoRun.lastBase = dirProp
        }
        if (newProp <= R || newProp == AL) {
            var i: Int32 = 0
            let flag = Int16(DirPropFlag(DirFromStrong(newProp)))
            i = Int32(pLastIsoRun.start)
            while (i < Int32(pLastIsoRun.limit)) {
                if (position > bd.openings[Int64(i)].position) {
                    bd.openings[Int64(i)].flags |= flag
                }
                i++
            }
        }
    }

    private func directionFromFlags(): UInt8 {
        if (!((flags & MASK_RTL) != 0 || ((flags & DirPropFlag(AN)) != 0 && (flags & MASK_POSSIBLE_N) != 0))) {
            return LTR
        } else if ((flags & MASK_LTR) == 0) {
            return RTL
        } else {
            return MIXED
        }
    }

    private func resolveExplicitLevels(): UInt8 {
        var i = 0
        var dirProp: UInt8 = 0
        var level = GetParaLevelAt(0)
        var dirct: UInt8 = 0
        isolateCount = 0
        dirct = directionFromFlags()
        if (dirct != MIXED) {
            return dirct
        }
        if (reorderingMode > Int32(REORDER_LAST_LOGICAL_TO_VISUAL)) {
            var paraIndex: Int32 = 0
            var start: Int32 = 0
            var limit: Int32 = 0
            paraIndex = 0
            while (paraIndex < paraCount) {
                if (paraIndex == 0) {
                    start = 0
                } else {
                    start = paras_limit[Int64(paraIndex - 1)]
                }
                limit = paras_limit[Int64(paraIndex)]
                level = paras_level[Int64(paraIndex)]
                i = start
                while (i < limit) {
                    levels[Int64(i)] = level
                    i++
                }
                paraIndex++
            }
            return dirct
        }
        if ((flags & (MASK_EXPLICIT | MASK_ISO)) == 0) {
            var paraIndex: Int32 = 0
            var start: Int32 = 0
            var limit: Int32 = 0
            let bracketData = Bidi_BracketData()
            bracketInit(bracketData)
            paraIndex = 0
            while (paraIndex < paraCount) {
                if (paraIndex == 0) {
                    start = 0
                } else {
                    start = paras_limit[Int64(paraIndex - 1)]
                }
                limit = paras_limit[Int64(paraIndex)]
                level = paras_level[Int64(paraIndex)]
                i = start
                while (i < limit) {
                    levels[Int64(i)] = level
                    dirProp = dirProps[Int64(i)]
                    if (dirProp == BN) {
                        continue
                    }
                    if (dirProp == B) {
                        if ((i + 1) < length) {
                            if (text[Int64(i)] == CR && text[Int64(i + 1)] == LF) {
                                continue
                            }
                            bracketProcessB(bracketData, level)
                        }
                        continue
                    }
                    bracketProcessChar(bracketData, i)
                    i++
                }
                paraIndex++
            }
            return dirct
        }
        var embeddingLevel = level
        var newLevel: UInt8 = 0
        var previousLevel = level
        var lastCcPos = 0
        let stack = Array<Int16>(Int64(Int32(MAX_EXPLICIT_LEVEL) + 2)) { _ => 0 }
        var stackLast = 0
        var overflowIsolateCount = 0
        var overflowEmbeddingCount = 0
        var validIsolateCount = 0
        let bracketData = Bidi_BracketData()
        bracketInit(bracketData)
        stack[0] = Int16(level)
        flags = 0
        i = 0
        while (i < length) {
            dirProp = dirProps[Int64(i)]
            match (dirProp) {
                case 11u8 | 14u8 | 12u8 | 15u8 =>
                    flags |= DirPropFlag(BN)
                    levels[Int64(i)] = previousLevel
                    if (dirProp == LRE || dirProp == LRO) {
                        newLevel = UInt8((Int32(embeddingLevel) + 2) & )
                    } else {
                        newLevel = UInt8((Int32(NoOverride(embeddingLevel)) + 1) | 1)
                    }
                    if (newLevel <= MAX_EXPLICIT_LEVEL && overflowIsolateCount == 0 && overflowEmbeddingCount == 0) {
                        lastCcPos = i
                        embeddingLevel = newLevel
                        if (dirProp == LRO || dirProp == RLO) {
                            embeddingLevel |= LEVEL_OVERRIDE
                        }
                        stackLast++
                        stack[Int64(stackLast)] = Int16(embeddingLevel)
                    } else {
                        if (overflowIsolateCount == 0) {
                            overflowEmbeddingCount++
                        }
                    }
                case 16u8 =>
                    flags |= DirPropFlag(BN)
                    levels[Int64(i)] = previousLevel
                    if (overflowIsolateCount > 0) {
                        break
                    }
                    if (overflowEmbeddingCount > 0) {
                        overflowEmbeddingCount--
                        break
                    }
                    if (stackLast > 0 && Int32(stack[Int64(stackLast)]) < ISOLATE) {
                        lastCcPos = i
                        stackLast--
                        embeddingLevel = UInt8(stack[Int64(stackLast)])
                    }
                case 20u8 | 21u8 =>
                    flags |= DirPropFlag(ON) | DirPropFlagLRStatic(embeddingLevel)
                    levels[Int64(i)] = NoOverride(embeddingLevel)
                    if (NoOverride(embeddingLevel) != NoOverride(previousLevel)) {
                        bracketProcessBoundary(bracketData, lastCcPos, previousLevel, embeddingLevel)
                        flags |= DirPropFlagMultiRuns
                    }
                    previousLevel = embeddingLevel
                    if (dirProp == LRI) {
                        newLevel = UInt8((Int32(embeddingLevel) + 2) & )
                    } else {
                        newLevel = UInt8((Int32(NoOverride(embeddingLevel)) + 1) | 1)
                    }
                    if (newLevel <= MAX_EXPLICIT_LEVEL && overflowIsolateCount == 0 && overflowEmbeddingCount == 0) {
                        flags |= DirPropFlag(dirProp)
                        lastCcPos = i
                        validIsolateCount++
                        if (validIsolateCount > isolateCount) {
                            isolateCount = validIsolateCount
                        }
                        embeddingLevel = newLevel
                        stackLast++
                        stack[Int64(stackLast)] = Int16(Int32(embeddingLevel) + ISOLATE)
                        bracketProcessLRI_RLI(bracketData, embeddingLevel)
                    } else {
                        dirProps[Int64(i)] = WS
                        overflowIsolateCount++
                    }
                case 22u8 =>
                    if (NoOverride(embeddingLevel) != NoOverride(previousLevel)) {
                        bracketProcessBoundary(bracketData, lastCcPos, previousLevel, embeddingLevel)
                        flags |= DirPropFlagMultiRuns
                    }
                    if (overflowIsolateCount > 0) {
                        overflowIsolateCount--
                        dirProps[Int64(i)] = WS
                    } else if (validIsolateCount > 0) {
                        flags |= DirPropFlag(PDI)
                        lastCcPos = i
                        overflowEmbeddingCount = 0
                        while (Int32(stack[Int64(stackLast)]) < ISOLATE) {
                            stackLast--
                        }
                        stackLast--
                        validIsolateCount--
                        bracketProcessPDI(bracketData)
                    } else {
                        dirProps[Int64(i)] = WS
                    }
                    embeddingLevel = UInt8(Int32(stack[Int64(stackLast)]) & )
                    flags |= DirPropFlag(ON) | DirPropFlagLRStatic(embeddingLevel)
                    previousLevel = embeddingLevel
                    levels[Int64(i)] = NoOverride(embeddingLevel)
                case 7u8 =>
                    flags |= DirPropFlag(B)
                    levels[Int64(i)] = GetParaLevelAt(i)
                    if ((i + 1) < length) {
                        if (text[Int64(i)] == CR && text[Int64(i + 1)] == LF) {
                            break
                        }
                        overflowEmbeddingCount = match (0) { case _ => overflowIsolateCount = 0; overflowIsolateCount }
                        validIsolateCount = 0
                        stackLast = 0
                        previousLevel = match (0) { case _ => embeddingLevel = GetParaLevelAt(i + 1); embeddingLevel }
                        stack[0] = Int16(embeddingLevel)
                        bracketProcessB(bracketData, embeddingLevel)
                    }
                case 18u8 =>
                    levels[Int64(i)] = previousLevel
                    flags |= DirPropFlag(BN)
                case _ =>
                    if (NoOverride(embeddingLevel) != NoOverride(previousLevel)) {
                        bracketProcessBoundary(bracketData, lastCcPos, previousLevel, embeddingLevel)
                        flags |= DirPropFlagMultiRuns
                        if ((embeddingLevel & LEVEL_OVERRIDE) != 0) {
                            flags |= DirPropFlagOStatic(embeddingLevel)
                        } else {
                            flags |= DirPropFlagEStatic(embeddingLevel)
                        }
                    }
                    previousLevel = embeddingLevel
                    levels[Int64(i)] = embeddingLevel
                    bracketProcessChar(bracketData, i)
                    flags |= DirPropFlag(dirProps[Int64(i)])
            }
            i++
        }
        if ((flags & MASK_EMBEDDING) != 0) {
            flags |= DirPropFlagLRStatic(paraLevel)
        }
        if (orderParagraphsLTR && (flags & DirPropFlag(B)) != 0) {
            flags |= DirPropFlag(L)
        }
        dirct = directionFromFlags()
        return dirct
    }

    private func checkExplicitLevels(): UInt8 {
        var isolateCount = 0
        this.flags = 0
        this.isolateCount = 0
        var currentParaIndex = 0
        var currentParaLimit = paras_limit[0]
        var currentParaLevel = paraLevel
        var i = 0
        while (i < length) {
            var level = levels[Int64(i)]
            let dirProp = dirProps[Int64(i)]
            if (dirProp == LRI || dirProp == RLI) {
                isolateCount++
                if (isolateCount > this.isolateCount) {
                    this.isolateCount = isolateCount
                }
            } else if (dirProp == PDI) {
                isolateCount--
            } else if (dirProp == B) {
                isolateCount = 0
            }
            if (Int32(defaultParaLevel) != 0 && i == currentParaLimit && (currentParaIndex + 1) < paraCount) {
                currentParaLevel = paras_level[Int64(match (0) { case _ => currentParaIndex++; currentParaIndex })]
                currentParaLimit = paras_limit[Int64(currentParaIndex)]
            }
            let overrideFlag = level & LEVEL_OVERRIDE
            level &= 
            if (level < currentParaLevel || MAX_EXPLICIT_LEVEL < level) {
                if (Int32(level) == 0) {
                    if (dirProp == B) { } else {
                        level = currentParaLevel
                        levels[Int64(i)] = UInt8(Int32(level) | overrideFlag)
                    }
                } else {
                    throw IllegalArgumentException("level " + level.toString() + " out of bounds at " + i.toString())
                }
            }
            if (overrideFlag != 0) {
                flags |= DirPropFlagOStatic(level)
            } else {
                flags |= DirPropFlagEStatic(level) | DirPropFlag(dirProp)
            }
            i++
        }
        if ((flags & MASK_EMBEDDING) != 0) {
            flags |= DirPropFlagLRStatic(paraLevel)
        }
        return directionFromFlags()
    }

    private static let IMPTABPROPS_COLUMNS = 16

    private static let IMPTABPROPS_RES = IMPTABPROPS_COLUMNS - 1

    private static func GetStateProps(cell: Int16): Int16 {
        return Int16(Int32(cell) & 31)
    }

    private static func GetActionProps(cell: Int16): Int16 {
        return Int16(shr(Int32(cell), 5))
    }

    private static let groupProp: Array<Int16> = [0i16, 1i16, 2i16, 7i16, 8i16, 3i16, 9i16, 6i16, 5i16, 4i16, 4i16, 10i16, 10i16, 12i16, 10i16, 10i16, 10i16, 11i16, 10i16, 4i16, 4i16, 4i16, 4i16, 13i16, 14i16]

    private static let _L = 0i16

    private static let _R = 1i16

    private static let _EN = 2i16

    private static let _AN = 3i16

    private static let _ON = 4i16

    private static let _S = 5i16

    private static let _B = 6i16

    private static let impTabProps: Array<Array<Int16>> = [[1i16, 2i16, 4i16, 5i16, 7i16, 15i16, 17i16, 7i16, 9i16, 7i16, 0i16, 7i16, 3i16, 18i16, 21i16, _ON], [1i16, Int16(32 + 2), Int16(32 + 4), Int16(32 + 5), Int16(32 + 7), Int16(32 + 15), Int16(32 + 17), Int16(32 + 7), Int16(32 + 9), Int16(32 + 7), 1i16, 1i16, Int16(32 + 3), Int16(32 + 18), Int16(32 + 21), _L], [Int16(32 + 1), 2i16, Int16(32 + 4), Int16(32 + 5), Int16(32 + 7), Int16(32 + 15), Int16(32 + 17), Int16(32 + 7), Int16(32 + 9), Int16(32 + 7), 2i16, 2i16, Int16(32 + 3), Int16(32 + 18), Int16(32 + 21), _R], [Int16(32 + 1), Int16(32 + 2), Int16(32 + 6), Int16(32 + 6), Int16(32 + 8), Int16(32 + 16), Int16(32 + 17), Int16(32 + 8), Int16(32 + 8), Int16(32 + 8), 3i16, 3i16, 3i16, Int16(32 + 18), Int16(32 + 21), _R], [Int16(32 + 1), Int16(32 + 2), 4i16, Int16(32 + 5), Int16(32 + 7), Int16(32 + 15), Int16(32 + 17), Int16(64 + 10), 11i16, Int16(64 + 10), 4i16, 4i16, Int16(32 + 3), 18i16, 21i16, _EN], [Int16(32 + 1), Int16(32 + 2), Int16(32 + 4), 5i16, Int16(32 + 7), Int16(32 + 15), Int16(32 + 17), Int16(32 + 7), Int16(32 + 9), Int16(64 + 12), 5i16, 5i16, Int16(32 + 3), Int16(32 + 18), Int16(32 + 21), _AN], [Int16(32 + 1), Int16(32 + 2), 6i16, 6i16, Int16(32 + 8), Int16(32 + 16), Int16(32 + 17), Int16(32 + 8), Int16(32 + 8), Int16(64 + 13), 6i16, 6i16, Int16(32 + 3), 18i16, 21i16, _AN], [Int16(32 + 1), Int16(32 + 2), Int16(32 + 4), Int16(32 + 5), 7i16, Int16(32 + 15), Int16(32 + 17), 7i16, Int16(64 + 14), 7i16, 7i16, 7i16, Int16(32 + 3), Int16(32 + 18), Int16(32 + 21), _ON], [Int16(32 + 1), Int16(32 + 2), Int16(32 + 6), Int16(32 + 6), 8i16, Int16(32 + 16), Int16(32 + 17), 8i16, 8i16, 8i16, 8i16, 8i16, Int16(32 + 3), Int16(32 + 18), Int16(32 + 21), _ON], [Int16(32 + 1), Int16(32 + 2), 4i16, Int16(32 + 5), 7i16, Int16(32 + 15), Int16(32 + 17), 7i16, 9i16, 7i16, 9i16, 9i16, Int16(32 + 3), 18i16, 21i16, _ON], [Int16(96 + 1), Int16(96 + 2), 4i16, Int16(96 + 5), Int16(128 + 7), Int16(96 + 15), Int16(96 + 17), Int16(128 + 7), Int16(128 + 14), Int16(128 + 7), 10i16, Int16(128 + 7), Int16(96 + 3), 18i16, 21i16, _EN], [Int16(32 + 1), Int16(32 + 2), 4i16, Int16(32 + 5), Int16(32 + 7), Int16(32 + 15), Int16(32 + 17), Int16(32 + 7), 11i16, Int16(32 + 7), 11i16, 11i16, Int16(32 + 3), 18i16, 21i16, _EN], [Int16(96 + 1), Int16(96 + 2), Int16(96 + 4), 5i16, Int16(128 + 7), Int16(96 + 15), Int16(96 + 17), Int16(128 + 7), Int16(128 + 14), Int16(128 + 7), 12i16, Int16(128 + 7), Int16(96 + 3), Int16(96 + 18), Int16(96 + 21), _AN], [Int16(96 + 1), Int16(96 + 2), 6i16, 6i16, Int16(128 + 8), Int16(96 + 16), Int16(96 + 17), Int16(128 + 8), Int16(128 + 8), Int16(128 + 8), 13i16, Int16(128 + 8), Int16(96 + 3), 18i16, 21i16, _AN], [Int16(32 + 1), Int16(32 + 2), Int16(128 + 4), Int16(32 + 5), 7i16, Int16(32 + 15), Int16(32 + 17), 7i16, 14i16, 7i16, 14i16, 14i16, Int16(32 + 3), Int16(128 + 18), Int16(128 + 21), _ON], [Int16(32 + 1), Int16(32 + 2), Int16(32 + 4), Int16(32 + 5), Int16(32 + 7), 15i16, Int16(32 + 17), Int16(32 + 7), Int16(32 + 9), Int16(32 + 7), 15i16, Int16(32 + 7), Int16(32 + 3), Int16(32 + 18), Int16(32 + 21), _S], [Int16(32 + 1), Int16(32 + 2), Int16(32 + 6), Int16(32 + 6), Int16(32 + 8), 16i16, Int16(32 + 17), Int16(32 + 8), Int16(32 + 8), Int16(32 + 8), 16i16, Int16(32 + 8), Int16(32 + 3), Int16(32 + 18), Int16(32 + 21), _S], [Int16(32 + 1), Int16(32 + 2), Int16(32 + 4), Int16(32 + 5), Int16(32 + 7), Int16(32 + 15), 17i16, Int16(32 + 7), Int16(32 + 9), Int16(32 + 7), 17i16, Int16(32 + 7), Int16(32 + 3), Int16(32 + 18), Int16(32 + 21), _B], [Int16(32 + 1), Int16(32 + 2), 18i16, Int16(32 + 5), Int16(32 + 7), Int16(32 + 15), Int16(32 + 17), Int16(64 + 19), 20i16, Int16(64 + 19), 18i16, 18i16, Int16(32 + 3), 18i16, 21i16, _L], [Int16(96 + 1), Int16(96 + 2), 18i16, Int16(96 + 5), Int16(128 + 7), Int16(96 + 15), Int16(96 + 17), Int16(128 + 7), Int16(128 + 14), Int16(128 + 7), 19i16, Int16(128 + 7), Int16(96 + 3), 18i16, 21i16, _L], [Int16(32 + 1), Int16(32 + 2), 18i16, Int16(32 + 5), Int16(32 + 7), Int16(32 + 15), Int16(32 + 17), Int16(32 + 7), 20i16, Int16(32 + 7), 20i16, 20i16, Int16(32 + 3), 18i16, 21i16, _L], [Int16(32 + 1), Int16(32 + 2), 21i16, Int16(32 + 5), Int16(32 + 7), Int16(32 + 15), Int16(32 + 17), Int16(64 + 22), 23i16, Int16(64 + 22), 21i16, 21i16, Int16(32 + 3), 18i16, 21i16, _AN], [Int16(96 + 1), Int16(96 + 2), 21i16, Int16(96 + 5), Int16(128 + 7), Int16(96 + 15), Int16(96 + 17), Int16(128 + 7), Int16(128 + 14), Int16(128 + 7), 22i16, Int16(128 + 7), Int16(96 + 3), 18i16, 21i16, _AN], [Int16(32 + 1), Int16(32 + 2), 21i16, Int16(32 + 5), Int16(32 + 7), Int16(32 + 15), Int16(32 + 17), Int16(32 + 7), 23i16, Int16(32 + 7), 23i16, 23i16, Int16(32 + 3), 18i16, 21i16, _AN]]

    private static let IMPTABLEVELS_COLUMNS = Int32(_B) + 2

    private static let IMPTABLEVELS_RES = IMPTABLEVELS_COLUMNS - 1

    private static func GetState(cell: UInt8): Int16 {
        return Int16(Int32(cell) & 15)
    }

    private static func GetAction(cell: UInt8): Int16 {
        return Int16(shr(Int32(cell), 4))
    }

    private static let impTabL_DEFAULT: Array<Array<UInt8>> = [[0, 1, 0, 2, 0, 0, 0, 0], [0, 1, 3, 3, 20, 20, 0, 1], [0, 1, 0, 2, 21, 21, 0, 2], [0, 1, 3, 3, 20, 20, 0, 2], [0, 33, 51, 51, 4, 4, 0, 0], [0, 33, 0, 50, 5, 5, 0, 0]]

    private static let impTabR_DEFAULT: Array<Array<UInt8>> = [[1, 0, 2, 2, 0, 0, 0, 0], [1, 0, 1, 3, 20, 20, 0, 1], [1, 0, 2, 2, 0, 0, 0, 1], [1, 0, 1, 3, 5, 5, 0, 1], [33, 0, 33, 3, 4, 4, 0, 0], [1, 0, 1, 3, 5, 5, 0, 0]]

    private static let impAct0: Array<Int16> = [0i16, 1i16, 2i16, 3i16, 4i16]

    private static let impTab_DEFAULT = Bidi_ImpTabPair(impTabL_DEFAULT, impTabR_DEFAULT, impAct0, impAct0)

    private static let impTabL_NUMBERS_SPECIAL: Array<Array<UInt8>> = [[0, 2, 17, 17, 0, 0, 0, 0], [0, 66, 1, 1, 0, 0, 0, 0], [0, 2, 4, 4, 19, 19, 0, 1], [0, 34, 52, 52, 3, 3, 0, 0], [0, 2, 4, 4, 19, 19, 0, 2]]

    private static let impTab_NUMBERS_SPECIAL = Bidi_ImpTabPair(impTabL_NUMBERS_SPECIAL, impTabR_DEFAULT, impAct0, impAct0)

    private static let impTabL_GROUP_NUMBERS_WITH_R: Array<Array<UInt8>> = [[0, 3, 17, 17, 0, 0, 0, 0], [32, 3, 1, 1, 2, 32, 32, 2], [32, 3, 1, 1, 2, 32, 32, 1], [0, 3, 5, 5, 20, 0, 0, 1], [32, 3, 5, 5, 4, 32, 32, 1], [0, 3, 5, 5, 20, 0, 0, 2]]

    private static let impTabR_GROUP_NUMBERS_WITH_R: Array<Array<UInt8>> = [[2, 0, 1, 1, 0, 0, 0, 0], [2, 0, 1, 1, 0, 0, 0, 1], [2, 0, 20, 20, 19, 0, 0, 1], [34, 0, 4, 4, 3, 0, 0, 0], [34, 0, 4, 4, 3, 0, 0, 1]]

    private static let impTab_GROUP_NUMBERS_WITH_R = Bidi_ImpTabPair(impTabL_GROUP_NUMBERS_WITH_R, impTabR_GROUP_NUMBERS_WITH_R, impAct0, impAct0)

    private static let impTabL_INVERSE_NUMBERS_AS_L: Array<Array<UInt8>> = [[0, 1, 0, 0, 0, 0, 0, 0], [0, 1, 0, 0, 20, 20, 0, 1], [0, 1, 0, 0, 21, 21, 0, 2], [0, 1, 0, 0, 20, 20, 0, 2], [32, 1, 32, 32, 4, 4, 32, 1], [32, 1, 32, 32, 5, 5, 32, 1]]

    private static let impTabR_INVERSE_NUMBERS_AS_L: Array<Array<UInt8>> = [[1, 0, 1, 1, 0, 0, 0, 0], [1, 0, 1, 1, 20, 20, 0, 1], [1, 0, 1, 1, 0, 0, 0, 1], [1, 0, 1, 1, 5, 5, 0, 1], [33, 0, 33, 33, 4, 4, 0, 0], [1, 0, 1, 1, 5, 5, 0, 0]]

    private static let impTab_INVERSE_NUMBERS_AS_L = Bidi_ImpTabPair(impTabL_INVERSE_NUMBERS_AS_L, impTabR_INVERSE_NUMBERS_AS_L, impAct0, impAct0)

    private static let impTabR_INVERSE_LIKE_DIRECT: Array<Array<UInt8>> = [[1, 0, 2, 2, 0, 0, 0, 0], [1, 0, 1, 2, 19, 19, 0, 1], [1, 0, 2, 2, 0, 0, 0, 1], [33, 48, 6, 4, 3, 3, 48, 0], [33, 48, 6, 4, 5, 5, 48, 3], [33, 48, 6, 4, 5, 5, 48, 2], [33, 48, 6, 4, 3, 3, 48, 1]]

    private static let impAct1: Array<Int16> = [0i16, 1i16, 13i16, 14i16]

    private static let impTab_INVERSE_LIKE_DIRECT = Bidi_ImpTabPair(impTabL_DEFAULT, impTabR_INVERSE_LIKE_DIRECT, impAct0, impAct1)

    private static let impTabL_INVERSE_LIKE_DIRECT_WITH_MARKS: Array<Array<UInt8>> = [[0, 99, 0, 1, 0, 0, 0, 0], [0, 99, 0, 1, 18, 48, 0, 4], [32, 99, 32, 1, 2, 48, 32, 3], [0, 99, 85, 86, 20, 48, 0, 3], [48, 67, 85, 86, 4, 48, 48, 3], [48, 67, 5, 86, 20, 48, 48, 4], [48, 67, 85, 6, 20, 48, 48, 4]]

    private static let impTabR_INVERSE_LIKE_DIRECT_WITH_MARKS: Array<Array<UInt8>> = [[19, 0, 1, 1, 0, 0, 0, 0], [35, 0, 1, 1, 2, 64, 0, 1], [35, 0, 1, 1, 2, 64, 0, 0], [3, 0, 3, 54, 20, 64, 0, 1], [83, 64, 5, 54, 4, 64, 64, 0], [83, 64, 5, 54, 4, 64, 64, 1], [83, 64, 6, 6, 4, 64, 64, 3]]

    private static let impAct2: Array<Int16> = [0i16, 1i16, 2i16, 5i16, 6i16, 7i16, 8i16]

    private static let impAct3: Array<Int16> = [0i16, 1i16, 9i16, 10i16, 11i16, 12i16]

    private static let impTab_INVERSE_LIKE_DIRECT_WITH_MARKS = Bidi_ImpTabPair(impTabL_INVERSE_LIKE_DIRECT_WITH_MARKS, impTabR_INVERSE_LIKE_DIRECT_WITH_MARKS, impAct2, impAct3)

    private static let impTab_INVERSE_FOR_NUMBERS_SPECIAL = Bidi_ImpTabPair(impTabL_NUMBERS_SPECIAL, impTabR_INVERSE_LIKE_DIRECT, impAct0, impAct1)

    private static let impTabL_INVERSE_FOR_NUMBERS_SPECIAL_WITH_MARKS: Array<Array<UInt8>> = [[0, 98, 1, 1, 0, 0, 0, 0], [0, 98, 1, 1, 0, 48, 0, 4], [0, 98, 84, 84, 19, 48, 0, 3], [48, 66, 84, 84, 3, 48, 48, 3], [48, 66, 4, 4, 19, 48, 48, 4]]

    private static let impTab_INVERSE_FOR_NUMBERS_SPECIAL_WITH_MARKS = Bidi_ImpTabPair(impTabL_INVERSE_FOR_NUMBERS_SPECIAL_WITH_MARKS, impTabR_INVERSE_LIKE_DIRECT_WITH_MARKS, impAct2, impAct3)

    static let FIRSTALLOC = 10

    private func addPoint(pos: Int32, flag: Int32): Unit {
        let point = Bidi_Point()
        var len = Int32(insertPoints.points.size)
        if (len == 0) {
            insertPoints.points = Array<Bidi_Point>(Int64(FIRSTALLOC))
            len = FIRSTALLOC
        }
        if (insertPoints.size >= len) {
            let savePoints = insertPoints.points
            insertPoints.points = Array<Bidi_Point>(Int64(len * 2))
            arraycopy(savePoints, 0, insertPoints.points, 0, Int64(len))
        }
        point.pos = pos
        point.flag = flag
        insertPoints.points[Int64(insertPoints.size)] = point
        insertPoints.size++
    }

    private func setLevelsOutsideIsolates(start: Int32, limit: Int32, level: UInt8): Unit {
        var dirProp: UInt8 = 0
        var isolateCount = 0
        var k: Int32 = 0
        k = start
        while (k < limit) {
            dirProp = dirProps[Int64(k)]
            if (dirProp == PDI) {
                isolateCount--
            }
            if (isolateCount == 0) {
                levels[Int64(k)] = level
            }
            if (dirProp == LRI || dirProp == RLI) {
                isolateCount++
            }
            k++
        }
    }

    private func processPropertySeq(levState: Bidi_LevState, _prop: Int16, start: Int32, limit: Int32): Unit {
        var tempstart = start
        let cell: UInt8
        let impTab = levState.impTab
        let impAct = levState.impAct
        let oldStateSeq: Int16
        let actionSeq: Int16
        var level: UInt8 = 0
        let addLevel: UInt8
        let start0: Int32
        var k: Int32 = 0
        start0 = tempstart
        oldStateSeq = levState.state
        cell = impTab[Int64(oldStateSeq)][Int64(_prop)]
        levState.state = GetState(cell)
        actionSeq = impAct[Int64(GetAction(cell))]
        addLevel = impTab[Int64(levState.state)][Int64(IMPTABLEVELS_RES)]
        if (Int32(actionSeq) != 0) {
            match (actionSeq) {
                case 1i16 => levState.startON = start0
                case 2i16 => tempstart = levState.startON
                case 3i16 =>
                    level = UInt8(Int32(levState.runLevel) + 1)
                    setLevelsOutsideIsolates(levState.startON, start0, level)
                case 4i16 =>
                    level = UInt8(Int32(levState.runLevel) + 2)
                    setLevelsOutsideIsolates(levState.startON, start0, level)
                case 5i16 =>
                    if (levState.startL2EN >= 0) {
                        addPoint(levState.startL2EN, LRM_BEFORE)
                    }
                    levState.startL2EN = -1
                    if ((Int32(insertPoints.points.size) == 0) || (insertPoints.size <= insertPoints.confirmed)) {
                        levState.lastStrongRTL = -1
                        level = impTab[Int64(oldStateSeq)][Int64(IMPTABLEVELS_RES)]
                        if ((Int32(level) & 1) != 0 && levState.startON > 0) {
                            tempstart = levState.startON
                        }
                        if (_prop == _S) {
                            addPoint(start0, LRM_BEFORE)
                            insertPoints.confirmed = insertPoints.size
                        }
                        break
                    }
                    k = levState.lastStrongRTL + 1
                    while (k < start0) {
                        levels[Int64(k)] = UInt8((Int32(levels[Int64(k)]) - 2) & )
                        k++
                    }
                    insertPoints.confirmed = insertPoints.size
                    levState.lastStrongRTL = -1
                    if (_prop == _S) {
                        addPoint(start0, LRM_BEFORE)
                        insertPoints.confirmed = insertPoints.size
                    }
                case 6i16 =>
                    if (Int32(insertPoints.points.size) > 0) {
                        insertPoints.size = insertPoints.confirmed
                    }
                    levState.startON = -1
                    levState.startL2EN = -1
                    levState.lastStrongRTL = limit - 1
                case 7i16 =>
                    if ((_prop == _AN) && (dirProps[Int64(start0)] == AN) && (reorderingMode != Int32(REORDER_INVERSE_FOR_NUMBERS_SPECIAL))) {
                        if (levState.startL2EN == -1) {
                            levState.lastStrongRTL = limit - 1
                            break
                        }
                        if (levState.startL2EN >= 0) {
                            addPoint(levState.startL2EN, LRM_BEFORE)
                            levState.startL2EN = -2
                        }
                        addPoint(start0, LRM_BEFORE)
                        break
                    }
                    if (levState.startL2EN == -1) {
                        levState.startL2EN = start0
                    }
                case 8i16 =>
                    levState.lastStrongRTL = limit - 1
                    levState.startON = -1
                case 9i16 =>
                    k = start0 - 1
                    while (k >= 0 && ((Int32(levels[Int64(k)]) & 1) == 0)) {
                        k--
                    }
                    if (k >= 0) {
                        addPoint(k, RLM_BEFORE)
                        insertPoints.confirmed = insertPoints.size
                    }
                    levState.startON = start0
                case 10i16 =>
                    addPoint(start0, LRM_BEFORE)
                    addPoint(start0, LRM_AFTER)
                case 11i16 =>
                    insertPoints.size = insertPoints.confirmed
                    if (_prop == _S) {
                        addPoint(start0, RLM_BEFORE)
                        insertPoints.confirmed = insertPoints.size
                    }
                case 12i16 =>
                    level = UInt8(levState.runLevel + addLevel)
                    k = levState.startON
                    while (k < start0) {
                        if (levels[Int64(k)] < level) {
                            levels[Int64(k)] = level
                        }
                        k++
                    }
                    insertPoints.confirmed = insertPoints.size
                    levState.startON = start0
                case 13i16 =>
                    level = levState.runLevel
                    k = start0 - 1
                    while (k >= levState.startON) {
                        if (Int32(levels[Int64(k)]) == Int32(level) + 3) {
                            while (Int32(levels[Int64(k)]) == Int32(level) + 3) {
                                levels[Int64(match (0) { case _ => k--; k + 1 })] -= 2
                            }
                            while (levels[Int64(k)] == level) {
                                k--
                            }
                        }
                        if (Int32(levels[Int64(k)]) == Int32(level) + 2) {
                            levels[Int64(k)] = level
                            continue
                        }
                        levels[Int64(k)] = UInt8(Int32(level) + 1)
                        k--
                    }
                case 14i16 =>
                    level = UInt8(Int32(levState.runLevel) + 1)
                    k = start0 - 1
                    while (k >= levState.startON) {
                        if (levels[Int64(k)] > level) {
                            levels[Int64(k)] -= 2
                        }
                        k--
                    }
                case _ => throw Exception("Internal ICU error in processPropertySeq")
            }
        }
        if ((Int32(addLevel)) != 0 || (tempstart < start0)) {
            level = UInt8(levState.runLevel + addLevel)
            if (tempstart >= levState.runStart) {
                k = tempstart
                while (k < limit) {
                    levels[Int64(k)] = level
                    k++
                }
            } else {
                setLevelsOutsideIsolates(tempstart, limit, level)
            }
        }
    }

    private func lastL_R_AL(): UInt8 {
        var i = Int32(prologue.size)
        while (i > 0) {
            let uchar = prologue.codePointBefore(i)
            i -= Character.charCount(uchar)
            let dirProp = UInt8(getCustomizedClass(uchar))
            if (dirProp == L) {
                return UInt8(_L)
            }
            if (dirProp == R || dirProp == AL) {
                return UInt8(_R)
            }
            if (dirProp == B) {
                return UInt8(_ON)
            }
        }
        return UInt8(_ON)
    }

    private func firstL_R_AL_EN_AN(): UInt8 {
        var i = 0
        while (i < Int32(epilogue.size)) {
            let uchar = epilogue.codePointAt(i)
            i += Character.charCount(uchar)
            let dirProp = UInt8(getCustomizedClass(uchar))
            if (dirProp == L) {
                return UInt8(_L)
            }
            if (dirProp == R || dirProp == AL) {
                return UInt8(_R)
            }
            if (dirProp == EN) {
                return UInt8(_EN)
            }
            if (dirProp == AN) {
                return UInt8(_AN)
            }
        }
        return UInt8(_ON)
    }

    private func resolveImplicitLevels(start: Int32, limit: Int32, sor: Int16, eor: Int16): Unit {
        var tempsor = sor
        var tempeor = eor
        var dirProp: UInt8 = 0
        let levState = Bidi_LevState()
        var i: Int32 = 0
        var start1: Int32 = 0
        var start2: Int32 = 0
        var oldStateImp: Int16 = 0
        var stateImp: Int16 = 0
        var actionImp: Int16 = 0
        var gprop: Int16 = 0
        var resProp: Int16 = 0
        var cell: Int16 = 0
        let inverseRTL: Bool
        var nextStrongProp = Int16(R)
        var nextStrongPos = -1
        inverseRTL = ((start < lastArabicPos) && ((Int32(GetParaLevelAt(start)) & 1) > 0) && (reorderingMode == Int32(REORDER_INVERSE_LIKE_DIRECT) || reorderingMode == Int32(REORDER_INVERSE_FOR_NUMBERS_SPECIAL)))
        levState.startL2EN = -1
        levState.lastStrongRTL = -1
        levState.runStart = start
        levState.runLevel = levels[Int64(start)]
        levState.impTab = impTabPair.imptab[Int64(Int32(levState.runLevel) & 1)]
        levState.impAct = impTabPair.impact[Int64(Int32(levState.runLevel) & 1)]
        if (start == 0 && prologue.isSome()) {
            let lastStrong = lastL_R_AL()
            if (Int32(lastStrong) != Int32(_ON)) {
                tempsor = Int16(lastStrong)
            }
        }
        if (dirProps[Int64(start)] == PDI) {
            levState.startON = isolates[Int64(isolateCount)].startON
            start1 = isolates[Int64(isolateCount)].start1
            stateImp = isolates[Int64(isolateCount)].stateImp
            levState.state = isolates[Int64(isolateCount)].state
            isolateCount--
        } else {
            levState.startON = -1
            start1 = start
            if (dirProps[Int64(start)] == NSM) {
                stateImp = Int16(1 + Int32(tempsor))
            } else {
                stateImp = 0i16
            }
            levState.state = 0i16
            processPropertySeq(levState, tempsor, start, start)
        }
        start2 = start
        i = start
        while (i <= limit) {
            if (i >= limit) {
                var k: Int32 = 0
                k = limit - 1
                while (k > start && (DirPropFlag(dirProps[Int64(k)]) & MASK_BN_EXPLICIT) != 0) {
                    k--
                }
                dirProp = dirProps[Int64(k)]
                if (dirProp == LRI || dirProp == RLI) {
                    break
                }
                gprop = tempeor
            } else {
                var property: UInt8 = 0
                var prop1: UInt8 = 0
                property = dirProps[Int64(i)]
                if (property == B) {
                    isolateCount = -1
                }
                if (inverseRTL) {
                    if (property == AL) {
                        property = R
                    } else if (property == EN) {
                        if (nextStrongPos <= i) {
                            var j: Int32 = 0
                            nextStrongProp = Int16(R)
                            nextStrongPos = limit
                            j = i + 1
                            while (j < limit) {
                                prop1 = dirProps[Int64(j)]
                                if (prop1 == L || prop1 == R || prop1 == AL) {
                                    nextStrongProp = Int16(prop1)
                                    nextStrongPos = j
                                    break
                                }
                                j++
                            }
                        }
                        if (Int32(nextStrongProp) == Int32(AL)) {
                            property = AN
                        }
                    }
                }
                gprop = groupProp[Int64(property)]
            }
            oldStateImp = stateImp
            cell = impTabProps[Int64(oldStateImp)][Int64(gprop)]
            stateImp = GetStateProps(cell)
            actionImp = GetActionProps(cell)
            if ((i == limit) && (Int32(actionImp) == 0)) {
                actionImp = 1i16
            }
            if (Int32(actionImp) != 0) {
                resProp = impTabProps[Int64(oldStateImp)][Int64(IMPTABPROPS_RES)]
                match (actionImp) {
                    case 1i16 =>
                        processPropertySeq(levState, resProp, start1, i)
                        start1 = i
                    case 2i16 => start2 = i
                    case 3i16 =>
                        processPropertySeq(levState, resProp, start1, start2)
                        processPropertySeq(levState, _ON, start2, i)
                        start1 = i
                    case 4i16 =>
                        processPropertySeq(levState, resProp, start1, start2)
                        start1 = start2
                        start2 = i
                    case _ => throw Exception("Internal ICU error in resolveImplicitLevels")
                }
            }
            i++
        }
        if (limit == length && epilogue.isSome()) {
            let firstStrong = firstL_R_AL_EN_AN()
            if (Int32(firstStrong) != Int32(_ON)) {
                tempeor = Int16(firstStrong)
            }
        }
        i = limit - 1
        while (i > start && (DirPropFlag(dirProps[Int64(i)]) & MASK_BN_EXPLICIT) != 0) {
            i--
        }
        dirProp = dirProps[Int64(i)]
        if ((dirProp == LRI || dirProp == RLI) && limit < length) {
            isolateCount++
            if (isolates[Int64(isolateCount)].isNone()) {
                isolates[Int64(isolateCount)] = Bidi_Isolate()
            }
            isolates[Int64(isolateCount)].stateImp = stateImp
            isolates[Int64(isolateCount)].state = levState.state
            isolates[Int64(isolateCount)].start1 = start1
            isolates[Int64(isolateCount)].startON = levState.startON
        } else {
            processPropertySeq(levState, tempeor, limit, limit)
        }
    }

    private func adjustWSLevels(): Unit {
        var i: Int32 = 0
        if ((flags & MASK_WS) != 0) {
            var flag: Int32 = 0
            i = trailingWSStart
            while (i > 0) {
                while (i > 0 && ((match (0) { case _ => flag = DirPropFlag(dirProps[Int64(match (0) { case _ => i--; i })]); flag }) & MASK_WS) != 0) {
                    if (orderParagraphsLTR && (flag & DirPropFlag(B)) != 0) {
                        levels[Int64(i)] = 0
                    } else {
                        levels[Int64(i)] = GetParaLevelAt(i)
                    }
                }
                while (i > 0) {
                    flag = DirPropFlag(dirProps[Int64(match (0) { case _ => i--; i })])
                    if ((flag & MASK_BN_EXPLICIT) != 0) {
                        levels[Int64(i)] = levels[Int64(i + 1)]
                    } else if (orderParagraphsLTR && (flag & DirPropFlag(B)) != 0) {
                        levels[Int64(i)] = 0
                        break
                    } else if ((flag & MASK_B_S) != 0) {
                        levels[Int64(i)] = GetParaLevelAt(i)
                        break
                    }
                }
            }
        }
    }

    public func setContext(prologue: String, epilogue: String): Unit {
        this.prologue = if (prologue.isSome() && Int32(prologue.size) > 0) { prologue } else { None }
        this.epilogue = if (epilogue.isSome() && Int32(epilogue.size) > 0) { epilogue } else { None }
    }

    private func setParaSuccess(): Unit {
        prologue = None
        epilogue = None
        paraBidi = this
    }

    public func Bidi_Min(x: Int32, y: Int32): Int32 {
        return if (x < y) { x } else { y }
    }

    public func Bidi_Abs(x: Int32): Int32 {
        return if (x >= 0) { x } else { -x }
    }

    public func setParaRunsOnly(parmText: Array<Char>, parmParaLevel: UInt8): Unit {
        var tempparmParaLevel = parmParaLevel
        let visualMap: Array<Int32>
        let visualText: String
        let saveLength: Int32
        let saveTrailingWSStart: Int32
        let saveLevels: Array<UInt8>
        let saveDirection: UInt8
        var i: Int32 = 0
        var j: Int32 = 0
        var visualStart: Int32 = 0
        var logicalStart: Int32 = 0
        let oldRunCount: Int32
        var runLength: Int32 = 0
        var addedRuns: Int32 = 0
        var insertRemove: Int32 = 0
        var start: Int32 = 0
        var limit: Int32 = 0
        var step: Int32 = 0
        var indexOddBit: Int32 = 0
        var logicalPos: Int32 = 0
        var index: Int32 = 0
        var index1: Int32 = 0
        let saveOptions: Int32
        reorderingMode = Int32(REORDER_DEFAULT)
        let parmLength = Int32(parmText.size)
        if (parmLength == 0) {
            setPara(parmText, tempparmParaLevel, None)
            reorderingMode = Int32(REORDER_RUNS_ONLY)
            return
        }
        saveOptions = reorderingOptions
        if ((saveOptions & OPTION_INSERT_MARKS) > 0) {
            reorderingOptions &= 
            reorderingOptions |= OPTION_REMOVE_CONTROLS
        }
        tempparmParaLevel &= 1
        setPara(parmText, tempparmParaLevel, None)
        saveLevels = Array<UInt8>(Int64(this.length)) { _ => 0 }
        arraycopy(getLevels(), 0, saveLevels, 0, Int64(this.length))
        saveTrailingWSStart = trailingWSStart
        visualText = writeReordered(Int32(DO_MIRRORING))
        visualMap = getVisualMap()
        this.reorderingOptions = saveOptions
        saveLength = this.length
        saveDirection = this.direction
        this.reorderingMode = Int32(REORDER_INVERSE_LIKE_DIRECT)
        tempparmParaLevel ^= 1
        setPara(visualText, tempparmParaLevel, None)
        BidiLine.getRuns(this)
        addedRuns = 0
        oldRunCount = this.runCount
        visualStart = 0
        i = 0
        while (i < oldRunCount) {
            runLength = runs[Int64(i)].limit - visualStart
            if (runLength < 2) {
                continue
            }
            logicalStart = runs[Int64(i)].start
            j = logicalStart + 1
            while (j < logicalStart + runLength) {
                index = visualMap[Int64(j)]
                index1 = visualMap[Int64(j - 1)]
                if ((Bidi_Abs(index - index1) != 1) || (saveLevels[Int64(index)] != saveLevels[Int64(index1)])) {
                    addedRuns++
                }
                j++
            }
            i++
            visualStart += runLength
        }
        if (addedRuns > 0) {
            getRunsMemory(oldRunCount + addedRuns)
            if (runCount == 1) {
                runsMemory[0] = runs[0]
            } else {
                arraycopy(runs, 0, runsMemory, 0, Int64(runCount))
            }
            runs = runsMemory
            runCount += addedRuns
            i = oldRunCount
            while (i < runCount) {
                if (runs[Int64(i)].isNone()) {
                    runs[Int64(i)] = BidiRun(0, 0, 0)
                }
                i++
            }
        }
        var newI: Int32 = 0
        i = oldRunCount - 1
        while (i >= 0) {
            newI = i + addedRuns
            runLength = if (i == 0) { runs[0].limit } else { runs[Int64(i)].limit - runs[Int64(i - 1)].limit }
            logicalStart = runs[Int64(i)].start
            indexOddBit = Int32(runs[Int64(i)].level) & 1
            if (runLength < 2) {
                if (addedRuns > 0) {
                    runs[Int64(newI)].copyFrom(runs[Int64(i)])
                }
                logicalPos = visualMap[Int64(logicalStart)]
                runs[Int64(newI)].start = logicalPos
                runs[Int64(newI)].level = UInt8(Int32(saveLevels[Int64(logicalPos)]) ^ indexOddBit)
                continue
            }
            if (indexOddBit > 0) {
                start = logicalStart
                limit = logicalStart + runLength - 1
                step = 1
            } else {
                start = logicalStart + runLength - 1
                limit = logicalStart
                step = -1
            }
            j = start
            while (j != limit) {
                index = visualMap[Int64(j)]
                index1 = visualMap[Int64(j + step)]
                if ((Bidi_Abs(index - index1) != 1) || (saveLevels[Int64(index)] != saveLevels[Int64(index1)])) {
                    logicalPos = Bidi_Min(visualMap[Int64(start)], index)
                    runs[Int64(newI)].start = logicalPos
                    runs[Int64(newI)].level = UInt8(Int32(saveLevels[Int64(logicalPos)]) ^ indexOddBit)
                    runs[Int64(newI)].limit = runs[Int64(i)].limit
                    runs[Int64(i)].limit -= Bidi_Abs(j - start) + 1
                    insertRemove = runs[Int64(i)].insertRemove & (LRM_AFTER | RLM_AFTER)
                    runs[Int64(newI)].insertRemove = insertRemove
                    runs[Int64(i)].insertRemove &= 
                    start = j + step
                    addedRuns--
                    newI--
                }
                j += step
            }
            if (addedRuns > 0) {
                runs[Int64(newI)].copyFrom(runs[Int64(i)])
            }
            logicalPos = Bidi_Min(visualMap[Int64(start)], visualMap[Int64(limit)])
            runs[Int64(newI)].start = logicalPos
            runs[Int64(newI)].level = UInt8(Int32(saveLevels[Int64(logicalPos)]) ^ indexOddBit)
            i--
        }
        this.paraLevel ^= 1
        this.text = parmText
        this.length = saveLength
        this.originalLength = parmLength
        this.direction = saveDirection
        this.levels = saveLevels
        this.trailingWSStart = saveTrailingWSStart
        if (runCount > 1) {
            this.direction = MIXED
        }
        this.reorderingMode = Int32(REORDER_RUNS_ONLY)
    }

    public func setPara(text: String, paraLevel: UInt8, embeddingLevels: Array<UInt8>): Unit {
        if (text.isNone()) {
            setPara(Array<Char>(0) { _ => '\u{0000}' }, paraLevel, embeddingLevels)
        } else {
            setPara(text.toRuneArray(), paraLevel, embeddingLevels)
        }
    }

    public func setPara(chars: Array<Char>, paraLevel: UInt8, embeddingLevels: Array<UInt8>): Unit {
        var tempchars = chars
        if (paraLevel < LEVEL_DEFAULT_LTR) {
            verifyRange(Int32(paraLevel), 0, Int32(MAX_EXPLICIT_LEVEL) + 1)
        }
        if (tempchars.isNone()) {
            tempchars = Array<Char>(0) { _ => '\u{0000}' }
        }
        if (reorderingMode == Int32(REORDER_RUNS_ONLY)) {
            setParaRunsOnly(tempchars, paraLevel)
            return
        }
        this.paraBidi = None
        this.text = tempchars
        this.length = match (0) { case _ => this.originalLength = match (0) { case _ => this.resultLength = Int32(text.size); this.resultLength }; this.originalLength }
        this.paraLevel = paraLevel
        this.direction = UInt8(Int32(paraLevel) & 1)
        this.paraCount = 1
        dirProps = Array<UInt8>(0) { _ => 0 }
        levels = Array<UInt8>(0) { _ => 0 }
        runs = Array<BidiRun>(0)
        isGoodLogicalToVisualRunsMap = false
        insertPoints.size = 0
        insertPoints.confirmed = 0
        defaultParaLevel = if (IsDefaultLevel(paraLevel)) { paraLevel } else { 0 }
        if (length == 0) {
            if (IsDefaultLevel(paraLevel)) {
                this.paraLevel &= 1
                defaultParaLevel = 0
            }
            flags = DirPropFlagLRStatic(paraLevel)
            runCount = 0
            paraCount = 0
            setParaSuccess()
            return
        }
        runCount = -1
        getDirPropsMemory(length)
        dirProps = dirPropsMemory
        getDirProps()
        trailingWSStart = length
        if (embeddingLevels.isNone()) {
            getLevelsMemory(length)
            levels = levelsMemory
            direction = resolveExplicitLevels()
        } else {
            levels = embeddingLevels
            direction = checkExplicitLevels()
        }
        if (isolateCount > 0) {
            if (isolates.isNone() || Int32(isolates.size) < isolateCount) {
                isolates = Array<Bidi_Isolate>(Int64(isolateCount + 3))
            }
        }
        isolateCount = -1
        match (direction) {
            case 0u8 => trailingWSStart = 0
            case 1u8 => trailingWSStart = 0
            case _ =>
                match (reorderingMode) {
                    case 0 => this.impTabPair = impTab_DEFAULT
                    case 1 => this.impTabPair = impTab_NUMBERS_SPECIAL
                    case 2 => this.impTabPair = impTab_GROUP_NUMBERS_WITH_R
                    case 3 => throw InternalError("Internal ICU error in setPara")
                    case 4 => this.impTabPair = impTab_INVERSE_NUMBERS_AS_L
                    case 5 => if ((reorderingOptions & OPTION_INSERT_MARKS) != 0) {
                        this.impTabPair = impTab_INVERSE_LIKE_DIRECT_WITH_MARKS
                    } else {
                        this.impTabPair = impTab_INVERSE_LIKE_DIRECT
                    }
                    case 6 => if ((reorderingOptions & OPTION_INSERT_MARKS) != 0) {
                        this.impTabPair = impTab_INVERSE_FOR_NUMBERS_SPECIAL_WITH_MARKS
                    } else {
                        this.impTabPair = impTab_INVERSE_FOR_NUMBERS_SPECIAL
                    }
                    case _ => ()
                }
                if (embeddingLevels.isNone() && paraCount <= 1 && (flags & DirPropFlagMultiRuns) == 0) {
                    resolveImplicitLevels(0, length, Int16(GetLRFromLevel(GetParaLevelAt(0))), Int16(GetLRFromLevel(GetParaLevelAt(length - 1))))
                } else {
                    var start: Int32 = 0
                    var limit = 0
                    var level: UInt8 = 0
                    var nextLevel: UInt8 = 0
                    var sor: Int16 = 0
                    var eor: Int16 = 0
                    level = GetParaLevelAt(0)
                    nextLevel = levels[0]
                    if (level < nextLevel) {
                        eor = Int16(GetLRFromLevel(nextLevel))
                    } else {
                        eor = Int16(GetLRFromLevel(level))
                    }
                            sor = eor
                        }
                        while ((match (0) { case _ => limit++; limit } < length) && ((levels[Int64(limit)] == level) || ((DirPropFlag(dirProps[Int64(limit)]) & MASK_BN_EXPLICIT) != 0))) { }
                        if (limit < length) {
                            nextLevel = levels[Int64(limit)]
                        } else {
                            nextLevel = GetParaLevelAt(length - 1)
                        }
                        if (NoOverride(level) < NoOverride(nextLevel)) {
                            eor = Int16(GetLRFromLevel(nextLevel))
                        } else {
                            eor = Int16(GetLRFromLevel(level))
                        }
                        if ((level & LEVEL_OVERRIDE) == 0) {
                            resolveImplicitLevels(start, limit, sor, eor)
                        } else {
                        }
                    } while (limit < length)
                }
                adjustWSLevels()
        }
        if ((Int32(defaultParaLevel) > 0) && ((reorderingOptions & OPTION_INSERT_MARKS) != 0) && ((reorderingMode == Int32(REORDER_INVERSE_LIKE_DIRECT)) || (reorderingMode == Int32(REORDER_INVERSE_FOR_NUMBERS_SPECIAL)))) {
            var start: Int32 = 0
            var last: Int32 = 0
            var level: UInt8 = 0
            var dirProp: UInt8 = 0
            var i = 0
            while (i < paraCount) {
                last = paras_limit[Int64(i)] - 1
                level = paras_level[Int64(i)]
                if (Int32(level) == 0) {
                    continue
                }
                start = if (i == 0) { 0 } else { paras_limit[Int64(i - 1)] }
                var j = last
                while (j >= start) {
                    dirProp = dirProps[Int64(j)]
                    if (dirProp == L) {
                        if (j < last) {
                            while (dirProps[Int64(last)] == B) {
                                last--
                            }
                        }
                        addPoint(last, RLM_BEFORE)
                        break
                    }
                    if ((DirPropFlag(dirProp) & MASK_R_AL) != 0) {
                        break
                    }
                    j--
                }
                i++
            }
        }
        if ((reorderingOptions & OPTION_REMOVE_CONTROLS) != 0) {
            resultLength -= controlCount
        } else {
            resultLength += insertPoints.size
        }
        setParaSuccess()
    }

    public func setPara(paragraph: AttributedCharacterIterator): Unit {
        let paraLvl: UInt8
        let runDirection = paragraph.getAttribute(TextAttribute.RUN_DIRECTION)
        if (runDirection.isNone()) {
            paraLvl = LEVEL_DEFAULT_LTR
        } else {
            paraLvl = if (refEq(runDirection, TextAttribute.RUN_DIRECTION_LTR)) { LTR } else { RTL }
        }
        var lvls: Array<UInt8>
        let len = paragraph.getEndIndex() - paragraph.getBeginIndex()
        let embeddingLevels = Array<UInt8>(Int64(len)) { _ => 0 }
        let txt = Array<Char>(Int64(len)) { _ => '\u{0000}' }
        var i = 0
        var ch = paragraph.first()
        while (ch != AttributedCharacterIterator.DONE) {
            txt[Int64(i)] = ch
            let embedding = paragraph.getAttribute(TextAttribute.BIDI_EMBEDDING)
            if (embedding.isSome()) {
                let level = UInt8(Int8(embedding))
                if (Int32(level) == 0) { } else if (Int32(level) < 0) {
                    lvls = embeddingLevels
                    embeddingLevels[Int64(i)] = UInt8((0 - Int32(level)) | Int32(LEVEL_OVERRIDE))
                } else {
                    lvls = embeddingLevels
                    embeddingLevels[Int64(i)] = level
                }
            }
            ch = paragraph.next()
            i++
        }
        let shaper = paragraph.getAttribute(TextAttribute.NUMERIC_SHAPING)
        if (shaper.isSome()) {
            shaper.shape(txt, 0, len)
        }
        setPara(txt, paraLvl, lvls)
    }

    public func orderParagraphsLTRMethod(ordarParaLTR: Bool): Unit {
        orderParagraphsLTR = ordarParaLTR
    }

    public func isOrderParagraphsLTR(): Bool {
        return orderParagraphsLTR
    }

    public func getDirection(): UInt8 {
        verifyValidParaOrLine()
        return direction
    }

    public func getTextAsString(): String {
        verifyValidParaOrLine()
        return String(text)
    }

    public func getText(): Array<Char> {
        verifyValidParaOrLine()
        return text
    }

    public func getLength(): Int32 {
        verifyValidParaOrLine()
        return originalLength
    }

    public func getProcessedLength(): Int32 {
        verifyValidParaOrLine()
        return length
    }

    public func getResultLength(): Int32 {
        verifyValidParaOrLine()
        return resultLength
    }

    public func getParaLevel(): UInt8 {
        verifyValidParaOrLine()
        return paraLevel
    }

    public func countParagraphs(): Int32 {
        verifyValidParaOrLine()
        return paraCount
    }

    public func getParagraphByIndex(paraIndex: Int32): BidiRun {
        verifyValidParaOrLine()
        verifyRange(paraIndex, 0, paraCount)
        let bidi = paraBidi
        let paraStart: Int32
        if (paraIndex == 0) {
            paraStart = 0
        } else {
            paraStart = bidi.paras_limit[Int64(paraIndex - 1)]
        }
        let bidiRun = BidiRun()
        bidiRun.start = paraStart
        bidiRun.limit = bidi.paras_limit[Int64(paraIndex)]
        bidiRun.level = GetParaLevelAt(paraStart)
        return bidiRun
    }

    public func getParagraph(charIndex: Int32): BidiRun {
        verifyValidParaOrLine()
        let bidi = paraBidi
        verifyRange(charIndex, 0, bidi.length)
        var paraIndex: Int32 = 0
        paraIndex = 0
        while (charIndex >= bidi.paras_limit[Int64(paraIndex)]) {
            paraIndex++
        }
        return getParagraphByIndex(paraIndex)
    }

    public func getParagraphIndex(charIndex: Int32): Int32 {
        verifyValidParaOrLine()
        let bidi = paraBidi
        verifyRange(charIndex, 0, bidi.length)
        var paraIndex: Int32 = 0
        paraIndex = 0
        while (charIndex >= bidi.paras_limit[Int64(paraIndex)]) {
            paraIndex++
        }
        return paraIndex
    }

    public func setCustomClassifier(classifier: BidiClassifier): Unit {
        this.customClassifier = classifier
    }

    public func getCustomClassifier(): BidiClassifier {
        return this.customClassifier
    }

    public func getCustomizedClass(c: Int32): Int32 {
        var dir: Int32 = 0
        if (customClassifier.isNone() || (match (0) { case _ => dir = customClassifier.classify(c); dir }) == Bidi.CLASS_DEFAULT) {
            dir = bdp.getClass(c)
        }
        if (dir >= UCharacterDirection.CHAR_DIRECTION_COUNT) {
            dir = Int32(ON)
        }
        return dir
    }

    public func setLine(start: Int32, limit: Int32): Bidi {
        verifyValidPara()
        verifyRange(start, 0, limit)
        verifyRange(limit, 0, length + 1)
        if (getParagraphIndex(start) != getParagraphIndex(limit - 1)) {
            throw IllegalArgumentException()
        }
        return BidiLine.setLine(this, start, limit)
    }

    public func getLevelAt(charIndex: Int32): UInt8 {
        verifyValidParaOrLine()
        verifyRange(charIndex, 0, length)
        return BidiLine.getLevelAt(this, charIndex)
    }

    public func getLevels(): Array<UInt8> {
        verifyValidParaOrLine()
        if (length <= 0) {
            return Array<UInt8>(0) { _ => 0 }
        }
        return BidiLine.getLevels(this)
    }

    public func getLogicalRun(logicalPosition: Int32): BidiRun {
        verifyValidParaOrLine()
        verifyRange(logicalPosition, 0, length)
        return BidiLine.getLogicalRun(this, logicalPosition)
    }

    public func countRuns(): Int32 {
        verifyValidParaOrLine()
        BidiLine.getRuns(this)
        return runCount
    }

    public func getVisualRun(runIndex: Int32): BidiRun {
        verifyValidParaOrLine()
        BidiLine.getRuns(this)
        verifyRange(runIndex, 0, runCount)
        return BidiLine.getVisualRun(this, runIndex)
    }

    public func getVisualIndex(logicalIndex: Int32): Int32 {
        verifyValidParaOrLine()
        verifyRange(logicalIndex, 0, length)
        return BidiLine.getVisualIndex(this, logicalIndex)
    }

    public func getLogicalIndex(visualIndex: Int32): Int32 {
        verifyValidParaOrLine()
        verifyRange(visualIndex, 0, resultLength)
        if (insertPoints.size == 0 && controlCount == 0) {
            if (direction == LTR) {
                return visualIndex
            } else if (direction == RTL) {
                return length - visualIndex - 1
            }
        }
        BidiLine.getRuns(this)
        return BidiLine.getLogicalIndex(this, visualIndex)
    }

    public func getLogicalMap(): Array<Int32> {
        countRuns()
        if (length <= 0) {
            return Array<Int32>(0) { _ => 0 }
        }
        return BidiLine.getLogicalMap(this)
    }

    public func getVisualMap(): Array<Int32> {
        countRuns()
        if (resultLength <= 0) {
            return Array<Int32>(0) { _ => 0 }
        }
        return BidiLine.getVisualMap(this)
    }

    public static func reorderLogical(levels: Array<UInt8>): Array<Int32> {
        return BidiLine.reorderLogical(levels)
    }

    public static func reorderVisual(levels: Array<UInt8>): Array<Int32> {
        return BidiLine.reorderVisual(levels)
    }

    public static func invertMap(srcMap: Array<Int32>): Array<Int32> {
        if (srcMap.isNone()) {
            return None
        } else {
            return BidiLine.invertMap(srcMap)
        }
    }

    public static let DIRECTION_LEFT_TO_RIGHT = Int32(LTR)

    public static let DIRECTION_RIGHT_TO_LEFT = Int32(RTL)

    public static let DIRECTION_DEFAULT_LEFT_TO_RIGHT = Int32(LEVEL_DEFAULT_LTR)

    public static let DIRECTION_DEFAULT_RIGHT_TO_LEFT = Int32(LEVEL_DEFAULT_RTL)

    public init(paragraph: String, flags: Int32) {
        this(paragraph.toRuneArray(), 0, None, 0, Int32(paragraph.size), flags)
    }

    public init(paragraph: AttributedCharacterIterator) {
        this()
        setPara(paragraph)
    }

    public init(text: Array<Char>, textStart: Int32, embeddings: Array<UInt8>, embStart: Int32, paragraphLength: Int32, flags: Int32) {
        this()
        let paraLvl: UInt8
        match (flags) {
            case 0 => paraLvl = LTR
            case 1 => paraLvl = RTL
            case 126 => paraLvl = LEVEL_DEFAULT_LTR
            case 127 => paraLvl = LEVEL_DEFAULT_RTL
            case _ => paraLvl = LTR
        }
        let paraEmbeddings: Array<UInt8>
        if (embeddings.isNone()) {
            paraEmbeddings = None
        } else {
            paraEmbeddings = Array<UInt8>(Int64(paragraphLength)) { _ => 0 }
            var lev: UInt8 = 0
            var i = 0
            while (i < paragraphLength) {
                lev = embeddings[Int64(i + embStart)]
                if (Int32(lev) < 0) {
                    lev = UInt8((Int32(-lev)) | Int32(LEVEL_OVERRIDE))
                }
                paraEmbeddings[Int64(i)] = lev
                i++
            }
        }
        if (textStart == 0 && paragraphLength == Int32(text.size)) {
            setPara(text, paraLvl, paraEmbeddings)
        } else {
            let paraText = Array<Char>(Int64(paragraphLength)) { _ => '\u{0000}' }
            arraycopy(text, Int64(textStart), paraText, 0, Int64(paragraphLength))
            setPara(paraText, paraLvl, paraEmbeddings)
        }
    }

    public func createLineBidi(lineStart: Int32, lineLimit: Int32): Bidi {
        return setLine(lineStart, lineLimit)
    }

    public func isMixed(): Bool {
        return (!isLeftToRight() && !isRightToLeft())
    }

    public func isLeftToRight(): Bool {
        return (getDirection() == LTR && (Int32(paraLevel) & 1) == 0)
    }

    public func isRightToLeft(): Bool {
        return (getDirection() == RTL && (Int32(paraLevel) & 1) == 1)
    }

    public func baseIsLeftToRight(): Bool {
        return (getParaLevel() == LTR)
    }

    public func getBaseLevel(): Int32 {
        return Int32(getParaLevel())
    }

    public func getRunCount(): Int32 {
        return countRuns()
    }

    public func getLogicalToVisualRunsMap(): Unit {
        if (isGoodLogicalToVisualRunsMap) {
            return
        }
        let count = countRuns()
        if ((logicalToVisualRunsMap.isNone()) || (Int32(logicalToVisualRunsMap.size) < count)) {
            logicalToVisualRunsMap = Array<Int32>(Int64(count)) { _ => 0 }
        }
        var i: Int32 = 0
        let keys = Array<Int64>(Int64(count)) { _ => 0 }
        i = 0
        while (i < count) {
            keys[Int64(i)] = (shl(Int64(runs[Int64(i)].start), 32)) + Int64(i)
            i++
        }
        stableSort(keys)
        i = 0
        while (i < count) {
            logicalToVisualRunsMap[Int64(i)] = Int32(keys[Int64(i)] & -1)
            i++
        }
        isGoodLogicalToVisualRunsMap = true
    }

    public func getRunLevel(run: Int32): Int32 {
        verifyValidParaOrLine()
        BidiLine.getRuns(this)
        verifyRange(run, 0, runCount)
        getLogicalToVisualRunsMap()
        return Int32(runs[Int64(logicalToVisualRunsMap[Int64(run)])].level)
    }

    public func getRunStart(run: Int32): Int32 {
        verifyValidParaOrLine()
        BidiLine.getRuns(this)
        verifyRange(run, 0, runCount)
        getLogicalToVisualRunsMap()
        return runs[Int64(logicalToVisualRunsMap[Int64(run)])].start
    }

    public func getRunLimit(run: Int32): Int32 {
        verifyValidParaOrLine()
        BidiLine.getRuns(this)
        verifyRange(run, 0, runCount)
        getLogicalToVisualRunsMap()
        let idx = logicalToVisualRunsMap[Int64(run)]
        let len = if (idx == 0) { runs[Int64(idx)].limit } else { runs[Int64(idx)].limit - runs[Int64(idx - 1)].limit }
        return runs[Int64(idx)].start + len
    }

    public static func requiresBidi(text: Array<Char>, start: Int32, limit: Int32): Bool {
        let RTLMask = (shl(1, Int32(UCharacter.DIRECTIONALITY_RIGHT_TO_LEFT)) | shl(1, Int32(UCharacter.DIRECTIONALITY_RIGHT_TO_LEFT_ARABIC)) | shl(1, Int32(UCharacter.DIRECTIONALITY_RIGHT_TO_LEFT_EMBEDDING)) | shl(1, Int32(UCharacter.DIRECTIONALITY_RIGHT_TO_LEFT_OVERRIDE)) | shl(1, Int32(UCharacter.DIRECTIONALITY_ARABIC_NUMBER)))
        var i = start
        while (i < limit) {
            if (((shl(1, UCharacter.getDirection(Int32(UInt32(text[Int64(i)]))))) & RTLMask) != 0) {
                return true
            }
            i++
        }
        return false
    }

    public static func reorderVisually(levels: Array<UInt8>, levelStart: Int32, objects: Array<Object>, objectStart: Int32, count: Int32): Unit {
        let reorderLevels = Array<UInt8>(Int64(count)) { _ => 0 }
        arraycopy(levels, Int64(levelStart), reorderLevels, 0, Int64(count))
        let indexMap = reorderVisual(reorderLevels)
        let temp = Array<Object>(Int64(count))
        arraycopy(objects, Int64(objectStart), temp, 0, Int64(count))
        var i = 0
        while (i < count) {
            objects[Int64(objectStart + i)] = temp[Int64(indexMap[Int64(i)])]
            i++
        }
    }

    public func writeReordered(options: Int32): String {
        verifyValidParaOrLine()
        if (length == 0) {
            return ""
        }
        return BidiWriter.writeReordered(this, options)
    }

    public static func writeReverse(src: String, options: Int32): String {
        if (src.isNone()) {
            throw IllegalArgumentException()
        }
        if (Int32(src.size) > 0) {
            return BidiWriter.writeReverse(src, options)
        } else {
            return ""
        }
    }
}


class Bidi_Point {

    var pos: Int32 = 0

    var flag: Int32 = 0
}


class Bidi_InsertPoints {

    var size: Int32 = 0

    var confirmed: Int32 = 0

    var points: Array<Bidi_Point> = Array<Bidi_Point>(0)
}


class Bidi_Opening {

    var position: Int32 = 0

    var match: Int32 = 0

    var contextPos: Int32 = 0

    var flags: Int16 = 0

    var contextDir: UInt8 = 0
}


class Bidi_IsoRun {

    var contextPos: Int32 = 0

    var start: Int16 = 0

    var limit: Int16 = 0

    var level: UInt8 = 0

    var lastStrong: UInt8 = 0

    var lastBase: UInt8 = 0

    var contextDir: UInt8 = 0
}


class Bidi_BracketData {

    var openings: Array<Bidi_Opening> = Array<Bidi_Opening>(Int64(Bidi.SIMPLE_OPENINGS_COUNT))

    var isoRunLast: Int32 = 0

    var isoRuns: Array<Bidi_IsoRun> = Array<Bidi_IsoRun>(Int64(Int32(Bidi.MAX_EXPLICIT_LEVEL) + 2))

    var isNumbersSpecial: Bool = false
}


class Bidi_Isolate {

    var startON: Int32 = 0

    var start1: Int32 = 0

    var stateImp: Int16 = 0

    var state: Int16 = 0
}


class Bidi_ImpTabPair {
    var imptab: Array<Array<Array<UInt8>>>

    var impact: Array<Array<Int16>>

    init(table1: Array<Array<UInt8>>, table2: Array<Array<UInt8>>, act1: Array<Int16>, act2: Array<Int16>) {
        imptab = [table1, table2]
        impact = [act1, act2]
    }
}


class Bidi_LevState {

    var impTab: Array<Array<UInt8>>

    var impAct: Array<Int16>

    var startON: Int32 = 0

    var startL2EN: Int32 = 0

    var lastStrongRTL: Int32 = 0

    var runStart: Int32 = 0

    var state: Int16 = 0

    var runLevel: UInt8 = 0
}
