package icu4cj.impl

public abstract class ICUNotifier {

    private let notifyLock = Object()

    private var notifyThread: ICUNotifier_NotifyThread

    private var listeners: ArrayList<EventListener> = None

    public func addListener(l: EventListener): Unit {
        if (l.isNone()) {
            throw NoneValueException()
        }
        if (acceptsListener(l)) {
            synchronized (getMonitorByObject(notifyLock)) {
                if (listeners.isNone()) {
                    listeners = ArrayList<EventListener>()
                } else {
                    for (ll in listeners) {
                        if (refEq(ll, l)) {
                            return
                        }
                    }
                }
                listeners.append(l)
            }
        } else {
            throw Exception("Listener invalid for this notifier.")
        }
    }

    public func removeListener(l: EventListener): Unit {
        if (l.isNone()) {
            throw NoneValueException()
        }
        synchronized (getMonitorByObject(notifyLock)) {
            if (listeners.isSome()) {
                let iter: Iterator<EventListener> = listeners.iterator()
                while (iter.hasNext()) {
                    if (refEq(iter.next(), l)) {
                        iter.remove()
                        if (Int32(listeners.size) == 0) {
                            listeners = None
                        }
                        return
                    }
                }
            }
        }
    }

    public func notifyChanged(): Unit {
        synchronized (getMonitorByObject(notifyLock)) {
            if (listeners.isSome()) {
                if (notifyThread.isNone()) {
                    notifyThread = ICUNotifier_NotifyThread(this)
                    notifyThread.setDaemon(true)
                    notifyThread.start()
                }
                notifyThread.queueMethod(listeners.toArray(Array<<-->(listeners.size)) : Array<??EventListener> => Array<EventListener> -->)
            }
        }
    }

    protected func acceptsListener(l: EventListener): Bool

    protected func notifyListener(l: EventListener): Unit
}


class ICUNotifier_NotifyThread <: Thread & Synchronizable {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    private let notifier: ICUNotifier

    private let queue = ArrayList<Array<EventListener>>()

    init(notifier: ICUNotifier) {
        super()
        this.notifier = notifier
    }

    public func queueMethod(list: Array<EventListener>): Unit {
        synchronized (getMonitorByObject(this)) {
            queue.append(list)
            notify()
        }
    }

    public override func run(): Unit {
        var list: Array<EventListener> = None
        while (true) {
            @AssertThrows[Exception]({
                synchronized (getMonitorByObject(this)) {
                    while (queue.isEmpty()) {
                        wait()
                    }
                    list = queue.remove(0)
                }
                var i = 0
                while (i < Int32(list.size)) {
                    notifier.notifyListener(list[Int64(i)])
                    i++
                }
            })
        }
    }
}
