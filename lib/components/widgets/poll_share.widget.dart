import 'package:awesome_poll_app/utils/commons.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
//import 'package:share_plus/share_plus.dart';

class PollShareWidget extends StatelessWidget {
  final String url;
  final String? title;
  const PollShareWidget({Key? key, this.title, required this.url}) : super(key: key);
  @override
  Widget build(BuildContext context) => Center(
    child: Dialog(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width / 2,
          height: MediaQuery.of(context).size.height / 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title ?? context.lang('poll.share'),
                style: Theme.of(context).textTheme.headline4,
              ),
              Expanded(
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) => Container(
                      constraints: constraints,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _qrCode(
                          context: context,
                          tabbed: () async {
                            await Clipboard.setData(ClipboardData(text: url));
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(context.lang('poll.share.url_copied')),//'url Copied to Clipboard!'
                            ));
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {

                    },
                      //TODO re enable
                      //onPressed: () => Share.share('check out that poll: $url'),
                      icon: const Icon(Icons.share),
                      label: Text(context.lang('poll.share'))
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(),
                      label: Text(context.lang('poll.share.close'))
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _qrCode({required BuildContext context, Function? tabbed}) => GestureDetector(
    onTap: () => tabbed != null ? tabbed() : () {},
    child: QrImage(
      data: url,
    ),
  );

  static Future<void> show({
    required BuildContext context,
    required String url,
  }) async => await showDialog(
      context: context,
      builder: (context) => PollShareWidget(
          url: url,
      ),
  );

}