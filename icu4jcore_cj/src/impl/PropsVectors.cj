package icu4cj.impl

public class PropsVectors {
    var v: Array<Int32>

    var columns: Int32 = 0

    private var maxRows: Int32 = 0

    private var rows: Int32 = 0

    private var prevRow: Int32 = 0

    private var isCompacted: Bool = false

    private func areElementsSame(index1: Int32, target: Array<Int32>, index2: Int32, length: Int32): Bool {
        var i = 0
        while (i < length) {
            if (v[Int64(index1 + i)] != target[Int64(index2 + i)]) {
                return false
            }
            i++
        }
        return true
    }

    private func findRow(rangeStart: Int32): Int32 {
        var index = 0
        index = prevRow * columns
        if (rangeStart >= v[Int64(index)]) {
            if (rangeStart < v[Int64(index + 1)]) {
                return index
            } else {
                index += columns
                if (rangeStart < v[Int64(index + 1)]) {
                    prevRow++
                    return index
                } else {
                    index += columns
                    if (rangeStart < v[Int64(index + 1)]) {
                        prevRow += 2
                        return index
                    } else if ((rangeStart - v[Int64(index + 1)]) < 10) {
                        prevRow += 2
                        return index
                    }
                }
            }
        } else if (rangeStart < v[1]) {
            prevRow = 0
            return 0
        }
        var start = 0
        var mid = 0
        var limit = rows
        while (start < limit - 1) {
            mid = (start + limit) / 2
            index = columns * mid
            if (rangeStart < v[Int64(index)]) {
                limit = mid
            } else if (rangeStart < v[Int64(index + 1)]) {
                prevRow = mid
                return index
            } else {
                start = mid
            }
        }
        prevRow = start
        index = start * columns
        return index
    }

    public static let FIRST_SPECIAL_CP = 1114112

    public static let INITIAL_VALUE_CP = 1114112

    public static let ERROR_VALUE_CP = 1114113

    public static let MAX_CP = 1114113

    public static let INITIAL_ROWS = shl(1, 12)

    public static let MEDIUM_ROWS = shl(1, 16)

    public static let MAX_ROWS = MAX_CP + 1

    public init(numOfColumns: Int32) {
        if (numOfColumns < 1) {
            throw IllegalArgumentException("numOfColumns need to be no less than 1; but it is " + numOfColumns.toString())
        }
        columns = numOfColumns + 2
        v = Array<Int32>(Int64(INITIAL_ROWS * columns)) { _ => 0 }
        maxRows = INITIAL_ROWS
        rows = 2 + (MAX_CP - FIRST_SPECIAL_CP)
        prevRow = 0
        isCompacted = false
        v[0] = 0
        v[1] = 1114112
        var index = columns
        var cp = FIRST_SPECIAL_CP
        while (cp <= MAX_CP) {
            v[Int64(index)] = cp
            v[Int64(index + 1)] = cp + 1
            index += columns
            cp++
        }
    }

    public func setValue(start: Int32, end: Int32, column: Int32, value: Int32, mask: Int32): Unit {
        var tempcolumn = column
        var tempvalue = value
        var tempmask = mask
        if (start < 0 || start > end || end > MAX_CP || tempcolumn < 0 || tempcolumn >= (columns - 2)) {
            throw IllegalArgumentException()
        }
        if (isCompacted) {
            throw Exception("Shouldn't be called aftercompact()!")
        }
        var firstRow: Int32 = 0
        var lastRow: Int32 = 0
        let limit = end + 1
        let splitFirstRow: Bool
        let splitLastRow: Bool
        tempcolumn += 2
        tempvalue &= tempmask
        firstRow = findRow(start)
        lastRow = findRow(end)
        splitFirstRow = (start != v[Int64(firstRow)] && tempvalue != (v[Int64(firstRow + tempcolumn)] & tempmask))
        splitLastRow = (limit != v[Int64(lastRow + 1)] && tempvalue != (v[Int64(lastRow + tempcolumn)] & tempmask))
        if (splitFirstRow || splitLastRow) {
            var rowsToExpand = 0
            if (splitFirstRow) {
                rowsToExpand++
            }
            if (splitLastRow) {
                rowsToExpand++
            }
            var newMaxRows = 0
            if ((rows + rowsToExpand) > maxRows) {
                if (maxRows < MEDIUM_ROWS) {
                    newMaxRows = MEDIUM_ROWS
                } else if (maxRows < MAX_ROWS) {
                    newMaxRows = MAX_ROWS
                } else {
                    throw IndexOutOfBoundsException("MAX_ROWS exceeded! Increase it to a higher valuein the implementation")
                }
                let temp = Array<Int32>(Int64(newMaxRows * columns)) { _ => 0 }
                arraycopy(v, 0, temp, 0, Int64(rows * columns))
                v = temp
                maxRows = newMaxRows
            }
            var count = (rows * columns) - (lastRow + columns)
            if (count > 0) {
                arraycopy(v, Int64(lastRow + columns), v, Int64(lastRow + (1 + rowsToExpand) * columns), Int64(count))
            }
            rows += rowsToExpand
            if (splitFirstRow) {
                count = lastRow - firstRow + columns
                arraycopy(v, Int64(firstRow), v, Int64(firstRow + columns), Int64(count))
                lastRow += columns
                v[Int64(firstRow + 1)] = match (0) { case _ => v[Int64(firstRow + columns)] = start; v[Int64(firstRow + columns)] }
                firstRow += columns
            }
            if (splitLastRow) {
                arraycopy(v, Int64(lastRow), v, Int64(lastRow + columns), Int64(columns))
                v[Int64(lastRow + 1)] = match (0) { case _ => v[Int64(lastRow + columns)] = limit; v[Int64(lastRow + columns)] }
            }
        }
        prevRow = lastRow / columns
        firstRow += tempcolumn
        lastRow += tempcolumn
        tempmask = 
        while (true) {
            v[Int64(firstRow)] = (v[Int64(firstRow)] & tempmask) | tempvalue
            if (firstRow == lastRow) {
                break
            }
            firstRow += columns
        }
    }

    public func getValue(c: Int32, column: Int32): Int32 {
        if (isCompacted || c < 0 || c > MAX_CP || column < 0 || column >= (columns - 2)) {
            return 0
        }
        let index = findRow(c)
        return v[Int64(index + 2 + column)]
    }

    public func getRow(rowIndex: Int32): Array<Int32> {
        if (isCompacted) {
            throw Exception("Illegal Invocation of the method after compact()")
        }
        if (rowIndex < 0 || rowIndex > rows) {
            throw IllegalArgumentException("rowIndex out of bound!")
        }
        let rowToReturn = Array<Int32>(Int64(columns - 2)) { _ => 0 }
        arraycopy(v, Int64(rowIndex * columns + 2), rowToReturn, 0, Int64(columns - 2))
        return rowToReturn
    }

    public func getRowStart(rowIndex: Int32): Int32 {
        if (isCompacted) {
            throw Exception("Illegal Invocation of the method after compact()")
        }
        if (rowIndex < 0 || rowIndex > rows) {
            throw IllegalArgumentException("rowIndex out of bound!")
        }
        return v[Int64(rowIndex * columns)]
    }

    public func getRowEnd(rowIndex: Int32): Int32 {
        if (isCompacted) {
            throw Exception("Illegal Invocation of the method after compact()")
        }
        if (rowIndex < 0 || rowIndex > rows) {
            throw IllegalArgumentException("rowIndex out of bound!")
        }
        return v[Int64(rowIndex * columns + 1)] - 1
    }

    public func compact(compactor: PropsVectors_CompactHandler): Unit {
        if (isCompacted) {
            return
        }
        isCompacted = true
        let valueColumns = columns - 2
        let indexArray = Array<Int32>(Int64(rows))
        } while (false)
        stableSort(indexArray, PropsVectors_1(this) as Comparator)
        var count = -valueColumns
                if (start == INITIAL_VALUE_CP) {
                    compactor.setRowIndexForInitialValue(count)
                } else if (start == ERROR_VALUE_CP) {
                    compactor.setRowIndexForErrorValue(count)
                }
                i++
            }
        } while (false)
        count += valueColumns
        compactor.startRealValues(count)
        let temp = Array<Int32>(Int64(count)) { _ => 0 }
        count = -valueColumns
                if (start < FIRST_SPECIAL_CP) {
                    compactor.setRowIndexForRange(start, limit - 1, count)
                }
                i++
            }
        } while (false)
        v = temp
        rows = count / valueColumns + 1
    }

    public func getCompactedArray(): Array<Int32> {
        if (!isCompacted) {
            throw Exception("Illegal Invocation of the method before compact()")
        }
        return v
    }

    public func getCompactedRows(): Int32 {
        if (!isCompacted) {
            throw Exception("Illegal Invocation of the method before compact()")
        }
        return rows
    }

    public func getCompactedColumns(): Int32 {
        if (!isCompacted) {
            throw Exception("Illegal Invocation of the method before compact()")
        }
        return columns - 2
    }

    public func compactToTrieWithRowIndexes(): IntTrie {
        let compactor = PVecToTrieCompactHandler()
        compact(compactor)
        return compactor.builder.serialize(PropsVectors_DefaultGetFoldedValue(compactor.builder), PropsVectors_DefaultGetFoldingOffset())
    }
}


class PropsVectors_1 <: Comparator {
    let this_0: PropsVectors

    init(this_0: PropsVectors) {
        this.this_0 = this_0
    }

    public override func compare(o1: Int32, o2: Int32): Int32 {
        let indexOfRow1 = o1
        let indexOfRow2 = o2
        var count = this_0.columns
        var index = 2
            if (match (0) { case _ => index++; index } == this_0.columns) {
                index = 0
            }
        } while (match (0) { case _ => count--; count } > 0)
        return 0
    }
}


class PropsVectors_DefaultGetFoldingOffset <: Trie_DataManipulate {

    public override func getFoldingOffset(value: Int32): Int32 {
        return value
    }
}


class PropsVectors_DefaultGetFoldedValue <: TrieBuilder_DataManipulate {
    private var builder: IntTrieBuilder

    public init(inBuilder: IntTrieBuilder) {
        builder = inBuilder
    }

    public override func getFoldedValue(start: Int32, offset: Int32): Int32 {
        var tempstart = start
        let initialValue = builder.m_initialValue_
        let limit = tempstart + 1024
        while (tempstart < limit) {
            let inBlockZero = Array<Bool>(1) { _ => false }
            let value = builder.getValue(tempstart, inBlockZero)
            if (inBlockZero[0]) {
                tempstart += TrieBuilder.DATA_BLOCK_LENGTH
            } else if (value != initialValue) {
                return offset
            } else {
                tempstart++
            }
        }
        return 0
    }
}


public interface PropsVectors_CompactHandler {
    public func setRowIndexForRange(start: Int32, end: Int32, rowIndex: Int32): Unit

    public func setRowIndexForInitialValue(rowIndex: Int32): Unit

    public func setRowIndexForErrorValue(rowIndex: Int32): Unit

    public func startRealValues(rowIndex: Int32): Unit
}