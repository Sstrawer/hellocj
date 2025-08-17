package icu4cj.impl

public abstract class CacheValue<V> {

     private static var strength: CacheValue_Strength = CacheValue_Strength.SOFT

    private static let NULL_VALUE: CacheValue<Any> = CacheValue_NullValue<Any>()

    public static func setStrength(strength: CacheValue_Strength): Unit {
        CacheValue.strength = strength
    }

    public static func futureInstancesWillBeStrong(): Bool {
        return refEq(strength, CacheValue_Strength.STRONG)
    }

    public static func getInstance<V>(value: V): CacheValue<V> {
        if (value.isNone()) {
            return NULL_VALUE
        }
        return if (refEq(strength, CacheValue_Strength.STRONG)) { CacheValue_StrongValue<V>(value) } else { CacheValue_SoftValue<V>(value) }
    }

    public func isNull(): Bool {
        return false
    }

    public func get(): V

    public func resetIfCleared(value: V): V
}

public class CacheValue_Strength <: Enum<CacheValue_Strength> {
    public static let STRONG = CacheValue_Strength("STRONG", 0)

    public static let SOFT = CacheValue_Strength("SOFT", 1)

    private static func _values(): Array<CacheValue_Strength> {
        return [CacheValue_Strength.STRONG, CacheValue_Strength.SOFT]
    }

    private static let _VALUES = CacheValue_Strength._values()

    public static func values(): Array<CacheValue_Strength> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): CacheValue_Strength {
        return (TypeInfo.of<CacheValue_Strength>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as CacheValue_Strength
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


class CacheValue_NullValue<V> <: CacheValue<V> {
    init() {
        super()
    }

    public override func isNull(): Bool {
        return true
    }

    public override func get(): V {
        return None
    }

    public override func resetIfCleared(value: V): V {
        if (value.isSome()) {
            throw ICUException("resetting a null value to a non-null value")
        }
        return None
    }
}

class CacheValue_StrongValue<V> <: CacheValue<V> {
    private var value: V

    init(value: V) {
        super()
        this.value = value
    }

    public override func get(): V {
        return value
    }

    public override func resetIfCleared(value: V): V {
        return this.value
    }
}

class CacheValue_SoftValue<V> <: CacheValue<V> & Synchronizable {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

     private var ref: Reference = None

    init(value: V) {
        super()
        ref = SoftReference(value)
    }

    public override func get(): V {
        return ref.get()
    }

    public override func resetIfCleared(value: V): V {
        synchronized (GeneratedLockObject) {
            let oldValue: V = ref.get()
            if (oldValue.isNone()) {
                ref = SoftReference(value)
                return value
            } else {
                return oldValue
            }
        }
    }
}