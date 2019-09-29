import 'dart:math';

class StringBuffer {
  String buf = "";
  StringBuffer();
  StringBuffer.withCapacity(String value, int capacity) {
    buf = value;
  }
  StringBuffer.fromStr(String value) {
    buf = value;
  }
  Append(String v) {
    buf += v;
  }

  AppendLine(String v) {
    buf += v + "\n";
  }

  ToString() {
    return buf;
  }

  Remove(int startIndex, int length) {
    buf.replaceRange(startIndex, startIndex + length, "");
  }

  get Length => buf.length;

  StringBuffer Replace(String oldValue, String newValue) {
    buf = buf.replaceAll(oldValue, newValue);
    return this;
  }
}

class Math {
  static double get PI => pi;

  static int Floor2Int(double d) => d.floor();

  static double Floor2Double(double d) => d.floor().toDouble();

  static double Cos(double r) => cos(r);

  static double Sin(double r) => sin(r);

  static double Acos(double v) => acos(v);

  static double Atan2(double y, double x) => atan2(y, x);

  static double Asin(double d) => asin(d);

  static double Tan(double a) => tan(a);

  static double Atan(double d) => atan(d);

  static double Sqrt(double d) => sqrt(d);

  static double Abs(double v) => v.abs();

  static double Pow(double x, double y) => pow(x, y);
}

class MyString {
  String data;
  MyString(this.data);

  MyString SubMyString(int startIndex, int length) {
    return MyString(data.substring(startIndex, startIndex + length));
  }

  MyString operator +(MyString other) {
    return MyString(this.data + other.data);
  }
}

class Tool {
  static double NowUTCmsSince19700101(DateTime nowDT) {
    DateTime DT19700101 = new DateTime(1970, 1, 1, 0, 0, 0, 0);
    return nowDT.toUtc().difference(DT19700101).inMilliseconds.toDouble();
  }
}
