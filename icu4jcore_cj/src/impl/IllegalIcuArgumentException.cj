package icu4cj.impl

public class IllegalIcuArgumentException <: IllegalArgumentException & Synchronizable {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    private static let serialVersionUID = 3789261542830211225

    public init(errorMessage: String) {
        super(errorMessage)
    }

    public init(cause: Exception) {
        super()
    }

    public init(errorMessage: String, cause: Exception) {
        super(errorMessage)
    }

    public override func initCause(cause: Exception): IllegalIcuArgumentException {
        synchronized (GeneratedLockObject) {
            return super.initCause(cause)
        }
    }
}
