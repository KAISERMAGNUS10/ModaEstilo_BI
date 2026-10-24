# Base de datos

| Archivo | Descripción |
| --- | --- |
| `01_ModaEstilo_BI_Demo.sql` | Crea `ModaEstilo_BI_Demo`, las 12 tablas transaccionales y `DimFecha`, carga los datos sintéticos, ejecuta 6 validaciones financieras (`THROW` 51001–51006) y crea las 11 vistas del esquema `bi` (5 dimensiones y 6 hechos). |
| `02_Consultas_Validacion_BI.sql` | Consultas de solo lectura Q1–Q5: indicadores globales, ingresos por categoría y por año, alquileres y penalidades, filas por vista e integridad de claves de fecha. |
| `03_Pruebas_5_4_Calidad_Seguridad.sql` | Pruebas de la sección 5.4 (unitarias, integración, calidad de datos y seguridad). T-11 y T-15 trabajan dentro de una transacción con `ROLLBACK`. |

Ejecutar primero el script 01 en una instancia de pruebas. Al volver a ejecutarlo, elimina y recrea solo los objetos de `ModaEstilo_BI_Demo`.
