package com

// 定义包，可以向java中一样定义
// 也可以像c#的namespace一样定义
package test {

  object HelloPackage {

  }

}


// 导入包和java基本一致，但是如果是导入包下面的所有类时，使用的是下划线_,而不是java的星号*

import java.util._

object HelloScala {

  // 同时，导包可以在任意地方导包，作用范围和变量范围一致

  import java.math._

  def main(args: Array[String]): Unit = {
    println("Hello, world!")
    // 带类型定义变量
    var str: String = "hello"
    // 类型自动推断定义变量
    var it = 10
    println(str + it)
    // 定义常量
    val PI = 3.14
    println(PI)

    // 定义元组
    var record = ("zhang", 12, 4)
    println(record)

    println(add(1, 2))

    println(sub(3, 2))

    // 延迟调用，mul方法的第一个参数，作为一个传名调用进入，
    // 因此mul的第一个实参，并不是在调用时计算出来，再传递给mul方法使用的，
    // 而是，mul方法内第一次用到x1的时候才做计算
    println(mul(add(1, 2), 3))

    console(1, 2f, 5L, "aaa")

    println(adds(5))

    println(getTask(1))

    val date = new Date
    val logDate = log(date, _: Any)

    logDate("msg")

    println(sub(x2 = 5, x1 = 7))

    println(convert(stringify, 10))

    val tfunc1 = tracer(1)

    println(tfunc1())
    println(tfunc1())

    val tfunc2 = tracer(1)

    println(tfunc2())
    println(tfunc2())

  }

  // 定义函数，可以理解为独立的函数式接口实现类，使用val常量定义
  val add = (x1: Int, x2: Int) => x1 + x2

  // 定义方法，也就是普通的类方法，使用def定义
  def sub(x1: Int, x2: Int): Int = x1 - x2

  // 定义方法的延迟调用，传名调用，这里的第一个参数就是传名调用，x1的值将会在函数内做乘法时，才会计算出来
  def mul(x1: => Int, x2: Int): Int = x1 * x2

  // 方法的可变参数，在类型后面用闭包*表示
  def console(args: Any*): Unit = {
    var str = ""
    var first = true
    for (arg <- args) {
      if (!first) {
        str += ", "
      }
      str += arg
      first = false
    }
    println(str)
  }

  def adds(c: Int, a: Int = 5, b: Int = 7): Int = {
    a + b + c
  }

  def getTask(i: Int = 0): Int = {
    var curr = i

    def next(): Int = {
      curr += 1
      curr
    }

    next()
  }

  def log(date: Date, msg: Any) = {
    println(date + " " + msg)
  }

  // 定义一个将任意类型转换为String的转换器
  // 接受一个转换器和需要转换的值
  def convert(func: Any => String, v: Any) = func(v)

  // 转化为String的定义
  def stringify(x: Any) = "" + x

  def tracer(i: Int): (Unit => Int) = {
    var curr = i
    return (Unit) => {
      curr += 1;
      curr
    }
  }
}



