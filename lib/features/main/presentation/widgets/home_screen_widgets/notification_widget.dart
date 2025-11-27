import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vermicomposting/core/common/entities/notification_service.dart';
import 'package:flutter_vermicomposting/core/common/widgets/empty_display_widget.dart';
import 'package:flutter_vermicomposting/features/main/presentation/widgets/home_screen_widgets/notification_tile.dart';
import 'package:flutter_vermicomposting/features/notification/domain/entities/notification.dart';
import 'package:flutter_vermicomposting/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationWidget extends StatefulWidget {
  final List<NotificationEntity> notificationList;

  const NotificationWidget({
    super.key,
    required this.notificationList,
  });

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {
  late NotificationService _notification;
  late SupabaseClient _supabaseClient;
  List<NotificationEntity> notificationList = [];

  static const double _popoverWidthRatio = 0.35;
  final GlobalKey _buttonKey = GlobalKey();
  OverlayEntry? _popoverEntry;

  int currentTab = 0;

  @override
  void initState() {
    super.initState();

    _notification = GetIt.I<NotificationService>();
    _supabaseClient = GetIt.I<SupabaseClient>();
    notificationList = widget.notificationList;
  }

  @override
  Widget build(BuildContext context) {
    if (notificationList.isNotEmpty) {
      final List<NotificationEntity> unreadList =
          notificationList.where((n) => !n.read).toList();

      for (var notification in unreadList) {
        _notification.showNotifications(
            id: notification.id,
            title: notification.subject,
            body: notification.description);
      }
    }

    return IconButton(
      key: _buttonKey,
      onPressed: () {
        if (_popoverEntry == null) {
          _showPopover(context, _buttonKey);
        } else {
          _removePopover();
        }
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        minimumSize: Size.zero,
        side: BorderSide(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          width: 1,
        ),
      ),
      icon: Badge(
        isLabelVisible:
            (notificationList.where((n) => n.read == false).isNotEmpty),
        label: Text(
            (notificationList.where((n) => n.read == false).length).toString()),
        backgroundColor: Colors.blueAccent,
        textStyle: GoogleFonts.spaceMono(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        textColor: Colors.white,
        child: Icon(
          FluentIcons.alert_24_regular,
          size: 28,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildPopover(BuildContext context, double popoverWidth) {
    const double maxPopoverHeight = 640;

    final bool showAll = currentTab == 0;
    final List<NotificationEntity> unreadList =
        notificationList.where((n) => !n.read).toList();

    final List<NotificationEntity> dataToDisplay =
        showAll ? notificationList : unreadList;

    final bool isEmpty = dataToDisplay.isEmpty;

    return Material(
      elevation: 10,
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
        constraints: const BoxConstraints(maxHeight: maxPopoverHeight),
        child: Column(
          children: [
            _buildHeader(),
            _buildTabSelector(context),
            Expanded(
              child: isEmpty
                  ? Center(
                      child: EmptyDisplayWidget(
                        icon: FluentIcons.alert_on_24_regular,
                        title: showAll
                            ? "No notifications yet"
                            : "No unread notifications",
                        description:
                            "Return here for updates on activities or schedules",
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: dataToDisplay.length,
                      itemBuilder: (context, index) {
                        return Container(
                          color: Colors.red.withOpacity(0.1),
                          child: NotificationTile(
                            notification: dataToDisplay[index],
                            supabaseClient: _supabaseClient,
                            onRefresh: () => context
                                .read<NotificationBloc>()
                                .add(NotificationList()),
                          ),
                        );
                      },
                    ),
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
          InkWell(
            onTap: () async {
              await _supabaseClient
                  .from("notification")
                  .update({'read': true})
                  .eq('read', false)
                  .select()
                  .order('created_at');

              context.read<NotificationBloc>().add(NotificationList());
            },
            child: Row(
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
  }
}
