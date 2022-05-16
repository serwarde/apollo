import 'package:awesome_poll_app/utils/commons.dart';

class NavigationRouteItem {
  String name;
  Icon icon;
  PageRouteInfo<dynamic> route;

  NavigationRouteItem(this.name, this.icon, this.route);
}

class NavigationComponent extends StatelessWidget {
  const NavigationComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<NavigationRouteItem> bottomNavigationItems = [
      NavigationRouteItem(context.lang('app.nav.my_poll'), const Icon(Icons.assessment_outlined), const MyPollRoute()),
      NavigationRouteItem(context.lang('app.nav.participate'), const Icon(Icons.location_on_outlined), const ParticipatePollRoute()),
      NavigationRouteItem(context.lang('app.nav.settings'), const Icon(Icons.settings), const SettingsRoute()),
    ];
    List<BottomNavigationBarItem> items = bottomNavigationItems
        .map((e) => BottomNavigationBarItem(label: e.name, icon: e.icon))
        .toList();
    return AutoTabsScaffold(
      routes: bottomNavigationItems.map((e) => e.route).toList(),
      bottomNavigationBuilder: (navContext, tabsRouter) {
        return BottomNavigationBar(
            backgroundColor: const Color(0xff1D3557),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            currentIndex: tabsRouter.activeIndex,
            onTap: (index) {
              if(items[index].label==context.lang('app.nav.participate')) {
                // Update nearby polls list, when clicking on the icon of the participate component.
                getIt.get<API>().fetchListPollsNearby();
              }
              tabsRouter.setActiveIndex(index);
            },
            items: items);
      },
    );
  }
}
