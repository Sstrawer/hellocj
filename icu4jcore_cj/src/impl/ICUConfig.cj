package icu4cj.impl


public class ICUConfig {

    public static let CONFIG_PROPS_FILE = "/com/ibm/icu/ICUConfig.properties"

    private static let CONFIG_PROPS: Properties


    public static func get(name: String): String {
        return get(name, None)
    }

    public static func get(name: String, def: String): String {
        var val: String
        let fname = name
        if (System.getSecurityManager().isSome()) {
            try {
                val = AccessController.doPrivileged(ICUConfig_1(fname) as PrivilegedAction)
            } catch (e: AccessControlException) { }
        } else {
            val = System.getProperty(name)
        }
        if (val.isNone() || val == "") {
            val = CONFIG_PROPS.getProperty(name, def)
        }
        return val
    }
}


class ICUConfig_1 <: PrivilegedAction {
    let val_fname: String

    init(val_fname: String) {
        this.val_fname = val_fname
    }

    public override func run(): String {
        return System.getProperty(val_fname)
    }
}
