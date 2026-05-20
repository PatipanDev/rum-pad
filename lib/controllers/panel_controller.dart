import 'package:riverpod/riverpod.dart';
import 'package:rum_tap/state/panel_state.dart';

class PanelController extends Notifier<PanelState> {
  @override
  PanelState build() {
    return const PanelState(
      currentPanel: AppPanel.mixer,
      isExpanded: true,
      isLocked: false,
    );
  }

  void togglePanel() {
    state = state.copyWith(
      currentPanel: state.currentPanel == AppPanel.mixer
          ? AppPanel.drumPad
          : AppPanel.mixer,
    );
  }

  void toggleExpand() {
    state = state.copyWith(
      isExpanded: !state.isExpanded,
    );
  }

  void toggleIsLocked() {
    state = state.copyWith(
      isLocked: !state.isLocked
    );
  }
}