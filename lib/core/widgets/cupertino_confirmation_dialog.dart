import 'package:flutter/cupertino.dart';
import 'package:fruit_hub/core/helpers/extentions.dart';
import 'package:google_fonts/google_fonts.dart';

class CupertinoConfirmationDialog extends StatelessWidget {
  const CupertinoConfirmationDialog({
    super.key,
    this.name,
    this.onTap,
    this.fullText,
    this.delete = true,
    this.textOkButton,
    required this.title,
    this.textCancelButton,
  });

  final String title;
  final String? name;
  final String? fullText;
  final String? textOkButton;
  final String? textCancelButton;
  final void Function()? onTap;
  final bool delete;

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(title, style: GoogleFonts.lato()),
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
          child: Text(textCancelButton ?? 'Cancel', style: GoogleFonts.lato()),
          onPressed: () => context.pop(),
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
