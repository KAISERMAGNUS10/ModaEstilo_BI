# Evidencia E-12: antes y después de las mejoras

Mejoras registradas en la sección 5.5 del informe (Registro de retroalimentación y mejoras). Cada una tiene su estado anterior y posterior verificable.

| Código | Origen | Antes | Después | Evidencia |
| --- | --- | --- | --- | --- |
| M-01 | Prueba T-10 (Q4 en SQL Server frente a DAX) | `Devoluciones con Retraso = CALCULATE([Número de Alquileres], FactAlquiler[FuePuntual] = 0)` devolvía 63 (27.39 %), porque en DAX un blanco es igual a 0 con `=` y contaba los 10 alquileres sin devolver. | Filtro con igualdad estricta `FactAlquiler[FuePuntual] == 0`: 53 (23.04 %), igual que SQL Server. | `Antes_Despues_Medidas.dax` y `Resultado_Antes_Despues.txt` |
| M-02 | Prueba T-17 (gráfico Top 10 de artículos) | `RANKX(..., Dense) <= 10` repetía puestos con empates: el gráfico mostraba 14 artículos. | `TOPN(10, ..., DimArticulo[Articulo], ASC)` desempata por nombre: el gráfico muestra 10 artículos. | `Antes_Despues_Medidas.dax` y `Resultado_Antes_Despues.txt` |
| M-03 | Revisión de las evidencias del informe | Capturas con los paneles de Power BI (Filtros, Visualizaciones y Datos): `../capitulo5/`. | Capturas recortadas al modelo y al lienzo del dashboard (figuras 5.2.1 a 5.2.4): `capturas_despues/`. | Carpetas `../capitulo5/` y `capturas_despues/` |

Para reproducir M-01 y M-02, abrir `powerbi/ModaEstilo_BI.pbix` y ejecutar las consultas de `Antes_Despues_Medidas.dax` en DAX Studio o en la vista de consultas DAX de Power BI.
