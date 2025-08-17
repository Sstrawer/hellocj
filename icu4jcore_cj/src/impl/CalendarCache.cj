package icu4cj.impl

public class CalendarCache <: Synchronizable {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    public init() {
        makeArrays(arraySize)
    }

    private func makeArrays(newSize: Int32): Unit {
        keys = Array<Int64>(Int64(newSize)) { _ => 0 }
        values = Array<Int64>(Int64(newSize)) { _ => 0 }
        var i = 0
        while (i < newSize) {
            values[Int64(i)] = EMPTY
            i++
        }
        arraySize = newSize
        threshold = Int32(Float64(arraySize) * 0.75)
        size = 0
    }

    public func get(key: Int64): Int64 {
        synchronized (GeneratedLockObject) {
            return values[Int64(findIndex(key))]
        }
    }

    public func put(key: Int64, value: Int64): Unit {
        synchronized (GeneratedLockObject) {
            if (size >= threshold) {
                rehash()
            }
            let index = findIndex(key)
            keys[Int64(index)] = key
            values[Int64(index)] = value
            size++
        }
    }

    private func findIndex(key: Int64): Int32 {
        var index = hash(key)
        var delta = 0
        while (values[Int64(index)] != EMPTY && keys[Int64(index)] != key) {
            if (delta == 0) {
                delta = hash2(key)
            }
            index = (index + delta) % arraySize
        }
        return index
    }

    private func rehash(): Unit {
        let oldSize = arraySize
        let oldKeys = keys
        let oldValues = values
        if (pIndex < Int32(primes.size) - 1) {
            arraySize = primes[Int64(match (0) { case _ => pIndex++; pIndex })]
        } else {
            arraySize = arraySize * 2 + 1
        }
        size = 0
        makeArrays(arraySize)
        var i = 0
        while (i < oldSize) {
            if (oldValues[Int64(i)] != EMPTY) {
                put(oldKeys[Int64(i)], oldValues[Int64(i)])
            }
            i++
        }
    }

    private func hash(key: Int64): Int32 {
        var h = Int32((key * 15821 + 1) % Int64(arraySize))
        if (h < 0) {
            h += arraySize
        }
        return h
    }

    private func hash2(key: Int64): Int32 {
        return arraySize - 2 - Int32(key % (Int64(arraySize - 2)))
    }

    private static let primes = [61, 127, 509, 1021, 2039, 4093, 8191, 16381, 32749, 65521, 131071, 262139]

    private var pIndex = 0

    private var size = 0

    private var arraySize = primes[Int64(pIndex)]

    private var threshold = (arraySize * 3) / 4

    private var keys: Array<Int64> = Array<Int64>(Int64(arraySize)) { _ => 0 }

    private var values: Array<Int64> = Array<Int64>(Int64(arraySize)) { _ => 0 }

    public static var EMPTY = Int64.Min
}
