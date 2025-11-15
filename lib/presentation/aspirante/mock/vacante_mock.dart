/// Modelo de Vacante
class Vacante {
  final String titulo;
  final String empresa;
  final String textoValorOferta;
  final List<String> keyWords;
  final String tipoJornada;
  final String ubicacion;
  final String modalidad;
  final int postulaciones;
  final String imagenAsset;

  const Vacante({
    required this.titulo,
    required this.empresa,
    required this.textoValorOferta,
    required this.keyWords,
    required this.tipoJornada,
    required this.ubicacion,
    required this.modalidad,
    required this.postulaciones,
    required this.imagenAsset,
  });
}

/// Mock de vacantes
const List<Vacante> vacantesMock = [
  Vacante(
    titulo: "Desarrollador FrontEnd",
    empresa: "TechCorp Colombia",
    textoValorOferta: "\$4.500.000 - \$6.000.000",
    keyWords: [
      "Fullstack",
      "Desarrollador .NET",
      "Administrador DBA",
      "Con moto y carro",
    ],
    tipoJornada: "Tiempo completo",
    ubicacion: "Bogotá",
    modalidad: "Remoto",
    postulaciones: 45,
    imagenAsset: "assets/images/vacante_0001.jpg",
  ),
  Vacante(
    titulo: "Backend Engineer",
    empresa: "SoftSolutions",
    textoValorOferta: "\$5.000.000 - \$7.000.000",
    keyWords: [
      "Ahorra oxigeno",
      "Que le guste bañarse",
      "Que le guste saltar",
      "Con solo moto",
    ],
    tipoJornada: "Medio tiempo",
    ubicacion: "Medellín",
    modalidad: "Híbrido",
    postulaciones: 32,
    imagenAsset: "assets/images/vacante_0002.jpg",
  ),
  Vacante(
    titulo: "UI/UX Designer",
    empresa: "Creative Studio",
    textoValorOferta: "\$3.500.000 - \$5.000.000",
    keyWords: [
      "Que sepa modo gráfico",
      "CSS",
      "SCSS pez",
      "Que use photoShop",
      "Hacer logos",
      "Usar Paint 3D",
    ],
    tipoJornada: "Tiempo completo",
    ubicacion: "Cali",
    modalidad: "Presencial",
    postulaciones: 20,
    imagenAsset: "assets/images/vacante_0003.jpg",
  ),
  Vacante(
    titulo: "Cocinero",
    empresa: "La cocina de doña Juana",
    textoValorOferta: "\$3.500.000 - \$5.000.000",
    keyWords: ["Platos a la carta", "Arepa caleña", "Mute santandereano"],
    tipoJornada: "Tiempo completo",
    ubicacion: "Cali",
    modalidad: "Presencial",
    postulaciones: 20,
    imagenAsset: "assets/images/vacante_0004.jpg",
  ),
  Vacante(
    titulo: "Veedor de Netflix",
    empresa: "Creative Studio",
    textoValorOferta: "\$3.500.000 - \$5.000.000",
    keyWords: ["Nextflix", "HBO", "Disney", "Prime", "La APP de mercado libre"],
    tipoJornada: "Medio tiempo",
    ubicacion: "Santa Marta",
    modalidad: "Remoto",
    postulaciones: 123,
    imagenAsset: "assets/images/vacante_0005.jpg",
  ),
  Vacante(
    titulo: "Ciclista",
    empresa: "Tour Colombia",
    textoValorOferta: "\$11.250.000 - \$27.500.000",
    keyWords: [
      "Tour de Francia",
      "Carreras",
      "Estadios de Colombia",
      "Fuerza piernas",
    ],
    tipoJornada: "Medio tiempo",
    ubicacion: "Bogotá",
    modalidad: "Presencial",
    postulaciones: 21,
    imagenAsset: "assets/images/vacante_0006.jpg",
  ),
  Vacante(
    titulo: "Cuidado de niños pequeños",
    empresa: "Hogar, salud y vida",
    textoValorOferta: "\$5.250.000 - Por definir",
    keyWords: ["Paciencia", "Pedagogía", "Trabajo en equipo", "Rapidez"],
    tipoJornada: "Tiempo completo",
    ubicacion: "Cali",
    modalidad: "Híbrido",
    postulaciones: 17,
    imagenAsset: "assets/images/vacante_0007.jpg",
  ),
  Vacante(
    titulo: "Comedor de hamburguesas Prof",
    empresa: "La casa del Gordo III",
    textoValorOferta: "Por definir",
    keyWords: ["Gordito", "Con hambre", "Coma rápido", "Que duerma rápido"],
    tipoJornada: "Orden de prestación",
    ubicacion: "Medellín",
    modalidad: "Presencial",
    postulaciones: 12,
    imagenAsset: "assets/images/vacante_0008.jpg",
  ),
  Vacante(
    titulo: "Albañil",
    empresa: "Industrial Sol y Luna",
    textoValorOferta: "Por definir",
    keyWords: [
      "Paredes y concretos",
      "Soldadura",
      "Cemento gris y blanco",
      "Baños",
    ],
    tipoJornada: "Término indefinido",
    ubicacion: "Bucaramanga",
    modalidad: "Remoto",
    postulaciones: 8,
    imagenAsset: "assets/images/vacante_0009.jpg",
  ),
  Vacante(
    titulo: "Ecualizador",
    empresa: "Sistemas de sonido de Colombia SaS",
    textoValorOferta: "\$3.750.000 - \$4.800.000",
    keyWords: ["Spotifai", "La yutub", "Música para todos", "Oído máximo"],
    tipoJornada: "Término indefinido",
    ubicacion: "Barranquilla",
    modalidad: "Híbrido",
    postulaciones: 19,
    imagenAsset: "assets/images/vacante_0010.jpg",
  ),
];
