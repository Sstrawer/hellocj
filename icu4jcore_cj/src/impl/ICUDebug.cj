package icu4cj.impl

public class ICUDebug {

    private static var params: String


    private static var debug = params.isSome()

    private static var help = debug && (params == "" || indexOfWrap(params.indexOf("help")) != -1)


    public static func enabled(): Bool {
        return debug
    }

    public static func enabled(arg: String): Bool {
        if (debug) {
            let result = indexOfWrap(params.indexOf(arg)) != -1
            if (help) {
                println("\nICUDebug.enabled(" + (arg) + ") = " + result.toString())
            }
            return result
        }
        return false
    }

    public static func value(arg: String): String {
        var result: String = "false"
        if (debug) {
            var index = indexOfWrap(params.indexOf(arg))
            if (index != -1) {
                index += Int32(arg.size)
                if (Int32(params.size) > index && Char(params[Int64(index)]) == '=') {
                    index += 1
                    let limit = indexOfWrap(params.indexOf(",", Int64(index)))
                    result = params[Int64(index)..if (limit == -1) { params.size } else { Int64(limit) }]
                } else {
                    result = "true"
                }
            }
            if (help) {
                println("\nICUDebug.value(" + (arg) + ") = " + (result))
            }
        }
        return result
    }
}
