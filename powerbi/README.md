# Modelo de Power BI

| Archivo | Descripción |
| --- | --- |
| `ModaEstilo_BI.pbip` | Proyecto de Power BI (abre el modelo `ModaEstilo_BI.SemanticModel` y el reporte `ModaEstilo_BI.Report`). |
| `ModaEstilo_BI.pbix` | El mismo proyecto guardado como archivo único con datos. |
| `Medidas_DAX.dax` | Las 23 medidas del modelo con su tabla, carpeta y formato. |
| `Verificacion_Modelo.dax` | Consultas DAX usadas para conciliar el modelo con SQL Server. |

El modelo se conecta en modo Import a `localhost` / `ModaEstilo_BI_Demo`. Tras abrirlo, pulsar **Actualizar**. La caché local (`.pbi/cache.abf`) y la configuración local no se versionan.
