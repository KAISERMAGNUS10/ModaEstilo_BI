# Modelo de Power BI

| Archivo | Descripción |
| --- | --- |
| `ModaEstilo_BI.pbip` | Proyecto de Power BI (abre el modelo `ModaEstilo_BI.SemanticModel` y el reporte `ModaEstilo_BI.Report`). |
| `ModaEstilo_BI.pbix` | El mismo proyecto guardado como archivo único con datos. |
| `Medidas_DAX.dax` | Las 23 medidas del modelo con su tabla, carpeta y formato. |
| `Verificacion_Modelo.dax` | Consultas DAX usadas para conciliar el modelo con SQL Server. |
| `Pruebas_5_4.dax` | Pruebas de la sección 5.4 sobre el modelo: filas, relaciones, indicadores, datos personales y filtros. |

El modelo se conecta en modo Import a `localhost` / `ModaEstilo_BI_Demo`. Tras abrirlo, pulsar **Actualizar**. La caché local (`.pbi/cache.abf`) y la configuración local no se versionan.
