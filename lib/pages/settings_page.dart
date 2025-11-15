import 'package:exp_trace/pages/categories_page.dart';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

import '../main.dart';
import '../widgets/custom_button.dart';

class SettingsPage extends StatelessWidget {
  Future<void> _backupDatabase(BuildContext context) async {
    String? selectedPath = await FilePicker.platform.getDirectoryPath();

    if (selectedPath != null) {
      final backupPath = '$selectedPath/backup.db';
      await DatabaseHelper.instance.backupDatabase(backupPath);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Backup salvato in: $backupPath')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selezione della cartella annullata')),
      );
    }
  }

  Future<void> _restoreDatabase(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      final restorePath = result.files.single.path!;

      if (!File(restorePath).existsSync()) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('File di backup non valido!')));
        return;
      }

      await DatabaseHelper.instance.restoreDatabase(restorePath);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Database ripristinato da: $restorePath')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Selezione del file annullata')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Impostazioni')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            CustomButton(
              onPressed: () => _backupDatabase(context),
              icon: Icons.file_download,
              color: Colors.grey,
              text: 'Esegui Backup',
            ),
            SizedBox(height: 20),
            CustomButton(
              onPressed: () => _restoreDatabase(context),
              icon: Icons.file_upload,
              color: Colors.grey,
              text: 'Ripristina Backup',
            ),
            SizedBox(height: 20),
            CustomButton(
              text: 'Categorie entrate',
              icon: Icons.input,
              color: Colors.grey,
              onPressed:
                  () => navigateTo(
                    context,
                    CategoriesPage(type: TransactionType.entrata),
                  ),
            ),
            SizedBox(height: 20),
            CustomButton(
              text: 'Categorie uscite',
              icon: Icons.output,
              color: Colors.grey,
              onPressed:
                  () => navigateTo(
                    context,
                    CategoriesPage(type: TransactionType.uscita),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
