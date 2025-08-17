package icu4cj.text

public interface Transform<S, D> {
    public func transform(source: S): D
}