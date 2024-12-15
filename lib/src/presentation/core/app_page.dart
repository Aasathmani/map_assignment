import 'package:flutter/material.dart';
import 'package:map_assignment/src/application/core/process_state.dart';
import 'package:map_assignment/src/presentation/core/theme/colors.dart';
import 'package:map_assignment/src/presentation/widgets/app_appbar.dart';
import 'package:map_assignment/src/presentation/widgets/error_widget.dart';
import 'package:map_assignment/src/presentation/widgets/loader_widget.dart';

/// Created by Jemsheer K D on 07 May, 2023.
/// File Name : app_page
/// Project : FESProject

class AppPage extends StatelessWidget {
  final String title;
  final Widget child;
  final bool isBackButtonRequired;
  final Function() retryOnTap;
  final Stream<ProcessState> processStateStream;
  final List<Widget> actions;

  const AppPage({
    required this.title,
    required this.child,
    this.isBackButtonRequired = true,
    required this.retryOnTap,
    required this.processStateStream,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      appBar: _getAppBarLayout(context),
      body: StreamBuilder<ProcessState>(
        stream: processStateStream,
        builder: (context, snapshot) {
          final processState = snapshot.data ?? ProcessState.initial();
          return SafeArea(
            top: false,
            child: _getBodyLayout(context, processState),
          );
        },
      ),
    );
  }

  AppAppbar _getAppBarLayout(BuildContext context) {
    return AppAppbar(
      title: title,
      onUserTap: () {},
      isBackButtonRequired: isBackButtonRequired,
      actions: actions,
    );
  }

  Widget _getBodyLayout(BuildContext context, ProcessState processState) {
    if (processState.status == ProcessStatus.busy) {
      return const LoaderWidget();
    } else if (processState.status == ProcessStatus.error) {
      return ErrorMessageWidget(
        title: processState.message,
        description: processState.errorMsg,
        retryOnTap: () => retryOnTap(),
      );
    } else {
      return child;
    }
  }
}
