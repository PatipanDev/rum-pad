

enum AppPanel { mixer, drumPad }

class PanelState {
  final AppPanel currentPanel;
  final bool isExpanded;
  final bool isLocked;

  const PanelState({
    required this.currentPanel,
    required this.isExpanded,
    required this.isLocked,
  });

  PanelState copyWith({
    AppPanel? currentPanel,
    bool? isExpanded,
    bool? isLocked,
  }) {
    return PanelState(
      currentPanel: currentPanel ?? this.currentPanel,
      isExpanded: isExpanded ?? this.isExpanded,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}
