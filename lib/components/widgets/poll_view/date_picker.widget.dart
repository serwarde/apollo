import 'dart:async';
import 'package:awesome_poll_app/utils/commons.dart';

//shows interactive date and time pickers
//the underlying value is bound to the timestamp form control
//timestamp itself uses ms
class PollViewDateWidget extends StatefulWidget {
  final Widget? prefix;
  final DateTime? minStartTime;
  final DateTime? maxEndTime;
  final FormControl<int> timestampControl;
  PollViewDateWidget({Key? key, this.prefix, int? initialTimestamp, this.minStartTime, this.maxEndTime, required this.timestampControl})
      : super(key: key) {
    if(initialTimestamp != null) timestampControl.value = initialTimestamp;
  }
  @override
  State<StatefulWidget> createState() => _PollViewDateWidget();
}

class _PollViewDateWidget extends State<PollViewDateWidget> {
  final FormControl<DateTime> datePickControl = FormControl(value: DateTime.now());
  final FormControl<TimeOfDay> timePickControl = FormControl();
  late FormGroup dateGroup;
  StreamSubscription? _valueChanges;
  //when the ts is update externally
  StreamSubscription? _externalValueChanges;
  _PollViewDateWidget() {
    dateGroup = FormGroup({
      'date': datePickControl,
      'time': timePickControl,
    });
  }

  @override
  void initState() {
    super.initState();
    _valueChanges = dateGroup.valueChanges.listen((event) {
      assert(datePickControl.value != null, 'internal date value is null');
      var date = datePickControl.value!.millisecondsSinceEpoch;
      assert(timePickControl.value != null, 'internal time value is null');
      var time = timePickControl.value!.millisecondsSinceEpoch;
      context.debug('date: $date, time: $time');
      widget.timestampControl.value = date + time;
    });
    _externalValueChanges = widget.timestampControl.valueChanges.listen((event) {
      context.debug('external update');
      _updateInternalControls();
    });
    // setup values initially
    _updateInternalControls();
  }

  @override
  Widget build(BuildContext context) => ReactiveForm(
    formGroup: dateGroup,
    child: ExcludeFocus(
      child: Row(
        children: [
          if(widget.prefix != null)
            widget.prefix!,
          Flexible(
            child: ReactiveTextField(
              autofocus: false,
              readOnly: true,
              formControlName: 'date',
              decoration: InputDecoration(
                prefixIcon: ReactiveDatePicker(
                  formControlName: 'date',
                  firstDate: widget.minStartTime ?? DateTime.fromMillisecondsSinceEpoch(widget.timestampControl.value!),
                  lastDate: widget.maxEndTime ?? DateTime
                      .fromMillisecondsSinceEpoch(widget.timestampControl.value!).add(const Duration(days: 365)),
                  builder: (context, picker, child) => IconButton(
                    onPressed: picker.showPicker,
                    icon: const Icon(Icons.date_range),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Flexible(
            child: ReactiveTextField(
              autofocus: false,
              readOnly: true,
              formControlName: 'time',
              decoration: InputDecoration(
                prefixIcon: ReactiveTimePicker(
                  formControlName: 'time',
                  builder: (BuildContext context,
                    ReactiveTimePickerDelegate picker, Widget? child) => IconButton(
                    onPressed: picker.showPicker,
                    icon: const Icon(Icons.schedule),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  void _updateInternalControls() {
    assert(widget.timestampControl.value != null, 'external timestamp control is null');
    var ts = DateTime.fromMillisecondsSinceEpoch(widget.timestampControl.value!);
    timePickControl.value = TimeOfDay.fromDateTime(ts);
    datePickControl.value = ts.clampTime();
  }

  @override
  void dispose() async{
    super.dispose();
    await _externalValueChanges?.cancel();
    await _valueChanges?.cancel();
  }
}
