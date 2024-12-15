import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_assignment/generated/l10n.dart';
import 'package:map_assignment/src/application/core/process_state.dart';
import 'package:map_assignment/src/application/web_view/web_view_bloc.dart';
import 'package:map_assignment/src/application/web_view/web_view_event.dart';
import 'package:map_assignment/src/application/web_view/web_view_state.dart';
import 'package:map_assignment/src/presentation/core/base_state.dart';
import 'package:map_assignment/src/presentation/core/theme/colors.dart';
import 'package:map_assignment/src/presentation/widgets/dialog/app_dialog.dart';
import 'package:map_assignment/src/presentation/widgets/loader_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart'
    as webview_android;

class WebViewPage extends StatefulWidget {
  static const String route = "/web_view";

  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends BaseState<WebViewPage> {
  WebViewBloc? _bloc;

  WebViewController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_bloc == null) {
      _bloc = BlocProvider.of<WebViewBloc>(context);

      _bloc!.stream.listen(
        (state) {
          if (state.isInitCompleted && !state.isControllerInitiated) {
            _controller = WebViewController()
              ..loadRequest(
                Uri.parse(_bloc!.url),
                headers: _bloc!.isHeaderRequired ? state.headers ?? {} : {},
              )
              ..setNavigationDelegate(
                NavigationDelegate(
                  onNavigationRequest: (request) {
                    if (!mounted) return NavigationDecision.prevent;
                    if (request.url.contains("mailto:")) {
                      launchUrlString(request.url);
                      return NavigationDecision.prevent;
                    }
                    if (_bloc!.successUrl != null ||
                        _bloc!.failureUrl != null) {
                      if (request.url.startsWith(_bloc!.successUrl ?? " ")) {
                        Navigator.pop(context, request.url);
                        return NavigationDecision.prevent;
                      } else if (request.url
                          .startsWith(_bloc!.failureUrl ?? " ")) {
                        Navigator.pop(context, null);
                        return NavigationDecision.prevent;
                      }
                    }
                    return NavigationDecision.navigate;
                  },
                  onProgress: (value) {
                    if (_bloc!.isClosed) return;
                    _bloc!.add(
                      WebViewEvent()
                        ..processState = value < 100
                            ? ProcessState.busy()
                            : ProcessState.completed(),
                    );
                  },
                  onWebResourceError: (error) async {
                    final currentUrl = await _controller!.currentUrl();
                    debugPrint(error.toString());
                    if (currentUrl != null &&
                        !currentUrl.startsWith(_bloc!.successUrl ?? " ") &&
                        !currentUrl.startsWith(_bloc!.failureUrl ?? " ")) {
                      _bloc!.add(
                        WebViewEvent()
                          ..processState =
                              ProcessState.error(errorMsg: error.toString()),
                      );
                      debugPrint(error.toString());
                    } else if (currentUrl == null) {
                      _bloc!.add(
                        WebViewEvent()
                          ..processState =
                              ProcessState.error(errorMsg: error.toString()),
                      );
                    }
                  },
                  onPageStarted: (url) async {
                    if (_bloc!.isHeaderRequired && url != _bloc!.currentUrl) {
                      _bloc!.currentUrl = url;
                      _controller?.loadRequest(
                        Uri.parse(url),
                        headers: state.headers!,
                      );
                    }
                    _bloc!.isPageLoading = true;
                    _bloc!.add(
                      WebViewEvent()..processState = ProcessState.busy(),
                    );
                  },
                  onPageFinished: (url) async {
                    _bloc!.isPageLoading = false;

                    if ((_bloc!.successUrl == null &&
                            _bloc!.failureUrl == null) ||
                        (!url.startsWith(_bloc?.successUrl ?? " ") &&
                            !url.startsWith(_bloc?.failureUrl ?? " "))) {
                      _bloc!.add(
                        WebViewEvent()..processState = ProcessState.completed(),
                      );
                    }

                    if (url.startsWith(_bloc!.alternateSuccessUrl ?? " ")) {
                      await _displayTemporaryLoader();
                    }
                  },
                ),
              )
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..setUserAgent(
                "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36",
              );
            if (!kIsWeb && Platform.isAndroid) {
              _initAndroidFileUploader();
            }
            _bloc!.add(WebViewControllerInitiatedEvent());
          }
        },
      );
    }
  }

  Future<void> _displayTemporaryLoader() async {
    late BuildContext loaderContext;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        loaderContext = context;
        return WillPopScope(
          onWillPop: () async => false,
          child: const LoaderWidget(),
        );
      },
    );
    await Future.delayed(const Duration(seconds: 5)).then((value) {
      if (loaderContext.mounted) Navigator.pop(loaderContext);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_bloc!.isBackConfirmationRequired) {
          final url = await _controller?.currentUrl();
          if (!mounted) return false;
          if (!_bloc!.isPageLoading &&
              (url?.startsWith(_bloc!.alternateSuccessUrl ?? ' ') ?? false)) {
            Navigator.pop(context, url);
            return false;
          }

          final result = await openAppDialog(
            context,
            title: S.current.labelCancelXConfirmation(_bloc!.title),
            positiveButtonText: S.current.btnYesCancel,
            negativeButtonText: S.current.btnNo,
          );
          if (result ?? false) {
            _controller?.runJavaScript('window.stop();');
          }
          return result ?? false;
        } else {
          return !_bloc!.isPageLoading;
        }
      },
      child: BlocBuilder<WebViewBloc, WebViewState>(
        bloc: _bloc,
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                _bloc!.title.toUpperCase(),
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: AppColors.white,
                    ),
              ),
            ),
            body: _getBodyLayout(context, state),
          );
        },
      ),
    );
  }

  Widget _getBodyLayout(BuildContext context, WebViewState state) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller!),
        if (state.processState.status == ProcessStatus.busy)
          const ColoredBox(
            color: AppColors.white,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        else if (state.processState.status == ProcessStatus.error)
          ColoredBox(
            color: AppColors.white,
            child: Center(
              child: Text(
                S.current.errWebView,
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _initAndroidFileUploader() async {
    if (Platform.isAndroid) {
      final controller =
          _controller!.platform as webview_android.AndroidWebViewController;
      await controller.setOnShowFileSelector(
        (params) => _bloc!.initAndroidFilePicker(params),
      );
    }
  }
}

class WebViewArgument {
  String title;
  String url;
  String? alternateSuccessUrl;
  String? successUrl;
  String? failureUrl;
  bool isHeaderRequired;
  bool isBackConfirmationRequired;

  WebViewArgument({
    required this.title,
    required this.url,
    this.alternateSuccessUrl,
    this.successUrl,
    this.failureUrl,
    this.isHeaderRequired = false,
    this.isBackConfirmationRequired = false,
  });
}
