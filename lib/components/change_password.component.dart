import 'package:awesome_poll_app/utils/commons.dart';
import 'package:awesome_poll_app/services/auth/auth.service.dart';

class ChangePasswordComponent extends StatefulWidget {
  const ChangePasswordComponent({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChangePasswordComponent();
}

class _ChangePasswordComponent extends State<ChangePasswordComponent> {
  String? someErrorMessage;
  bool _obscureText = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    FormGroup registerForm() => FormGroup({
          'oldPassword': FormControl<String>(
            value: '',
            validators: [Validators.required],
          ),
          'password': FormControl<String>(
            value: '',
            validators: [Validators.required],
          ),
          'passwordRepeat': FormControl<String>(
            value: '',
            validators: [Validators.required],
          )
        }, validators: [
          Validators.mustMatch('password', 'passwordRepeat'),
        ]);

    /// Executed when clicking on the submit button
    /// If the passwords are equal, then change the password of the current user.
    /// Print an error notice, if it did not work (e.e. password too weak)
    void _changePassword(FormGroup form) async {
      if (!form.hasErrors) {
        setState(() => _isLoading = true); // trigger load animation
        var auth = getIt.get<AuthService>();
        try {
          await auth.changePassword(
              form.control('oldPassword').value,
              form.control('password').value,
              form.control('passwordRepeat').value);
          form.reset();
          setState(() {
            someErrorMessage = context.lang('accountManagement.changedPassword');
          });
        } on RegisterException catch (e) {
          if (e.code == 'passwords-differ') {
            setState(() {
              someErrorMessage = context.lang('accountManagement.passwordsNotEqual');
            });
          } else if (e.code == 'weak-password') {
            // TODO: Implement a validator that enforces at least six chars (this is forced by Firebase)
            setState(() {
              someErrorMessage = context.lang('accountManagement.passwordsTooWeak');
            });
          }
        } on LoginException catch (e) {
          if (e.code == 'wrong-password') {
            setState(() {
              someErrorMessage = context.lang('accountManagement.oldPasswordWrong');
            });
          }
        } catch (e) {
          debugPrint('Changing password failed $e');
        }
        setState(() => _isLoading = false); // hide loading animation
      } else {
        setState(() {
          someErrorMessage = context.lang('forms.formValidationFailed');
        });
      }
    }

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              AutoRouter.of(context).navigateBack();
            },
          ),
          elevation: 3,
          title: Text(context.lang('settings.menu.changePassword')),
        ),
        body: Padding(
            padding: const EdgeInsets.all(30),
            child: Center(
                child: SingleChildScrollView(
                    child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 360,
                        ),
                        child: Container(
                            padding: const EdgeInsets.all(30),
                            child: Column(
                              children: [
                                ReactiveFormBuilder(
                                  form: registerForm,
                                  builder: (formContext, form, child) {
                                    return Column(
                                      children: <Widget>[
                                        Row(
                                          children: [
                                            Text(context.lang('accountManagement.oldPassword'),
                                                style: const TextStyle(
                                                    fontSize: 15)),
                                            const SizedBox(
                                              height: 15,
                                            )
                                          ],
                                        ),
                                        ReactiveTextField(
                                          validationMessages: (control) => {
                                            'required': context.lang('forms.requiredField'),
                                          },
                                          decoration: InputDecoration(
                                              errorStyle: const TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                              filled: true,
                                              fillColor: Colors.white,
                                              border: const OutlineInputBorder(),
                                              hintText:
                                                  context.lang('accountManagement.enterCurrentPassword'),
                                              hintStyle: const TextStyle(
                                                  color: Colors.black)),
                                          style: TextStyle(
                                      color: context.customTheme.colors["inputTextColor"],
                                    ),        
                                          formControlName: 'oldPassword',
                                          obscureText: _obscureText,
                                        ),
                                        
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        Row(
                                          children: const [
                                            Text('Password',
                                                style: TextStyle(
                                                    fontSize: 15)),
                                            SizedBox(
                                              height: 15,
                                            )
                                          ],
                                        ),
                                        ReactiveTextField(
                                          validationMessages: (control) => {
                                            'required': context.lang('forms.requiredField'),
                                          },
                                          decoration: InputDecoration(
                                            errorStyle: const TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: const OutlineInputBorder(),
                                            hintText: context.lang('accountManagement.enterNewPassword'),
                                            hintStyle: const TextStyle(
                                                color: Colors.black),
                                            suffixIcon: IconButton(
                                                icon: Icon(
                                                  // Based on passwordVisible state choose the icon
                                                  _obscureText
                                                      ? Icons.visibility_off
                                                      : Icons.visibility,
                                                  color:
                                                      const Color(0xff111111),
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _obscureText =
                                                        !_obscureText;
                                                  });
                                                }),
                                          ),
                                          style: TextStyle(
                                      color: context.customTheme.colors["inputTextColor"],
                                    ),
                                          formControlName: 'password',
                                          obscureText: _obscureText,
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        Row(
                                          children: const [
                                            Text('Password Confirmation',
                                                style: TextStyle(
                                                    fontSize: 15)),
                                            SizedBox(
                                              height: 15,
                                            )
                                          ],
                                        ),
                                        ReactiveTextField(
                                          validationMessages: (control) => {
                                            'required': context.lang('forms.requiredField'),
                                            'mustMatch':
                                                'Passwords don\'t match',
                                          },
                                          decoration: InputDecoration(
                                            errorStyle: const TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: const OutlineInputBorder(),
                                            hintText:
                                                context.lang('accountManagement.enterNewPasswordAgain'),
                                            hintStyle:
                                                const TextStyle(color: Colors.black),
                                          ),
                                          style: TextStyle(
                                      color: context.customTheme.colors["inputTextColor"],
                                    ),
                                          formControlName: 'passwordRepeat',
                                          obscureText: _obscureText,
                                        ),
                                        const SizedBox(
                                          height: 100,
                                        ),
                                        _isLoading
                                            ? TextButton.icon(
                                                style: ButtonStyle(
                                                    padding: MaterialStateProperty.all(
                                                        const EdgeInsets.only(
                                                            left: 30, right: 30, top: 20, bottom: 20)),
                                                    backgroundColor:
                                                        MaterialStateProperty.all(
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .secondary)),
                                                onPressed: () =>
                                                    _changePassword(form),
                                                label: Text(
                                                    context.lang('settings.menu.changePassword'),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                    )),
                                                icon: _isLoading
                                                    ? Container(
                                                        width: 24,
                                                        height: 24,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2.0),
                                                        child:
                                                            const CircularProgressIndicator(
                                                          color: Colors.white,
                                                          strokeWidth: 3,
                                                        ),
                                                      )
                                                    : const Icon(null))
                                            : TextButton(
                                                style: ButtonStyle(
                                                    padding: MaterialStateProperty.all(
                                                        const EdgeInsets.only(
                                                            left: 30, right: 30, top: 20, bottom: 20)),
                                                    backgroundColor:
                                                        MaterialStateProperty.all(Theme.of(context).colorScheme.secondary)),
                                                onPressed: () => _changePassword(form),
                                                child: Text(context.lang('settings.menu.changePassword'),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                    ))),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 0,
                                            top: 20,
                                            right: 0,
                                            bottom: 0,
                                          ),
                                          child: someErrorMessage == null
                                              ? const Text('')
                                              : Text('$someErrorMessage'),
                                        )
                                      ],
                                    );
                                  },
                                ),
                              ],
                            )))))));
  }
}
