# Moda y Estilo BI

Proyecto académico de Inteligencia de Negocios para analizar las ventas y los alquileres de prendas de vestir de ModaEstilo mediante SQL Server y Power BI.

## Información del repositorio

- Repositorio: [KAISERMAGNUS10/ModaEstilo_BI](https://github.com/KAISERMAGNUS10/ModaEstilo_BI).
- Rama principal: `main`.
- Estado: estructura inicial de carpetas y documentación.

## Organización

| Carpeta | Contenido previsto |
| --- | --- |
| [database](database/) | Script de la base de demostración, vistas y consultas de validación. |
| [powerbi](powerbi/) | Modelo de Power BI y medidas DAX. |
| [resultados](resultados/) | Salidas de consultas y registros de pruebas. |
| [evidencias](evidencias/) | Manifiesto y evidencias del proyecto. Las capturas del capítulo 5 se organizarán en `evidencias/capitulo5/`. |
| [docs](docs/) | Modelo de datos, diccionario y guía de reproducción. |

Por ahora se incluyen únicamente archivos README.md. Los scripts, el modelo, las capturas y los resultados se incorporarán progresivamente. Esta estructura no acredita una ejecución de SQL Server ni la validación de un dashboard.

## Reproducibilidad

El flujo previsto comprende preparar la base de demostración, validar conteos e importes, importar las vistas en Power BI, configurar relaciones y medidas y conciliar los indicadores con SQL Server.

Al incorporar cada componente se documentarán sus requisitos, versiones, dependencias y pasos de ejecución. Los controles esperados se distinguirán de los resultados observados.

## Control de versiones

Los cambios se registran mediante commits de Git. Para cada entrega del informe se identificará la rama, el hash completo del commit, su fecha y su mensaje. Las evidencias se vincularán a la revisión evaluada mediante enlaces permanentes.

## Datos y condiciones de uso

La fuente de demostración prevista es `ModaEstilo_BI_Demo`, con datos sintéticos e importes en soles peruanos (PEN). Cada resultado deberá identificar su fuente, versión, filtros, fecha y responsable.

Las capturas compartidas omitirán credenciales y datos personales innecesarios. Las condiciones de uso y las licencias aplicables se documentarán al incorporar código y conjuntos de datos.
