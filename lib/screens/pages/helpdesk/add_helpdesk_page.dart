import 'package:flutter/material.dart';
import 'package:sk_app/widgets/text_widget.dart';
import 'package:sk_app/widgets/textfield_widget.dart';

class AddHelpdeskPage extends StatelessWidget {
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final emailController = TextEditingController();
  final concernController = TextEditingController();

  AddHelpdeskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          label: const TextWidget(
            text: 'Submit',
            fontSize: 16,
            color: Colors.white,
            fontFamily: 'Medium',
          ),
        ),
        appBar: AppBar(
          title: const TextWidget(
            text: 'Adding Concern',
            fontSize: 18,
            color: Colors.white,
            fontFamily: 'Bold',
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextWidget(
                  text: 'Fill up the form below',
                  fontSize: 18,
                  fontFamily: 'Bold',
                ),
                const SizedBox(
                  height: 20,
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFieldWidget(
                    height: 300,
                    maxLine: 10,
                    label: 'Input your concern',
                    controller: concernController),
              ],
            ),
          ),
        ));
  }
}
