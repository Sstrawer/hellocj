package icu4cj.impl


public class Norm2AllModes {
    init(ni: Normalizer2Impl) {
        impl = ni
        comp = Norm2AllModes_ComposeNormalizer2(ni, false)
        decomp = Norm2AllModes_DecomposeNormalizer2(ni)
        fcd = Norm2AllModes_FCDNormalizer2(ni)
        fcc = Norm2AllModes_ComposeNormalizer2(ni, true)
    }

    public let impl: Normalizer2Impl

    public let comp: Norm2AllModes_ComposeNormalizer2

    public let decomp: Norm2AllModes_DecomposeNormalizer2

    public let fcd: Norm2AllModes_FCDNormalizer2

    public let fcc: Norm2AllModes_ComposeNormalizer2

    private static func getInstanceFromSingleton(singleton: Norm2AllModes_Norm2AllModesSingleton): Norm2AllModes {
        if (singleton.exception.isSome()) {
            throw singleton.exception
        }
        return singleton.allModes
    }

    public static func getNFCInstance(): Norm2AllModes {
        return getInstanceFromSingleton(Norm2AllModes_NFCSingleton.INSTANCE)
    }

    public static func getNFKCInstance(): Norm2AllModes {
        return getInstanceFromSingleton(Norm2AllModes_NFKCSingleton.INSTANCE)
    }

    public static func getNFKC_CFInstance(): Norm2AllModes {
        return getInstanceFromSingleton(Norm2AllModes_NFKC_CFSingleton.INSTANCE)
    }

    public static func getNFKC_SCFInstance(): Norm2AllModes {
        return getInstanceFromSingleton(Norm2AllModes_NFKC_SCFSingleton.INSTANCE)
    }

    public static func getN2WithImpl(index: Int32): Norm2AllModes_Normalizer2WithImpl {
        match (index) {
            case 0 => return getNFCInstance().decomp
            case 1 => return getNFKCInstance().decomp
            case 2 => return getNFCInstance().comp
            case 3 => return getNFKCInstance().comp
            case _ => return None
        }
    }

    public static func getInstance(bytes: ByteArrayStream, name: String): Norm2AllModes {
        if (bytes.isNone()) {
            let singleton: Norm2AllModes_Norm2AllModesSingleton
            if (name == "nfc") {
                singleton = Norm2AllModes_NFCSingleton.INSTANCE
            } else if (name == "nfkc") {
                singleton = Norm2AllModes_NFKCSingleton.INSTANCE
            } else if (name == "nfkc_cf") {
                singleton = Norm2AllModes_NFKC_CFSingleton.INSTANCE
            } else {
                singleton = None
            }
            if (singleton.isSome()) {
                if (singleton.exception.isSome()) {
                    throw singleton.exception
                }
                return singleton.allModes
            }
        }
        return cache.getInstance(name, bytes)
    }

    private static var cache: CacheBase<String, Norm2AllModes, ByteArrayStream> = Norm2AllModes_1()

    public static let NOOP_NORMALIZER2 = Norm2AllModes_NoopNormalizer2()

    public static func getFCDNormalizer2(): Normalizer2 {
        return getNFCInstance().fcd
    }
}


public class Norm2AllModes_NoopNormalizer2 <: Normalizer2 {
    public init() {
        super()
    }

    public override func normalize(src: String, dest: StringBuilder): StringBuilder {
        if (!refEq(dest, src)) {
            dest.setLength(0)
            return dest.append(src)
        } else {
            throw IllegalArgumentException()
        }
    }

    public override func normalize(src: String, dest: Appendable): Appendable {
        if (!refEq(dest, src)) {
            try {
                return dest.append(src)
            } catch (e: IOException) {
                throw ICUUncheckedIOException(e)
            }
        } else {
            throw IllegalArgumentException()
        }
    }

    public override func normalizeSecondAndAppend(first: StringBuilder, second: String): StringBuilder {
        if (!refEq(first, second)) {
            return first.append(second)
        } else {
            throw IllegalArgumentException()
        }
    }

    public override func append(first: StringBuilder, second: String): StringBuilder {
        if (!refEq(first, second)) {
            return first.append(second)
        } else {
            throw IllegalArgumentException()
        }
    }

    public override func getDecomposition(c: Int32): String {
        return None
    }

    public override func isNormalized(s: String): Bool {
        return true
    }

    public override func quickCheck(s: String): Normalizer_QuickCheckResult {
        return Normalizer.YES
    }

    public override func spanQuickCheckYes(s: String): Int32 {
        return s.size
    }

    public override func hasBoundaryBefore(c: Int32): Bool {
        return true
    }

    public override func hasBoundaryAfter(c: Int32): Bool {
        return true
    }

    public override func isInert(c: Int32): Bool {
        return true
    }
}


public abstract class Norm2AllModes_Normalizer2WithImpl <: Normalizer2 {
    public init(ni: Normalizer2Impl) {
        super()
        impl = ni
    }

    public override func normalize(src: String, dest: StringBuilder): StringBuilder {
        if (refEq(dest, src)) {
            throw IllegalArgumentException()
        }
        dest.setLength(0)
        normalize(src, Normalizer2Impl_ReorderingBuffer(impl, dest, src.size))
        return dest
    }

    public override func normalize(src: String, dest: Appendable): Appendable {
        if (refEq(dest, src)) {
            throw IllegalArgumentException()
        }
        let buffer = Normalizer2Impl_ReorderingBuffer(impl, dest, src.size)
        normalize(src, buffer)
        buffer.flush()
        return dest
    }

    protected func normalize(src: String, buffer: Normalizer2Impl_ReorderingBuffer): Unit

    public override func normalizeSecondAndAppend(first: StringBuilder, second: String): StringBuilder {
        return normalizeSecondAndAppend(first, second, true)
    }

    public override func append(first: StringBuilder, second: String): StringBuilder {
        return normalizeSecondAndAppend(first, second, false)
    }

    public func normalizeSecondAndAppend(first: StringBuilder, second: String, doNormalize: Bool): StringBuilder {
        if (refEq(first, second)) {
            throw IllegalArgumentException()
        }
        normalizeAndAppend(second, doNormalize, Normalizer2Impl_ReorderingBuffer(impl, first, Int32(first.size) + second.size))
        return first
    }

    protected func normalizeAndAppend(src: String, doNormalize: Bool, buffer: Normalizer2Impl_ReorderingBuffer): Unit

    public override func getDecomposition(c: Int32): String {
        return impl.getDecomposition(c)
    }

    public override func getRawDecomposition(c: Int32): String {
        return impl.getRawDecomposition(c)
    }

    public override func composePair(a: Int32, b: Int32): Int32 {
        return impl.composePair(a, b)
    }

    public override func getCombiningClass(c: Int32): Int32 {
        return impl.getCC(impl.getNorm16(c))
    }

    public override func isNormalized(s: String): Bool {
        return s.size == spanQuickCheckYes(s)
    }

    public override func quickCheck(s: String): Normalizer_QuickCheckResult {
        return if (isNormalized(s)) { Normalizer.YES } else { Normalizer.NO }
    }

    public func getQuickCheck(c: Int32): Int32

    public let impl: Normalizer2Impl
}


public class Norm2AllModes_DecomposeNormalizer2 <: Norm2AllModes_Normalizer2WithImpl {
    public init(ni: Normalizer2Impl) {
        super(ni)
    }

    override protected func normalize(src: String, buffer: Normalizer2Impl_ReorderingBuffer): Unit {
        impl.decompose(src, 0, src.size, buffer)
    }

    override protected func normalizeAndAppend(src: String, doNormalize: Bool, buffer: Normalizer2Impl_ReorderingBuffer): Unit {
        impl.decomposeAndAppend(src, doNormalize, buffer)
    }

    public override func spanQuickCheckYes(s: String): Int32 {
        return impl.decompose(s, 0, s.size, None)
    }

    public override func getQuickCheck(c: Int32): Int32 {
        return if (impl.isDecompYes(impl.getNorm16(c))) { 1 } else { 0 }
    }

    public override func hasBoundaryBefore(c: Int32): Bool {
        return impl.hasDecompBoundaryBefore(c)
    }

    public override func hasBoundaryAfter(c: Int32): Bool {
        return impl.hasDecompBoundaryAfter(c)
    }

    public override func isInert(c: Int32): Bool {
        return impl.isDecompInert(c)
    }
}


public class Norm2AllModes_ComposeNormalizer2 <: Norm2AllModes_Normalizer2WithImpl {
    public init(ni: Normalizer2Impl, fcc: Bool) {
        super(ni)
        onlyContiguous = fcc
    }

    override protected func normalize(src: String, buffer: Normalizer2Impl_ReorderingBuffer): Unit {
        impl.compose(src, 0, src.size, onlyContiguous, true, buffer)
    }

    override protected func normalizeAndAppend(src: String, doNormalize: Bool, buffer: Normalizer2Impl_ReorderingBuffer): Unit {
        impl.composeAndAppend(src, doNormalize, onlyContiguous, buffer)
    }

    public override func isNormalized(s: String): Bool {
        return impl.compose(s, 0, s.size, onlyContiguous, false, Normalizer2Impl_ReorderingBuffer(impl, StringBuilder() as Appendable, 5))
    }

    public override func quickCheck(s: String): Normalizer_QuickCheckResult {
        let spanLengthAndMaybe = impl.composeQuickCheck(s, 0, s.size, onlyContiguous, false)
        if ((spanLengthAndMaybe & 1) != 0) {
            return Normalizer.MAYBE
        } else if ((ushr(spanLengthAndMaybe, 1)) == s.size) {
            return Normalizer.YES
        } else {
            return Normalizer.NO
        }
    }

    public override func spanQuickCheckYes(s: String): Int32 {
        return ushr(impl.composeQuickCheck(s, 0, s.size, onlyContiguous, true), 1)
    }

    public override func getQuickCheck(c: Int32): Int32 {
        return impl.getCompQuickCheck(impl.getNorm16(c))
    }

    public override func hasBoundaryBefore(c: Int32): Bool {
        return impl.hasCompBoundaryBefore(c)
    }

    public override func hasBoundaryAfter(c: Int32): Bool {
        return impl.hasCompBoundaryAfter(c, onlyContiguous)
    }

    public override func isInert(c: Int32): Bool {
        return impl.isCompInert(c, onlyContiguous)
    }

    private let onlyContiguous: Bool
}


public class Norm2AllModes_FCDNormalizer2 <: Norm2AllModes_Normalizer2WithImpl {
    public init(ni: Normalizer2Impl) {
        super(ni)
    }

    override protected func normalize(src: String, buffer: Normalizer2Impl_ReorderingBuffer): Unit {
        impl.makeFCD(src, 0, src.size, buffer)
    }

    override protected func normalizeAndAppend(src: String, doNormalize: Bool, buffer: Normalizer2Impl_ReorderingBuffer): Unit {
        impl.makeFCDAndAppend(src, doNormalize, buffer)
    }

    public override func spanQuickCheckYes(s: String): Int32 {
        return impl.makeFCD(s, 0, s.size, None)
    }

    public override func getQuickCheck(c: Int32): Int32 {
        return if (impl.isDecompYes(impl.getNorm16(c))) { 1 } else { 0 }
    }

    public override func hasBoundaryBefore(c: Int32): Bool {
        return impl.hasFCDBoundaryBefore(c)
    }

    public override func hasBoundaryAfter(c: Int32): Bool {
        return impl.hasFCDBoundaryAfter(c)
    }

    public override func isInert(c: Int32): Bool {
        return impl.isFCDInert(c)
    }
}


class Norm2AllModes_1 <: SoftCache<String, Norm2AllModes, ByteArrayStream> {
    init() {
        super()
    }

    override protected func createInstance(key: String, bytes: ByteArrayStream): Norm2AllModes {
        let impl: Normalizer2Impl
        if (bytes.isNone()) {
            impl = Normalizer2Impl().load((key) + ".nrm")
        } else {
            impl = Normalizer2Impl().load(bytes)
        }
        return Norm2AllModes(impl)
    }
}


class Norm2AllModes_Norm2AllModesSingleton {
    init(name: String) {
        try {
            let impl = Normalizer2Impl().load((name) + ".nrm")
            allModes = Norm2AllModes(impl)
        } catch (e: Exception) {
            exception = e
        }
    }

    var allModes: Norm2AllModes

    var exception: Exception
}


class Norm2AllModes_NFCSingleton {

    static let INSTANCE = Norm2AllModes_Norm2AllModesSingleton("nfc")
}


class Norm2AllModes_NFKCSingleton {

    static let INSTANCE = Norm2AllModes_Norm2AllModesSingleton("nfkc")
}


class Norm2AllModes_NFKC_CFSingleton {

    static let INSTANCE = Norm2AllModes_Norm2AllModesSingleton("nfkc_cf")
}


class Norm2AllModes_NFKC_SCFSingleton {

    static let INSTANCE = Norm2AllModes_Norm2AllModesSingleton("nfkc_scf")
}
