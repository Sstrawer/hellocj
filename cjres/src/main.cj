package icu

import icu.utilmacro.*
import icu.res.*
import std.runtime.*
import std.convert.*

// let a: Array<UInt8> = @res("../src/main/resources/com/ibm/icu/impl/data/icudata/zh.res")

main(): Int64 {
    println("hello world")
    let max=getMaxHeapSize()
    let allocated=getUsedHeapSize()
    println("""
max: ${max.format('x')} 
allocate: ${getAllocatedHeapSize().format('x')} 
used: ${allocated.format('x')} ${Float64(allocated)/Float64(max)}
""")
    return 0
}
