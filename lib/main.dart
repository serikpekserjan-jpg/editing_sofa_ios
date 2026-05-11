import 'package:flutter/material.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gal/gal.dart';
import 'dart:io';

void main() => runApp(MaterialApp(home: SofaPatcher(), theme: ThemeData.dark()));

class SofaPatcher extends StatefulWidget {
  @override
  _SofaPatcherState createState() => _SofaPatcherState();
}

class _SofaPatcherState extends State<SofaPatcher> {
  String status = "Нажмите, чтобы выбрать видео";
  double progress = 0.0;
  bool isPatching = false;

  Future<void> runPatch() async {
    // 1. Выбираем файл
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.video);
    
    if (result != null) {
      File file = File(result.files.single.path!);
      String outputPath = "${file.path}_patched.mp4";

      setState(() {
        isPatching = true;
        status = "PATCHING... 0%";
      });

      // 2. Команда сжатия (как в твоем EXE)
      // Мы используем кодек x264 и пресет для соцсетей
      String command = "-i ${file.path} -vcodec libx264 -crf 24 -preset faster -acodec copy $outputPath";

      await FFmpegKit.execute(command).then((session) async {
        final returnCode = await session.getReturnCode();

        if (returnCode!.isValueSuccess()) {
          // 3. Сохраняем в галерею iPhone
          await Gal.putVideo(outputPath);
          setState(() {
            status = "PATCH COMPLETE! Видео в галерее";
            isPatching = false;
          });
        } else {
          setState(() {
            status = "Ошибка патча";
            isPatching = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Video Patcher", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 40),
            GestureDetector(
              onTap: isPatching ? null : runPatch,
              child: Container(
                width: 250, height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.upload_file, size: 50, color: Colors.white54),
              ),
            ),
            SizedBox(height: 30),
            if (isPatching) CircularProgressIndicator(color: Colors.green),
            SizedBox(height: 20),
            Text(status, style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}