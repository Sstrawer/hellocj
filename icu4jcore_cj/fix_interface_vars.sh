#!/bin/bash

# 修复接口中的变量声明问题
echo "开始修复接口中的变量声明问题..."

# 修复UProperty.cj中的变量声明
sed -i '' 's/^    let /    public static let /g' src/lang/UProperty.cj

# 修复UCharacterEnums.cj中的变量声明
sed -i '' 's/^    let /    public static let /g' src/lang/UCharacterEnums.cj

# 修复TimeUnitConstants.cj中的变量声明
sed -i '' 's/^    let /    public static let /g' src/impl/duration/TimeUnitConstants.cj

echo "接口变量声明修复完成！"
