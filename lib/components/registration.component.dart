import 'package:awesome_poll_app/utils/commons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:awesome_poll_app/services/auth/auth.service.dart';

class RegistrationComponent extends StatefulWidget {
  const RegistrationComponent({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RegistrationComponent();
}

class _RegistrationComponent extends State<RegistrationComponent> {
  String? someErrorMessage;
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    FormGroup registerForm() => FormGroup({
          'email': FormControl<String>(
            value: '',
            validators: [Validators.required, Validators.email],
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

    return Scaffold(
      backgroundColor: const Color(0xff1D3557),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 400,
              ),
              child: Container(
                // padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    Image.asset('assets/images/Logo.png',
                        width: MediaQuery.of(context).size.height * 0.2),
                    Text(context.lang('app.name'),
                        style: GoogleFonts.ribeyeMarrow(
                            textStyle: const TextStyle(
                          color: Color(0xffFCBF49),
                          fontSize: 42,
                        ))),
                    const SizedBox(
                      height: 10,
                    ),
                    ReactiveFormBuilder(
                      form: registerForm,
                      builder: (formContext, form, child) {
                        return Column(
                          children: <Widget>[
                            Row(
                              children: const [
                                Text('Email',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15)),
                                SizedBox(
                                  height: 15,
                                )
                              ],
                            ),
                            ReactiveTextField(
                              validationMessages: (control) => {
                                'required': context.lang('validators.required'),
                                'email':
                                    context.lang('validators.invalid_email'),
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
                                  hintText: context.lang('login.hint.username'),
                                  hintStyle:
                                      const TextStyle(color: Colors.black)),
                              style: TextStyle(
                                color: context
                                    .read<AppThemeCubit>()
                                    .theme
                                    .colors["inputTextColor"],
                              ),
                              formControlName: 'email',
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Row(
                              children: [
                                Text(context.lang('registration.password'),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 15)),
                                const SizedBox(
                                  height: 15,
                                )
                              ],
                            ),
                            ReactiveTextField(
                              validationMessages: (control) => {
                                'required': context.lang('validators.required'),
                                'email':
                                    context.lang('validators.invalid_email'),
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
                                    context.lang('registration.hint.password'),
                                hintStyle: const TextStyle(color: Colors.black),
                                suffixIcon: IconButton(
                                    icon: Icon(
                                      // Based on passwordVisible state choose the icon
                                      _obscureText
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: const Color(0xff111111),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureText = !_obscureText;
                                      });
                                    }),
                              ),
                              style: TextStyle(
                                color: context
                                    .read<AppThemeCubit>()
                                    .theme
                                    .colors["inputTextColor"],
                              ),
                              formControlName: 'password',
                              obscureText: _obscureText,
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Row(
                              children: [
                                Text(
                                    context
                                        .lang('registration.confirm_password'),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 15)),
                                const SizedBox(
                                  height: 15,
                                )
                              ],
                            ),
                            ReactiveTextField(
                              validationMessages: (control) => {
                                'required': context.lang('validators.required'),
                                'mustMatch':
                                    context.lang('validators.password_match'),
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
                                hintText: context
                                    .lang('registration.hint.password_repeat'),
                                hintStyle: const TextStyle(color: Colors.black),
                              ),
                              style: TextStyle(
                                color: context
                                    .read<AppThemeCubit>()
                                    .theme
                                    .colors["inputTextColor"],
                              ),
                              formControlName: 'passwordRepeat',
                              obscureText: _obscureText,
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            MaterialButton(
                                color: const Color(0xff2A9D8F),
                                minWidth: 360,
                                height: 50,
                                onPressed: () async {
                                  if (!form.hasErrors) {
                                    var auth = getIt.get<AuthService>();
                                    try {
                                      await auth.registerWithEmailAndPassword(
                                          form.control('email').value,
                                          form.control('password').value,
                                          form.control('passwordRepeat').value);
                                      var canPop = await context.router.pop();
                                      if (!canPop) {
                                        context.router.replaceNamed('/');
                                      }
                                    } on RegisterException catch (e) {
                                      if (e.code == 'passwords-differ') {
                                        setState(() {
                                          someErrorMessage = context.lang(
                                              'registration.error.passwords_differ');
                                        });
                                      } else if (e.code == 'weak-password') {
                                        setState(() {
                                          someErrorMessage = context.lang(
                                              'registration.error.weak_password');
                                        });
                                      } else if (e.code ==
                                          'email-already-in-use') {
                                        setState(() {
                                          someErrorMessage = context.lang(
                                              'registration.error.email_in_use');
                                        });
                                      }
                                    } catch (e) {
                                      context.error('Login failed $e');
                                    }
                                  } else {
                                    setState(() {
                                      someErrorMessage = context
                                          .lang('forms.formValidationFailed');
                                    });
                                  }
                                },
                                child: Text(
                                    context.lang('registration.create_account'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ))),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                    context.lang(
                                        'registration.already_have_account'),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                    )),
                                // Go back to login page if user doesn't want/need to register
                                TextButton(
                                  child: Text(
                                      context.lang('registration.sign_in'),
                                      style: const TextStyle(
                                          color: Color(0xffFCBF49))),
                                  onPressed: () {
                                    context.router.popUntilRoot();
                                    context.router.replaceNamed('/login');
                                  },
                                )
                              ],
                            ),
                            someErrorMessage == null
                                ? const Text('')
                                : Text('$someErrorMessage',
                                    style:
                                        const TextStyle(color: Colors.white)),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
