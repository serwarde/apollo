import 'package:awesome_poll_app/utils/commons.dart';
import 'package:awesome_poll_app/services/poll_state/poll_view.dart';
import 'package:awesome_poll_app/components/widgets/animations/fancy_loading.widget.dart';


//initializes poll view
class PollViewWidget extends StatelessWidget {
  late final ViewState viewState;
  final PollFormEvent initial;
  late final PollFormBloc _formBloc;
  late final ViewStateCubit _viewState;

  PollViewWidget({Key? key, required this.initial, ViewState? initialViewState}) : super(key: key) {
    viewState = initial.maybeWhen<ViewState>(
      createPoll: () => const ViewState.create(),
      loadPoll: (pollId) => initialViewState!,
      orElse: () => throw Exception('initial poll state not supported: $initial'),
    );
    _viewState = ViewStateCubit(initial: viewState);
    _formBloc = PollFormBloc(initial: initial, viewState: _viewState);
  }

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) => _formBloc,
      ),
      BlocProvider(
        create: (context) => _viewState,
      ),
    ],
    child: BlocConsumer<PollFormBloc, PollFormState>(
      builder: (context, state) =>
          state.maybeWhen(
            loading: () => const Scaffold(
              body:  Center(
                child: DefaultFancyLoadingWidget(),
              ),
            ),
            orElse: () => ReactiveForm(
              formGroup: context.read<PollFormBloc>().rootForm,
              child: const PollViewLayoutWidget(),
            ),
          ),
      listener: (context, state) {
        state.whenOrNull<dynamic>(
          submitted: () => context.router.navigateBack(),
        );
      },
    ),
  );

}
