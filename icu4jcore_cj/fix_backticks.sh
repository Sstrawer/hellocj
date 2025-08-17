#!/bin/bash

# 批量修复反引号问题
echo "开始修复反引号问题..."

# 修复所有.cj文件中的反引号包围的var声明
find src -name "*.cj" -type f -exec sed -i '' 's/`var`/var/g' {} \;

# 修复所有.cj文件中的反引号包围的let声明
find src -name "*.cj" -type f -exec sed -i '' 's/`let`/let/g' {} \;

# 修复所有.cj文件中的反引号包围的func声明
find src -name "*.cj" -type f -exec sed -i '' 's/`func`/func/g' {} \;

# 修复所有.cj文件中的反引号包围的class声明
find src -name "*.cj" -type f -exec sed -i '' 's/`class`/class/g' {} \;

# 修复所有.cj文件中的反引号包围的interface声明
find src -name "*.cj" -type f -exec sed -i '' 's/`interface`/interface/g' {} \;

# 修复所有.cj文件中的反引号包围的match声明
find src -name "*.cj" -type f -exec sed -i '' 's/`match`/match/g' {} \;

# 修复所有.cj文件中的反引号包围的case声明
find src -name "*.cj" -type f -exec sed -i '' 's/`case`/case/g' {} \;

# 修复所有.cj文件中的反引号包围的while声明
find src -name "*.cj" -type f -exec sed -i '' 's/`while`/while/g' {} \;

# 修复所有.cj文件中的反引号包围的if声明
find src -name "*.cj" -type f -exec sed -i '' 's/`if`/if/g' {} \;

# 修复所有.cj文件中的反引号包围的else声明
find src -name "*.cj" -type f -exec sed -i '' 's/`else`/else/g' {} \;

# 修复所有.cj文件中的反引号包围的for声明
find src -name "*.cj" -type f -exec sed -i '' 's/`for`/for/g' {} \;

# 修复所有.cj文件中的反引号包围的return声明
find src -name "*.cj" -type f -exec sed -i '' 's/`return`/return/g' {} \;

# 修复所有.cj文件中的反引号包围的throw声明
find src -name "*.cj" -type f -exec sed -i '' 's/`throw`/throw/g' {} \;

# 修复所有.cj文件中的反引号包围的try声明
find src -name "*.cj" -type f -exec sed -i '' 's/`try`/try/g' {} \;

# 修复所有.cj文件中的反引号包围的catch声明
find src -name "*.cj" -type f -exec sed -i '' 's/`catch`/catch/g' {} \;

# 修复所有.cj文件中的反引号包围的finally声明
find src -name "*.cj" -type f -exec sed -i '' 's/`finally`/finally/g' {} \;

# 修复所有.cj文件中的反引号包围的new声明
find src -name "*.cj" -type f -exec sed -i '' 's/`new`/new/g' {} \;

# 修复所有.cj文件中的反引号包围的super声明
find src -name "*.cj" -type f -exec sed -i '' 's/`super`/super/g' {} \;

# 修复所有.cj文件中的反引号包围的this声明
find src -name "*.cj" -type f -exec sed -i '' 's/`this`/this/g' {} \;

# 修复所有.cj文件中的反引号包围的static声明
find src -name "*.cj" -type f -exec sed -i '' 's/`static`/static/g' {} \;

# 修复所有.cj文件中的反引号包围的public声明
find src -name "*.cj" -type f -exec sed -i '' 's/`public`/public/g' {} \;

# 修复所有.cj文件中的反引号包围的private声明
find src -name "*.cj" -type f -exec sed -i '' 's/`private`/private/g' {} \;

# 修复所有.cj文件中的反引号包围的protected声明
find src -name "*.cj" -type f -exec sed -i '' 's/`protected`/protected/g' {} \;

# 修复所有.cj文件中的反引号包围的override声明
find src -name "*.cj" -type f -exec sed -i '' 's/`override`/override/g' {} \;

# 修复所有.cj文件中的反引号包围的abstract声明
find src -name "*.cj" -type f -exec sed -i '' 's/`abstract`/abstract/g' {} \;

# 修复所有.cj文件中的反引号包围的final声明
find src -name "*.cj" -type f -exec sed -i '' 's/`final`/final/g' {} \;

# 修复所有.cj文件中的反引号包围的synchronized声明
find src -name "*.cj" -type f -exec sed -i '' 's/`synchronized`/synchronized/g' {} \;

# 修复所有.cj文件中的反引号包围的volatile声明
find src -name "*.cj" -type f -exec sed -i '' 's/`volatile`/volatile/g' {} \;

# 修复所有.cj文件中的反引号包围的transient声明
find src -name "*.cj" -type f -exec sed -i '' 's/`transient`/transient/g' {} \;

# 修复所有.cj文件中的反引号包围的native声明
find src -name "*.cj" -type f -exec sed -i '' 's/`native`/native/g' {} \;

# 修复所有.cj文件中的反引号包围的strictfp声明
find src -name "*.cj" -type f -exec sed -i '' 's/`strictfp`/strictfp/g' {} \;

# 修复所有.cj文件中的反引号包围的default声明
find src -name "*.cj" -type f -exec sed -i '' 's/`default`/default/g' {} \;

# 修复所有.cj文件中的反引号包围的break声明
find src -name "*.cj" -type f -exec sed -i '' 's/`break`/break/g' {} \;

# 修复所有.cj文件中的反引号包围的continue声明
find src -name "*.cj" -type f -exec sed -i '' 's/`continue`/continue/g' {} \;

# 修复所有.cj文件中的反引号包围的switch声明
find src -name "*.cj" -type f -exec sed -i '' 's/`switch`/switch/g' {} \;

# 修复所有.cj文件中的反引号包围的do声明
find src -name "*.cj" -type f -exec sed -i '' 's/`do`/do/g' {} \;

# 修复所有.cj文件中的反引号包围的import声明
find src -name "*.cj" -type f -exec sed -i '' 's/`import`/import/g' {} \;

# 修复所有.cj文件中的反引号包围的package声明
find src -name "*.cj" -type f -exec sed -i '' 's/`package`/package/g' {} \;

# 修复所有.cj文件中的反引号包围的extends声明
find src -name "*.cj" -type f -exec sed -i '' 's/`extends`/extends/g' {} \;

# 修复所有.cj文件中的反引号包围的implements声明
find src -name "*.cj" -type f -exec sed -i '' 's/`implements`/implements/g' {} \;

# 修复所有.cj文件中的反引号包围的instanceof声明
find src -name "*.cj" -type f -exec sed -i '' 's/`instanceof`/instanceof/g' {} \;

# 修复所有.cj文件中的反引号包围的enum声明
find src -name "*.cj" -type f -exec sed -i '' 's/`enum`/enum/g' {} \;

# 修复所有.cj文件中的反引号包围的assert声明
find src -name "*.cj" -type f -exec sed -i '' 's/`assert`/assert/g' {} \;

# 修复所有.cj文件中的反引号包围的const声明
find src -name "*.cj" -type f -exec sed -i '' 's/`const`/const/g' {} \;

# 修复所有.cj文件中的反引号包围的goto声明
find src -name "*.cj" -type f -exec sed -i '' 's/`goto`/goto/g' {} \;

# 修复所有.cj文件中的反引号包围的synchronized声明
find src -name "*.cj" -type f -exec sed -i '' 's/`synchronized`/synchronized/g' {} \;

# 修复所有.cj文件中的反引号包围的transient声明
find src -name "*.cj" -type f -exec sed -i '' 's/`transient`/transient/g' {} \;

# 修复所有.cj文件中的反引号包围的volatile声明
find src -name "*.cj" -type f -exec sed -i '' 's/`volatile`/volatile/g' {} \;

# 修复所有.cj文件中的反引号包围的native声明
find src -name "*.cj" -type f -exec sed -i '' 's/`native`/native/g' {} \;

# 修复所有.cj文件中的反引号包围的strictfp声明
find src -name "*.cj" -type f -exec sed -i '' 's/`strictfp`/strictfp/g' {} \;

# 修复所有.cj文件中的反引号包围的default声明
find src -name "*.cj" -type f -exec sed -i '' 's/`default`/default/g' {} \;

# 修复所有.cj文件中的反引号包围的break声明
find src -name "*.cj" -type f -exec sed -i '' 's/`break`/break/g' {} \;

# 修复所有.cj文件中的反引号包围的continue声明
find src -name "*.cj" -type f -exec sed -i '' 's/`continue`/continue/g' {} \;

# 修复所有.cj文件中的反引号包围的switch声明
find src -name "*.cj" -type f -exec sed -i '' 's/`switch`/switch/g' {} \;

# 修复所有.cj文件中的反引号包围的do声明
find src -name "*.cj" -type f -exec sed -i '' 's/`do`/do/g' {} \;

# 修复所有.cj文件中的反引号包围的import声明
find src -name "*.cj" -type f -exec sed -i '' 's/`import`/import/g' {} \;

# 修复所有.cj文件中的反引号包围的package声明
find src -name "*.cj" -type f -exec sed -i '' 's/`package`/package/g' {} \;

# 修复所有.cj文件中的反引号包围的extends声明
find src -name "*.cj" -type f -exec sed -i '' 's/`extends`/extends/g' {} \;

# 修复所有.cj文件中的反引号包围的implements声明
find src -name "*.cj" -type f -exec sed -i '' 's/`implements`/implements/g' {} \;

# 修复所有.cj文件中的反引号包围的instanceof声明
find src -name "*.cj" -type f -exec sed -i '' 's/`instanceof`/instanceof/g' {} \;

# 修复所有.cj文件中的反引号包围的enum声明
find src -name "*.cj" -type f -exec sed -i '' 's/`enum`/enum/g' {} \;

# 修复所有.cj文件中的反引号包围的assert声明
find src -name "*.cj" -type f -exec sed -i '' 's/`assert`/assert/g' {} \;

# 修复所有.cj文件中的反引号包围的const声明
find src -name "*.cj" -type f -exec sed -i '' 's/`const`/const/g' {} \;

# 修复所有.cj文件中的反引号包围的goto声明
find src -name "*.cj" -type f -exec sed -i '' 's/`goto`/goto/g' {} \;

echo "反引号修复完成！"
