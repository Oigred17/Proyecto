from datetime import date, timedelta

def obtener_siguiente_dia_semana(fecha_inicio: date, dia_semana: str) -> date:
    mapa_dias = {
        'LUNES': 0, 'MARTES': 1, 'MIÉRCOLES': 2, 'JUEVES': 3,
        'VIERNES': 4, 'SÁBADO': 5, 'DOMINGO': 6
    }
    dia_objetivo_int = mapa_dias.get(dia_semana.upper())
    if dia_objetivo_int is None:
        raise ValueError(f"Día de la semana '{dia_semana}' no válido.")

    if dia_semana.upper() == 'DOMINGO':
        return fecha_inicio + timedelta(days=7)

    dias_adelante = (dia_objetivo_int - fecha_inicio.weekday() + 7) % 7
    return fecha_inicio + timedelta(days=dias_adelante)

def obtener_siguiente_lunes(fecha_actual: date) -> date:
    dias_hasta_lunes = (0 - fecha_actual.weekday() + 7) % 7
    return fecha_actual + timedelta(days=dias_hasta_lunes)
