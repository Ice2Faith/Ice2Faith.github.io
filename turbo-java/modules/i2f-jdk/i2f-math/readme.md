# i2f-math 数学计算工具箱

## 概述

`i2f-math` 是 i2f-turbo-java 框架中**规模最大、功能最杂的纯 JDK 数学工具集合模块**（14 源文件约 3100 行），覆盖五个子领域——静态数学函数门面（`MathUtil`，1037 行）、双栈字符串公式计算器（`FormulaCalculator`，905 行）、矩阵运算（`Matrix`/`MatrixInt`，各 348 行）、区间/线段抽象（`Segment` 四元组）以及缓存数列（`Fibonacci`/`Factorial`）+ 进制转换（`HexNumberConverter`）。五个子领域之间**零耦合**，各自独立可独立使用。

### 子领域概览

| 子领域 | 源文件 | 行数 | 核心类 |
|--------|--------|------|--------|
| 静态数学函数门面 | `MathUtil.java` | 1037 | `MathUtil` |
| 字符串公式计算器 | `FormulaCalculator.java` | 905 | `FormulaCalculator` |
| 矩阵运算 | `Matrix.java` + `MatrixInt.java` + `MatrixDiffrentException.java` | 713 | `Matrix`, `MatrixInt` |
| 区间抽象 | `Segment.java` + 4 实现 | 209 | `Segment<Date/Long/Integer/Double>` |
| 进制转换 | `HexNumberConverter.java` | 121 | `HexNumberConverter` |
| 缓存数列 | `Fibonacci.java` + `Factorial.java` | 85 | `Fibonacci`, `Factorial` |
| 区间工厂 | `Segments.java` | 27 | `Segments` |

## 依赖关系

| 依赖类型 | 坐标 | 说明 |
|---------|------|------|
| 编译 | `i2f.turbo:i2f-jdk` (parent) | 仅继承父 POM 版本管理 |
| provided | `org.projectlombok:lombok` | **真实使用**于 `Segment` 基类的 `@Data` |

> 全模块零三方运行期依赖。maven-assembly-plugin 用于 fat-jar 构建。

## 包结构

```
i2f.math
├── MathUtil.java              # 静态数学函数门面（1037 行）
├── Fibonacci.java              # 缓存斐波那契数列
├── Factorial.java              # 缓存阶乘
├── HexNumberConverter.java     # 2-36 进制数转换
├── Segments.java               # 区间工厂门面
├── calculator/
│   └── FormulaCalculator.java  # 双栈字符串公式计算器
├── matrix/
│   ├── Matrix.java             # double 矩阵类
│   ├── MatrixInt.java          # int 矩阵类
│   └── MatrixDiffrentException.java
└── segment/
    ├── Segment.java            # 抽象区间基类
    ├── IntegerSegment.java
    ├── LongSegment.java
    ├── DoubleSegment.java
    └── DateSegment.java
```

## 子领域详解

### 1. MathUtil 静态数学门面

**总计约 70+ 静态方法**，按功能分组：

#### 数学常量
| 常量 | 值 | 说明 |
|------|-----|------|
| `PI` / `PI_RADIAN` | 3.141592653549626 | π，与 JDK `Math.PI` 精度不同 |
| `PI2` | `PI * 2` | 2π |
| `PI_ANGLE` | 180.0 | 180° 对应弧度 |
| `PI_ANGLE2` | `PI_ANGLE * 2` | 360° |
| `RANDOM` | `new SecureRandom()` | 全局安全随机数源 |

#### 基本算术（int/long/double 三类型重载）
- `abs` 绝对值、`opposite` 相反数、`reciprocal` 倒数
- `square` 平方、`cube` 立方
- `distance(d1,d2)` 一维距离（`abs(d2-d1)`）
- `distance(x1,y1,x2,y2)` / `distance(x1,y1,z1,x2,y2,z2)` 欧氏距离

#### 聚集运算（int/long/double 三类型重载）
- `min` / `max` 变长参数最值
- `sum` / `mul` 变长参数求和/积
- `sumi(i)` / `muli(i)` 1→i 的累加/累乘
- `sumij(i,j,step?)` / `mulij(i,j,step?)` i→j 的累加/累乘（支持反向）
- `squareSum` / `cubeSum` / `sqrtSquareSum` 平方和/立方和/均方根
- `arrangement(n,m)` / `combination(n,m)` 排列组合

#### 几何与三角
- `radianTriangle(lenA,lenB,lenC)` / `angleTriangle` 余弦定理求角
- `radian(dx,dy)` / `radian(bx,by,ex,ey)` 坐标→弧度
- `angle2radian` / `radian2angle` 弧角互转
- `regularRadian` / `regularAngle` 规范化到 [0,2π) / [0,360°)

#### 插值与平滑
- `smooth(rate,start,end)` / `smoothValue` 线性插值
- `smoothRate(begin,end,ref)` 反向求比例
- `gather(val,min)` / `lower(val,max)` / `between(val,min,max)` 区间钳制
- `regular(val,min,max)` 循环区间取模

#### 随机数（基于 `SecureRandom`）
- `rand()` / `rand(max)` / `rand(min,max)` 随机整数
- `randInt` 系列同 `rand` 系列（命名冗余）
- `randDouble()` / `randPercent()` / `randBoolean()`

#### 精度控制
- `trunc(num,prec)` 截断到指定位数（prec≥0 小数截断，prec<0 整数级舍入）
- `fibonacci(i)` 委托 `Fibonacci.get(i)` 取数列第 i 项

---

### 2. FormulaCalculator 字符串公式计算器

基于 C++ 移植的双栈（数字栈 + 符号栈）公式计算器，以 `BigDecimal` 高精度运算，支持 **60+ 运算符**。

#### 运算符分类

| 类别 | 运算符 | 示例 |
|------|--------|------|
| 基础双目 | `+ - * / % ^` | `3+2*5-(2^3)%5` |
| 扩展双目 | `sqrt log adds muls and or xor lmov rmov max min avg recipadds recipmuls minsum maxfac peradd persub rand dayofmonth` | `2 sqrt 4`(4开2次根), `2 log 8`(以2为底8的对数), `1 adds 5`(1+...+5), `7 and 3`(位与) |
| 单目 | `not ! neg per abs radian angle sin cos tan arcsin arccos arctan recip epow ln numpi nume numgsec xpowx randz randf ceil floor round dhead ftail dayofyear kmhtoms mstokmh fttoct cttoft feibo` | `3!`(阶乘), `5neg`(负5), `50per`(百分之50), `(60radian)sin`(sin60°) |
| 内建 | `dehex` | `16 dehex0c`(16进制0c转10进制) |

#### 内建常量
- `PI` = 3.141592653549626
- `E` = 2.718281828459045
- 黄金分割率 = 0.618033988749894

#### 使用方法
```java
FormulaCalculator calc = new FormulaCalculator();
BigDecimal result = calc.calculate("3+2*5-(2^3)%5 + 2 sqrt 4 + 1 adds 5");
```

**注意**：三角函数族使用弧度制；运算符不区分大小写；空格任意添加；`dehex` 后紧跟数值不能有空格。

#### 静态工具方法
- `buildPrepareFormula(preFormula,flags,values)` 符号替换预处理
- `hex2Number(str,base)` / `number2Hex(num,base,decimal)` 进制转换
- `getUseHelpStr()` 获取使用帮助字符串
- `isLeapYear(year)` 闰年判断
- `feiboSeqIdx(idx)` 递归斐波那契索引（**注意**：递归实现，大索引性能差）

---

### 3. 矩阵运算（Matrix / MatrixInt）

`Matrix`（`double[][]` 后备）与 `MatrixInt`（`int[][]` 后备）结构完全对称，提供以下能力：

| 操作 | 方法 | 说明 |
|------|------|------|
| 构造 | `Matrix(rows,cols)` / `Matrix(size)` / `Matrix(double[][])` / `Matrix(double[])` / `Matrix(List)` | 5 种构造器 |
| 单位矩阵 | `makeE(size)` | 对角线为 1 |
| 转置 | `transpose()` | `M[i][j] → M[j][i]` |
| 加法 | `add(m2)` / `add(m1,m2)` | 同型矩阵逐元素相加 |
| 标量乘 | `mul(val)` / `mul(m,val)` | 每元素乘常数 |
| 矩阵乘法 | `mul(m2)` / `mul(m1,m2)` | `A.cols == B.rows` |
| 逐元素操作 | `everyMul` / `everyAdd` / `everySet` | 就地修改 |
| 行/列提取 | `row(r)` / `col(c)` | 返回副本数组 |
| 判定 | `isRegular()` 方阵 / `isDiff(m2)` 非同型 / `assertDiff(m2)` 断言 |

`MatrixDiffrentException extends ArithmeticException` 用于矩阵尺寸不匹配时抛出。

---

### 4. 区间抽象（Segment 四元组）

`Segment<T extends Comparable<T>, D>` 是泛型抽象基类，定义区间/线段的长度计算与重叠判定协议：

```java
public abstract D distance();                    // 区间长度
public abstract Segment<T,D> instance(T,T);     // 用新边界创建实例
public abstract D addDistance(D d1, D d2);       // 长度相加
public abstract int compareDistance(D d1, D d2); // 长度比较

public boolean isOverlap(Segment<T,D> segment);  // 两区间是否有重叠
```

`isOverlap` 核心逻辑：两区间长度之和 > 合并后的总长度 → 存在重叠。

四种实现：

| 类型 | T | D | 长度计算 |
|------|---|----|---------|
| `IntegerSegment` | `Integer` | `Integer` | `Math.abs(end - begin)` |
| `LongSegment` | `Long` | `Long` | `Math.abs(end - begin)` |
| `DoubleSegment` | `Double` | `Double` | `Math.abs(end - begin)` |
| `DateSegment` | `Date` | `Long` | `Math.abs(end.getTime() - begin.getTime())` |

`Segments.of(begin,end)` 工厂门面按参数类型自动分派。

---

### 5. 缓存数列

| 类 | 缓存范围 | 算法 | 异常 |
|----|----------|------|------|
| `Fibonacci.get(i)` | `BigInteger[0..99]` | 递归 + 缓存（`nums[i]` 懒填充） | `i<0` 返回 `-1` |
| `Factorial.get(n)` | `BigInteger[0..99]` | 递归 + 缓存（`nums[n]` 懒填充） | `n<0` 抛 `IllegalArgumentException` |

两者均超出缓存范围时仅计算不缓存。

---

### 6. 进制转换

`HexNumberConverter` 支持 **2-36 进制**的字符串与数值互转（字符集 `0-9A-Z`）：

| 方法 | 说明 |
|------|------|
| `hex2number(str, base)` | 任意进制字符串→`double`（支持小数部分） |
| `number2hex(num, base, scale)` | 数值→任意进制字符串（`scale` 控制小数位数） |
| `isNumberChar(ch, base)` | 判断字符是否是该进制有效数字 |
| `getNumCharValue(ch, base)` | 获取字符在该进制下的数值 |

---

### 7. 下游消费者

| 模块 | 消费内容 |
|------|----------|
| `i2f-color` | `MathUtil.between` / `smooth`（RGBA 插值与钳制） |
| `i2f-graphics-2d` | `MathUtil` |
| `i2f-graphics-3d` | `MathUtil` |
| `i2f-image-impl` | `MathUtil`（~18 滤镜） |
| `i2f-extension-gif` | `MathUtil` |
| `i2f-ai-std` / `i2f-extension-xproc4j` | `FormulaCalculator` = `calculate()` |

## 已知瑕疵与设计说明

### 已知瑕疵

1. **`MathUtil.combination`**：使用 `int` 运算，**32 位溢出无保护**且 `muli(m)` 循环 `j=1; j<i` 漏乘 `i` 本身（应有 `j<=i`），导致组合数结果偏小。
2. **`MathUtil.fibonacci(i)`**：委托 `Fibonacci.get(i).longValue()`，**超过 `Long.MAX_VALUE` 无声截断**。
3. **`MathUtil.regular`**：使用 `while` 循环而非取模运算，**大值性能差**（如 `regular(1e10, 0, 1)` 循环 1e10 次）。
4. **`FormulaCalculator.calculate`**：`dehex` 运算符用 `String.valueOf(m_numberStack.pop().intValue())` 取进制数，但**进制值未校验**（非 2-36 基也能执行）；小数位数固定 `DEFAULT_CONTEXT`（16 位精度）可能丢失精度。
5. **`FormulaCalculator`**：单线程非安全（实例字段 `m_numberStack`/`m_flagStack` 共享状态），并发需各自 new 实例。
6. **`Segment.isOverlap`**：`addDistance` 可能加法溢出（`Integer.MAX_VALUE` 段长），但 `Segment` 文档中有 `(dis1+dis2)>dis → dis1+dis2-dis>0` 的溢出规避说明——然而 `dis1+dis2` 本身在 `IntegerSegment.addDistance` 中已经溢出了，防御未生效。
7. **`Fibonacci.get(i)`**：负值返回 `NEG_ONE`，而非抛出异常，与 `Factorial` 负值行为不一致。
8. **`MathUtil.randPercent()`**：命名不准确——返回 `[0.0, 1.0)` 而非严格百分比 `[0, 100]`。
9. **`Matrix` 与 `MatrixInt`**：无行列式、逆矩阵、伴随矩阵等高等线性代数运算；无迭代器/行流/列流；`everyMul`/`everyAdd`/`everySet` 是 static 副作用方法（修改入参），与 `mul(val)` 返回新对象的语义不一致。
10. **`MatrixDiffrentException`**：拼写为 `Diffrent`（应为 `Different`），且有两处命名不一致——`assertDiff`（缺 r）与 `isDiff`（缺 r）均已省略字母。

### 设计说明

- **零三方依赖**：全模块仅依赖 JDK 标准库（`java.math.BigDecimal`、`java.security.SecureRandom`），可在任意 JDK 8+ 环境直接使用。
- **`MathUtil` 与 `java.lang.Math` 的关系**：`MathUtil` 不替代 `Math` 的基础函数（sin/cos/exp 仍委托 `Math`），而是补充 JDK 缺失的"业务数学"——插值、钳制、排列组合、坐标几何、区间规整。
- **`FormulaCalculator` 的单例 vs 实例**：`hex2Number`/`number2Hex` 为静态方法可安全调用；`calculate(formula)` 操作实例状态，每次计算需 `new FormulaCalculator()` 或自行管理线程隔离。
- **接口抛 `Throwable` 的设计**：`ILock`/`INotify` 等锁接口的方法签名抛 `Throwable`，避免强制 try-catch，与 `Runnable` 抛 `Throwable` 一致的最低承诺原则——详见 [i2f-lock 文档](../i2f-lock/readme.md)。