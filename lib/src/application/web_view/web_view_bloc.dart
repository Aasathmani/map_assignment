import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_assignment/src/application/core/base_bloc.dart';
import 'package:map_assignment/src/application/web_view/web_view_event.dart';
import 'package:map_assignment/src/application/web_view/web_view_state.dart';
import 'package:map_assignment/src/domain/auth/auth_repository.dart';
import 'package:map_assignment/src/utils/file_util.dart';
import 'package:map_assignment/src/utils/network_utils.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart'
    as webview_android;

class WebViewBloc extends BaseBloc<WebViewEvent, WebViewState> {
  final AuthRepository authRepository;
  final FileUtil fileUtil;
  final bool isHeaderRequired;
  final bool isBackConfirmationRequired;
  final String url;
  final String title;
  final String? successUrl;
  final String? alternateSuccessUrl;
  final String? failureUrl;

  String? currentUrl;
  bool isPageLoading = false;

  WebViewBloc({
    required this.authRepository,
    required this.isHeaderRequired,
    required this.url,
    required this.title,
    required this.fileUtil,
    this.successUrl,
    this.alternateSuccessUrl,
    this.failureUrl,
    this.isBackConfirmationRequired = false,
  }) : super(WebViewState()) {
    on<WebViewEvent>(
      (event, emit) => emit(
        state.copyWith()..processState = event.processState,
      ),
    );
    on<InitWebViewEvent>((event, emit) => _onWebViewInit(event, emit));
    on<WebViewControllerInitiatedEvent>(
      (event, emit) => emit(state.copyWith(isControllerInitiated: true)),
    );

    add(InitWebViewEvent());
  }

  Future<void> _onWebViewInit(
    InitWebViewEvent event,
    Emitter<WebViewState> emit,
  ) async {
    if (isHeaderRequired) {
      await setHeader(emit);
    } else {
      emit(state.copyWith(isInitCompleted: true));
    }
  }

  Future<void> setHeader(Emitter<WebViewState> emit) async {
    final map = await getHeader();
    emit(
      state.copyWith(
        headers: map.map((key, value) => MapEntry(key, value.toString())),
        isInitCompleted: true,
      ),
    );
  }

  Future<Map<String, dynamic>> getHeader() async {
    final authToken = await authRepository.getActiveToken();
    return getHeaders(authToken: authToken);
  }

  Future<List<String>> initAndroidFilePicker(
    webview_android.FileSelectorParams fileSelectorParams,
  ) async {
    final xFile = await fileUtil.pickDocument().onError(
      (e, stackTrace) {
        debugPrint(e.toString());
        return null;
      },
    );

    if (xFile == null) {
      return [];
    }
    return [xFile.path];
  }
}
