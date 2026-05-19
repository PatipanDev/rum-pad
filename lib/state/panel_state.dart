enum AppPanel {
  mixer,
  drumPad,
}

class PanelState {
  final AppPanel currentPanel;
  final bool isExpanded;

  const PanelState({
    required this.currentPanel,
    required this.isExpanded,
  });

  PanelState copyWith({
    AppPanel? currentPanel,
    bool? isExpanded,
  }) {
    return PanelState(
      currentPanel: currentPanel ?? this.currentPanel,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}