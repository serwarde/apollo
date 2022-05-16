import 'package:awesome_poll_app/utils/commons.dart';
import 'package:awesome_poll_app/services/auth/auth.service.dart';


class DeleteUserDialog extends StatefulWidget {
  const DeleteUserDialog({Key? key}) : super(key: key);

  @override
  _DeleteUserDialogState createState () => _DeleteUserDialogState();
}

class _DeleteUserDialogState extends State<DeleteUserDialog> {
  // Define a controller for the password input field to later gain its content
  final passwordInputController = TextEditingController();
  bool _passwordValid = true;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    passwordInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return AlertDialog(
      title: Text(context.lang('settings.menu.deleteAccount')),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.lang('settings.menu.deleteAccount.reallySure')),
          const SizedBox(
            height: 15,
          ),
          TextField(
            controller: passwordInputController,
            decoration: InputDecoration(
              hintText: context.lang('settings.menu.deleteAccount.hintPassword'),//"Enter your password"
              errorText: _passwordValid ? null : context.lang('settings.menu.deleteAccount.errorPassword')//"Wrong password"
            ),
            style: TextStyle(
                color: context.customTheme.colors['inputTextColor'],
              ),
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
          )
        ]),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, context.lang('app.cancel')),
          child: Text(context.lang('app.cancel')),
          style: AppTheme.instance.getMode()==AppThemeMode.light ? TextButton.styleFrom(primary: Colors.black) : null
        ),
        TextButton(
          onPressed: () async {
            var auth = getIt.get<AuthService>();
            try {
              // Delete the account, if the password is correct.
              await auth.deleteAccount(passwordInputController.text);
            } on LoginException catch(e) {
              setState(() => _passwordValid = false);
            }
          },
          child: Text(context.lang('settings.menu.deleteAccount.yesDelete')),
          style: AppTheme.instance.getMode()==AppThemeMode.light ? TextButton.styleFrom(primary: Colors.black) : null
        ),
      ],
    );
  }
}


