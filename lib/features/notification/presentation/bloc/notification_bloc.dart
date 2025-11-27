import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vermicomposting/core/usecase/usecase.dart';
import 'package:flutter_vermicomposting/features/notification/domain/entities/notification.dart';
import 'package:flutter_vermicomposting/features/notification/domain/usecases/list_notification.dart';
import 'package:flutter_vermicomposting/features/notification/domain/usecases/patch_notification.dart';
import 'package:meta/meta.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final ListNotification _listNotification;
  final PatchNotification _patchNotification;

  NotificationBloc({
    required ListNotification listNotification,
    required PatchNotification patchNotification,
  })  : _listNotification = listNotification,
        _patchNotification = patchNotification,
        super(NotificationInitial()) {
    on<NotificationList>(_onListNotification);
    on<NotificationPatch>(_onPatchNotification);
  }

  Future<void> _onListNotification(
    NotificationList event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());

    final result = await _listNotification(NoParams());

    await result.fold(
      (l) async => emit(NotificationFailure(l.message)),
      (r) async {
        await emit.forEach<List<NotificationEntity>>(
          r,
          onData: (data) => NotificationListSuccess(data),
          onError: (e, st) => NotificationFailure(e.toString()),
        );
      },
    );
  }

  Future<void> _onPatchNotification(
    NotificationPatch event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());

    final result = await _patchNotification(PatchNotificationParams(
      id: event.id,
      read: event.read,
    ));

    result.fold(
      (l) => emit(NotificationFailure(l.message)),
      (r) => emit(NotificationSuccess(r)),
    );
  }
}
