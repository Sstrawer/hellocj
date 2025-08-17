package icu4cj.text

class NormalizationTransliterator <: Transliterator {
    private let norm2: Normalizer2

    static func register(): Unit {
        Transliterator.registerFactory("Any-NFC", NormalizationTransliterator_1())
        Transliterator.registerFactory("Any-NFD", NormalizationTransliterator_2())
        Transliterator.registerFactory("Any-NFKC", NormalizationTransliterator_3())
        Transliterator.registerFactory("Any-NFKD", NormalizationTransliterator_4())
        Transliterator.registerFactory("Any-FCD", NormalizationTransliterator_5())
        Transliterator.registerFactory("Any-FCC", NormalizationTransliterator_6())
        Transliterator.registerSpecialInverse("NFC", "NFD", true)
        Transliterator.registerSpecialInverse("NFKC", "NFKD", true)
        Transliterator.registerSpecialInverse("FCC", "NFD", false)
        Transliterator.registerSpecialInverse("FCD", "FCD", false)
    }

    init(id: String, n2: Normalizer2) {
        super(id, None)
        norm2 = n2
    }

    override protected func handleTransliterate(text: Replaceable, offsets: Transliterator_Position, isIncremental: Bool): Unit {
        var start = offsets.start
        var limit = offsets.limit
        if (start >= limit) {
            return
        }
        let segment = StringBuilder()
        let normalized = StringBuilder()
        var c = text.char32At(start)
            if (start == limit && isIncremental && !norm2.hasBoundaryAfter(c)) {
                start = prev
                break
            }
            norm2.normalize(segment.toString(), normalized)
            if (!Normalizer2Impl_UTF16Plus.equal(segment.toString(), normalized.toString())) {
                text.replace(prev, start, normalized.toString())
                let delta = Int32(normalized.size) - (start - prev)
                start += delta
                limit += delta
            }
        } while (start < limit)
        offsets.start = start
        offsets.contextLimit += limit - offsets.limit
        offsets.limit = limit
    }

    static let SOURCE_CACHE: Map<Normalizer2, SourceTargetUtility> = HashMap<Normalizer2, SourceTargetUtility>()

    public override func addSourceTargetSet(inputFilter: UnicodeSet, sourceSet: UnicodeSet, targetSet: UnicodeSet): Unit {
        var cache: SourceTargetUtility
        synchronized (// Expecting Object descendant, got interface std$collection.Map<class com.ibm.icu.text.Normalizer2, class com.ibm.icu.text.SourceTargetUtility>: SOURCE_CACHE) {
            cache = SOURCE_CACHE.get(norm2)
            if (cache.isNone()) {
                cache = SourceTargetUtility(NormalizationTransliterator_NormalizingTransform(norm2), norm2)
                SOURCE_CACHE.put(norm2, cache)
            }
        }
        cache.addSourceTargetSet(this, inputFilter, sourceSet, targetSet)
    }
}


class NormalizationTransliterator_1 <: Transliterator_Factory {

    public override func getInstance(ID: String): Transliterator {
        return NormalizationTransliterator("NFC", Normalizer2.getNFCInstance())
    }
}


class NormalizationTransliterator_2 <: Transliterator_Factory {

    public override func getInstance(ID: String): Transliterator {
        return NormalizationTransliterator("NFD", Normalizer2.getNFDInstance())
    }
}


class NormalizationTransliterator_3 <: Transliterator_Factory {

    public override func getInstance(ID: String): Transliterator {
        return NormalizationTransliterator("NFKC", Normalizer2.getNFKCInstance())
    }
}


class NormalizationTransliterator_4 <: Transliterator_Factory {

    public override func getInstance(ID: String): Transliterator {
        return NormalizationTransliterator("NFKD", Normalizer2.getNFKDInstance())
    }
}


class NormalizationTransliterator_5 <: Transliterator_Factory {

    public override func getInstance(ID: String): Transliterator {
        return NormalizationTransliterator("FCD", Norm2AllModes.getFCDNormalizer2())
    }
}


class NormalizationTransliterator_6 <: Transliterator_Factory {

    public override func getInstance(ID: String): Transliterator {
        return NormalizationTransliterator("FCC", Norm2AllModes.getNFCInstance().fcc)
    }
}


class NormalizationTransliterator_NormalizingTransform <: Transform<String, String> {
    let norm2: Normalizer2

    public init(norm2: Normalizer2) {
        this.norm2 = norm2
    }

    public override func transform(source: String): String {
        return norm2.normalize(source)
    }
}
