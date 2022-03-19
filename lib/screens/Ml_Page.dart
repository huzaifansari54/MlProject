import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class MlPage extends StatefulWidget {
  const MlPage({Key? key}) : super(key: key);

  @override
  State<MlPage> createState() => _MlPageState();
}

class _MlPageState extends State<MlPage> {
  XFile? imagePath;
  String recognisedText = '';

  void getImage(ImageSource imageSource) async {
    final image = await ImagePicker().pickImage(source: imageSource);

    if (image != null || imagePath != null) {
      setState(() {
        imagePath = image;
      });
    }
  }

  Future getRecogniseText(path) async {
    final inputImage = InputImage.fromFilePath(path);
    final textDectore = GoogleMlKit.vision.textDetector();
    final RecognisedText _recognised =
        await textDectore.processImage(inputImage);
    if (_recognised.text.isNotEmpty) {
      for (TextBlock textBlock in _recognised.blocks) {
        for (TextLine textLine in textBlock.lines) {
          recognisedText = recognisedText + textLine.text + '  ';
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Image dont have any text Or \n Have non latin language')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  width: double.infinity,
                  color: Colors.red,
                  height: size.height * .6,
                  child: imagePath != null
                      ? Image.file(
                          File(imagePath!.path),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/noImagefounded.png'),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              'No Image is founded',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline4!
                                  .copyWith(color: Colors.white),
                            )
                          ],
                        )),
              const SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 25,
                  ),
                  MaterialButton(
                    color: Colors.red,
                    shape: const StadiumBorder(side: BorderSide.none),
                    onPressed: () async {
                      await resourceDialog(context);
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'PickImage',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  MaterialButton(
                      color: Colors.red,
                      shape: const StadiumBorder(side: BorderSide.none),
                      onPressed: () {
                        if (imagePath != null) {
                          recognisedText = '';
                          getRecogniseText(imagePath!.path).whenComplete(() {
                            setState(() {});
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Select Resourese')));
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('ProceesImage',
                            style: TextStyle(color: Colors.white)),
                      )),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30, bottom: 50, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 15,
                    ),
                    const Divider(),
                    Text(
                      'Recognised Text',
                      style: Theme.of(context)
                          .textTheme
                          .headline4!
                          .copyWith(color: Colors.red),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      recognisedText,
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1!
                          .copyWith(fontSize: 17, color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> resourceDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Select Resources'),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    MaterialButton(
                        color: Colors.red,
                        shape: const StadiumBorder(side: BorderSide.none),
                        onPressed: () {
                          getImage(ImageSource.camera);
                          Navigator.pop(context);
                        },
                        child: const Text('Camera',
                            style: TextStyle(color: Colors.white))),
                    const SizedBox(
                      width: 10,
                    ),
                    MaterialButton(
                        color: Colors.red,
                        shape: const StadiumBorder(side: BorderSide.none),
                        onPressed: () {
                          getImage(ImageSource.gallery);
                          Navigator.pop(context);
                        },
                        child: const Text('Gallery',
                            style: TextStyle(color: Colors.white))),
                  ],
                )
              ],
            ),
          );
        });
  }
}
