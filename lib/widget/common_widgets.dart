import 'package:flutter/material.dart';

class CommonWidgets {
  static String placeholderImage =
      "https://www.kindpng.com/picc/m/78-786111_transparent-placeholder-png-placeholder-image-png-clipart.png";
  static Widget audioProfileWithMic(String imageUrl) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(25), // half of 50 for circle
          child: Image.network(
            imageUrl != "" || imageUrl != null ? imageUrl : placeholderImage,
            height: 50,
            width: 50,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 35,
          left: 35,
          bottom: 0,
          right: 0,
          // child: Container(
          //   height: 20,
          //   width: 20,
          //   decoration: BoxDecoration(
          //     shape: BoxShape.circle,
          //     color: Colors.black.withOpacity(0.6),
          //   ),
          child: Icon(
            Icons.mic,
            size: 18,
            color: Colors.grey,
          ),
          // ),
        ),
      ],
    );
  }

  static Widget audioReplyMessage(String img) {
    return Container(
      padding: EdgeInsets.all(5),
      child: Row(
        children: [
          audioProfileWithMic(img),
          Icon(
            size: 30,
            Icons.play_arrow_rounded,
            color: Colors.blue,
          ),
          const SizedBox(width: 8),
          // Expanded(
          Container(
            width: 120,
            decoration: BoxDecoration(
                border: Border.all(
              width: 2,
              color: Colors.grey,
            )),
          ),
          // ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
