import 'package:flutter/material.dart';
import '../constants/enums.dart';

Widget recordButtonStatusText({required BuildContext context, required bool isDownloadingKaraokeFile, required RecorderStatus status}){

    return  Text((status == RecorderStatus.recording ? 'RECORDING' :  'PAUSED'),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w400,
            color: Colors.deepOrange
        )
    );
}