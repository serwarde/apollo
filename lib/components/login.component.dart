import 'package:awesome_poll_app/utils/commons.dart';
import 'package:awesome_poll_app/services/auth/auth.service.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginComponent extends StatefulWidget {
  const LoginComponent({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginComponent();
}

class _LoginComponent extends State<LoginComponent> {
  String? someErrorMessage;
  bool _obscureText = true;
  FormGroup form = fb.group({
    'email': FormControl<String>(
      value: '',
      validators: [Validators.required, Validators.email],
    ),
    'password': FormControl<String>(
      value: '',
      validators: [Validators.required],
    )
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.read<AppThemeCubit>().theme.colors['darkBlue'],
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 400,
            ),
            child: Container(
              height: MediaQuery.of(context).size.height - 30,
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 5),
                      Image.asset('assets/images/Logo.png',
                          width: MediaQuery.of(context).size.height * 0.2),
                      Text(context.lang('app.name'),
                          style: GoogleFonts.ribeyeMarrow(
                              textStyle: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 42,
                          ))),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 10,
                      ),
                      ReactiveForm(
                        formGroup: form,
                        child: Column(
                          children: <Widget>[
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
                                hintText: context.lang('login.hint.username'),
                              ),
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
                            ReactiveTextField(
                              validationMessages: (control) => {
                                'required': context.lang('validators.required'),
                              },
                              decoration: InputDecoration(
                                  errorStyle: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  hintText: context.lang('login.hint.password'),
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
                                      })),
                              style: TextStyle(
                                  color: context
                                      .read<AppThemeCubit>()
                                      .theme
                                      .colors["inputTextColor"]),
                              formControlName: 'password',
                              obscureText: _obscureText,
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            // Login button
                            MaterialButton(
                              color: Theme.of(context).colorScheme.secondary,
                              minWidth: 360,
                              height: 50,
                              onPressed: () async {
                                context.debug(
                                    'submitted login values: ${form.value}');
                                if (!form.hasErrors) {
                                  var auth = getIt.get<AuthService>();
                                  try {
                                    await auth.loginWithEmailAndPassword(
                                        form.control('email').value,
                                        form.control('password').value);
                                    var canPop = await context.router.pop();
                                    if (!canPop) {
                                      context.router.replaceNamed('/');
                                    }
                                  } on LoginException catch (e) {
                                    if (e.code == 'user-not-found') {
                                      setState(() {
                                        someErrorMessage = context
                                            .lang('login.error.user_not_found');
                                      });
                                    } else if (e.code == 'wrong-password') {
                                      setState(() {
                                        someErrorMessage = context
                                            .lang('login.error.wrong_password');
                                      });
                                    }
                                  } catch (e) {
                                    context.debug('Login failed $e');
                                  }
                                } else {
                                  setState(() {
                                    someErrorMessage = context
                                        .lang('forms.formValidationFailed');
                                  });
                                }
                              },
                              child: Text(
                                context.lang('login.log_in'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            someErrorMessage == null
                                ? const Text('')
                                : Text('$someErrorMessage'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Button to go to registration page
                  MaterialButton(
                    color: const Color(0xffFCBF49),
                    minWidth: 360,
                    height: 50,
                    onPressed: () {
                      context.router.push(const RegistrationRoute());
                    },
                    child: Text(
                      context.lang('login.create_account'),
                      style: const TextStyle(
                        color: Color(0xff000000),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
