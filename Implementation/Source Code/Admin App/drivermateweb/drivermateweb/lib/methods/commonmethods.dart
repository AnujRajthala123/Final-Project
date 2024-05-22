
import 'package:flutter/material.dart';

class CommonMethods{
  Widget header(int headerflexValue, String headertitle){
    return Expanded(
      flex: headerflexValue,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          color: Colors.orange[700],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            headertitle,
            style: const TextStyle(
              color: Colors.white,
            ),
            ),),
      ),
    );
  }
    Widget data(int dataFlexValue, Widget widget){
    return Expanded(
      flex: dataFlexValue,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: widget,
      ),
    ));
  }

  
}