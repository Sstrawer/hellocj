package icu4cj.impl.data

public class HolidayBundle_el <: ListResourceBundle & Synchronizable {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    public init() {
        ListResourceBundle()
    }

    private static let fContents: Array<Array<Object>> = [["Assumption", "15 \u{0391}\u{03cd}\u{03b3}\u{03bf}\u{03cd}\u{03c3}\u{03c4}\u{03bf}\u{03c5}"], ["Boxing Day", "\u{0394}\u{03b5}\u{03cd}\u{03c4}\u{03b5}\u{03c1}\u{03b7} \u{03bc}\u{03ad}\u{03c1}\u{03b1} \u{03c4}\u{03ce}\u{03bd} \u{03a7}\u{03c1}\u{03b9}\u{03c3}\u{03c4}\u{03bf}\u{03c5}\u{03b3}\u{03ad}\u{03bd}\u{03bd}\u{03c9}\u{03bd}"], ["Christmas", "\u{03a7}\u{03c1}\u{03b9}\u{03c3}\u{03c4}\u{03bf}\u{03cd}\u{03b3}\u{03b5}\u{03bd}\u{03bd}\u{03b1}"], ["Clean Monday", "\u{039a}\u{03b1}\u{03b8}\u{03b1}\u{03c1}\u{03ae} \u{0394}\u{03b5}\u{03c5}\u{03c4}\u{03ad}\u{03c1}\u{03b1}"], ["Easter Monday", "\u{0394}\u{03b5}\u{03cd}\u{03c4}\u{03b5}\u{03c1}\u{03b7} \u{03bc}\u{03ad}\u{03c1}\u{03b1} \u{03c4}\u{03bf}\u{03cd} \u{03a0}\u{03ac}\u{03c3}\u{03c7}\u{03b1}"], ["Epiphany", "\u{0388}\u{03c0}\u{03b9}\u{03c6}\u{03ac}\u{03bd}\u{03b5}\u{03b9}\u{03b1}"], ["Good Friday", "\u{039c}\u{03b5}\u{03b3}\u{03ac}\u{03bb}\u{03b7} \u{03a0}\u{03b1}\u{03c1}\u{03b1}\u{03c3}\u{03ba}\u{03b5}\u{03c5}\u{03ae}"], ["May Day", "\u{03a0}\u{03c1}\u{03c9}\u{03c4}\u{03bf}\u{03bc}\u{03b1}\u{03b3}\u{03b9}\u{03ac}"], ["New Year's Day", "\u{03a0}\u{03c1}\u{03c9}\u{03c4}\u{03bf}\u{03c7}\u{03c1}\u{03bf}\u{03bd}\u{03b9}\u{03ac}"], ["Ochi Day", "28 \u{038c}\u{03ba}\u{03c4}\u{03c9}\u{03b2}\u{03c1}\u{03af}\u{03bf}\u{03c5}"], ["Whit Monday", "\u{0394}\u{03b5}\u{03cd}\u{03c4}\u{03b5}\u{03c1}\u{03b7} \u{03bc}\u{03ad}\u{03c1}\u{03b1} \u{03c4}\u{03bf}\u{03cd} \u{03a0}\u{03b5}\u{03bd}\u{03c4}\u{03b7}\u{03ba}\u{03bf}\u{03c3}\u{03c4}\u{03ae}"]]

    public override func getContents(): Array<Array<Object>> {
        synchronized (GeneratedLockObject) {
            return fContents
        }
    }
}
