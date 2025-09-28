import 'package:flutter/cupertino.dart';
import 'package:fruit_hub/core/helpers/extentions.dart';
import 'package:google_fonts/google_fonts.dart';

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    this.name,
    this.onTap,
    this.fullText,
    this.delete = true,
    this.textOkButton,
  });

  final String? name;
  final void Function()? onTap;
  final String? fullText;
  final bool delete;
  final String? textOkButton;

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(
        delete ? 'Delete Confirmation' : 'Confirmation',
        style: GoogleFonts.lato(),
      ),
      content: fullText != null
          ? Text(fullText!, style: GoogleFonts.lato())
          : Text.rich(
              TextSpan(
                style: GoogleFonts.lato(),
                children: [
                  const TextSpan(text: 'Are you sure you want to delete '),
                  TextSpan(
                    text: name,
                    style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: ' ? This action cannot be undone.'),
                ],
              ),
            ),

      actions: [
        CupertinoDialogAction(
          child: Text('Cancel', style: GoogleFonts.lato()),
          onPressed: () {
            context.pop();
          },
        ),
        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: onTap,
          child: Text(textOkButton ?? 'Delete', style: GoogleFonts.lato()),
        ),
      ],
    );
  }
}
