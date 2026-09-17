/// Etapa de vida del usuario que moldea la personalidad, tono, energía y pedagogía de Lev.
enum LevUserStage {
  /// < 13 años: Tono dulce, lúdico, juego, calma sencilla y protección cálida
  child,

  /// 13 - 18 años: De igual a igual, sin juzgar, comprensión de presión escolar y redes sociales
  teen,

  /// 19 - 59 años: Anti-burnout, estrés laboral, mindfulness somático y desconexión digital
  adult,

  /// 60+ años: Sosiego, paz profunda, respeto, cuidado articular suave y gratitud por la vida
  senior,
}

extension LevUserStageX on LevUserStage {
  String get label {
    switch (this) {
      case LevUserStage.child:
        return 'Niñez (< 13 años)';
      case LevUserStage.teen:
        return 'Adolescencia (13 - 18 años)';
      case LevUserStage.adult:
        return 'Adulto (19 - 59 años)';
      case LevUserStage.senior:
        return 'Plenitud (60+ años)';
    }
  }

  String get shortLabel {
    switch (this) {
      case LevUserStage.child:
        return 'Niñez';
      case LevUserStage.teen:
        return 'Adolescente';
      case LevUserStage.adult:
        return 'Adulto';
      case LevUserStage.senior:
        return 'Plenitud';
    }
  }

  String get emoji {
    switch (this) {
      case LevUserStage.child:
        return '🧒';
      case LevUserStage.teen:
        return '🌱';
      case LevUserStage.adult:
        return '🌿';
      case LevUserStage.senior:
        return '🌳';
    }
  }

  String get description {
    switch (this) {
      case LevUserStage.child:
        return 'Lev actúa de forma tierna, juguetona y protectora, con metáforas simples y juegos de respiración.';
      case LevUserStage.teen:
        return 'Lev te habla con cercanía y respeto de igual a igual, aliviando la presión académica y el juicio de redes.';
      case LevUserStage.adult:
        return 'Lev se enfoca en disolver el estrés laboral, la sobrecarga mental y reconectar con tu cuerpo y paz.';
      case LevUserStage.senior:
        return 'Lev te acompaña con sosiego, calma profunda, respeto, cuidado suave y gratitud por la vida.';
    }
  }
}

/// Modelo del perfil del usuario en Lev
class UserProfile {
  final String name;
  final int age;

  const UserProfile({
    required this.name,
    required this.age,
  });

  factory UserProfile.defaultProfile() {
    return const UserProfile(
      name: 'Humano',
      age: 25,
    );
  }

  LevUserStage get stage {
    if (age <= 0) return LevUserStage.adult;
    if (age < 13) return LevUserStage.child;
    if (age <= 18) return LevUserStage.teen;
    if (age < 60) return LevUserStage.adult;
    return LevUserStage.senior;
  }

  UserProfile copyWith({
    String? name,
    int? age,
  }) {
    return UserProfile(
      name: name ?? this.name,
      age: age ?? this.age,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'age': age,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'] as String? ?? 'Humano',
    age: json['age'] as int? ?? 25,
  );
}

