import 'dart:io';
import 'package:awesome_poll_app/utils/commons.dart';
import 'package:awesome_poll_app/services/auth/auth.service.dart';
import 'package:awesome_poll_app/services/lang/language.service.dart';
import 'package:awesome_poll_app/components/widgets/delete-user-dialog.widget.dart';

class SettingsComponent extends StatefulWidget {
  const SettingsComponent({Key? key}) : super(key: key);

  @override
  State<SettingsComponent> createState() => _SettingsComponentState();
}

class _SettingsComponentState extends State<SettingsComponent> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(
            context.lang('app.nav.settings'),
            style: Theme.of(context).textTheme.headline5,
          ),
          actions: [
            PopupMenuButton(
              icon: const Icon(Icons.expand_more),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Row(
                    children: [
                      const Icon(Icons.logout),
                      Text(context.lang('settings.menu.logout')),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.panorama),
                title: Text(context.lang('settings.menu.appearance')),
                trailing: BlocBuilder<AppThemeCubit, CustomTheme>(
                  builder: (context, state) =>
                      Text(context.lang('theme.${state.name}')),
                ),
                onTap: () async {
                  var theme = await showDialog<CustomTheme?>(
                    context: context,
                    builder: (context) => SimpleDialog(
                      title: Text(context.lang('settings.menu.appearance')),
                      children: [
                        /* //TODO system settings?
                    SimpleDialogOption(
                      child: Text(context.lang('theme.system')),
                      onPressed: () => Navigator.pop(context, e),
                    ),
                     */
                        ...Themes.listThemes()
                            .map((e) => SimpleDialogOption(
                                  child: Text(context.lang('theme.${e.name}')),
                                  onPressed: () => Navigator.pop(context, e),
                                ))
                            .toList(),
                      ],
                    ),
                  );
                  if (theme != null) {
                    context.read<AppThemeCubit>().theme = theme;
                  }
                },
              ),
              // ListTile(
              //   leading: const Icon(Icons.language),
              //   title: Text(context.lang('settings.menu.notification')),
              // ),
              //ListTile(
              //  leading: const Icon(Icons.lock),
              //  title: Text(context.lang('settings.menu.privacy')),
              //),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(context.lang('settings.menu.language')),
                trailing: Text(context
                    .stringifyLocale(context.watch<LocalizationCubit>().state)),
                onTap: () async {
                  var lang = await showDialog<Locale?>(
                    context: context,
                    builder: (context) => SimpleDialog(
                      title: Text(context.lang('settings.menu.language')),
                      children: [
                        //TODO system
                        if (_supportsSystemLocale(context) != null)
                          SimpleDialogOption(
                            child: Text(context.lang('language.system')),
                            onPressed: () => Navigator.pop(
                                context, _supportsSystemLocale(context)),
                          ),
                        ...context
                            .read<LocalizationCubit>()
                            .listLocales()
                            .map((e) => SimpleDialogOption(
                                  child: Text(context.stringifyLocale(e)),
                                  onPressed: () => Navigator.pop(context, e),
                                ))
                            .toList()
                      ],
                    ),
                  );
                  if (lang != null) {
                    context.read<LocalizationCubit>().changeLocale(lang);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.password),
                title: Text(context.lang('settings.menu.changePassword')),
                onTap: () async {
                  context.router.navigate(const ChangePasswordRoute());
                },
              ),
              ListTile(
                  leading: const Icon(Icons.person_remove),
                  title: Text(context.lang('settings.menu.deleteAccount')),
                  onTap: () async {
                    showDialog<String>(
                        context: context,
                        builder: (BuildContext context) =>
                            const DeleteUserDialog());
                  }),
              const Divider(),
              //Help
              Theme(
                data: context.customTheme.mode==AppThemeMode.dark ? context.theme :
                Theme.of(context).copyWith(textTheme: const TextTheme(
                  bodyText2: TextStyle(color: Colors.black),
                  subtitle1: TextStyle(color: Colors.black),
                  headline5: TextStyle(color: Colors.black),
                  )),
                child: 
                  Builder(
                    builder: (BuildContext context) {
                      return ListTile(
                        leading: const Icon(Icons.contact_support),
                        title: Text(context.lang('settings.menu.about')),
                        onTap: () => showAboutDialog(
                          context: context,
                          applicationName: 'Apollo',
                          applicationIcon: Image.asset('assets/images/Logo.png',
                              width: MediaQuery.of(context).size.height * 0.05),
                          applicationVersion: '1.0',
                          children: [
                            const Text("Made with joy by \n\nSerwar Basch\nLina El Haouli\nHenning Klagemann\nDaniel Thomas \n\nThank you for using Apollo!")
                          ]
                        ),
                      );
                    })
              ),
              ListTile(
                      leading: const Icon(Icons.verified_user),
                      title: Text(context.lang('settings.menu.policy')),
                      onTap: () => showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                              title: Text(
                                context.lang('settings.menu.policy'),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                    color: Colors.black),
                              ),
                              content: SingleChildScrollView(
                                child: privacyPolicyText(),
                              ))),
                  ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: Text(context.lang('settings.menu.logout')),
                onTap: () {
                  getIt.get<AuthService>().logout();
                },
              ),
            ],
          ),
        ),
      );

  /// looks platform language and returns locale if supported
  Locale? _supportsSystemLocale(BuildContext context) {
    try {
      var localLocale = Locale(Platform.localeName);
      var target = BlocProvider.of<LocalizationCubit>(context)
          .listLocales()
          .firstWhere((element) =>
              element.toLanguageTag() == localLocale.toLanguageTag());
      return target;
    } catch (e) {
      //debugPrint('$e');
    }
    return null;
  }

  RichText privacyPolicyText() => RichText(
        overflow: TextOverflow.clip,
        text: const TextSpan(
          children: <TextSpan>[
            TextSpan(
                style: TextStyle(color: Colors.black),
                text:
                    'Verantwortlicher im Sinne der Datenschutzgesetze, insbesondere der EU-Datenschutzgrundverordnung (DSGVO), ist:\nIPTK GROUP G\n\nIhre Betroffenenrechte\nUnter den angegebenen Kontaktdaten unseres Datenschutzbeauftragten k??nnen Sie jederzeit folgende Rechte aus??ben:\nAuskunft ??ber Ihre bei uns gespeicherten Daten und deren Verarbeitung (Art. 15 DSGVO),\nBerichtigung unrichtiger personenbezogener Daten (Art. 16 DSGVO),\nL??schung Ihrer bei uns gespeicherten Daten (Art. 17 DSGVO),\nEinschr??nkung der Datenverarbeitung, sofern wir Ihre Daten aufgrund gesetzlicher Pflichten noch nicht l??schen d??rfen (Art. 18 DSGVO),\nWiderspruch gegen die Verarbeitung Ihrer Daten bei uns (Art. 21 DSGVO) und Daten??bertragbarkeit, sofern Sie in die Datenverarbeitung eingewilligt haben oder einen Vertrag mit uns abgeschlossen haben (Art. 20 DSGVO).\nSofern Sie uns eine Einwilligung erteilt haben, k??nnen Sie diese jederzeit mit Wirkung f??r die Zukunft widerrufen.\n\nSie k??nnen sich jederzeit mit einer Beschwerde an eine Aufsichtsbeh??rde wenden, z. B. an die zust??ndige Aufsichtsbeh??rde des Bundeslands Ihres Wohnsitzes oder an die f??r uns als verantwortliche Stelle zust??ndige Beh??rde.\n\nEine Liste der Aufsichtsbeh??rden (f??r den nicht??ffentlichen Bereich) mit Anschrift finden Sie unter: https://www.bfdi.bund.de/DE/Service/Anschriften/Laender/Laender-node.html.\n\nErfassung allgemeiner Informationen beim Besuch unserer Website\nArt und Zweck der Verarbeitung:\nWenn Sie auf unsere Website zugreifen, d.h., wenn Sie sich nicht registrieren oder anderweitig Informationen ??bermitteln, werden automatisch Informationen allgemeiner Natur erfasst. Diese Informationen (Server-Logfiles) beinhalten etwa die Art des Webbrowsers, das verwendete Betriebssystem, den Domainnamen Ihres Internet-Service-Providers, Ihre IP-Adresse und ??hnliches.\n\nSie werden insbesondere zu folgenden Zwecken verarbeitet:\nSicherstellung eines problemlosen Verbindungsaufbaus der Website,\nSicherstellung einer reibungslosen Nutzung unserer Website,\nAuswertung der Systemsicherheit und -stabilit??t sowie zur Optimierung unserer Website.\nWir verwenden Ihre Daten nicht, um R??ckschl??sse auf Ihre Person zu ziehen. Informationen dieser Art werden von uns ggfs. anonymisiert statistisch ausgewertet, um unseren Internetauftritt und die dahinterstehende Technik zu optimieren.\n\nRechtsgrundlage und berechtigtes Interesse:\nDie Verarbeitung erfolgt gem???? Art. 6 Abs. 1 lit. f DSGVO auf Basis unseres berechtigten Interesses an der Verbesserung der Stabilit??t und Funktionalit??t unserer Website.\n\nEmpf??nger:\nEmpf??nger der Daten sind ggf. technische Dienstleister, die f??r den Betrieb und die Wartung unserer Webseite als Auftragsverarbeiter t??tig werden.\n\nSpeicherdauer:\nDie Daten werden gel??scht, sobald diese f??r den Zweck der Erhebung nicht mehr erforderlich sind. Dies ist f??r die Daten, die der Bereitstellung der Website dienen, grunds??tzlich der Fall, wenn die jeweilige Sitzung beendet ist.\n\nIm Falle der Speicherung der Daten in Logfiles ist dies nach sp??testens 14 Tagen der Fall. Eine dar??berhinausgehende Speicherung ist m??glich. In diesem Fall werden die IP-Adressen der Nutzer anonymisiert, sodass eine Zuordnung des aufrufenden Clients nicht mehr m??glich ist.\n\nBereitstellung vorgeschrieben oder erforderlich:\nDie Bereitstellung der vorgenannten personenbezogenen Daten ist weder gesetzlich noch vertraglich vorgeschrieben. Ohne die IP-Adresse ist jedoch der Dienst und die Funktionsf??higkeit unserer Website nicht gew??hrleistet. Zudem k??nnen einzelne Dienste und Services nicht verf??gbar oder eingeschr??nkt sein. Aus diesem Grund ist ein Widerspruch ausgeschlossen.\n\nRegistrierung auf unserer Website\nArt und Zweck der Verarbeitung:\nF??r die Registrierung auf unserer Website ben??tigen wir einige personenbezogene Daten, die ??ber eine Eingabemaske an uns ??bermittelt werden.\n\nZum Zeitpunkt der Registrierung werden zus??tzlich folgende Daten erhoben:\n\nIhre Registrierung ist f??r das Bereithalten bestimmter Inhalte und Leistungen auf unserer Website erforderlich.\n\nRechtsgrundlage:\nDie Verarbeitung der bei der Registrierung eingegebenen Daten erfolgt auf Grundlage einer Einwilligung des Nutzers (Art. 6 Abs. 1 lit. a DSGVO).\n\nEmpf??nger:\nEmpf??nger der Daten sind ggf. technische Dienstleister, die f??r den Betrieb und die Wartung unserer Website als Auftragsverarbeiter t??tig werden.\n\nSpeicherdauer:\nDaten werden in diesem Zusammenhang nur verarbeitet, solange die entsprechende Einwilligung vorliegt.\n\nBereitstellung vorgeschrieben oder erforderlich:\nDie Bereitstellung Ihrer personenbezogenen Daten erfolgt freiwillig, allein auf Basis Ihrer Einwilligung. Ohne die Bereitstellung Ihrer personenbezogenen Daten k??nnen wir Ihnen keinen Zugang auf unsere angebotenen Inhalte gew??hren.\n\nVerwendung von Google Maps\nAuf dieser Website nutzen wir das Angebot von Google Maps. Google Maps wird von Google LLC, 1600 Amphitheatre Parkway, Mountain View, CA 94043, USA (nachfolgend ???Google???) betrieben. Dadurch k??nnen wir Ihnen interaktive Karten direkt in der Webseite anzeigen und erm??glichen Ihnen die komfortable Nutzung der Karten-Funktion.\nN??here Informationen ??ber die Datenverarbeitung durch Google k??nnen Sie den Google-Datenschutzhinweisen entnehmen: https://policies.google.com/privacy. Dort k??nnen Sie im Datenschutzcenter auch Ihre pers??nlichen Datenschutz-Einstellungen ver??ndern.\nAusf??hrliche Anleitungen zur Verwaltung der eigenen Daten im Zusammenhang mit Google-Produkten finden Sie hier: https://www.dataliberation.org\nDurch den Besuch der Website erh??lt Google Informationen, dass Sie die entsprechende Unterseite unserer Webseite aufgerufen haben. Dies erfolgt unabh??ngig davon, ob Google ein Nutzerkonto bereitstellt, ??ber das Sie eingeloggt sind, oder ob keine Nutzerkonto besteht. Wenn Sie bei Google eingeloggt sind, werden Ihre Daten direkt Ihrem Konto zugeordnet.\nWenn Sie die Zuordnung in Ihrem Profil bei Google nicht w??nschen, m??ssen Sie sich vor Aktivierung des Buttons bei Google ausloggen. Google speichert Ihre Daten als Nutzungsprofile und nutzt sie f??r Zwecke der Werbung, Marktforschung und/oder bedarfsgerechter Gestaltung seiner Websites. Eine solche Auswertung erfolgt insbesondere (selbst f??r nicht eingeloggte Nutzer) zur Erbringung bedarfsgerechter Werbung und um andere Nutzer des sozialen Netzwerks ??ber Ihre Aktivit??ten auf unserer Website zu informieren. Ihnen steht ein Widerspruchsrecht zu gegen die Bildung dieser Nutzerprofile, wobei Sie sich zur Aus??bung dessen an Google richten m??ssen.\n\nWiderruf der Einwilligung:\nVom Anbieter wird derzeit keine M??glichkeit f??r einen einfachen Opt-out oder ein Blockieren der Daten??bertragung angeboten. Wenn Sie eine Nachverfolgung Ihrer Aktivit??ten auf unserer Website verhindern wollen, widerrufen Sie bitte im Cookie-Consent-Tool Ihre Einwilligung f??r die entsprechende Cookie-Kategorie oder alle technisch nicht notwendigen Cookies und Daten??bertragungen. In diesem Fall k??nnen Sie unsere Website jedoch ggfs. nicht oder nur eingeschr??nkt nutzen.\n\nSSL-Verschl??sselung\nUm die Sicherheit Ihrer Daten bei der ??bertragung zu sch??tzen, verwenden wir dem aktuellen Stand der Technik entsprechende Verschl??sselungsverfahren (z. B. SSL) ??ber HTTPS.\n\nInformation ??ber Ihr Widerspruchsrecht nach Art. 21 DSGVO\nEinzelfallbezogenes Widerspruchsrecht\nSie haben das Recht, aus Gr??nden, die sich aus Ihrer besonderen Situation ergeben, jederzeit gegen die Verarbeitung Sie betreffender personenbezogener Daten, die aufgrund Art. 6 Abs. 1 lit. f DSGVO (Datenverarbeitung auf der Grundlage einer Interessenabw??gung) erfolgt, Widerspruch einzulegen, dies gilt auch f??r ein auf diese Bestimmung gest??tztes Profiling im Sinne von Art. 4 Nr. 4 DSGVO.\n\nLegen Sie Widerspruch ein, werden wir Ihre personenbezogenen Daten nicht mehr verarbeiten, es sei denn, wir k??nnen zwingende schutzw??rdige Gr??nde f??r die Verarbeitung nachweisen, die Ihre Interessen, Rechte und Freiheiten ??berwiegen, oder die Verarbeitung dient der Geltendmachung, Aus??bung oder Verteidigung von Rechtsanspr??chen.\n\nEmpf??nger eines Widerspruchs\nIPTK Group G\n\n??nderung unserer Datenschutzbestimmungen\nWir behalten uns vor, diese Datenschutzerkl??rung anzupassen, damit sie stets den aktuellen rechtlichen Anforderungen entspricht oder um ??nderungen unserer Leistungen in der Datenschutzerkl??rung umzusetzen, z.B. bei der Einf??hrung neuer Services. F??r Ihren erneuten Besuch gilt dann die neue Datenschutzerkl??rung.'),
          ],
        ),
      );
}
