# Moda y Estilo BI

Proyecto académico de Inteligencia de Negocios para analizar las ventas y los alquileres de prendas de vestir de ModaEstilo mediante SQL Server y Power BI.

## Información del repositorio

- Repositorio: [KAISERMAGNUS10/ModaEstilo_BI](https://github.com/KAISERMAGNUS10/ModaEstilo_BI).
- Rama principal: `main`.
- Estado: solución BI implementada (base de demostración, vistas del modelo estrella, consultas de validación y proyecto de Power BI).

## Organización

| Carpeta | Contenido |
| --- | --- |
| [database](database/) | `01_ModaEstilo_BI_Demo.sql` (base, datos sintéticos y vistas `bi`) y `02_Consultas_Validacion_BI.sql` (consultas Q1–Q5). |
| [powerbi](powerbi/) | Proyecto de Power BI `ModaEstilo_BI.pbip`, medidas DAX (`Medidas_DAX.dax`) y consultas DAX de verificación. |
| [resultados](resultados/) | Salidas de las consultas Q1–Q5 en SQL Server y de la verificación del modelo de Power BI. |
| [evidencias](evidencias/) | Capturas del capítulo 5 (`evidencias/capitulo5/`). |
| [docs](docs/) | Modelo de datos y guía de reproducción. |

## Requisitos

- SQL Server 2022 o superior (probado en SQL Server 2025 Standard Developer Edition 17.0.1000.7) con autenticación de Windows.
- SQL Server Management Studio o `sqlcmd`.
- Power BI Desktop (probado en la versión 2.159.883.0, 64 bits).

## Reproducción

1. Ejecutar `database/01_ModaEstilo_BI_Demo.sql` en una instancia de pruebas. Crea la base `ModaEstilo_BI_Demo`, carga los datos sintéticos (2024–2026, importes en PEN), valida los totales y crea las vistas del esquema `bi`. No modifica `ModaEstilo_Final`.
2. Ejecutar `database/02_Consultas_Validacion_BI.sql` y comparar con `resultados/Resultados_Q1_Q5_SQLServer.txt`.
3. Abrir `powerbi/ModaEstilo_BI.pbip` (o `powerbi/ModaEstilo_BI.pbix`) en Power BI Desktop y pulsar **Actualizar**. El origen es `localhost` / `ModaEstilo_BI_Demo`; si la instancia tiene otro nombre, cambiarlo en **Transformar datos > Configuración de origen de datos**.
4. Comparar las tarjetas con los resultados de Q1–Q5 o ejecutar `powerbi/Verificacion_Modelo.dax`.

## Modelo de Power BI

- 9 tablas importadas desde las vistas `bi`: DimFecha, DimArticulo, DimTrabajador, DimCliente (solo clave y distrito), FactVenta, FactAlquiler, FactPenalidad, FactGasto y FactPago.
- 16 relaciones de muchos a uno, filtro en una dirección.
- 23 medidas DAX.
- Dashboard de 3 páginas: Resumen general, Ventas y artículos, y Alquileres y penalidades.

## Datos y condiciones de uso

La fuente es `ModaEstilo_BI_Demo`, con datos sintéticos e importes en soles peruanos (PEN). El modelo de Power BI no importa DNI, nombres, teléfonos, correos ni direcciones de clientes.
