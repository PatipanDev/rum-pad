import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rum_tap/controllers/panel_controller.dart';
import 'package:rum_tap/state/panel_state.dart';

final panelControllerProvider = NotifierProvider<PanelController, PanelState>(
  PanelController.new,
);
