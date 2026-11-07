import 'package:flutter/material.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../services/app_state.dart';
import '../../services/audio_service.dart';
import '../painting/space_painter.dart';
import '../widgets/glass.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  Widget _slider(BuildContext context, double value, ValueChanged<double> onChanged, bool enabled) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: enabled ? NC.violet : const Color(0x44FFFFFF),
        inactiveTrackColor: const Color(0x33FFFFFF),
        thumbColor: Colors.white,
        trackHeight: 5,
      ),
      child: Slider(value: value, min: 0, max: 1, onChanged: enabled ? onChanged : null, onChangeEnd: (double v) => AppState.instance.commitSettings()),
    );
  }

  Widget _row(IconData icon, String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: <Widget>[
        Icon(icon, color: NC.lavender, size: 26),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: ts(17, weight: FontWeight.w700))),
        NyanToggle(value: value, onChanged: onChanged),
      ],
    );
  }

  Widget _langChip(AppState s, String code) {
    final bool sel = s.lang == code;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          AudioService.instance.sfx('click');
          s.setLang(code);
        },
        child: Container(
          margin: EdgeInsets.only(right: code == 'bg' ? 10 : 0),
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: sel ? const Color(0x337C5CFF) : const Color(0x14FFFFFF),
            border: Border.all(color: sel ? NC.violet : const Color(0x44FFFFFF), width: sel ? 2 : 1.2),
          ),
          child: Text(code == 'bg' ? 'Български' : 'English', style: ts(16, weight: FontWeight.w800, color: sel ? Colors.white : NC.textDim)),
        ),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: GlassCard(
          radius: 26,
          padding: const EdgeInsets.all(20),
          fill: const <Color>[Color(0xF21B1560), Color(0xF20E0B3D)],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.warning_amber_rounded, color: NC.danger, size: 44),
              const SizedBox(height: 10),
              Text(tr('resetTitle'), style: ts(22, weight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(tr('resetBody'), textAlign: TextAlign.center, style: ts(15, weight: FontWeight.w500, color: NC.textDim)),
              const SizedBox(height: 18),
              Row(
                children: <Widget>[
                  Expanded(child: GlowButton(label: tr('cancel'), onTap: () => Navigator.of(ctx).pop(false), style: GlowStyle.outline, height: 46, fontSize: 15)),
                  const SizedBox(width: 10),
                  Expanded(child: GlowButton(label: tr('confirmReset'), onTap: () => Navigator.of(ctx).pop(true), style: GlowStyle.danger, height: 46, fontSize: 15)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (ok == true) {
      await AppState.instance.resetProgress();
      if (context.mounted) showToast(context, tr('resetDone'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (BuildContext context, Widget? _) {
        final AppState s = AppState.instance;
        return SpaceBackground(
          colors: NC.darkBg,
          stops: NC.darkStops,
          seed: 61,
          nebula: const <NebulaBlob>[NebulaBlob(0.9, 0.2, 0.6, 0xFF512DA8), NebulaBlob(0.1, 0.8, 0.6, 0xFF2A4C8F)],
          child: SafeArea(
            bottom: false,
            child: ListView(
              padding: EdgeInsets.fromLTRB(20, 14, 20, MediaQuery.paddingOf(context).bottom + 110),
              children: <Widget>[
                Center(child: Text(tr('settingsTitle'), style: ts(26, weight: FontWeight.w800, spacing: 1.5))),
                const SizedBox(height: 18),
                GlassCard(
                  child: Column(
                    children: <Widget>[
                      _row(Icons.music_note_rounded, tr('music'), s.musicOn, s.setMusicOn),
                      const SizedBox(height: 6),
                      Align(alignment: Alignment.centerLeft, child: Text(tr('musicVol'), style: ts(13, weight: FontWeight.w500, color: NC.textDim))),
                      _slider(context, s.musicVol, s.setMusicVol, s.musicOn),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                GlassCard(
                  child: Column(
                    children: <Widget>[
                      _row(Icons.volume_up_rounded, tr('sound'), s.sfxOn, s.setSfxOn),
                      const SizedBox(height: 6),
                      Align(alignment: Alignment.centerLeft, child: Text(tr('sfxVol'), style: ts(13, weight: FontWeight.w500, color: NC.textDim))),
                      _slider(context, s.sfxVol, s.setSfxVol, s.sfxOn),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(children: <Widget>[const Icon(Icons.language_rounded, color: NC.lavender, size: 26), const SizedBox(width: 12), Text(tr('language'), style: ts(17, weight: FontWeight.w700))]),
                      const SizedBox(height: 12),
                      Row(children: <Widget>[_langChip(s, 'bg'), _langChip(s, 'en')]),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                GlowButton(label: tr('reset'), onTap: () => _confirmReset(context), style: GlowStyle.danger, height: 54, fontSize: 17, icon: Icons.delete_forever_rounded, width: double.infinity),
                const SizedBox(height: 22),
                Center(child: Text(tr('version'), style: ts(13, weight: FontWeight.w500, color: NC.textDim))),
              ],
            ),
          ),
        );
      },
    );
  }
}
