import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vermicomposting/core/common/widgets/empty_display_widget.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/home_screen_widgets/notification_tile.dart';
import 'package:flutter_vermicomposting/features/notification/data/models/notification_model.dart';
import 'package:flutter_vermicomposting/features/notification/domain/entities/notification.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationWidget extends StatefulWidget {
  const NotificationWidget({super.key});

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {
  late SupabaseClient _supabaseClient;
  late List<NotificationEntity> notificationList;

  static const double _popoverWidthRatio = 0.35;
  final GlobalKey _buttonKey = GlobalKey();
  OverlayEntry? _popoverEntry;

  int currentTab = 0;

  @override
  void initState() {
    super.initState();

    _supabaseClient = GetIt.I<SupabaseClient>();

    _supabaseClient
        .from("notification")
        .stream(primaryKey: ['id'])
        .order('created_at')
        .listen((rawData) {
          setState(() {
            notificationList = rawData
                .map((data) => NotificationModel.fromJsonSupabase(data))
                .toList();
          });
        });
  }

  Future<void> _refreshNotificationList() async {
    final data =
        await _supabaseClient.from("notification").select().order('created_at');

    setState(() {
      notificationList = data
          .map<NotificationEntity>(
              (item) => NotificationModel.fromJsonSupabase(item))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      key: _buttonKey,
      onPressed: () {
        if (_popoverEntry == null) {
          _showPopover(context, _buttonKey);
        } else {
          _removePopover();
        }
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        minimumSize: Size.zero,
        side: BorderSide(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          width: 1,
        ),
      ),
      child: Icon(
        FluentIcons.alert_24_regular,
        size: 20,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildPopover(BuildContext context, double popoverWidth) {
    final double maxPopoverHeight = 468;

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            width: 1,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(32),
          ),
        ),
        width: popoverWidth,
        constraints: BoxConstraints(
          maxHeight: maxPopoverHeight,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildTabSelector(context),
            Expanded(
              child: currentTab == 0
                  ? notificationList.isEmpty
                      ? Center(
                          child: EmptyDisplayWidget(
                            icon: FluentIcons.alert_on_24_regular,
                            title: "No notifications yet",
                            description:
                                "Return here for updates on activities or schedules",
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: notificationList.length,
                          itemBuilder: (context, index) => NotificationTile(
                            notification: notificationList[index],
                            supabaseClient: _supabaseClient,
                            onRefresh: _refreshNotificationList,
                          ),
                        )
                  : notificationList.where((n) => !n.read).toList().isEmpty
                      ? Center(
                          child: EmptyDisplayWidget(
                            icon: FluentIcons.alert_on_24_regular,
                            title: "No unread notifications",
                            description:
                                "Return here for updates on activities or schedules",
                          ),
                        )
                      : Builder(builder: (context) {
                          final unreadNotifications =
                              notificationList.where((n) => !n.read).toList();

                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: unreadNotifications.length,
                            itemBuilder: (context, index) => NotificationTile(
                              notification: unreadNotifications[index],
                              supabaseClient: _supabaseClient,
                              onRefresh: _refreshNotificationList,
                            ),
                          );
                        }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Notifications",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.025,
            ),
          ),
          Row(
            children: [
              Icon(
                Icons.done_all_rounded,
                size: 14,
                color: Colors.lightBlueAccent,
              ),
              const SizedBox(width: 4),
              const Text(
                "Mark all as read",
                style: TextStyle(
                  color: Colors.lightBlueAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector(BuildContext context) {
    final List<Map<String, dynamic>> tabList = [
      {
        'label': "All",
        'count': notificationList.length,
      },
      {
        'label': "Unread",
        'count': notificationList
            .where((notification) => notification.read == false)
            .length,
      }
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: tabList
            .asMap()
            .entries
            .where((entry) => !(notificationList.isEmpty && entry.key == 1))
            .map((entry) {
          final index = entry.key;
          final item = entry.value;

          return InkWell(
            onTap: () {
              setState(() {
                currentTab = index;
              });
              if (_popoverEntry != null) {
                _popoverEntry!.markNeedsBuild();
              }
            },
            child: _buildTab(
              context,
              label: item['label'],
              count: item['count'].toString(),
              isActive: index == currentTab,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTab(
    BuildContext context, {
    required String label,
    required String count,
    required bool isActive,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isActive ? Colors.lightBlueAccent : Colors.transparent,
            width: 2.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isActive
                  ? Colors.lightBlueAccent
                  : Theme.of(context).colorScheme.onSurface.withAlpha(124),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: isActive
                  ? Colors.lightBlueAccent
                  : Theme.of(context).colorScheme.outline,
            ),
            padding: const EdgeInsets.fromLTRB(6, 1, 6, 1),
            child: Text(
              count,
              style: GoogleFonts.spaceMono(
                fontSize: 10,
                color: isActive
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.025,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPopover(BuildContext context, GlobalKey key) {
    final RenderBox buttonBox =
        key.currentContext!.findRenderObject() as RenderBox;
    final Offset position = buttonBox.localToGlobal(Offset.zero);
    final Size buttonSize = buttonBox.size;
    final double popoverWidth =
        MediaQuery.of(context).size.width * _popoverWidthRatio;

    _popoverEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => _removePopover(),
                child: Container(),
              ),
            ),
            Positioned(
              left: position.dx + buttonSize.width - popoverWidth,
              top: position.dy + buttonSize.height,
              child: GestureDetector(
                behavior: HitTestBehavior.deferToChild,
                onTap: () {},
                child: _buildPopover(context, popoverWidth),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_popoverEntry!);
  }

  void _removePopover() {
    _popoverEntry?.remove();
    _popoverEntry = null;

    _refreshNotificationList();
  }
}
