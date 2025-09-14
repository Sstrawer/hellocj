macro package icu.utilmacro

import std.ast.*
import std.fs.*
import std.collection.*

public macro res(inputTokens: Tokens): Tokens {
    let str = inputTokens.toString()
    let resfilepath = str[1..str.size-1]
    let arr = File.readFrom(resfilepath)
    return arr.toTokens()
}