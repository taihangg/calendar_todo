import 'dart:math';

import 'sxwnl_tool.dart';

/*-----------------------------------------------------------------------------------------------------------------------------------
   说明: 主要代码由许剑伟先生的寿星万年历(v4.11)源代码转换而来, 并进行了适当的改写, 如果有疑问, 请参阅原来的 Javascript 代码
   转换人: ynyuxiang(foxer12345@126.com)
 -----------------------------------------------------------------------------------------------------------------------------------
   转换规范:
       1. 避免使用 C# 保留字作为变量(字段名等), 在必要时, 把原来 Javascript 代码中的相关变量名末尾添加 2 个下划线作为新的变量名,
          或者添加其数据类型
       2. 事先声明变量, 尽量避免使用 var 来声明变量
       3. 尽量保留原注释, 对原注释中的部分专有名词(如"物件"等), 不作修改
       4. 对新增的特定注释, 以 "C#" 字样作为开始标识
       5. 对于特殊的转换, 在转换代码中给出必要的说明
       6. 对于 Javascript 代码中有自定义属性的数组, 采用派生类来解决此问题
       7. 对数值数据, 除可以明确确定的数据类型外, 均采用 double 类型
       8. 对于原 Javascript 中的独立函数, 分别转换到特定的类中
       9. 对于不太确定的(新增)注释, 在尾部加上 "(?)" 标识
      10. 对于新增的私有字段, 如果被封装后用于保存公共属性的值, 则在此公共属性名前添加 2 个下划线作为私有字段的名称
      11. 转换时新增加的属性, 方法等, 通常应放到文件的最下面, 并说明是新增的内容
  -----------------------------------------------------------------------------------------------------------------------------------
   需要考虑的事项:
       1. 在 C# 中的数值计算精度(可以保证)
       2. 在 C# 中不允许使用 Substring 方法超出字符串长度去截取子串, 因此必须进行必要的调整
       3. 在 C# 中数值数据运算的问题:
                  例如:  表达式 8/24 的值为0(与 Javascript 中不同), 但表达式 8d/24d 的值为 0.333333333333333...
  -----------------------------------------------------------------------------------------------------------------------------------
   尚未转换:
       [eph.js]
              独立函数 Number.prototype.toFixed : 直接改用 ToString() 方法来实现
              日食批量快速计算器物件 rsPL :       作为精简版本, 不转换
              月食快速计算器物件 ysPL :           作为精简版本, 不转换
       [tools.js]
              独立函数 getCookie(name) :       不需要
              独立函数 setCookie(name,value) : 不需要
              独立函数 addOp(sel,v,t) :        不需要
       [vml.js]
              整个 vml.js 文件:    作为精简版本, 不转换
  -----------------------------------------------------------------------------------------------------------------------------------
   待完成的工作:
       [  ] 1. 拟加入的信息
               [√] 1.1 每日的 12 建信息(依次为: 建, 除, 满, 平, 定, 执, 破, 危, 成, 收, 开, 闭)
               [  ] ......
       [√] 2. 对于原算法转换到 C# 以后, 需要作出的调整(考虑性能和效率等, 如: 字符串处理)
       [√] 3. 将首次转换时使用的 myArraryList 改写为 List<T> 类, 取消原代码中涉及拆箱时的显式类型转换
       [×] 4. 修改引用本类的泛型方法的相关代码 ?  (注: 由于 C# 编译器可以自动推断其类型, 因此不作处理)
       [√] 5. 把原 Index.htm 中的某些 Javascript 函数调整成为独立的方法
       [√] 6. 改写部分数据硬编码的代码(如: 历史纪年表数据, 节假日的定义, 经纬度数据, 时区数据等)
               [√] JnbArrayList.cs
               [√] JWdata.cs
               [√] oba.cs
               [√] obb.cs
               [×] 本命名空间中的其余 *.cs 文件 :  不改写
       [√] 7. 增加常规八字计算方法, 即不计算真太阳时(参阅 obb.cs 中的 mingLiBaZiNormal 方法)
       [√] 8. 适当地添加注释
       [  ] 9. 拟加入的功能
               [√] 9.1 指定某日, 计算出它的所属节(气), 上一节(气), 下一节(气)信息
               [  ] ......
       [√]10. 使用自实现属性来改写公共字段(有外部引用时), 或把公共字段调整为私有字段(无外部引用时), 但需要注意初值问题
               [√] JD.cs
               [√] JWdata.cs
               [√] Lunar.cs
               [√] LunarInfoListT.cs
               [√] ob.cs
               [√] oba.cs
               [√] obb.cs
               [√] SSQ.cs
               [√] sun_moon.cs
               [√] SZJ.cs
               [√] XL.cs
               [√] ZB.cs
               [×] 本命名空间中的其余 *.cs 文件 :  不存在上述情况, 无需改写
-----------------------------------------------------------------------------------------------------------------------------------*/

/// 助理类
class LunarHelper {
  /// 地球赤道半径(千米)
  static const double cs_rEar = 6378.1366; // 地球赤道半径(千米)

  /// 平均半径
  static const double cs_rEarA = 0.99834 * cs_rEar; // 平均半径

  /// 天文单位长度(千米)
  static const double cs_AU = 1.49597870691e8; // 天文单位长度(千米)

  /// Sin(太阳视差)
  static const double cs_sinP = cs_rEar / cs_AU; // sin(太阳视差)

  /// 太阳视差
  static const double cs_PI =
      0.0000426352097959108; // 太阳视差, 即 Math.Asin(cs_sinP)

  /// 每弧度的角秒数
  static const double rad = 180 * 3600 / pi; // 每弧度的角秒数

  /// 圆周率的2倍
  static const double pi2 = pi * 2; // 圆周率的2倍,即2*3.14159...

  /// 2000年1月1日 12:00:00 的儒略日数
  static const double J2000 = 2451545; // 2000年1月1日 12:00:00 的儒略日数

  /// 将弧度转为指定格式的字符串(度分秒, 或时分秒)
  /// <param name="d">要转换的弧度</param>
  /// <param name="tim">指明返回值的格式类型</param>
  /// <returns>tim = 0 输出格式示例: -23°59' 48.23"
  /// tim = 1 输出格式示例:  18h 29m 44.52s
  static String rad2str(double d, int tim) {
    String s = " ";
    String w1 = "°", w2 = "'", w3 = "\"";
    if (d < 0) // C#: 要转换的弧度值为负数
    {
      d = -d;
      s = "-";
    }
    if (tim != 0) // C#: 要返回值的格式为"时分秒"
    {
      d *= 12 / pi;
      w1 = "h ";
      w2 = "m ";
      w3 = "s";
    } else
      d *= 180 / pi; // C#: 要返回值的格式为"度分秒"

    double a = Math.Floor2Double(d);
    d = (d - a) * 60;
    double b = Math.Floor2Double(d);
    d = (d - b) * 60;
    double c = Math.Floor2Double(d);
    d = (d - c) * 100;
    d = Math.Floor2Double(d + 0.5);
    if (d >= 100) {
      d -= 100;
      c++;
    }
    if (c >= 60) {
      c -= 60;
      b++;
    }
    if (b >= 60) {
      b -= 60;
      a++;
    }

    String aStr = "   " + a.toString();
    String bStr = "0" + b.toString();
    String cStr = "0" + c.toString();
    String dStr = "0" + d.toString();
    s += aStr.substring(aStr.length - 3, aStr.length - 3 + 3) +
        w1 +
        bStr.substring(bStr.length - 2, bStr.length - 2 + 2) +
        w2 +
        cStr.substring(cStr.length - 2, cStr.length - 2 + 2) +
        "." +
        dStr.substring(dStr.length - 2, dStr.length - 2 + 2) +
        w3;
    return s;
  }

  /// 将弧度转为字串,精确到分
  /// <param name="d">要转换的弧度</param>
  /// <returns>输出格式示例: -23°59'</returns>
  static String rad2str2(double d) {
    String s = "+";
    String w1 = "°", w2 = "'";
    if (d < 0) {
      d = -d;
      s = "-";
    }
    d *= 180 / Math.PI;
    double a = Math.Floor2Double(d);
    double b = Math.Floor2Double((d - a) * 60 + 0.5);
    if (b >= 60) {
      b -= 60;
      a++;
    }
    String aStr = "   " + a.toString();
    String bStr = "0" + b.toString();
    s += aStr.substring(aStr.length - 3, aStr.length - 3 + 3) +
        w1 +
        bStr.substring(bStr.length - 2, bStr.length - 2 + 2) +
        w2;
    return s;
  }

  /// 秒转为分秒
  /// <param name="v">要转换的秒</param>
  /// <param name="fx">小数点位数</param>
  /// <param name="fs">为 1 转为"分秒"格式, 否则转为"角分秒"格式</param>
  static String m2fm(double v, int fx, int fs) {
    String gn = "";
    if (v < 0) {
      v = -v;
      gn = "-";
    }
    double f = Math.Floor2Double(v / 60);
    double m = v - f * 60;
    if (fs != 0)
      return gn + f.toString() + "分" + m.toStringAsFixed(fx) + "秒";
    else
      return gn + f.toString() + "'" + m.toStringAsFixed(fx) + "\"";
  }

  /// 对超过0-2PI的角度转为0-2PI
  /// <param name="v">要转换的角度</param>
  static double rad2mrad(double v) {
    v = v % (2 * Math.PI);
    if (v < 0) v += 2 * Math.PI;
    return v;
  }

  /// 对超过-PI到PI的角度转为-PI到PI
  /// <param name="v">要转换的角度</param>
  static double rad2rrad(double v) {
    v = v % (2 * Math.PI);
    if (v <= -Math.PI) return v + 2 * Math.PI;
    if (v > Math.PI) return v - 2 * Math.PI;
    return v;
  }

  /// 临界余数(a与最近的整倍数b相差的距离)
  static double mod2(double a, double b) {
    double c = (a / b);
    c -= Math.Floor2Double(c);
    if (c > 0.5) c -= 1;
    return c * b;
  }

  /// 去除字符串前后的所有空白字符
  static String trim(String s) {
    RegExp regexToTrim =
        RegExp(r"(^\s*)|(\s*$)"); // C#: 匹配任何空白字符, 与 [ \f\n\r\t\v] 等效
    return s.replaceAll(regexToTrim, "");
  }

  /// 传入普通纪年或天文纪年，传回天文纪年
  /// <param name="c">普通纪年或天文纪年, 泛型, 支持数值或字符串</param>
  static int year2Ayear<T>(T c) {
    int y;
    RegExp regexToReplace =
        new RegExp(r"[^0-9Bb\*-.]"); // C#: 匹配字符: 数字0-9, B, b, *, -
    String strC = c.toString().replaceAll(regexToReplace, ""); // C#: 去除无效字符

    String q = strC.substring(0, 0 + 1);
    if (q == "B" || q == "b" || q == "*") //通用纪年法(公元前)
    {
      y = (1 - LunarHelper.VAL_int(strC.substring(1))).toInt();
      if (y > 0) {
        print("通用纪法的公元前纪法从 B.C.1 年开始，并且没有公元 0 年！");
        return -10000;
      }
    } else
      y = LunarHelper.VAL_int(strC).toInt();

    if (y < -4712) {
      print("不得小于 B.C.4713 年！");
      return -10000;
    }
    if (y > 9999) {
      print("超过9999年的农历计算很不准。");
    }

    return y;
  }

  /// 传入天文纪年，传回显示用的常规纪年
  /// <param name="y">天文纪年, 泛型, 支持数值或字符串</param>
  static String Ayear2year<T>(T y) {
    int result = LunarHelper.VAL_int(y.toString()).toInt();
    if (result <= 0) return "B" + (-result + 1).toString();
    return result.toString();
  }

  /// 时间串转为小时
  /// <param name="s">时间串</param>
  static double timeStr2hour(String s) {
    RegExp regexToReplace = new RegExp(r"[^0-9:]"); // C#: 匹配字符: 数字0-9, :
    int a, b, c;
    List<String> timeStr =
        s.replaceAll(regexToReplace, "").split(':'); // C#: 去除无效字符后, 按 : 分隔字符串
    for (int i = 0; i < timeStr.length; i++) {
      // C#: 即使参数 s 为空串, 也会产生一个数组元素
      if (timeStr[i].length == 0) // C#: 把空串设置为 "0"
        timeStr[i] = "0";
    }
    switch (timeStr.length) {
      case 1:
        {
          // C#: 为避免 Substring 方法超出范围取子串引发异常, 改用本类中的静态方法 SUBSTRING
          a = LunarHelper.VAL_int(LunarHelper.SUBSTRING(timeStr[0], 0, 2));
          b = LunarHelper.VAL_int(LunarHelper.SUBSTRING(timeStr[0], 2, 2));
          c = LunarHelper.VAL_int(LunarHelper.SUBSTRING(timeStr[0], 4, 2));
          break;
        }
      case 2:
        {
          a = LunarHelper.VAL_int(timeStr[0]);
          b = LunarHelper.VAL_int(timeStr[1]);
          c = 0;
          break;
        }
      default:
        {
          a = LunarHelper.VAL_int(timeStr[0]);
          b = LunarHelper.VAL_int(timeStr[1]);
          c = LunarHelper.VAL_int(timeStr[2]);
          break;
        }
    }
    return a + b / 60 + c / 3600;
  }

  /// 将度分秒转换为弧度值(只作简单转化, 要求传递的格式严格遵守"度分秒"的格式, 如: 0°0'31.49"
  static double str2rad(String d) {
    double result = 0;
    String strSpliter = "°'\"";

    RegExp re = RegExp("[°'\"]");

    List<String> strD = d.split(re);

    if (strD.length > 0) {
      double a = 0, b = 0, c = 0;
      a = LunarHelper.VAL(strD[0]) /
          180 *
          Math.PI; // 1°= 1/180*PI ≈ 0.017453292519943 弧度
      if (strD.length > 1) {
        b = LunarHelper.VAL(strD[1]) /
            60 /
            180 *
            Math.PI; // 1' = (1/60)°≈ 0.000290888208666 弧度
        if (strD.length > 2) {
          c = LunarHelper.VAL(strD[2]) /
              60 /
              180 /
              60 *
              Math.PI; // 1" = (1/60)' ≈ 0.000004848136811 弧度
        }
      }
      if (a > 0)
        result = a + b + c;
      else
        result = a - b - c;
    }
    return result;
  }

  /// 将弧度转化为相等的度
  /// <param name="nRadians"></param>
  static double RTOD(double nRadians) {
    return ((nRadians * 180) / Math.PI);
  }

  /// 将度转换为弧度
  /// <param name="nDegrees"></param>
  static double DTOR(double nDegrees) {
    return ((nDegrees * Math.PI) / 180);
  }

  /// 取子字符串, 允许起始位置超过整个字符串长度(此时返回空串), 弥补 String.Substring 方法的不足
  /// <param name="cExpression">被取子串的字符串</param>
  /// <param name="nStartPosition">起始位置（从零开始）</param>
  /// <param name="nLength">子串的长度</param>
  static String SUBSTRING(String cExpression, int nStartPosition, int nLength) {
    if (nStartPosition >= cExpression.length ||
        nStartPosition < 0 ||
        nLength <= 0) return "";
    if (nLength + nStartPosition >= cExpression.length)
      return cExpression.substring(nStartPosition);
    else
      return cExpression.substring(nStartPosition, nStartPosition + nLength);
  }

  /// 将字符串解析为数值, 允许字符串中含有非数值类型的字符
  /// <param name="strExpression">要解析的字符串</param>
  static double VAL(String strExpression) {
    // 数值字符串的正则表达式(注: "|"表示"或者", n >= 0):
    //   允许的字符:        ￥|$   +|-  [0-9]   .     [0-9]   E|e   +|-   [0-9]   %
    //   允许出现的次数:     0,1   0,1    n     0,1     n     0,1   0,1     n     0,1
    //   正则式表示的次数:    ?     ?     *      ?      *      ?     ?      *      ?
    const String numberPattern =
        r"(((￥|\$)?)((\+|\-)?)([0-9]*)((\.)?)([0-9]*)((E|e)?)((\+|\-)?)([0-9]*))((%)?)";

    double result = 0;
    String strResult = "";
    double percentPow = 1;

//  char[] toTrimStart = new char[] { ' ' };                 // 允许在前面出现的空白字符: 空格符
    strExpression = strExpression.trimLeft(); // 去除前面的空白字符

    RegExp numberRegPattern = new RegExp(numberPattern);
    Match matched = numberRegPattern.firstMatch(strExpression);
    //if (matched.Success)
    if (0 < matched.groupCount) {
      strResult = matched.group(0).toString().toUpperCase(); // 匹配结果转换为大写的字符串
      if (strResult.endsWith("%")) // 如果字符串以某符号(本行为 "%") 结尾, 去除此符号, 以下类推
      {
        strResult = strResult.substring(
            0, 0 + strResult.length > 1 ? strResult.length - 1 : 0);
        if ((strResult.indexOf("E") < 0) ||
            (strResult.indexOf("e") < 0)) // 不同时存在 % 和 E 字符
          percentPow = 0.01; // 百分数, 除以 100
      }
      if (strResult.endsWith("+") || strResult.endsWith("-")) // 第 1 次
        strResult = strResult.substring(
            0, 0 + strResult.length > 1 ? strResult.length - 1 : 0);
      if (strResult.endsWith("E"))
        strResult = strResult.substring(
            0, 0 + strResult.length > 1 ? strResult.length - 1 : 0);
      if (strResult.endsWith("."))
        strResult = strResult.substring(
            0, 0 + strResult.length > 1 ? strResult.length - 1 : 0);
      if (strResult.endsWith("+") || strResult.endsWith("-")) // 第 2 次
        strResult = strResult.substring(
            0, 0 + strResult.length > 1 ? strResult.length - 1 : 0);

      if (strResult.startsWith("￥") ||
          strResult.startsWith(r"$")) // 扫描字符串的开始, 以下类推
        strResult = strResult.substring(1);
      if (strResult.length <= 0 ||
          strResult.startsWith("E") ||
          strResult.startsWith(".E") ||
          strResult.startsWith("+-") ||
          strResult.startsWith("-+") ||
          strResult.startsWith("+E") ||
          strResult.startsWith("-E") ||
          strResult.startsWith("+.E") ||
          strResult.startsWith("-.E"))
        strResult = "0"; // 尽量避免让下面的 double.Parse 方法产生异常(补注: 已改写为 TryParse 方法)

      //double.tryParse(strResult, out result);     // 在解析失败时, TryParse 方法不会产生异常
      result = double.tryParse(strResult); // 在解析失败时, TryParse 方法不会产生异常
      result ?? (result = 0.0);
      result *= percentPow;
    }
    return result;
  }

  static int VAL_int(String strExpression) {
    return LunarHelper.VAL(strExpression).toInt();
  }

//  #region 转换时新增的属性和字段

}

//#region 计算节气的类型
/// 计算节气的类型
enum CalcJieQiType {
  /// 仅计算节
  CalcJie,

  /// 仅计算气
  CalcQi,

  /// 计算节和气
  CalcBoth
}
