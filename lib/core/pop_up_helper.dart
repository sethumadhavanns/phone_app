import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PopupAlertHelper {
  /// Shows a popup with success or failure icon and message.
  /// Only needs [success] flag and [message] text.
  static Future<void> showPopupAlert(
    BuildContext context,
    bool success,
    String message,
  ) async {
    if (!context.mounted) return;

    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: _buildPopupContent(context, success, message),
        ),
      ),
    );
  }

  static Widget _buildPopupContent(
    BuildContext context,
    bool success,
    String message,
  ) {
    double screenWidth = MediaQuery.of(context).size.width;
    double dialogWidth = screenWidth > 900
        ? 500
        : screenWidth > 600
        ? 400
        : screenWidth * 0.9;

    return Container(
      width: dialogWidth,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 2),
            Icon(
              success
                  ? CupertinoIcons.check_mark_circled
                  : CupertinoIcons.exclamationmark_shield_fill,
              size: 50,
              color: success ? Colors.green : Colors.red,
            ),
            SizedBox(height: 25),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Close'),
              ),
            ),
            SizedBox(height: 2),
          ],
        ),
      ),
    );
  }
}
