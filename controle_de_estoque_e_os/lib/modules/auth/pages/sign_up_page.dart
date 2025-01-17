import 'package:controle_de_estoque_e_os/modules/auth/auth_controller.dart';
import 'package:controle_de_estoque_e_os/modules/establishiment/establishiment_store.dart';
import 'package:controle_de_estoque_e_os/shared/models/establishiment_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_text_field/flutter_text_field.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends ModularState<SignUpPage, EstablishimentStore> {
  final displayNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final pageController = PageController();
  final firstFormKey = GlobalKey<FormState>();
  final secondFormKey = GlobalKey<FormState>();
  final createButtonFocus = FocusNode();
  final nextButtonFocus = FocusNode();
  final confirmPasswordFocus = FocusNode();
  final errorNotifier = ValueNotifier<String?>(null);

  Future<void> signUp() async {
    errorNotifier.value = null;
    try {
      if (secondFormKey.currentState?.validate() == true) {
        final authController = Modular.get<AuthController>();
        await authController.signOut();
        final credentials = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        if (credentials.user != null) {
          final result = await store.create(
            estalishiment: EstalishimentModel(
              displayName: displayNameController.text,
            ),
          );
          if (result) {
            Modular.to.pop(true);
          } else {
            await credentials.user?.delete();
          }
        }
      }
    } on FirebaseAuthException catch (error) {
      switch (error.code) {
        case 'email-already-in-use':
          errorNotifier.value = 'Email já utilizado.';
          break;
        case 'weak-password':
          errorNotifier.value = 'Senha muito fraca.';
          break;
        case 'operation-not-allowed':
          errorNotifier.value = 'Operação não permitida.';
          break;
        case 'invalid-email':
          errorNotifier.value = 'Email inválido.';
          break;
      }
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        scrollBehavior: CupertinoScrollBehavior(),
        slivers: [
          SliverAppBar(
            expandedHeight: 150,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Criar Conta'),
            ),
            stretch: true,
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).size.height - 150,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: PageView(
                        controller: pageController,
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Olá!',
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Para criar uma conta, informe o nome fantasia de sua empresa.',
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Form(
                                  key: firstFormKey,
                                  child: FlutterTextField(
                                    controller: displayNameController,
                                    labelText: 'Nome Fantasia',
                                    nextFocus: nextButtonFocus,
                                    validator: (displayName) => displayName?.isEmpty == true ? 'Informe o nome fantasia' : null,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton(
                                      focusNode: nextButtonFocus,
                                      onPressed: () {
                                        if (firstFormKey.currentState?.validate() == true) {
                                          pageController.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.ease);
                                        }
                                      },
                                      child: Text('Próximo'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Agora, crie o seu usuário.',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Form(
                                key: secondFormKey,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: FlutterTextField.email(
                                        controller: emailController,
                                        labelText: 'Email',
                                        required: true,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: FlutterTextField.senha(
                                        controller: passwordController,
                                        labelText: 'Senha',
                                        nextFocus: confirmPasswordFocus,
                                        required: true,
                                        validator: (password) => (password?.length ?? 0) >= 6 == true ? null : 'A senha deve ter pelo menos 6 caracteres',
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: FlutterTextField.senha(
                                        controller: confirmPasswordController,
                                        focusNode: confirmPasswordFocus,
                                        nextFocus: createButtonFocus,
                                        labelText: 'Confirme sua Senha',
                                        required: true,
                                        validator: (password) {
                                          if (password != passwordController.text) {
                                            return 'As senhas não conferem';
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ValueListenableBuilder<String?>(
                                valueListenable: errorNotifier,
                                builder: (context, error, child) {
                                  if (error != null) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(
                                        child: Text(
                                          error,
                                          style: TextStyle(color: Theme.of(context).errorColor),
                                        ),
                                      ),
                                    );
                                  }
                                  return Container();
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    OutlinedButton(
                                      onPressed: () {
                                        pageController.previousPage(duration: const Duration(milliseconds: 350), curve: Curves.ease);
                                      },
                                      child: Text('Voltar'),
                                    ),
                                    OutlinedButton(
                                      focusNode: createButtonFocus,
                                      onPressed: signUp,
                                      child: Text('Criar Conta'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Divider(),
                    Center(
                      child: Text.rich(
                        TextSpan(
                          text: 'Já tem uma conta? ',
                          children: [
                            TextSpan(
                              text: 'Faça login',
                              style: TextStyle(
                                color: Theme.of(context).textTheme.button?.color,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  final login = await Modular.to.pushNamed('/login/');
                                  if (login == true) {
                                    Modular.to.pop(true);
                                  }
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
