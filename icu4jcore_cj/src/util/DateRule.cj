package icu4cj.util

public interface DateRule {
    public func firstAfter(start: DateTime): DateTime

    public func firstBetween(start: DateTime, end: DateTime): DateTime

    public func isOn(date: DateTime): Bool

    public func isBetween(start: DateTime, end: DateTime): Bool
}