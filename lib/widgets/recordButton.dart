import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../constants/enums.dart';
import '../providers/recordProvider.dart';

Widget recordButton(RecordProvider recordProvider,Size screenSize) {
  return SizedBox(
      child: Container(
          width: screenSize.width * 0.09,
          height: screenSize.width * 0.09,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.green)
          ),
          child: Center(
              child: InkWell(
                  onTap: (){
                    if(kDebugMode){
                      print("Sing button tapped in recording mode");
                      print("recorder status : ${recordProvider.voiceRecorderStatus}");
                    }
                    recordProvider.toggleRecordButton();
                  },
                  child: buttonIcon(recordProvider)
              )
          )
      )
  );
}


Widget buttonIcon(RecordProvider recordProvider){
  if (recordProvider.voiceRecorderStatus.value == RecorderStatus.recording) {
      return const Icon(Icons.pause, color: Colors.deepOrange);
    } else {
      return const Icon(Icons.play_arrow, color: Colors.deepOrange);
  }
}
