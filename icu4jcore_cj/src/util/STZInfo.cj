package icu4cj.util

class STZInfo <: Serializable {

    private static let serialVersionUID = -7849612037842370168

    public func setStart(sm: Int32, sdwm: Int32, sdw: Int32, st: Int32, sdm: Int32, sa: Bool): Unit {
        this.sm = sm
        this.sdwm = sdwm
        this.sdw = sdw
        this.st = st
        this.sdm = sdm
        this.sa = sa
    }

    public func setEnd(em: Int32, edwm: Int32, edw: Int32, et: Int32, edm: Int32, ea: Bool): Unit {
        this.em = em
        this.edwm = edwm
        this.edw = edw
        this.et = et
        this.edm = edm
        this.ea = ea
    }

    public func applyTo(stz: SimpleTimeZone): Unit {
        if (sy != -1) {
            stz.setStartYear(sy)
        }
        if (sm != -1) {
            if (sdm == -1) {
                stz.setStartRule(sm, sdwm, sdw, st)
            } else if (sdw == -1) {
                stz.setStartRule(sm, sdm, st)
            } else {
                stz.setStartRule(sm, sdm, sdw, st, sa)
            }
        }
        if (em != -1) {
            if (edm == -1) {
                stz.setEndRule(em, edwm, edw, et)
            } else if (edw == -1) {
                stz.setEndRule(em, edm, et)
            } else {
                stz.setEndRule(em, edm, edw, et, ea)
            }
        }
    }

    var sy = -1

    var sm = -1

    var sdwm: Int32 = 0

    var sdw: Int32 = 0

    var st: Int32 = 0

    var sdm: Int32 = 0

    var sa: Bool = false

    var em = -1

    var edwm: Int32 = 0

    var edw: Int32 = 0

    var et: Int32 = 0

    var edm: Int32 = 0

    var ea: Bool = false
}
