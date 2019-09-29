//using System;
//using System.Collections.Generic;
//using System.Text;
//using System.Collections;

//namespace SharpSxwnl
//{
// <summary>
// 由于在 Javascript 中, 数组可以有自己的属性, 为了对应此功能, 设计本类
// 可用的方案: 使用 List&lt;T&gt; 或 ArrayList, 使用前者可以提高代码的效率, 后者则需要装箱拆箱和显式类型转换操作
// </summary>
// <typeparam name="T"></typeparam>
//class LunarInfoListT<T> : List<T>      // 派生于泛型 List<T> 类, 以提高代码的效率
class LunarInfoListT<T> // 派生于泛型 List<T> 类, 以提高代码的效率
{
  List<T> l = [];
  T operator [](int i) {
    return l[i];
  }

  operator []=(int i, T value) {
    l[i] = value;
  }

  add(T t) {
    l.add(t);
  }

//#region 公共属性(注: 初始转换时为公共字段, 已改写)

  double s__; // 升(时间)
  double z__; // 中(时间)
  double j__; // 降(时间)
  double c__; // 晨(时间)
  double h__; // 昏(时间)
  double ch__; // 晨昏差(时间)
  double sj__; // 升降差(时间)
  String s; // 升(时间串)
  String z; // 中(时间串)
  String j; // 降(时间串)
  String c; // 晨(时间串)
  String h; // 昏(时间串)
  String ch; // 日照时间(串)
  String sj; // 昼长(时间串)
  String Ms; // 月出时间(串)
  String Mz; // 月亮中天时间(串)
  String Mj; // 月落时间(串)

  // 本属性(字段)有不同的含义：
  // (1) 用于月对象 LunarInfoListT<OB> lun 的属性(字段) dn: 该月的总天数；
  // (2) 用于多天的升中降容器 LunarInfoListT<LunarInfoListT<double>> rts 的属性(字段) dn: 要求计算升中降信息的天数
  double dn;

  double H; // 指定时刻的天体时角
  double H0; // 本属性(字段)有不同的含义： 升起对应的时角(月亮?), 或地平以下50分的时角(太阳?)
  double H1; // 地平以下6度的时角(太阳?)
  double pe1; // 节气的儒略日
  double pe2; // 节气的儒略日

  int get Count => this.l.length;

  LunarInfoListT() {}

  // 构造函数, 添加指定数目的元素到本类中, 并赋初值
  // <param name="itemsCount">要添加的元素个数</param>
  // <param name="initValue">元素的初值(泛型)</param>
  LunarInfoListT.withData(int itemsCount, T initValue) {
    for (int i = 0; i < itemsCount; i++) {
      this.l.add(initValue);
    }
  }
}
