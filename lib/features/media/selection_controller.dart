import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CompressionPreset { light, balanced, aggressive, custom }

class CompressionSettings {
  const CompressionSettings({
    this.preset = CompressionPreset.balanced,
    this.imageQuality = 78,
    this.imageMaxDimension = 2048,
    this.videoBitrateKbps = 2500,
    this.videoMaxDimension = 1080,
    this.videoFpsCap = 30,
    this.audioBitrateKbps = 128,
    this.replaceOriginal = false,
    this.stripMetadata = false,
    this.keepRecycleBin = false,
  });

  final CompressionPreset preset;
  final int imageQuality;
  final int imageMaxDimension;
  final int videoBitrateKbps;
  final int videoMaxDimension;
  final int videoFpsCap;
  final int audioBitrateKbps;
  final bool replaceOriginal;
  final bool stripMetadata;
  final bool keepRecycleBin;

  CompressionSettings copyWith({
    CompressionPreset? preset,
    int? imageQuality,
    int? imageMaxDimension,
    int? videoBitrateKbps,
    int? videoMaxDimension,
    int? videoFpsCap,
    int? audioBitrateKbps,
    bool? replaceOriginal,
    bool? stripMetadata,
    bool? keepRecycleBin,
  }) {
    return CompressionSettings(
      preset: preset ?? this.preset,
      imageQuality: imageQuality ?? this.imageQuality,
      imageMaxDimension: imageMaxDimension ?? this.imageMaxDimension,
      videoBitrateKbps: videoBitrateKbps ?? this.videoBitrateKbps,
      videoMaxDimension: videoMaxDimension ?? this.videoMaxDimension,
      videoFpsCap: videoFpsCap ?? this.videoFpsCap,
      audioBitrateKbps: audioBitrateKbps ?? this.audioBitrateKbps,
      replaceOriginal: replaceOriginal ?? this.replaceOriginal,
      stripMetadata: stripMetadata ?? this.stripMetadata,
      keepRecycleBin: keepRecycleBin ?? this.keepRecycleBin,
    );
  }

  CompressionSettings forPreset(CompressionPreset value) {
    if (value == CompressionPreset.custom) return copyWith(preset: value);
    return switch (value) {
      CompressionPreset.light => copyWith(
        preset: value,
        imageQuality: 88,
        imageMaxDimension: 4096,
        videoBitrateKbps: 4500,
        videoMaxDimension: 2160,
        videoFpsCap: 60,
        audioBitrateKbps: 192,
      ),
      CompressionPreset.balanced => copyWith(
        preset: value,
        imageQuality: 78,
        imageMaxDimension: 2048,
        videoBitrateKbps: 2500,
        videoMaxDimension: 1080,
        videoFpsCap: 30,
        audioBitrateKbps: 128,
      ),
      CompressionPreset.aggressive => copyWith(
        preset: value,
        imageQuality: 62,
        imageMaxDimension: 1280,
        videoBitrateKbps: 1200,
        videoMaxDimension: 720,
        videoFpsCap: 24,
        audioBitrateKbps: 96,
      ),
      CompressionPreset.custom => copyWith(preset: value),
    };
  }
}

class SelectionState {
  const SelectionState({this.selectedUris = const <String>{}, this.settings = const CompressionSettings()});

  final Set<String> selectedUris;
  final CompressionSettings settings;

  SelectionState copyWith({Set<String>? selectedUris, CompressionSettings? settings}) {
    return SelectionState(
      selectedUris: selectedUris ?? this.selectedUris,
      settings: settings ?? this.settings,
    );
  }
}

class SelectionController extends StateNotifier<SelectionState> {
  SelectionController() : super(const SelectionState());

  void toggle(String uri) {
    final next = {...state.selectedUris};
    if (!next.add(uri)) next.remove(uri);
    state = state.copyWith(selectedUris: next);
  }

  void selectAll(Iterable<String> uris) => state = state.copyWith(selectedUris: uris.toSet());

  void clear() => state = state.copyWith(selectedUris: <String>{});

  void setSettings(CompressionSettings settings) => state = state.copyWith(settings: settings);
}

final selectionControllerProvider = StateNotifierProvider<SelectionController, SelectionState>(
  (ref) => SelectionController(),
);
