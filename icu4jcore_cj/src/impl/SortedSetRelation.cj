package icu4cj.impl


public class SortedSetRelation {

    public static let A_NOT_B = 4

    public static let A_AND_B = 2

    public static let B_NOT_A = 1

    public static let ANY = A_NOT_B | A_AND_B | B_NOT_A

    public static let CONTAINS = A_NOT_B | A_AND_B

    public static let DISJOINT = A_NOT_B | B_NOT_A

    public static let ISCONTAINED = A_AND_B | B_NOT_A

    public static let NO_B = A_NOT_B

    public static let EQUALS = A_AND_B

    public static let NO_A = B_NOT_A

    public static let NONE = 0

    public static let ADDALL = ANY

    public static let A = CONTAINS

    public static let COMPLEMENTALL = DISJOINT

    public static let B = ISCONTAINED

    public static let REMOVEALL = NO_B

    public static let RETAINALL = EQUALS

    public static let B_REMOVEALL = NO_A

    public static func hasRelation<T>(a: SortedSet, allow: Int32, b: SortedSet): Bool {
        if (allow < NONE || allow > ANY) {
            throw IllegalArgumentException("Relation " + allow.toString() + " out of range")
        }
        let anb = (allow & A_NOT_B) != 0
        let ab = (allow & A_AND_B) != 0
        let bna = (allow & B_NOT_A) != 0
        match (allow) {
            case 6 => if (Int32(a.size) < Int32(b.size)) {
                return false
            }
            case 3 => if (Int32(a.size) > Int32(b.size)) {
                return false
            }
            case 2 => if (Int32(a.size) != Int32(b.size)) {
                return false
            }
            case _ => ()
        }
        if (Int32(a.size) == 0) {
            if (Int32(b.size) == 0) {
                return true
            }
            return bna
        } else if (Int32(b.size) == 0) {
            return anb
        }
        let ait: Iterator<T> = a.iterator()
        let bit: Iterator<T> = b.iterator()
        var aa: T = ait.next()
        var bb: T = bit.next()
        while (true) {
            let comp = aa.compareTo(bb)
            if (comp == 0) {
                if (!ab) {
                    return false
                }
                if (!ait.hasNext()) {
                    if (!bit.hasNext()) {
                        return true
                    }
                    return bna
                } else if (!bit.hasNext()) {
                    return anb
                }
                aa = ait.next()
                bb = bit.next()
            } else if (comp < 0) {
                if (!anb) {
                    return false
                }
                if (!ait.hasNext()) {
                    return bna
                }
                aa = ait.next()
            } else {
                if (!bna) {
                    return false
                }
                if (!bit.hasNext()) {
                    return anb
                }
                bb = bit.next()
            }
        }
        throw Exception()
    }

    public static func doOperation<T>(a: SortedSet, relation: Int32, b: SortedSet): SortedSet {
        let temp: TreeSet
        match (relation) {
            case 7 =>
                a.addAll(b)
                return a
            case 6 => return a
            case 3 =>
                a.clear()
                a.addAll(b)
                return a
            case 4 =>
                a.removeAll(b)
                return a
            case 2 =>
                a.retainAll(b)
                return a
            case 5 =>
                temp = TreeSet(b)
                temp.removeAll(a)
                a.removeAll(b)
                a.addAll(temp)
                return a
            case 1 =>
                temp = TreeSet(b)
                temp.removeAll(a)
                a.clear()
                a.addAll(temp)
                return a
            case 0 =>
                a.clear()
                return a
            case _ => throw IllegalArgumentException("Relation " + relation.toString() + " out of range")
        }
    }
}
