# Moda y Estilo BI

Solución de Inteligencia de Negocios para analizar las ventas y los alquileres de prendas formales de ModaEstilo con SQL Server y Power BI. Corresponde al capítulo 5 del informe del proyecto final de Base de Datos Avanzadas y Big Data (Grupo 8).

## Estructura del repositorio

```
database/
  01_ModaEstilo_BI_Demo.sql             Base ModaEstilo_BI_Demo: tablas, datos sintéticos, validaciones y vistas bi
  02_Consultas_Validacion_BI.sql        Consultas Q1–Q5 (indicadores y conteos de control)
  03_Pruebas_5_4_Calidad_Seguridad.sql  Pruebas de la sección 5.4 en SQL Server
  04_Consultas_Procedimiento_Replicacion_ETL.sql  Consultas paso a paso del procedimiento de replicación del ETL (OLTP a OLAP)
powerbi/
  ModaEstilo_BI.pbix                    Dashboard con datos (abrir con Power BI Desktop)
  ModaEstilo_BI.pbip                    Mismo proyecto en formato de texto (modelo y reporte versionables)
  Medidas_DAX.dax                       Las 23 medidas del modelo
  Verificacion_Modelo.dax               Conciliación del modelo con SQL Server
  Pruebas_5_4.dax                       Pruebas de la sección 5.4 sobre el modelo
resultados/                             Salidas de Q1–Q5, de la conciliación y de las pruebas 5.4
evidencias/
  capitulo5/                            Capturas originales: modelo y 3 páginas del dashboard
  antes_despues/                        Evidencia E-12 de las mejoras M-01 a M-03 (sección 5.5)
```

## Requisitos

- SQL Server 2022 o superior con autenticación de Windows (probado en SQL Server 2025 Standard Developer Edition 17.0.1000.7).
- SQL Server Management Studio o `sqlcmd`.
- Power BI Desktop (probado en la versión 2.159.883.0, 64 bits).

## Cómo reproducir la solución

1. Ejecutar `database/01_ModaEstilo_BI_Demo.sql` en una instancia de pruebas. Crea `ModaEstilo_BI_Demo` con 12 tablas, 2,313 filas sintéticas y 1,096 fechas, valida los totales (`THROW` 51001–51006) y crea las 11 vistas del esquema `bi`. No modifica `ModaEstilo_Final`.
2. Ejecutar `database/02_Consultas_Validacion_BI.sql` y comparar con `resultados/Resultados_Q1_Q5_SQLServer.txt`.
3. Abrir `powerbi/ModaEstilo_BI.pbix` y pulsar **Actualizar**. El origen es `localhost` / `ModaEstilo_BI_Demo`; si la instancia tiene otro nombre, cambiarlo en **Transformar datos > Configuración de origen de datos**.
4. Ejecutar `database/03_Pruebas_5_4_Calidad_Seguridad.sql` y las consultas de `powerbi/Pruebas_5_4.dax` (DAX Studio o vista de consultas DAX) y comparar con la carpeta `resultados/`. Las pruebas T-11 y T-15 trabajan dentro de una transacción con `ROLLBACK`.

## Modelo de Power BI

- Modo Import. 9 tablas desde las vistas `bi`: DimFecha, DimArticulo, DimTrabajador, DimCliente (solo clave y distrito), FactVenta, FactAlquiler, FactPenalidad, FactGasto y FactPago.
- 16 relaciones de muchos a uno con filtro en una dirección y 23 medidas DAX.
- Dashboard de 3 páginas: Resumen general, Ventas y artículos, y Alquileres y penalidades.

## Evidencias

| Carpeta o archivo | Contenido |
| --- | --- |
| `evidencias/capitulo5/Modelo POWER BI.png` | Figura 5.2.1: vista de modelo. |
| `evidencias/capitulo5/5.2.2 Resumen general.png` | Figura 5.2.2: página Resumen general. |
| `evidencias/capitulo5/5.2.3 Ventas y Articulos.png` | Figura 5.2.3: página Ventas y artículos. |
| `evidencias/capitulo5/5.2.4 Alquileres y Penalidades.png` | Figura 5.2.4: página Alquileres y penalidades. |
| `evidencias/antes_despues/` | M-01: medida Devoluciones con Retraso (63 antes, 53 después). M-02: Top 10 de artículos (14 antes, 10 después). M-03: capturas recortadas (`capturas_despues/`). `Antes_Despues_Medidas.dax` ejecuta ambas versiones. |

## Datos y privacidad

Los datos son sintéticos e importes en soles peruanos (PEN). El modelo de Power BI no importa DNI, nombres, teléfonos, correos ni direcciones de clientes, y ningún script contiene credenciales. Uso académico.
