package icu4cj.text

public interface StringTransform <: Transform<String, String> {
    public override func transform(source: String): String
}