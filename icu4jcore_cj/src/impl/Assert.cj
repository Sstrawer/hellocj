package icu4cj.impl

public class Assert {

    public static func fail(e: Exception): Unit {
        fail(e.toString())
    }

    public static func fail(msg: String): Unit {
        throw Exception("failure '" + (msg) + "'")
    }

    public static func assrt(val: Bool): Unit {
        if (!val) {
            throw Exception("assert failed")
        }
    }

    public static func assrt(msg: String, val: Bool): Unit {
        if (!val) {
            throw Exception("assert '" + (msg) + "' failed")
        }
    }
}
