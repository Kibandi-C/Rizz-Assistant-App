enum Tone {
  witty,
  romantic,
  friendly,
  professional,
  bold,
  chill;

  String get label {
    switch (this) {
      case Tone.witty: return 'Witty';
      case Tone.romantic: return 'Romantic';
      case Tone.friendly: return 'Friendly';
      case Tone.professional: return 'Professional';
      case Tone.bold: return 'Bold';
      case Tone.chill: return 'Chill';
    }
  }
}
