import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_assignment/generated/l10n.dart';
import 'package:map_assignment/src/application/core/base_bloc.dart';
import 'package:map_assignment/src/application/core/process_state.dart';
import 'package:map_assignment/src/application/profile/profile_event.dart';
import 'package:map_assignment/src/application/profile/profile_state.dart';
import 'package:map_assignment/src/utils/extensions.dart';
import 'package:map_assignment/src/utils/string_utils.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileBloc extends BaseBloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileState()) {
    on<GetCurrentLocation>((event, emit) async {
      await _getCurrentLocation(event: event, emit: emit);
    });
    on<DateChanged>(
      (event, emit) =>
          emit(state.copyWith(selectedDate: formatDate(event.selectedDate))),
    );
    on<LastNameChanged>(
      (event, emit) =>
          emit(state.copyWith(lastName: event.lastName, lastNameErr: "")),
    );
    on<FirstNameChanged>(
      (event, emit) => emit(
        state.copyWith(firstName: event.firstName, firstNameErr: ""),
      ),
    );
    on<CreateProfileButtonTapped>(
      (event, emit) => _getSubmitButtonTapped(event: event, emit: emit),
    );

    on<EditProfileButton>((event, emit) async {
      _getEditProfileTapped(event: event, emit: emit);
    });
    on<EditButtonClicked>((event, emit) async {
      emit(state.copyWith(editStatus: true));
    });
  }

  Future<void> _getCurrentLocation({
    required GetCurrentLocation event,
    required Emitter<ProfileState> emit,
  }) async {
    try {
      final status = await Permission.location.request();
      if (status.isGranted) {
        final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          throw Exception('Location services are disabled.');
        }

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            throw Exception('Location permission denied.');
          }
        }

        if (permission == LocationPermission.deniedForever) {
          throw Exception(
              'Location permissions are permanently denied, we cannot request permissions.');
        }

        final Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        emit(
          state.copyWith(
            currentLocation:
                "Lat: ${position.latitude}, Lon: ${position.longitude}",
            firstName: state.firstName,
            lastName: state.lastName,
          )..processState = ProcessState.completed(),
        );
      }
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future<void> _getSubmitButtonTapped({
    required CreateProfileButtonTapped event,
    required Emitter<ProfileState> emit,
  }) async {
    if (!_isValid(emit)) {
      return;
    } else {
      showMessage("Profile os created successfully");
      emit(state.copyWith(profileCreatedStatus: true));
    }
  }

  Future<void> _getEditProfileTapped({
    required EditProfileButton event,
    required Emitter<ProfileState> emit,
  }) async {
    if (!_isValid(emit)) {
      return;
    } else {
      showMessage("The profile is edited successfully");
      emit(state.copyWith(editStatus: false));
    }
  }

  bool _isValid(Emitter<ProfileState> emit) {
    bool isValid = true;
    if (StringUtils.isNullOrEmpty(state.firstName)) {
      emit(
        state.copyWith(
          firstNameErr: S.current.msgPleaseEnterFirstName,
        ),
      );
      isValid = false;
    } else if (StringUtils.isNullOrEmpty(state.lastName)) {
      emit(
        state.copyWith(
          lastNameErr: S.current.msgPleaseEnterLastName,
        ),
      );
      isValid = false;
    } else if (StringUtils.isNullOrEmpty(state.selectedDate)) {
      showMessage("Please select the Date of Birth");
      isValid = false;
    } else if (StringUtils.isNullOrEmpty(state.currentLocation)) {
      showMessage("Please Tap the current location");
      isValid = false;
    }
    return isValid;
  }
}
