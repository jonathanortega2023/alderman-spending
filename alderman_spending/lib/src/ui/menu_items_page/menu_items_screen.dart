import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:alderman_spending/src/data/models/menu_item_info.dart';
import 'package:alderman_spending/src/data/loaders.dart';
import 'package:intl/intl.dart';
import 'package:alderman_spending/src/ui/navigation/navigation_drawer.dart';
import 'package:card_banner/card_banner.dart';
import 'package:banner_listtile/banner_listtile.dart';

const baseImagePath = 'assets/images/menu_items';

class MenuItemsScreen extends StatelessWidget {
  static const _menuItemsHeading =
      "Each year, CDOT and OBM provide alderpersons a list of standard menu items. Costs are estimated based on previous years' costs. Alderpersons select items from this list to allocate their \$1.5 million budget.";

  const MenuItemsScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MenuItemInfo>>(
      future: loadMenuItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading data'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data available'));
        }

        final menuItems = snapshot.data!;

        return Scaffold(
          drawer: const MyNavigationDrawer(),
          appBar: AppBar(
            title: const Text('Aldermanic Menu Items'),
          ),
          body: CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Column(
                        children: [
                          const SizedBox(height: 30),
                          Text(
                            _menuItemsHeading,
                            style: Theme.of(context).textTheme.headlineMedium,
                            softWrap: true,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Tap items to learn more.",
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            softWrap: true,
                          ),
                          const SizedBox(height: 25),
                          if (MediaQuery.of(context).size.aspectRatio < 1.3)
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: menuItems.length,
                              itemBuilder: (context, index) {
                                return MenuListItem(
                                    menuItemInfo: menuItems[index]);
                              },
                            )
                          else
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: menuItems.length,
                              primary: false,
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 600,
                                childAspectRatio: 5.25,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20,
                              ),
                              itemBuilder: (context, index) {
                                return MenuGridItem(
                                    menuItemInfo: menuItems[index]);
                              },
                            )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class MenuListItem extends StatelessWidget {
  final MenuItemInfo menuItemInfo;

  const MenuListItem({super.key, required this.menuItemInfo});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      hoverColor: Colors.grey[300],
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MenuItemDetailPortraitCard(
              menuItemInfo: menuItemInfo,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.fromLTRB(5, 8, 5, 8),
        elevation: 5,
        child: BannerListTile(
          showBanner: menuItemInfo.visionZero,
          bannerColor: Colors.blue..withOpacity(0.25),
          bannerText: "Vision Zero",
          bannerIconRotation: 1,
          bannerIcon: Image.asset("assets/images/vision_zero_icon.png"),
          bannerPosition: BannerPosition.topRight,
          bannerSize: 50,
          backgroundColor: Colors.white,
          imageContainerShapeZigzagIndex: 1,
          imageContainer: Image.asset(
            '$baseImagePath/${menuItemInfo.imgFilename}',
            fit: BoxFit.cover,
            scale: 2,
          ),
          title: Text(
            menuItemInfo.title,
            style: const TextStyle(fontSize: 20),
          ),
          subtitle: Text(
            _parseCostMeasurement(menuItemInfo),
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}

// TODO make look good on landscape
class MenuGridItem extends StatelessWidget {
  final MenuItemInfo menuItemInfo;

  const MenuGridItem({Key? key, required this.menuItemInfo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // InkWell stopped working on switching to BannerListTile
    return InkWell(
      hoverColor: Colors.grey[300],
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MenuItemDetailLandscapeCard(
              menuItemInfo: menuItemInfo,
            ),
          ),
        );
      },
      child: BannerListTile(
        showBanner: menuItemInfo.visionZero,
        elevation: 5,
        bannerColor: Colors.blue..withOpacity(0.25),
        bannerText: "Vision Zero",
        bannerIconRotation: 1,
        bannerIcon: Image.asset("assets/images/vision_zero_icon.png"),
        bannerPosition: BannerPosition.topRight,
        bannerSize: 50,
        backgroundColor: Colors.white,
        imageContainerShapeZigzagIndex: 0,
        imageContainer: Image.asset(
          '$baseImagePath/${menuItemInfo.imgFilename}',
          fit: BoxFit.fill,
        ),
        title: Text(
          menuItemInfo.title,
          style: const TextStyle(fontSize: 20),
        ),
        subtitle: Text(
          _parseCostMeasurement(menuItemInfo),
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

class MenuItemDetailPortraitCard extends StatelessWidget {
  final MenuItemInfo menuItemInfo;
  static final _boxShadowSettingsGFCard = BoxShadow(
    color: Colors.grey[500]!,
    spreadRadius: 5,
    blurRadius: 7,
    offset: const Offset(0, 3),
  );

  const MenuItemDetailPortraitCard({super.key, required this.menuItemInfo});
  // TODO change to hero, don't route to new page
  // TODO make landscape version
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 40,
        ),
        body: GFCard(
          color: Colors.grey[200]!,
          elevation: 15,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          image: Image.asset(
            '$baseImagePath/${menuItemInfo.imgFilename}',
            fit: BoxFit.cover,
          ),
          showImage: true,
          title: GFListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Text(
                    menuItemInfo.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (menuItemInfo.visionZero)
                  Image.asset(
                    "assets/images/vision_zero_logo.png",
                    height: 50,
                  ),
              ],
            ),
            subTitle: Text(
              _parseCostMeasurement(menuItemInfo),
              style: const TextStyle(fontSize: 16),
            ),
            shadow: _boxShadowSettingsGFCard,
          ),
          content: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            foregroundDecoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey[400]!,
                width: 2,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(5)),
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height / 3.25,
              child: CustomScrollView(
                shrinkWrap: true,
                scrollBehavior: const ScrollBehavior(),
                scrollDirection: Axis.vertical,
                slivers: [
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Text(
                          menuItemInfo.description,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        _parseNotes(menuItemInfo),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

class MenuItemDetailLandscapeCard extends StatelessWidget {
  final MenuItemInfo menuItemInfo;
  static final _boxShadowSettingsGFCard = BoxShadow(
    color: Colors.grey[500]!,
    spreadRadius: 5,
    blurRadius: 7,
    offset: const Offset(0, 3),
  );

  const MenuItemDetailLandscapeCard({super.key, required this.menuItemInfo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
      ),
      body: Card(
        elevation: 15,
        shadowColor: Colors.grey[500]!,
        margin: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left side - Image, Title, Subtitle
                        Expanded(
              flex: 2,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                                        GFListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * .2,
                            child: Text(
                              menuItemInfo.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (menuItemInfo.visionZero)
                            Image.asset(
                              "assets/images/vision_zero_logo.png",
                              height: 50,
                            ),
                        ],
                      ),
                      subTitle: Text(
                        _parseCostMeasurement(menuItemInfo),
                        style: const TextStyle(fontSize: 16),
                      ),
                      shadow: _boxShadowSettingsGFCard,
                    ),
                    const Divider(),
                    Text(
                      menuItemInfo.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    _parseNotes(menuItemInfo),
                  ],
                ),
              ),
            ),

            const VerticalDivider(),
            // Right side - Scrollable text content
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      '$baseImagePath/${menuItemInfo.imgFilename}',
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height*.65,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 10),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

_parseNotes(MenuItemInfo menuItemInfo, {double fontSize=16}) {
  if (menuItemInfo.notes != null) {
    if (menuItemInfo.notes!.length == 1) {
      return Text(
        'Note: ${menuItemInfo.notes![0]}',
        style: TextStyle(fontSize: fontSize),
      );
    }
    return Column(
      children: menuItemInfo.notes!
          .asMap()
          .entries
          .map((entry) => Text(
                'Note ${entry.key + 1}: ${entry.value}\n',
                style: TextStyle(fontSize: fontSize),
              ))
          .toList(),
    );
  } else {
    return const SizedBox.shrink();
  }
}

_parseCostMeasurement(MenuItemInfo menuItemInfo) {
  return '${NumberFormat.simpleCurrency(decimalDigits: 0).format(menuItemInfo.cost)} per ${menuItemInfo.measurement}';
}
