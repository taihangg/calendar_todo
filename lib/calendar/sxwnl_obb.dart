import 'sxwnl_JD.dart';
import 'sxwnl_XL.dart';
import 'sxwnl_tool.dart';
import 'sxwnl_xml_data.dart';

/// 农历基础构件(常数、通用函数等)
class obb {
//  #region 公共属性(注: 初始转换时为公共字段, 已改写, 请参阅“转换时增加的私有字段”)

//  #region 公共方法

  /// 取年号
  /// <param name="y">公历年(天文纪年, 如 -1 表示常规纪年的"公元前2年")</param>
  static String getNianhao(int y) {
    int i, j;
    String c, s = "";
    List ob = obb.JNB;
    for (i = 0; i < ob.length; i += 7) {
      j = ob[i].toInt();
      if ((y < j) || (y >= j + ob[i + 1].toInt())) {
        continue;
      }
      c = ob[i + 6].toString() + (y - j + 1 + ob[i + 2].toInt()).toString() + "年"; // 年号及年次
      s += (s.length > 0 ? ";" : "") +
          "[" +
          ob[i + 3] +
          "]" +
          ob[i + 4] +
          " " +
          ob[i + 5] +
          " " +
          c; // i为年号元年,i+3朝代,i+4朝号,i+5皇帝,i+6年号
    }
    return s;
  }

  /// 精气计算
  static double qi_accurate(double W) {
    double t = XL.S_aLon_t(W) * 36525;
    return t - JD.deltatT2(t) + 8 / 24; // 精气
  }

  /// 精朔计算
  static double so_accurate(double W) {
    double t = XL.MS_aLon_t(W) * 36525;
    return t - JD.deltatT2(t) + 8 / 24; // 精朔
  }

  /// 精气计算法 2:
  static double qi_accurate2(double jd) {
    return obb.qi_accurate(Math.Floor2Double((jd + 293) / 365.2422 * 24) * Math.PI / 12); //精气
  }

  /// 精朔计算法 2:
  static double so_accurate2(double jd) {
    return obb.so_accurate(Math.Floor2Double((jd + 8) / 29.5306) * Math.PI * 2); // 精朔
  }

//  #region 转换时增加的私有字段(用于封装成公共属性, 按转换规范 10 命名)

  // 数字 0 - 10 对应的中文名称
  static const List<String> numCn = [
    //
    "零", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十",
  ];

  // 十天干表
  static const List<String> Gan = [
    //
    "甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸"
  ];

  // 十二地支表
  static const List<String> Zhi = [
    //
    "子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"
  ];

  // 十二属相表
  static const List<String> ShX = [
    //
    "鼠", "牛", "虎", "兔", "龙", "蛇", "马", "羊", "猴", "鸡", "狗", "猪"
  ];

  // 十二星座表
  static const List<String> XiZ = [
    //
    "摩羯", "水瓶", "双鱼", "白羊", "金牛", "双子", "巨蟹", "狮子", "处女", "天秤", "天蝎", "射手"
  ];

  // 月相名称表
  static const List<String> yxmc = ["朔", "上弦", "望", "下弦"]; //月相名称表

  // 廿四节气表
  static const List<String> jqmc = [
    //
    "冬至", "小寒", "大寒", "立春", "雨水", "惊蛰",
    "春分", "清明", "谷雨", "立夏", "小满", "芒种",
    "夏至", "小暑", "大暑", "立秋", "处暑", "白露",
    "秋分", "寒露", "霜降", "立冬", "小雪", "大雪"
  ];

  // 农历各月的名称, 从 "十一" 月开始, 即从月建 "子" 开始, 与十二地支的顺序对应
  static const List<String> ymc = [
    //
    "冬", "腊", "正", "二", "三", "四", "五", "六", "七", "八", "九", "十"
  ]; //月名称,建寅

  // 农历各日的名称
  static const List<String> rmc = [
    //
    "初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十",
    "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十",
    "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十",
    "卅一"
  ];

  // 历史纪年表
  static List JNB = () {
    List data = [];
    // 加载 Xml 数据:  历史纪年表
    // 注: 加载时自动去除历史纪年表 Xml 数据中所有的空白字符
    // 读取并解开历史纪年表
    SxwnlData foundNode = lishijinianbiao;
    RegExp regexToTrim = new RegExp(r"\s*"); // C#: 匹配任何空白字符, 用于去除所有空白字符
    List<String> JNB = foundNode.Data.replaceAll(regexToTrim, "").split(",");

    data.addAll(JNB);
    for (int i = 0; i < JNB.length; i += 7) {
      data[i] = int.parse((data[i]).toString());
      data[i + 1] = int.parse((data[i + 1]).toString());
      data[i + 2] = int.parse((data[i + 2]).toString());
    }

    return data;
  }();

  // 廿四节气对应的月建表, 与 jqmc 对应
  static const List<String> JieQiYueJian = [
    //
    "子", "丑", "丑", "寅", "寅", "卯", "卯", "辰", "辰", "巳", "巳", "午",
    "午", "未", "未", "申", "申", "酉", "酉", "戌", "戌", "亥", "亥", "子"
  ];

  // 日十二建表
  static const List<String> RiJian12 = [
    //
    "建", "除", "满", "平", "定", "执", "破", "危", "成", "收", "开", "闭"
  ];

  // 双重日十二建表
  static const List<String> DoubleRiJian12 = [
    //
    "建", "除", "满", "平", "定", "执", "破", "危", "成", "收", "开", "闭",
    "建", "除", "满", "平", "定", "执", "破", "危", "成", "收", "开", "闭"
  ];

  // 双重十二地支表
  static const List<String> DoubleZhi = [
    //
    "子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥",
    "子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"
  ];
}
