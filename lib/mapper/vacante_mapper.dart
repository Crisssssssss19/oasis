import 'package:oasis/data/remote/dto/vacante_datos_dto.dart';
import 'package:oasis/domain/model/vacante_respuesta.dart';
import 'package:oasis/domain/model/vacante_peticion.dart';
import 'package:oasis/data/remote/dto/vacante_peticion_dto.dart';

extension VacanteDatosDtoMapper on VacanteDatosDto {
  VacanteRespuesta toDomain() {
    return VacanteRespuesta(
      id: idVacante,
      titulo: tituloVacante,
      fechaInicioUtc: DateTime.parse(fechaInicioVacante).toUtc(),
      minSalario: minSalarioVacante,
      maxSalario: maxSalarioVacante,
      ubicacion: nombreUbicacion,
      empresa: nombreEmpresa,
      jornada: nombreJornada,
      modalidad: nombreModalidad,
      tipoContrato: nombreTipoContrato,
      nombrePrivadoAnuncio: nombrePrivadoAnuncio,
      estado: nombreEstadoVacante,
      palabrasClave: palabrasClave,
      imagenUrl: imagenUrl,
    );
  }
}

extension VacantePeticionMapper on VacantePeticion {
  VacantePeticionDto toDto() {
    return VacantePeticionDto(campoOrden: campoOrden, orden: orden);
  }
}
