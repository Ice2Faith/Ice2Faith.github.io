# go 语法简介

## 语法总结
- 在编译器的层面，保证代码的整洁
- 用编译器的方式避免部分代码异味
- 也就是在语法层面，加上了格式等可能出现异味的要求

## 基础横向对比
- 语句之后，不强制也不建议加分号
```go
var name = "marks"
```
- 具有语法格式上的要求
- 比如，作用域括号符号位置
- 运算符前后需要有空格等
```
var age = 12
```
- 对未使用变量的编译器要求
- 未使用的变量将会在编译时报错
```
func main(){
    var name = "marks"
}
```
- 作用域开始符号，必须是行最后一个字符
- 最常见的就是花括号{
```go
func main(){

}
```
- 不过，上面说到的，针对语法格式的要求中
- 可以直接在对应的IDE环境中，添加插件进行格式化得到解决
- 也可以使用go提供的命令行格式化工具
```shell script
go fmt hello.go
```
- 面向过程开发
- 也可以通过一定手段使得面向对象开发
- 声明变量使用var关键字
- 变量类型在变量名之后
- 支持自动类型推导
```go
var 变量名 变量类型 = 变量值

var name string
var name string = "marks"
```
- 类型推导情况下，可以去掉变量类型
```go
var 变量名 = 变量值

var name = "marks"
```
- 使用立即定义，可以省略var关键字
```go
变量名 := 变量值

name := "marks"
```
- 可以使用解包定义多个变量
```go
var (
    变量名1 变量类型1 = 变量值1
    变量名2 变量类型2 = 变量值2
)

var (
    name string
    age int = 14
    grade int
)
```
- 使用nil表示空
```go
nil
```
- 函数允许返回多个值
```go
func getData()(ret int,err erros){
    return 1,nil
}
```
- 可以使用下划线_定义匿名变量
- 用来忽略一些不想处理的值
- 比如，用来忽略函数返回的异常
```go
ret,_ := getData()
```
- 使用const关键字定义常量
- 常量必须有定义值
```go
const 变量名 变量类型 = 变量值

const pi = 3.1415926
```
- 主文件必须包是main，具有main函数
```go
package main

func main(){

}
```

## 常用的包
- fmt 标准输入输出
- math 数学运算
- net 网络
- net/http HTTP
- io IO处理
- io/fs 文件系统
- io/ioutil IO工具
- os 操作系统
- os/exec 命令执行
- flag 命令行参数解析
- errors 异常
- strconv 字符串与基本类型转换
- strings 字符串操作

## 快速入门
## 基本介绍
- 变量声明，关键字：var
- 变量声明并复制，操作符：:=
- 函数声明，关键字：func
- 函数支持多个返回值
- 可以给类型绑定函数，感觉和定义类函数一样
- 类型声明，关键字：type
- 数组或内建复杂类型，大部分都是使用中括号访问
    - 数组、切片：arr[0],arr[1]
    - 映射：map["a"],map[1]
- 变长参数，使用 ... 在类型之前表示，例如： strs ... string,nums ...int,args ... interface{}
- 数组或切片展开，使用 ... 在类型之后表示，例如：arr=append(arr,args ...)
- 使用单下划线表示匿名变量，不占用变量空间和变量名，用来接受不想处理的返回值：_,ok:=mp[1]
- 变量定义了，必须使用，否则编译不通过
- 操作符前后必须有一个空格，否则编译不通过
- 作用域开始符号（左花括号{）必须是行尾符号，并且必须和前置语句在同一行
- if / for 等条件部分，不需要圆括号

## 数据类型
- 在go中，有这严格的数据类型
- 虽然定义变量时，支持类型自动推导
- 导致在编码时感觉没有类型
- 但是，实际上有这严格的类型机制
- 没有所谓的类型自动提升
- 必须显式的进行类型转换
- 内建类型
    - nil 空值，其他语言中的null
    - true/false 逻辑值，和其他语言中bool一致
    - any/interface{} 接口类型，和其他语言中的Object类型一致
- 基础数据类型
    - 整形，默认值 0
        - int 根据机器位数，实际上为 int32 或 int64
        - int32 其他语言中的int
        - int64 其他语言中的long
    - 浮点型，默认值 0.0
        - float 根据机器位数，实际上为 float32 或 float64
        - float32 其他语言中的float
        - float64 其他语言中的double
    - 逻辑型，默认值 false
        - bool 布尔
    - 字符型，默认值 "",注意，其他语言中可能是null，但是go中，string不可为空
        - string 字符串
- 复合数据类型
    - [3]string/[3]int 数组，是带有长度的类型
        - 定义：[长度]类型
        - 举例：[3]string,[2]int,[5]float,[8]interface{}
        - 声明：var arr [3]int
        - 访问：通过下标访问：var a=arr[0] arr[1]=5 arr[2]
        - 长度：使用内建函数len获取：len(arr)
    - []string/[]int 切片，是不定长的数组，可以对等Java的ArrayList
        - 使用上和数组完全一致
        - 增加元素：使用内建函数append实现：arr=append(arr,elem)
        - 删除元素：没有提供相关操作函数，通过切片重组合实现
            - 例如，删除小标为2的元素：arr=append(arr[:2],arr[3]...)
    - map[string]int/map[int]int 映射，是基于Hash的映射表，对等于HashMap
        - 定义：map[键类型]值类型
        - 举例：map[string]string,map[string]int
        - 声明：var mp map[string]string
        - 分配空间：通过声明的map，需要进行分配空间，使用内建函数make：mp=make(map[string]string)
        - 访问：通过中括号访问：mp["hello"]
        - 是否存在：通过中括号访问，第二个返回值表示是否存在：_,ok:=mp["hello"]
    - chan 通道，用于多线程通信的结构，对等于BlockingQueue
- 类型转换
    - 前面说了，GO没有隐式类型转换
    - 所有的类型转换都必须是显式的
    - 类型转换，通过：T()形式转换，T为目标类型
    - 例如：int32(num),float64(num),string(bytes),byte(str),User(elem)
    - 或者通过类型断言，实现类型转换
    - 类型断言，格式：newValue,isOk := oldVal.(T)
        - 其中oldVal就是需要转换的数据，T就是目标类型，isOK是布尔类型，表示是否成功，newValue就是转换之后的值
        - 因此，如果isOK为true的话，就能够转换
        - 如果，能确定一定能够转换，则可以使用匿名变量替换isOK，直接得到转换后的值
        - 格式：newValue,_ := oldVal.(T)
        - 例如：user,_ := obj.(User)

## 变量与常量
- 变量，通过var关键字声明
- 常量，通过const关键字声明，常量声明时必须有初值
    - 其他定义上的使用和变量一致
    - 常量不可再赋值
    - 其他使用上和变量一致
- 声明变量
```shell script
var 变量名 变量类型 = 变量初值
```
```go
var a int = 12
var b int
```
- 给初值的情况下，可以类型推断
```shell script
var 变量名 = 变量初值
```
```go
var a = 12
var b = "b"
```
- 可以同时声明一批变量
```shell script
var (
变量名 变量类型 = 变量初值
变量名 变量类型 = 变量初值
)
```
```go
var (
a int = 12
b int
c string
)
```
- 可以使用，定义并赋值操作符 := 直接定义，省去 var 关键字
```shell script
变量名 := 变量初值
```
```go
a := 12
b := "b"
```
- 常量的定义和变量一致，区别于，不可省略const关键字，必须有初值
- 也就是说，如下的定义都是错误的
```go
const a int // 没有初值
a:=12 // 实际上定义了一个变量
```
- 以下常量的定义都是可以的
```go
const pi = 3.14
const one int = 1
const (
 OK = 200
 Err = 500
)
```
- 变量，一旦声明，类型就固定了
- 也就是说，不能将不同类型的值进行赋值操作

## 标准输出
- 学习，总要能够打印出内容
- 才能知道实际的运行结果
- 因此，这里先介绍标准输出
- 标准输入输出，在fmt包中
```go
import "fmt"
```
- 输出一行
```shell script
fmt.Println(变长参数)
```
```go
fmt.Println(1)
fmt.Println(1,2,true,"aaa")
```
- 格式化输出
    - 格式占位符
        - %v : 直接输出值
        - %T : 输出类型
        - %d/%f/%.2f: 这些和C语言一致
        - %#v : 带结构类型输出值，可以用来查看结构的具体结构和值
    - 转义符号
        - \r\n\t 都是常见的转义符号
```shell script
fmt.Printf(格式字符串,格式化变长参数)
```
```shell script
fmt.Printf("1")
fmt.Printf("%v, %T\n",1,1)
```
- 格式化为字符串返回
    - 在某些情况下，需要得到一个格式化之后的字符串
```shell script
接受变量 = fmt.Sprintf(格式字符串,格式化变长参数)
```
```shell script
str = fmt.Sprintf("1")
str = fmt.Sprintf("%v, %T\n",1,1)
```


## 函数
- 通过func声明函数
- 函数定义
- 前面说了，GO是支持多返回值的
```shell script
func 函数名(参数列表) (返回值列表){
  return 返回值
}
```
- 可以无返回值
```go
func one(){
}
func two(num int){
}
func three(num int,str string){
}
```
- 单个返回值
```go
func one() string {
    return "ok"
}
func two(num int) int {
    return 2006
}
func three(num int,str string) bool {
    return true
}
```
- 多个返回值
```go
func one() (string,int) {
    return "ok",200
}
func two(num int) (int,float32) {
    return 2006,1.2
}
func three(num int,str string) (bool,string) {
    return true,""
}
```
- 返回值可以预定义返回值名称
- 这种情况下，return语句可以省略具体的值
```go
func one() (str string,num int) {
    str = "ok"
    num = 24
    return
}
```
- 参数列表或返回值列表，连续相邻参数类型相同，可以省略
```go
func one(a,b,c int,d,e string,f bool) (num1,num2 int) {
    num1 = 0
    num2 = 1
    return
}
```
- 接受函数的返回值
- 单个返回值时，一般可以先定义变量
```go
var num int
num = one(1,2)
```
- 多个返回值时，一般定义并赋值
```go
num,ok := check()
```
- 可以使用匿名变量，忽略多个返回值中的某些值
```go
num,_ := check()
_,ok := check()
```

## 流程控制
- 在GO中，尽管流程体只有一句话，作用域符号{}也是不可省略的
### if 语句
- 在go中，流程控制语句的条件部分，都是不需要括号的
- 结构
```shell script
if 条件表达式 {
  条件体
}
```
```go
if err != nil {
    fmt.Println(err)
}
```
- 可以在条件部分嵌入语句
```go
if _,ok := isOk(); ok {
    fmt.Println("is ok")
}
```
- 换句话说，就是可以在条件位置，声明一个局部变量，仅在if条件内使用

### for 语句
- GO 中，for成分复杂，因为没有while语句
- 而是for的一种形式，取代了while语句
- 结构
```shell script
for 初始语句;条件语句;增量语句 {
  循环体
}
```
```go
for i := 0;i<10;i++{
    fmt.Println(i)
}
```
- 可以只有条件语句，那就等价于while语句
```go
i := 0
for i<10 {
    fmt.Println(i)
    i++
}
```
- 可以条件也没有，那就是死循环模式
```go
i := 0
for {
    if i >= 10 {
        break
    }
    fmt.Println(i)
    i++
}
```
- 其中，对于break和continue的使用，和其他语言一致

### switch 语句
- switch语言，大体和其他语言一样
- 但是，有几点区别
    - switch 变量可以支持表达式
    - case 部分可以支持表达式
    - case 部分可以支持不同类型
    - 每个case 默认break
    - 如果需要实现C语言中的case穿透，需要使用fallthrough关键字
    - default 语句不需要放在case最后
    - 独有的type-switch语法判断类型
- 下面，直接给出一个案例简单说明
```go
package main

import "fmt"

func main() {
   /* 定义局部变量 */
   var grade string = "B"
   var marks int = 90

   switch marks {
      case 90: grade = "A"
      case 80: grade = "B"
      case 50,60,70 : grade = "C"
      default: grade = "D"  
   }

   switch {
      case grade == "A" :
         fmt.Printf("优秀!\n" )    
      case grade == "B", grade == "C" :
         fmt.Printf("良好\n" )      
      case grade == "D" :
         fmt.Printf("及格\n" )      
      case grade == "F":
         fmt.Printf("不及格\n" )
      default:
         fmt.Printf("差\n" );
   }
   fmt.Printf("你的等级是 %s\n", grade );      
}
```
- 独有的type-switch
```go
package main

import "fmt"

func main() {
   var x interface{}
     
   switch i := x.(type) {
      case nil:  
         fmt.Printf(" x 的类型 :%T",i)                
      case int:  
         fmt.Printf("x 是 int 型")                      
      case float64:
         fmt.Printf("x 是 float64 型")          
      case func(int) float64:
         fmt.Printf("x 是 func(int) 型")                      
      case bool, string:
         fmt.Printf("x 是 bool 或 string 型" )      
      default:
         fmt.Printf("未知型")    
   }  
}
```
## 数组与切片
- 数组和切片放在一起说明
- 大部分操作相同
- 区别在于数组是长度固定的
- 而切片是可变长度的
- 下面看下声明变量的差别
```go
// 数组，长度为3
var arr1 [3]int

// 数组，长度初始化自动推断，自动推断结果长度为4
var arr2 [...]int{1,2,3,4}

// 切片
var spl1 []int

// 切片并赋值
var sp2 []int{1,2,3}

// 切片
sp3 := []int{1,2,3}

// 使用内建函数make创建切片，长度为5，容量为10
sp4 := make([]int,5,10)
```
- 切片和数组的访问，都是通过下标访问
- 小标从0开始
```go
// 数组访问
var arr [...]int{1,2,3,4}
arr1 := arr[0]
arr[1] = 9

// 切片访问
var spl []int{1,2,3,4}
spl1 := spl[0]
spl[1] = 9
```
- 切片，通过切片语法[开始小标:结束小标]进行切片
- 获得一个新的序列，包含开始，不包含结束
- 数组和切片都支持切片
```go
arr := []int{1,2,3,4}

// 取0-2个，得到[1,2]
arr1 := arr[0:2]

// 取从2之后的所有，得到[3,4]
arr2 := arr[2:]

// 取截止到2的所有，得到[1,2]
arr3 := arr[:2]
```
- 增加元素，数组是不可变长度的
- 因此，只有切片可以增加元素
- 使用内建函数append添加元素
```go
arr := []int{1,2}
// 添加单个元素
arr = append(arr,2)

// 通过后置解包操作符...来添加多个元素
// 这就是切片的合并
arr1 := []int{3,4}
arr = append(arr,arr1...)
```
- 删除元素，数组不可变，没有删除
- 删除，没有内建命令
- 而是借助切片后合并的方式实现
```go
arr := []int{1,2,3}

// 删除第二个元素
arr = append(arr[:1],arr[2:]...)
```

## 映射
- 映射，也叫map
- 是一个K-V类型的数据结构
- 定义，类型：map[键类型]值类型
- 初始化
```go
// 使用声明加申请空间方式
var mp map[int]string
mp = make(map[int]string)

// 使用立即声明
mp2 := map[int]string{}

// 立即声明并赋值
// 注意，赋值中，每行都需要以逗号结尾
mp3 := map[int]string{
    1:"ONE",
    2:"TWO",
}
```
- 增加和更新操作，通过中括号进行
```go
mp := map[int]string{}

mp[1]="A"
mp[2]="B"

mp[1]="C"

str := mp[1]
```
- 判断是否存在，需要借助取值的第二个参数
```go
mp := map[int]string{}

mp[1]="A"

val,existes := mp[1]
if exists {
    fmt.Println(val)
}

// 也可以合并写
if _,ok := mp[1]; ok {
    fmt.Println("exists")
}
```
- 删除，通过内建函数delete实现
```go
mp := map[int]string{}

mp[1]="A"

delete(mp,1)
```

## 类型定义
- 通过type关键字定义
- 可以定义普通类型
```go
type MyInt int
```
- 可以定义接口
```go
type MyInterface interface{
}
```
- 可以定义结构体
```go
type MyStruct struct{
}
```
- 可以定义函数
```go
type MyFunc func(int,int)int

// 实现一个函数定义
var fc MyFunc

fc=func(num1,num2)int{
    return num1+num2
}

rs := fc(1,2)
```

## 结构体
- 结构体，是对一组属性和操作封装的集合
- Go中的结构体，带有其他语言中类的概念
- 注意，结构体中，属性名的大小写开头，也表示权限
- 大写开头，表示共有，其他包也可以访问
- 小写开头，表示私有，自由自己包可以访问
- 也就是说，如果其他框架想要使用，必须得大写
- 比如序列化框架json/xml等
- 否则，一旦小写，其他框架访问不到，就可能发生意料之外的事
- 定义结构体
```shell script
type 结构体名称 struct{
  属性名 类型 `TAG名称:"TAG值"`
}
```
- 例如
```go
type User struct{
    Username string `json:"username"`
    Age int
}
```
- 为结构绑定方法函数
```shell script
func (变量名 结构体类型) 函数名(参数列表)返回值列表{
  函数体
}
```
- 结构体类型中，值类型不能修改结构体
- 只有指针类型可以，这也是go中，结构体是值传递导致的
```go
func (user *User) SetUsername(name string){
    user.Username=name
}
func (user User) GetAge()int{
    return user.Age
}
```
- 结构的访问，通过.访问，不论是否是指针类型
```go
// 值类型
user := User{
    Username: "zhang",
    Age: 12
}

fmt.Println(user.Username)

user.Age=22

user.SetUsername("li")

// 指针类型
user1 := &User{
    Username: "zhang",
    Age: 12
}
fmt.Println(user1.Username)

user1.Age=22

user1.SetUsername("li")
```
- 结构的包含/结构继承
- 在golang中，通过给结构嵌入匿名结构的方式
- 可以嵌入一个结构，并可以通过直接访问方式进行嵌入结构的访问
```go
// 定义键盘结构
type Keyboard struct{
    Key int
    EventCode int
}
// 定义计算机结构，嵌入键盘结构
type Computer struct{
    Core int
    Memory int
    Keyboard // 匿名嵌入
}

// 这时候，在访问不冲突的前提下
// 可以直接贯穿访问
com := Computer{}

// 可以直接访问
k := com.Keyboard.Key
k = com.Key

// 但是如果嵌入多个匿名结构
// 多个匿名结构中存在同名属性时
// 就需要具名完全访问
k = com.Keyboard.Key
```


## 接口
- 接口，只定义标准
- 不定义实现
- 也就是定义一些列函数
- 特殊的，interface{}是一个空接口，是任何结构的都实现的接口
```go
type Animal interface{
    Eat()
    Say(string)
    GetName()string
}
```
- 其他的结构负责实现接口
- 在go中，不需要实现接口时指定特殊的关键字
- 只需要覆盖接口中的方法即可
- 例如下面的示例
```go
type Dog struct{

}
func (dog Dog)Eat(){
    fmt.Println("狗在吃")
}
func (dog *Dog)Say(str string){
    fmt.Printf("狗说：%v\n",str)
}
func (dog *Dog)GetName()string{
    return "Alex"
}
func (dog *Dog)See(){
     fmt.Println("狗在看")
}
```

## 包
- 在前面的内容中
- 每个main.go中
- 第一行都是 package main
- 这就是说明这个包是main包
- 在go中，包只需要一级即可
- 一般来说，包名和文件夹名称相同
- 比如，如果在 hello 文件夹下，一般就称为hello包
- 特别的，除了main包，绝大多数不是在同名的文件夹下
### 包的声明
- 通过package关键字声明包
- 包名只包含一级，不包含多级包
- 而且，包声明必须在第一行
```go
package main
package hello
package github.com
```
### 包的导入
- 通过import关键字导入包
- 导入的实际是包路径
- 导入某个包，实际是导入GOPATH下面指定的文件夹的所有内容
```go
import "fmt"
```
- 同时，一般导入多个，合并写
- 通过圆括号包含
```go
import (
    "fmt"
    "os"
)
```
- 导入重命名，当两个包名字重复时
- 可以使用重命名导入
- 通过包名前加别名
```go
import (
    "hello/rpc"
    trpc "test/rpc"
)

// 使用时
// 原来：rpc.GetRpcServer()
// 变成： trpc.GetRpcServer()
```
- 匿名导入，当导入包，但是包中不直接使用时
- 在golang中，导入的包必须使用
- 否则会被编译器排除报错
- 例如，最常见的驱动包，包含数据库驱动包
- 这时候，包是必须导入的，但是包缺没有直接使用
- 这时候就需要使用你们导入
- 通过包名前加匿名下划线
```go
import (
    "fmt"
    _ "mysql/driver/sql"
)
```
### 包管理
- 使用 gomod 进行管理
- 具体细节查看 go-mod.md


## JSON/XML的序列化和反序列化
- 序列化和反序列化是很常用的功能
- 这两个过程互为逆过程
- 存在于内存结构和字符串之间转换
- 在golang中，也就表示在string和struct之间的转换
- 转换一般需要借助反射，以及结构的TAG标签进行
- 下面直接给出示例
```go
type Region struct{
    Code int `xml:"code" json:"code"`
    Name string `json:"name" xml:"name"`
    Level int `json:"level" xml:"level"`
}
```
- 上面，通过结构的TAG标签指定了JSON和XML序列化和反序列化时对应的名称
- 可以看出，只是Pascal属性名和Camel序列化名字的区别
- 也就是首字母大小写的区别
- 为什么需要这么干？
- 因为，在golang中，首字母的大小写，表示权限
- 大写表示所有包都可以访问
- 小写表示只有自己的包可以访问
- 由于序列化和反序列化过程，借助反射实现，反射受限于权限
- 因此，如果属性时小写开头，则无法被反射到，也就无法被序列化识别到
- 下面给出JSON的序列化和反序列化流程
```go
package main

import (
	"encoding/json"
	"fmt"
)

type Region struct {
	Code  int    `xml:"code" json:"code"`
	Name  string `json:"name" xml:"name"`
	Level int    `json:"level" xml:"level"`
}

func main() {
	reg := Region{
		Code:  1001,
		Name:  "河北省",
		Level: 1,
	}
	bytes, err := json.Marshal(reg)
	if err != nil {
		fmt.Println(err)
	}
	str := string(bytes)
	fmt.Println(str)

	rev := Region{}
	err = json.Unmarshal([]byte(str), &rev)
	if err != nil {
		fmt.Println(err)
	}
	fmt.Printf("%#v\n", rev)
}
```
- 下面是运行结果
```shell script
{"code":1001,"name":"河北省","level":1}
main.Region{Code:1001, Name:"河北省", Level:1}
```
- 下面给出XML的序列化和反序列化流程
```go
package main

import (
	"encoding/xml"
	"fmt"
)

type Region struct {
	Code  int    `xml:"code" json:"code"`
	Name  string `json:"name" xml:"name"`
	Level int    `json:"level" xml:"level"`
}

func main() {
	reg := Region{
		Code:  1001,
		Name:  "河北省",
		Level: 1,
	}
	bytes, err := xml.Marshal(reg)
	if err != nil {
		fmt.Println(err)
	}
	str := string(bytes)
	fmt.Println(str)

	rev := Region{}
	err = xml.Unmarshal([]byte(str), &rev)
	if err != nil {
		fmt.Println(err)
	}
	fmt.Printf("%#v\n", rev)
}
```
- 运行结果如下
```shell script
<Region><code>1001</code><name>河北省</name><level>1</level></Region>
main.Region{Code:1001, Name:"河北省", Level:1}
```
- 可以明确的看到
- 使用上，基本没有差异
- 都是通过 Marshal 方法传入一个结构，返回字节切片和错误
- 都是通过 Unmarshal 方法传入一个字节切片和结构地址，返回错误