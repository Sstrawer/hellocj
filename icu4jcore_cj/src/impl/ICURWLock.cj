package icu4cj.impl


public class ICURWLock <: Synchronizable {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }


    private var rwl: ReentrantReadWriteLock = ReentrantReadWriteLock()

    private var stats: ICURWLock_Stats

    public func resetStats(): ICURWLock_Stats {
        synchronized (GeneratedLockObject) {
            let result = stats
            stats = ICURWLock_Stats()
            return result
        }
    }

    public func clearStats(): ICURWLock_Stats {
        synchronized (GeneratedLockObject) {
            let result = stats
            stats = None
            return result
        }
    }

    public func getStats(): ICURWLock_Stats {
        synchronized (GeneratedLockObject) {
            return if (stats.isNone()) { None } else { ICURWLock_Stats(stats) }
        }
    }

    public func acquireRead(): Unit {
        if (stats.isSome()) {
            synchronized (getMonitorByObject(this)) {
                stats._rc++
                if (rwl.getReadLockCount() > 0) {
                    stats._mrc++
                }
                if (rwl.isWriteLocked()) {
                    stats._wrc++
                }
            }
        }
        rwl.readLock().lock()
    }

    public func releaseRead(): Unit {
        rwl.readLock().unlock()
    }

    public func acquireWrite(): Unit {
        if (stats.isSome()) {
            synchronized (getMonitorByObject(this)) {
                stats._wc++
                if (rwl.getReadLockCount() > 0 || rwl.isWriteLocked()) {
                    stats._wwc++
                }
            }
        }
        rwl.writeLock().lock()
    }

    public func releaseWrite(): Unit {
        rwl.writeLock().unlock()
    }
}


public class ICURWLock_Stats {
    public var _rc: Int32 = 0

    public var _mrc: Int32 = 0

    public var _wrc: Int32 = 0

    public var _wc: Int32 = 0

    public var _wwc: Int32 = 0


    private init(rc: Int32, mrc: Int32, wrc: Int32, wc: Int32, wwc: Int32) {
        this._rc = rc
        this._mrc = mrc
        this._wrc = wrc
        this._wc = wc
        this._wwc = wwc
    }

    init(rhs: ICURWLock_Stats) {
        this(rhs._rc, rhs._mrc, rhs._wrc, rhs._wc, rhs._wwc)
    }

    public override func toString(): String {
        return " rc: " + _rc.toString() + " mrc: " + _mrc.toString() + " wrc: " + _wrc.toString() + " wc: " + _wc.toString() + " wwc: " + _wwc.toString()
    }
}
