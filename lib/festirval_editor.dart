import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FestirvalEditor extends StatefulWidget {
//  final double screenHeight;
  String oldText;
  String Function(String) onSaveFn;
  FestirvalEditor(this.oldText, this.onSaveFn) {}

  @override
  State<StatefulWidget> createState() {
    return FestirvalEditorState();
  }
}

class FestirvalEditorState extends State<FestirvalEditor> {
  String _newText;
  FestirvalEditorState();

  double _width = MediaQueryData.fromWindow(window).size.width;
  double _height = MediaQueryData.fromWindow(window).size.height;

  final TextEditingController _controller = TextEditingController();
  double _fontSize;

  @override
  initState() {
    super.initState();

    _newText = widget.oldText;

    _fontSize = _width / 20;

    _controller.text = widget.oldText;
  }

  Widget _buildExample() {
    return Scrollbar(
        child: SingleChildScrollView(
            child: Container(
      width: _width * 8 / 10,
      height: _height * 2 / 10,
//      decoration: BoxDecoration(
//        color: Colors.blue[300],
//        border: Border.all(width: 0.5, color: Colors.black38),
//        borderRadius: BorderRadius.all(Radius.circular(6.0)),
//      ),
      child: TextField(
        readOnly: true,
//        controller: _controller,
//      autofocus: true,
        maxLines: 5,
        minLines: 5,
        decoration: InputDecoration(
//        icon: Icon(Icons.event_note, color: Colors.black),
          hintText: """示例：
G11.11/#FF8C00/光棍节
解释：公历11月11日/显示颜色/内容
L0.-1/#FF8C00/十斋日
解释：农历每月最后一天/显示颜色/内容""",
          hintStyle: TextStyle(fontSize: _width / 25, color: Colors.grey[600]),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        style: TextStyle(fontSize: _fontSize),
        onChanged: (String str) {
          _newText = str;
        },
      ),
    )));
  }

  Widget _buildTextInput() {
    return Scrollbar(
        child: SingleChildScrollView(
            child: Container(
      width: _width * 8 / 10,
      height: _height * 55 / 100,
//      decoration: BoxDecoration(
//        color: Colors.blue[300],
//        border: Border.all(width: 0.5, color: Colors.black38),
//        borderRadius: BorderRadius.all(Radius.circular(6.0)),
//      ),
      child: TextField(
        controller: _controller,
//      autofocus: true,
        maxLines: 1000,
        minLines: 15,
        decoration: InputDecoration(
//        icon: Icon(Icons.event_note, color: Colors.black),
          hintText: "点击此处，\n输入节日名称!",
          hintStyle: TextStyle(fontSize: _fontSize, color: Colors.grey[500]),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        style: TextStyle(fontSize: _fontSize),
        onChanged: (String str) {
          _newText = str;
        },
      ),
    )));
  }

  Widget _buildButtonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        RaisedButton(
          child: Text("退出",
              style: TextStyle(color: Colors.red, fontSize: _fontSize)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        RaisedButton(
          child: Text("保存", style: TextStyle(fontSize: _fontSize)),
          onPressed: () {
            final log = widget.onSaveFn(_newText);
            if ((null == log) || ("" == log)) {
              Navigator.pop(context);
            } else {
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text(
                  log,
                  style: TextStyle(color: Colors.red, fontSize: _fontSize),
                ),
                duration: Duration(seconds: 5),
                backgroundColor: Colors.tealAccent,
//    action: SnackBarAction(
//      label: "button",
//      onPressed: () {
//        print("in press");
//      },
//    ),
              ));
            }
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
//      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        SizedBox(
          width: _width / 40,
          height: _width / 40,
        ),
        _buildExample(),
        SizedBox(
          width: _width / 40,
          height: _width / 40,
        ),
        _buildTextInput(),
//        SizedBox(
//          width: _width / 40,
//          height: _width / 40,
//        ),
        _buildButtonRow(),
      ],
    );
  }
}
