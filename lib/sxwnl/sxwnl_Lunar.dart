import 'dart:math';

import 'sxwnl_JD.dart';
import 'sxwnl_LunarHelper.dart';
import 'sxwnl_SSQ.dart';
import 'sxwnl_XL.dart';
import 'sxwnl_obb.dart';
import 'sxwnl_tool.dart';
import 'sxwnl_xml_data.dart';

///
/// 农历核心算法类库（含源码），源自许剑伟先生的寿星万年历
/// 移植自HongchenMeng先生的c#移植项目，地址：https://github.com/HongchenMeng/SharpSxwnl
/// 感谢许剑伟先生！感谢HongchenMeng先生!
///
/// 只想保留 公历->(农历，干支)等信息，在HongchenMeng先生的项目的基础上，去掉了很多信息，修改了一些写法，
/// 但是天文算法看不懂，修改一处就运行测试一下，即便如此，还是有很多内容不敢动，
/// 只做了非常简单的测试，可能被我改出bug了但我自己没测出来，如果有遇到，请告知一下，谢谢！
///
/// 处理有点慢，最好异步处理
///
/// TODO:
/// 类静态数据的方式，都修改成非静态的方式；

/// 日对象
class DayInfo {
//  #region 日的公历信息
  int year; // 所在公历年,同lun.y
  int month; // 所在公历月,同lun.m
  int day; // 公历日，从1开示
  int DayIndex; //  所在公历月内日序数
  double d0; // 2000.0起算儒略日,北京时12:00

//  #region 农历信息
  int lunarMonth; //农历月，1对应正月
  int lunarDay; // 农历日，1对应初一
  String lunarDayName; // 日名称(农历),即'初一,初二等'
  String lunarRunyue; // 闰状况(值为'闰'或空串)
  int lunarMonthIndex; //月序号，0对应一月
  String lunarMonthName; // 月名称
  int lunarMonthDayCount; //月天数

  //  #region 日的农历纪年、月、日、时及星座
  double Lyear; // 农历纪年(10进制,1984年起算,分界点可以是立春也可以是春节,在程序中选择一个)
  double Lmonth; // 纪月处理,1998年12月7日(大雪)开始连续进行节气计数,0为甲子

  String gzYear; // 干支纪年(立春)
  String gzMonth; // 干支纪月
  String gzDay; // 干支纪日
  String xingzuo; // 星座

  String jieqi = ""; // 节气名称
  String jieqi2; // 节气名称(实历?)
  String jqjd; // 节气时刻(儒略日)
  String jqsj; // 节气时间串

  double Lyear0; // 农历纪年(10进制,1984年起算)
  String Lyear3; // 干支纪年(正月)
  double Lyear4; // 黄帝纪年

  String gregorianFestival = ""; // 公历节日
  String lunarFestival = ""; // 农历节日
  String ganzhiFestival = ""; // 干支纪日的特殊日子

  /////////////// 不重要信息 ///////////////

  double cur_dz; // 距冬至的天数
  double cur_xz; // 距夏至的天数
  double cur_lq; // 距立秋的天数
  double cur_mz; // 距芒种的天数
  double cur_xs; // 距小暑的天数

  double Ldn; // 月大小

  String Lmc2; // 下个月名称,判断除夕时要用到

//  #region 日的其它信息
  String yxmc; // 月相名称
  String yxjd; // 月相时刻(儒略日)
  String yxsj; // 月相时间串

//  #region C#: 从 Javascript 代码中提取出来的其他字段(属性)

  String Ri12Jian; // 每日的十二建信息, 即: {建, 除, 满, 平, 定, 执, 破, 危, 成, 收, 开, 闭} 其中之一

  void getLunarShujiu() {
    // 数九

    if (this.cur_dz >= 0 && this.cur_dz < 81) {
      // 数九
      String w = obb.numCn[(this.cur_dz / 9).toInt() + 1];
      if (this.cur_dz % 9 == 0) {
        this.ganzhiFestival = w + "九";
      } else {
        w + "九第" + (this.cur_dz % 9 + 1).toString() + "天 ";
      }
    }
  }

  void getLunarSanfu() {
    // 三伏天
    String tg = this.gzDay.substring(0, 0 + 1); //天干
    String dz = this.gzDay.substring(1, 1 + 1); //地支
    if (this.cur_xz > 20 && this.cur_xz <= 30 && tg == "庚") {
      this.ganzhiFestival += "初伏 ";
    }
    if (this.cur_xz > 30 && this.cur_xz <= 40 && tg == "庚") {
      this.ganzhiFestival += "中伏 ";
    }
    if (this.cur_lq > 0 && this.cur_lq <= 10 && tg == "庚") {
      this.ganzhiFestival += "末伏 ";
    }
    if (this.cur_mz > 0 && this.cur_mz <= 10 && tg == "丙") {
      this.ganzhiFestival += "入梅 ";
    }
    if (this.cur_xs > 0 && this.cur_xs <= 12 && dz == "未") {
      this.ganzhiFestival += "出梅 ";
    }
  }

  void getLunarFestival() {
    // 农历节日
    if ("闰" != this.lunarRunyue) {
      //闰月不算节日
      final str1 = "${this.lunarMonthIndex + 1}.${this.lunarDay}";
      this.lunarFestival += lunarfestivals[str1] ?? "";

      // 月用倒数序的节日
      final invertFestivalFmt =
          "${this.lunarMonthIndex + 1}.-${this.Ldn.toInt() - this.lunarDay + 1}";
      final invertFestival = lunarfestivals[invertFestivalFmt];
      if (null != invertFestival) {
        this.lunarFestival +=
            (("" != this.lunarFestival) ? "," : "") + invertFestival;
      }
    }

    // 每月都有的节日
    final everyMonthFestivalFmt = "0.${this.lunarDay}";
    final everyMonthFestival = lunarfestivals[everyMonthFestivalFmt];
    if (null != everyMonthFestival) {
      this.lunarFestival +=
          (("" != this.lunarFestival) ? "," : "") + everyMonthFestival;
    }

    // 每月用倒数序的节日
    final everyMonthInvertFestivalFmt =
        "0.-${this.Ldn.toInt() - this.lunarDay + 1}";
    final everyMonthInvertFestival =
        lunarfestivals[everyMonthInvertFestivalFmt];
    if (null != everyMonthInvertFestival) {
      this.lunarFestival +=
          (("" != this.lunarFestival) ? "," : "") + everyMonthInvertFestival;
    }
  }

  void getGregorianFestival() {
    // 公历节日
    var str = "${this.month}.${this.day}";
    this.gregorianFestival = gregorianFestivals[str] ?? "";
  }
}

// 日历计算类
class LunarMonth {
  int gregorianYear; // 公历年份
  int gregorianMonth; // 公历月分
  int monthDaysCount; // 本月的天数
  String ganzhiYear; // 该年的干支纪年
  String shengxiao; // 该年的生肖

  String nianhao; // 年号
  int weeksCount; // 本月的总周数

  int firstWeekday; // 本月第一天的星期
  double day0; // 月首的J2000.0起算的儒略日数

  // 月对象，存储 OB 类的实例(31个日对象)
  List<DayInfo> days = [];

  LunarMonth(DateTime dt, [int dayCount]) {
    double curTZ = -8;

    //J2000起算的儒略日数(当前本地时间)
    double curJD =
        Tool.NowUTCmsSince19700101(dt) / 86400000 - 10957.5 - curTZ / 24;

    JD.setFromJD(curJD + LunarHelper.J2000); // 设置JD环境

    curJD = Math.Floor2Double(curJD + 0.5);
    double By = LunarHelper.year2Ayear(JD.Y).toDouble(); // 自动推断类型为: string

    this.yueLiCalc(By.toInt(), JD.M, dayCount); // 农历计算
  }

  // 计算公历某一个月的"公农回"三合历, 并把相关信息保存到月对象 lun, 以及日对象 lun[?] 中
  // <param name="By">要计算月历的年</param>
  // <param name="Bm">要计算月历的月</param>
  void yueLiCalc(int By, int Bm, [int dayCount]) {
    // 日历物件初始化
    JD.h = 12;
    JD.m = 0;
    JD.s = 0.1;
    JD.Y = By;
    JD.M = Bm;
    JD.D = 1;

    double Bd0 = Math.Floor2Double(JD.toJD()) - LunarHelper.J2000; // 公历某年的月首,中午
    JD.M++;
    // C#: 如果月份大于 12, 则年数 + 1, 月数取 1
    if (JD.M > 12) {
      JD.Y++;
      JD.M = 1;
    }
    int monthDaysCount =
        (Math.Floor2Double(JD.toJD()) - LunarHelper.J2000 - Bd0)
            .toInt(); // 本月天数(公历)

    this.firstWeekday = ((Bd0 + LunarHelper.J2000 + 1) % 7).toInt(); //本月第一天的星期
    this.gregorianYear = By; // 公历年份
    this.gregorianMonth = Bm; // 公历月分
    this.day0 = Bd0;
    this.monthDaysCount = monthDaysCount;
    this.weeksCount =
        Math.Floor2Int((this.firstWeekday + monthDaysCount - 1) / 7) +
            1; // 本月的总周数

    getLunarYearInfo(By); // 农历年信息：天干地支，生肖，年号

    double D, w;

    int showDayNum = dayCount ?? monthDaysCount;

    // 循环提取各日信息
    for (int i = 0, j = 0; i < monthDaysCount; i++) {
      var day = DayInfo();
      this.days.add(day);

      day.d0 = Bd0 + i; // 儒略日,北京时12:00
      day.DayIndex = i; // 公历月内日序数
      day.year = By; // 公历年
      day.month = Bm; // 公历月

      JD.setFromJD(day.d0 + LunarHelper.J2000);
      day.day = JD.D; //公历日名称

      // 农历月历

      if ((SSQ.ZQ.Count == 0) ||
          (day.d0 < SSQ.ZQ[0]) ||
          (day.d0 >= SSQ.ZQ[24])) {
        // 如果d0已在计算农历范围内则不再计算
        SSQ.calcY(day.d0);
      }
      int mk = Math.Floor2Double((day.d0 - SSQ.HS[0]) / 30).toInt();
      if (mk < 13 && SSQ.HS[mk + 1] <= day.d0) {
        mk++;
      } // 农历所在月的序数

      day.lunarDay =
          (day.d0 - SSQ.HS[mk]).toInt() + 1; // 农历日，由距农历月首的编移量+1,1对应初一
      day.lunarDayName = obb.rmc[day.lunarDay - 1]; // 农历日名称

      // 节气相关的内容
      day.cur_dz = day.d0 - SSQ.ZQ[0]; // 距冬至的天数
      day.cur_xz = day.d0 - SSQ.ZQ[12]; // 距夏至的天数
      day.cur_lq = day.d0 - SSQ.ZQ[15]; // 距立秋的天数
      day.cur_mz = day.d0 - SSQ.ZQ[11]; // 距芒种的天数
      day.cur_xs = day.d0 - SSQ.ZQ[13]; // 距小暑的天数

      if ((day.d0 == SSQ.HS[mk]) || (day.d0 == Bd0)) {
        // 月的信息
        day.lunarMonthIndex = (mk + 12 - 2) % 12;
        day.lunarMonth = day.lunarMonthIndex + 1;
        day.lunarMonthName = SSQ.ym[mk] + "月"; // 月名称
        day.Ldn = SSQ.dx[mk]; // 月大小
        day.lunarMonthDayCount = day.Ldn.toInt();
        day.lunarRunyue = (SSQ.leap != 0 && SSQ.leap == mk) ? "闰" : ""; // 闰状况
        day.Lmc2 = mk < 13 ? SSQ.ym[mk + 1] : "未知"; // 下个月名称,判断除夕时要用到
      } else {
        DayInfo day2 = (this.days[i - 1]);
        day.lunarMonthName = day2.lunarMonthName;
        day.lunarMonthIndex = day2.lunarMonthIndex;
        day.lunarMonth = day2.lunarMonth;
        day.Ldn = day2.Ldn;
        day.lunarMonthDayCount = day2.lunarMonthDayCount;
        day.lunarRunyue = day2.lunarRunyue;
        day.Lmc2 = day2.Lmc2;
      }

      int qk = Math.Floor2Double((day.d0 - SSQ.ZQ[0] - 7) / 15.2184).toInt();
      if (qk < 23 && day.d0 >= SSQ.ZQ[qk + 1]) {
        qk++;
      } //节气的取值范围是0-23

      if (day.d0 == SSQ.ZQ[qk]) {
        day.jieqi2 = obb.jqmc[qk];
      } else {
        day.jieqi2 = "";
      }

      day.yxmc = day.yxjd = day.yxsj = ""; // 月相名称,月相时刻(儒略日),月相时间串

      day.jieqi = day.jqjd = day.jqsj = ""; // 定气名称,节气时刻(儒略日),节气时间串

      // 干支纪年处理
      // 以立春为界定年首
      D = SSQ.ZQ[3] +
          (day.d0 < SSQ.ZQ[3] ? -365 : 0) +
          365.25 * 16 -
          35; //以立春为界定纪年
      day.Lyear = Math.Floor2Double(D / 365.2422 + 0.5); //农历纪年(10进制,1984年起算)

      // 以下几行以正月初一定年首
      D = SSQ.HS[2]; // 一般第3个月为春节
      for (j = 0; j < 14; j++) {
        // 找春节
        if (SSQ.ym[j] != "正") {
          continue;
        }
        D = SSQ.HS[j];
        if (day.d0 < D) {
          D -= 365;
          break;
        } // 无需再找下一个正月
      }
      D = D + 5810; // 计算该年春节与1984年平均春节(立春附近)相差天数估计
      day.Lyear0 = Math.Floor2Double(D / 365.2422 + 0.5); // 农历纪年(10进制,1984年起算)

      D = day.Lyear + 9000;
      day.gzYear =
          obb.Gan[(D % 10).toInt()] + obb.Zhi[(D % 12).toInt()]; // 干支纪年(立春)
      D = day.Lyear0 + 9000;
      day.Lyear3 =
          obb.Gan[(D % 10).toInt()] + obb.Zhi[(D % 12).toInt()]; // 干支纪年(正月)
      day.Lyear4 = day.Lyear0 + 1984 + 2698; // 黄帝纪年

      // 纪月处理,1998年12月7(大雪)开始连续进行节气计数,0为甲子
      mk = Math.Floor2Int((day.d0 - SSQ.ZQ[0]) / 30.43685);
      if (mk < 12 && day.d0 >= SSQ.ZQ[2 * mk + 1]) {
        mk++;
      } //相对大雪的月数计算,mk的取值范围0-12

      D = mk +
          Math.Floor2Double((SSQ.ZQ[12] + 390) / 365.2422) * 12 +
          900000; //相对于1998年12月7(大雪)的月数,900000为正数基数
      day.Lmonth = D % 12;
      day.gzMonth = obb.Gan[(D % 10).toInt()] + obb.Zhi[(D % 12).toInt()];

      // 纪日,2000年1月7日起算
      D = day.d0 - 6 + 9000000;
      day.gzDay = obb.Gan[(D % 10).toInt()] + obb.Zhi[(D % 12).toInt()];

      // 星座
      mk = Math.Floor2Double((day.d0 - SSQ.ZQ[0] - 15) / 30.43685).toInt();
      if (mk < 11 && day.d0 >= SSQ.ZQ[2 * mk + 2]) {
        mk++;
      } //星座所在月的序数,(如果j=13,ob.d0不会超过第14号中气)
      day.xingzuo = obb.XiZ[((mk + 12) % 12).toInt()] + "座";

      day.getLunarFestival(); //农历节日
      day.getGregorianFestival(); //公历节日

      day.getLunarShujiu(); // 数九
      day.getLunarSanfu(); // 三伏
    }

    // 以下是月相与节气的处理
    double d, jd2 = Bd0 + JD.deltatT2(Bd0) - 8 / 24;
    int xn;

    // 月相查找
    w = XL.MS_aLon(jd2 / 36525, 10, 3);
    w = Math.Floor2Double((w - 0.78) / pi * 2) * pi / 2;
    do {
      d = obb.so_accurate(w);
      D = Math.Floor2Double(d + 0.5);
      //xn = (int)Math.Floor2Double(w / LunarHelper.pi2 * 4 + 4000000.01) % 4;
      xn = Math.Floor2Double(w / LunarHelper.pi2 * 4 + 4000000.01).toInt() % 4;
      w += LunarHelper.pi2 / 4;
      if (D >= Bd0 + monthDaysCount) {
        break;
      }
      if (D < Bd0) {
        continue;
      }
      DayInfo day = (this.days[(D - Bd0).toInt()]);
      day.yxmc = obb.yxmc[xn]; // 取得月相名称
      day.yxjd = d.toString();
      day.yxsj = JD.timeStr(d);
    } while (D + 5 < Bd0 + monthDaysCount);

    // 节气查找
    w = XL.S_aLon(jd2 / 36525, 3);
    w = Math.Floor2Double((w - 0.13) / LunarHelper.pi2 * 24) *
        LunarHelper.pi2 /
        24;
    do {
      d = obb.qi_accurate(w);
      D = Math.Floor2Double(d + 0.5);
      xn = Math.Floor2Double(w / LunarHelper.pi2 * 24 + 24000006.01).toInt() %
          24;
      w += LunarHelper.pi2 / 24;
      if (D >= Bd0 + monthDaysCount) {
        break;
      }
      if (D < Bd0) {
        continue;
      }
      DayInfo day = (this.days[(D - Bd0).toInt()]);
      day.jieqi = obb.jqmc[xn]; // 取得节气名称
      day.jqjd = d.toString();
      day.jqsj = JD.timeStr(d);
    } while (D + 12 < Bd0 + monthDaysCount);

    // C#: 转换时新增的代码行
    this.CalcRiJianThisMonth(); // 计算本月所有日期的日十二建信息
  }

  getLunarYearInfo(int By) {
    // 所属公历年对应的农历年信息：天干地支，生肖，年号
    int ganzhiYear = By - 1984 + 9000;
    this.ganzhiYear =
        obb.Gan[(ganzhiYear % 10)] + obb.Zhi[(ganzhiYear % 12)]; //干支纪年
    this.shengxiao = obb.ShX[(ganzhiYear % 12)]; // 该年对应的生肖
    this.nianhao = obb.getNianhao(By);
  }

  // 根据指定的月建(地支), 查找并返回指定日(地支)的日十二建
  // <param name="yueJian">月建(地支)</param>
  // <param name="riZhi">要计算日十二建的指定日(地支)</param>
  String GetRi12Jian(String yueJian, String riZhi) {
    String result = "";
    int posYueJian = -1, posRiZhi = -1, pos;

    for (int i = 0; i < obb.Zhi.length; i++) {
      if (obb.Zhi[i] == yueJian) {
        posYueJian = i;
        break;
      }
    }

    if (posYueJian >= 0) {
      for (int i = posYueJian + 1; i < obb.DoubleZhi.length; i++) {
        if (obb.DoubleZhi[i] == riZhi) {
          posRiZhi = i;
          break;
        }
      }

      if (posRiZhi >= posYueJian) {
        pos = posRiZhi - posYueJian;
        result = obb.DoubleRiJian12[pos];
      }
    }

    return result;
  }

  // 计算本月所有日期的日十二建信息
  void CalcRiJianThisMonth() {
    DayInfo lunDay;
    String yuejian = "";

    for (int i = 0; i < this.monthDaysCount; i++) // 遍历月
    {
      lunDay = this.days[i];

      // 可直接使用该属性的月建而无需再次计算节气, 但上述被注释的代码也可用(主要为了测试 CalcJieQiInfo 方法, 暂保留)
      yuejian = LunarHelper.SUBSTRING(lunDay.gzMonth, 1, 1);

      lunDay.Ri12Jian = this.GetRi12Jian(
          yuejian, LunarHelper.SUBSTRING(lunDay.gzDay, 1, 1)); // 计算日十二建
    }
  }
}
