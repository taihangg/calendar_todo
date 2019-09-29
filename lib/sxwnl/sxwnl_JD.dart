import 'sxwnl_tool.dart';

class JD {
  static final data = JD();
  //  #region 转换时增加的私有字段(用于封装成公共属性, 按转换规范 10 命名)
  int _Y = 2000; // 年
  static int get Y => data._Y;
  static set Y(v) => data._Y = v;

  int _M = 1; // 月
  static int get M => data._M;
  static set M(v) => data._M = v;

  int _D = 1; // 日
  static int get D => data._D;
  static set D(v) => data._D = v;

  int _h = 12; // 时
  static int get h => data._h;
  static set h(v) => data._h = v;

  int _m = 0; // 分
  static int get m => data._m;
  static set m(v) => data._m = v;

  double _s = 0; // 秒
  static double get s => data._s;
  static set s(v) => data._s = v;

  // 星期中文名称
  static const List<String> _Weeks = ["日", "一", "二", "三", "四", "五", "六", "七"];

  /// TD - UT1 计算表
  static const List<double> dts = [
    //
    -4000, 108371.7, -13036.80, 392.000, 0.0000,
    -500, 17201.0, -627.82, 16.170, -0.3413,
    -150, 12200.6, -346.41, 5.403, -0.1593,
    150, 9113.8, -328.13, -1.647, 0.0377,
    500, 5707.5, -391.41, 0.915, 0.3145,
    900, 2203.4, -283.45, 13.034, -0.1778,
    1300, 490.1, -57.35, 2.085, -0.0072,
    1600, 120.0, -9.81, -1.532, 0.1403,
    1700, 10.2, -0.91, 0.510, -0.0370,
    1800, 13.4, -0.72, 0.202, -0.0193,
    1830, 7.8, -1.81, 0.416, -0.0247,
    1860, 8.3, -0.13, -0.406, 0.0292,
    1880, -5.4, 0.32, -0.183, 0.0173,
    1900, -2.3, 2.06, 0.169, -0.0135,
    1920, 21.2, 1.69, -0.304, 0.0167,
    1940, 24.2, 1.22, -0.064, 0.0031,
    1960, 33.2, 0.51, 0.231, -0.0109,
    1980, 51.0, 1.29, -0.026, 0.0032,
    2000, 63.87, 0.1, 0, 0,
    2005
  ];

  /// 二次曲线外推
  static double deltatExt(double y, double jsd) {
    double dy = (y - 1820) / 100;
    return -20 + jsd * dy * dy;
  }

  /// 计算世界时与原子时之差,传入年
  /// <param name="y">年</param>
  static double deltatT(double y) {
    if (y >= 2005) {
      //sd 是2005年之后几年（一值到y1年）的速度估计。
      //jsd 是y1年之后的加速度估计。瑞士星历表jsd=31,NASA网站jsd=32,skmap的jsd=29
      double y1 = 2014;
      double sd = 0.4;
      double jsd = 31;
      if (y <= y1) return 64.7 + (y - 2005) * sd; //直线外推
      double v = JD.deltatExt(y, jsd); //二次曲线外推
      double dv =
          JD.deltatExt(y1, jsd) - (64.7 + (y1 - 2005) * sd); //y1年的二次外推与直线外推的差
      if (y < y1 + 100) v -= dv * (y1 + 100 - y) / 100;
      return v;
    }
    int i;
    List<double> d = JD.dts;
    for (i = 0; i < d.length; i += 5) if (y < d[i + 5]) break;
    double t1 = (y - d[i]) / (d[i + 5] - d[i]) * 10;
    double t2 = t1 * t1;
    double t3 = t2 * t1;
    return d[i + 1] + d[i + 2] * t1 + d[i + 3] * t2 + d[i + 4] * t3;
  }

  /// 传入儒略日(J2000起算),计算TD-UT(单位:日)
  /// <param name="t">J2000起算的儒略日</param>
  static double deltatT2(double t) {
    return JD.deltatT(t / 365.2425 + 2000) / 86400.0;
  }

  /// 公历转儒略日
  /// <param name="y">年</param>
  /// <param name="m">月</param>
  /// <param name="d">日</param>
  static double JD__(double y, double m,
      double d) // C#: 为了避免与类名相同而冲突(被视为构造函数), 按转换规范 1 为方法名添加下划线
  {
    double n = 0;
    double G = 0;
    if (y * 372 + m * 31 + Math.Floor2Double(d) >= 588829) {
      G = 1; //判断是否为格里高利历日1582*372+10*31+15
    }
    if (m <= 2) {
      m += 12;
      y--;
    }
    if (G != 0) {
      n = Math.Floor2Double(y / 100);
      n = 2 - n + Math.Floor2Double(n / 4);
    } //加百年闰
    return Math.Floor2Double(365.25 * (y + 4716) + 0.01) +
        Math.Floor2Double(30.6001 * (m + 1)) +
        d +
        n -
        1524.5;
  }

  /// <summary>
  /// 公历转儒略日
  /// </summary>
  /// <returns></returns>
  static double toJD() {
    return JD.JD__(JD.Y.toDouble(), JD.M.toDouble(),
        JD.D + ((JD.s / 60 + JD.m) / 60 + JD.h) / 24);
  }

  /// <summary>
  /// 儒略日数转公历
  /// </summary>
  /// <param name="jd">儒略日</param>
  static void setFromJD(double jd) {
    jd += 0.5;
    double A = Math.Floor2Double(jd);
    double F = jd - A;
    int D; //取得日数的整数部份A及小数部分F
    if (A >= 2299161) {
      D = Math.Floor2Int((A - 1867216.25) / 36524.25);
      A += 1 + D - Math.Floor2Int(D / 4);
    }
    A += 1524; //向前移4年零2个月
    JD.Y = Math.Floor2Int((A - 122.1) / 365.25); //年
    D = A.toInt() - Math.Floor2Int(365.25 * JD.Y); //去除整年日数后余下日数
    JD.M = Math.Floor2Int(D / 30.6001); //月数
    JD.D = D - Math.Floor2Int(JD.M * 30.6001); //去除整月日数后余下日数
    JD.Y -= 4716;
    JD.M--;
    if (JD.M > 12) JD.M -= 12;
    if (JD.M <= 2) JD.Y++;

    //日的小数转为时分秒
    F *= 24;
    JD.h = Math.Floor2Int(F);
    F -= JD.h;
    F *= 60;
    JD.m = Math.Floor2Int(F);
    F -= JD.m;
    F *= 60;
    JD.s = F;
  }

  /// <summary>
  /// 日期转为串
  /// </summary>
  /// <returns></returns>
  static String toStr() {
    String Y = "     " + JD.Y.toString();
    String M = "0" + JD.M.toString();
    String D = "0" + JD.D.toString();
    int h = JD.h;
    int m = JD.m;
    double s = Math.Floor2Double(JD.s + .5);
    if (s >= 60) {
      s -= 60;
      m++;
    }
    if (m >= 60) {
      m -= 60;
      h++;
    }
    String hStr = "0" + h.toString();
    String mStr = "0" + m.toString();
    String sStr = "0" + s.toString();
    Y = Y.substring(Y.length - 5, Y.length - 5 + 5);
    M = M.substring(M.length - 2, M.length - 2 + 2);
    D = D.substring(D.length - 2, D.length - 2 + 2);
    hStr = hStr.substring(hStr.length - 2, hStr.length - 2 + 2);
    mStr = mStr.substring(mStr.length - 2, mStr.length - 2 + 2);
    sStr = sStr.substring(sStr.length - 2, sStr.length - 2 + 2);
    return Y + "-" + M + "-" + D + " " + hStr + ":" + mStr + ":" + sStr;
  }

  /// <summary>
  /// 儒略日数转公历, 并且返回日期转化的时间串
  /// </summary>
  /// <param name="jd"></param>
  /// <returns></returns>
  static String setFromJD_str(double jd) {
    JD.setFromJD(jd);
    return JD.toStr();
  }

  /// <summary>
  /// 提取jd中的时间(去除日期)
  /// </summary>
  /// <param name="jd"></param>
  /// <returns></returns>
  static String timeStr(double jd) {
    double h;
    double m;
    double s;
    jd += 0.5;
    jd = (jd - Math.Floor2Double(jd));
    jd *= 24;
    h = Math.Floor2Double(jd);
    jd -= h;
    jd *= 60;
    m = Math.Floor2Double(jd);
    jd -= m;
    jd *= 60;
    s = Math.Floor2Double(jd + 0.5);
    if (s >= 60) {
      s -= 60;
      m++;
    }
    if (m >= 60) {
      m -= 60;
      h++;
    }
    String hStr = "0" + h.toString();
    String mStr = "0" + m.toString();
    String sStr = "0" + s.toString();
    return hStr.substring(hStr.length - 2, hStr.length - 2 + 2) +
        ':' +
        mStr.substring(mStr.length - 2, mStr.length - 2 + 2) +
        ':' +
        sStr.substring(sStr.length - 2, sStr.length - 2 + 2);
  }

  /// 星期计算
  static double getWeek(double jd) {
    return Math.Floor2Double(jd + 1.5) % 7;
  }

  /// 求y年m月的第n个星期w的儒略日数
  /// <param name="y">年</param>
  /// <param name="m">月</param>
  /// <param name="n"></param>
  /// <param name="w">星期w</param>
  static double nnweek(double y, double m, double n, double w) {
    double jd = JD.JD__(y, m, 1.5); //月首儒略日
    double w0 = (jd + 1) % 7; //月首的星期
    double r =
        jd - w0 + 7 * n + w; //jd-w0+7*n是和n个星期0,起算下本月第一行的星期日(可能落在上一月)。加w后为第n个星期w
    if (w >= w0) r -= 7; //第1个星期w可能落在上个月,造成多算1周,所以考虑减1周
    if (n == 5) {
      m++;
      if (m > 12) {
        m = 1;
        y++;
      } //下个月
      if (r >= JD.JD__(y, m, 1.5)) r -= 7; //r跑到下个月则减1周
    }
    return r;
  }
}
