package icu4cj.impl

public class ClassLoaderUtil {

     private static var BOOTSTRAP_CLASSLOADER: ClassLoader = None

    private static func getBootstrapClassLoader(): ClassLoader {
        if (BOOTSTRAP_CLASSLOADER.isNone()) {
            synchronized (getMonitorByObject(TypeInfo.of<ClassLoaderUtil>())) {
                if (BOOTSTRAP_CLASSLOADER.isNone()) {
                    var cl: ClassLoader = None
                    if (System.getSecurityManager().isSome()) {
                        cl = AccessController.doPrivileged(ClassLoaderUtil_1() as PrivilegedAction)
                    } else {
                        cl = ClassLoaderUtil_BootstrapClassLoader()
                    }
                    BOOTSTRAP_CLASSLOADER = cl
                }
            }
        }
        return BOOTSTRAP_CLASSLOADER
    }

    public static func getClassLoader(cls: ClassTypeInfo): ClassLoader {
        var cl = cls.getClassLoader()
        if (cl.isNone()) {
            cl = getClassLoader()
        }
        return cl
    }

    public static func getClassLoader(): ClassLoader {
        var cl = Thread.currentThread.getContextClassLoader()
        if (cl.isNone()) {
            cl = ClassLoader.getSystemClassLoader()
            if (cl.isNone()) {
                cl = getBootstrapClassLoader()
            }
        }
        return cl
    }
}


class ClassLoaderUtil_BootstrapClassLoader <: ClassLoader {
    init() {
        ClassLoader(TypeInfo.of<Object>().getClassLoader())
    }
}


class ClassLoaderUtil_1 <: PrivilegedAction {

    public override func run(): ClassLoaderUtil_BootstrapClassLoader {
        return ClassLoaderUtil_BootstrapClassLoader()
    }
}
