"""
Conversor de horarios desde formato Markdown a JSON.
Lee el archivo Horarios.md y genera horario_por_grupo.json.
"""
import re
import json
import os
import hashlib

def generate_id(text):
    """Genera un ID único basado en hash MD5."""
    return str(int(hashlib.md5(text.encode()).hexdigest(), 16))[:6]

def generate_code(text, prefix=""):
    """Genera un código único con prefijo."""
    return prefix + str(int(hashlib.md5(text.encode()).hexdigest(), 16))[:4].upper()

def convert_md_to_json():
    """Convierte el archivo Horarios.md a formato JSON."""
    candidates = [
        os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'db', 'horarios', 'Horarios.md'),
        os.path.join(os.path.dirname(os.path.abspath(__file__)), 'db', 'horarios', 'Horarios.md'),
        '/db/horarios/Horarios.md'
    ]
    
    md_path = None
    for c in candidates:
        if os.path.exists(c):
            md_path = c
            break
            
    if not md_path:
        print(f"No se encontró Horarios.md. Buscado en: {candidates}")
        return

    json_path = os.path.join(os.path.dirname(md_path), 'horario_por_grupo.json')

    with open(md_path, 'r', encoding='utf-8') as f:
        content = f.read()

    output_list = []
    
    dias_map = {"Lunes": 1, "Martes": 2, "Miércoles": 3, "Jueves": 4, "Viernes": 5, "Sábado": 6, "Domingo": 7}
    
    careers_data = re.split(r'##\s+Licenciatura en', content)[1:]
    
    row_counter = 100000

    profesores_codes = {}
    materias_codes = {}
    aulas_codes = {}
    
    for c_data in careers_data:
        c_lines = c_data.strip().split('\n')
        carrera_nombre_raw = c_lines[0].strip()
        carrera_nombre = "Licenciatura en " + carrera_nombre_raw
        
        carrera_code = generate_code(carrera_nombre, "C")
        
        group_blocks = re.split(r'#{3,4}\s+Grupo\s+', c_data)[1:]
        
        for g_block in group_blocks:
            g_lines = g_block.strip().split('\n')
            grupo_nombre = g_lines[0].strip()
            id_grupo = grupo_nombre.replace("-", "").replace(" ", "")
            
            prof_map = {}
            prof_match = re.search(r'\*\*Profesores:\*\*(.*?)(?=\n\n|\Z)', g_block, re.DOTALL)
            if prof_match:
                for p_line in prof_match.group(1).strip().split('\n'):
                    if ':' in p_line:
                        parts = p_line.strip('- ').split(':', 1)
                        if len(parts) == 2:
                            m_name, p_name = parts
                            m_name = m_name.strip()
                            p_name = p_name.strip()
                            prof_map[m_name.upper()] = p_name
                            
                            if p_name not in profesores_codes:
                                profesores_codes[p_name] = generate_id(p_name)

            table_match = re.search(r'\| [Hh][Oo][Rr][Aa][\s]*\| Lunes \| Martes \| Miércoles \| Jueves \| Viernes \|.*?\n((?:\|.*?\n)+)', g_block, re.IGNORECASE)
            
            if table_match:
                for row in table_match.group(1).strip().split('\n'):
                    if '---|' in row: continue
                    cells = [c.strip() for c in row.split('|') if c.strip()]
                    if len(cells) < 6: continue
                    
                    try:
                        h_range = cells[0].replace(' ', '')
                        h_start_str, h_end_str = h_range.split('-')
                        start_h = int(h_start_str.split(':')[0])
                        end_h = int(h_end_str.split(':')[0])
                    except:
                        continue
                        
                    days = ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes"]
                    for i, day_name in enumerate(days):
                        cell_val = cells[i+1]
                        
                        if not cell_val: continue
                        
                        m_match = re.search(r'^(.*?)(?:\s+Aula:\s*|\s*\()(.*?)(?:\)|$)', cell_val, re.IGNORECASE)
                        
                        if m_match:
                            m_raw = m_match.group(1).strip()
                            aula_nombre = m_match.group(2).strip()
                        else:
                            m_raw = cell_val.strip()
                            aula_nombre = "SIN AULA"
                        
                        if "Aula:" in cell_val and (not aula_nombre or aula_nombre == "SIN AULA"):
                            print(f"⚠️ Warning: 'Aula:' detected but not parsed in: '{cell_val}'")
                            if "Aula:" in cell_val:
                                parts = cell_val.split("Aula:")
                                if len(parts) > 1:
                                    aula_nombre = parts[1].strip().rstrip(')')
                                    m_raw = parts[0].strip()
                                    print(f"   -> Fixed via fallback: Aula='{aula_nombre}'")

                        
                        materia_nombre = m_raw
                        
                        profesor_nombre = "SIN PROFESOR ASIGNADO"
                        id_profesor = "P000"
                        
                        if materia_nombre.upper() in prof_map:
                            profesor_nombre = prof_map[materia_nombre.upper()]
                        else:
                             for k, v in prof_map.items():
                                 if k in materia_nombre.upper() or materia_nombre.upper() in k:
                                     profesor_nombre = v
                                     break

                        if profesor_nombre in profesores_codes:
                            id_profesor = profesores_codes[profesor_nombre]
                        
                        if materia_nombre not in materias_codes:
                            materias_codes[materia_nombre] = generate_code(materia_nombre, "M")
                        asignatura_code = materias_codes[materia_nombre]
                        
                        if aula_nombre not in aulas_codes:
                            aulas_codes[aula_nombre] = generate_id(aula_nombre)[:3]
                        id_aula = aulas_codes[aula_nombre]

                        duration = end_h - start_h
                        for h_offset in range(duration):
                            current_h = start_h + h_offset
                            
                            entry = {
                                "rowId": row_counter,
                                "idprofesor": id_profesor,
                                "nombreCompleto": profesor_nombre,
                                "asignatura": asignatura_code,
                                "idGrupo": id_grupo,
                                "idAula": id_aula,
                                "dia": dias_map[day_name],
                                "hora": current_h,
                                "carrera": id_grupo[:2] + "X",
                                "nombreCarrera": carrera_nombre,
                                "periodog": "2526A",
                                "materia": materia_nombre.upper(),
                                "nombreGrupo": grupo_nombre,
                                "nombreAula": aula_nombre
                            }
                            output_list.append(entry)
                            row_counter += 1

    with open(json_path, 'w', encoding='utf-8') as f:
        json.dump(output_list, f, indent=2, ensure_ascii=False)
    
    print(f"Generado {json_path} con {len(output_list)} registros.")

if __name__ == "__main__":
    convert_md_to_json()
