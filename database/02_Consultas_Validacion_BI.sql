/*
ModaEstilo BI | Consultas de validación Q1–Q5 (solo lectura)
Base: ModaEstilo_BI_Demo (creada con 01_ModaEstilo_BI_Demo.sql).
Los resultados se comparan con las medidas DAX del modelo de Power BI.
Importes en soles (PEN).
*/
USE ModaEstilo_BI_Demo;
SET NOCOUNT ON;

-- Q1. Indicadores globales (tarjetas del dashboard)
SELECT
    v.IngresoVentas,
    a.IngresoAlquileres,
    v.IngresoVentas + a.IngresoAlquileres AS IngresoTotal,
    v.NumeroVentas,
    a.NumeroAlquileres,
    v.NumeroVentas + a.NumeroAlquileres AS NumeroOperaciones,
    CAST((v.IngresoVentas + a.IngresoAlquileres) / (v.NumeroVentas + a.NumeroAlquileres) AS DECIMAL(12,2)) AS TicketPromedio,
    CAST(v.IngresoVentas / v.NumeroVentas AS DECIMAL(12,2)) AS TicketPromedioVenta,
    v.MargenBruto,
    CAST(100.0 * v.MargenBruto / v.IngresoVentas AS DECIMAL(5,2)) AS PctMargenBruto,
    (SELECT SUM(MontoGasto) FROM bi.FactGasto) AS GastosTotales,
    (SELECT SUM(MontoPenalidad) FROM bi.FactPenalidad) AS MontoPenalidades,
    (SELECT SUM(MontoPago) FROM bi.FactPago WHERE EstadoPago = N'Confirmado') AS CobrosConfirmados
FROM (SELECT SUM(ImporteVenta) AS IngresoVentas, COUNT(DISTINCT VentaID) AS NumeroVentas,
             SUM(MargenBrutoVenta) AS MargenBruto FROM bi.FactVenta) v
CROSS JOIN (SELECT SUM(ImporteAlquiler) AS IngresoAlquileres, COUNT(DISTINCT AlquilerID) AS NumeroAlquileres
            FROM bi.FactAlquiler) a;

-- Q2. Ingresos por categoría (ventas y alquileres)
SELECT d.Categoria,
       ISNULL(v.IngresoVentas, 0) AS IngresoVentas,
       ISNULL(a.IngresoAlquileres, 0) AS IngresoAlquileres
FROM (SELECT DISTINCT Categoria FROM bi.DimArticulo) d
LEFT JOIN (SELECT da.Categoria, SUM(f.ImporteVenta) AS IngresoVentas
           FROM bi.FactVenta f JOIN bi.DimArticulo da ON da.ArticuloKey = f.ArticuloKey
           GROUP BY da.Categoria) v ON v.Categoria = d.Categoria
LEFT JOIN (SELECT da.Categoria, SUM(f.ImporteAlquiler) AS IngresoAlquileres
           FROM bi.FactAlquiler f JOIN bi.DimArticulo da ON da.ArticuloKey = f.ArticuloKey
           GROUP BY da.Categoria) a ON a.Categoria = d.Categoria
ORDER BY IngresoVentas DESC;

-- Q3. Ingresos y operaciones por año
SELECT c.Anio,
       SUM(x.IngresoVentas) AS IngresoVentas, SUM(x.IngresoAlquileres) AS IngresoAlquileres,
       COUNT(DISTINCT x.VentaID) AS NumeroVentas, COUNT(DISTINCT x.AlquilerID) AS NumeroAlquileres
FROM (
    SELECT FechaVentaKey AS FechaKey, ImporteVenta AS IngresoVentas, CAST(0 AS DECIMAL(12,2)) AS IngresoAlquileres,
           VentaID, NULL AS AlquilerID FROM bi.FactVenta
    UNION ALL
    SELECT FechaAlquilerKey, 0, ImporteAlquiler, NULL, AlquilerID FROM bi.FactAlquiler
) x
JOIN bi.DimCalendario c ON c.FechaKey = x.FechaKey
GROUP BY c.Anio
ORDER BY c.Anio;

-- Q4. Alquileres, devoluciones y penalidades
SELECT COUNT(*) AS NumeroAlquileres,
       SUM(CASE WHEN estado = N'Devuelto' THEN 1 ELSE 0 END) AS AlquileresDevueltos,
       SUM(CASE WHEN estado IN (N'En curso', N'Reservado', N'Vencido') THEN 1 ELSE 0 END) AS AlquileresPendientes,
       CAST(100.0 * SUM(CASE WHEN estado = N'Devuelto' THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5,2)) AS PctTasaDevolucion,
       SUM(CASE WHEN CONVERT(date, fechaDevolucionReal) > CONVERT(date, fechaDevolucionProgramada) THEN 1 ELSE 0 END) AS DevolucionesConRetraso,
       CAST(100.0 * SUM(CASE WHEN CONVERT(date, fechaDevolucionReal) > CONVERT(date, fechaDevolucionProgramada) THEN 1 ELSE 0 END)
            / NULLIF(SUM(CASE WHEN fechaDevolucionReal IS NOT NULL THEN 1 ELSE 0 END), 0) AS DECIMAL(5,2)) AS PctDevolucionesConRetraso
FROM dbo.Alquiler;

SELECT TipoPenalidad, COUNT(*) AS Penalidades, SUM(MontoPenalidad) AS Monto
FROM bi.FactPenalidad
GROUP BY TipoPenalidad
ORDER BY Monto DESC;

-- Q5. Filas por vista (deben coincidir con las tablas cargadas en Power BI)
SELECT N'bi.DimCalendario' AS Vista, COUNT(*) AS Filas FROM bi.DimCalendario
UNION ALL SELECT N'bi.DimArticulo', COUNT(*) FROM bi.DimArticulo
UNION ALL SELECT N'bi.DimTrabajador', COUNT(*) FROM bi.DimTrabajador
UNION ALL SELECT N'bi.DimCliente', COUNT(*) FROM bi.DimCliente
UNION ALL SELECT N'bi.FactVenta', COUNT(*) FROM bi.FactVenta
UNION ALL SELECT N'bi.FactAlquiler', COUNT(*) FROM bi.FactAlquiler
UNION ALL SELECT N'bi.FactPenalidad', COUNT(*) FROM bi.FactPenalidad
UNION ALL SELECT N'bi.FactGasto', COUNT(*) FROM bi.FactGasto
UNION ALL SELECT N'bi.FactPago', COUNT(*) FROM bi.FactPago;

-- Integridad: claves de hechos sin fila en DimCalendario (esperado: 0)
SELECT
    (SELECT COUNT(*) FROM bi.FactVenta f WHERE NOT EXISTS (SELECT 1 FROM bi.DimCalendario c WHERE c.FechaKey = f.FechaVentaKey)) AS VentaSinFecha,
    (SELECT COUNT(*) FROM bi.FactAlquiler f WHERE NOT EXISTS (SELECT 1 FROM bi.DimCalendario c WHERE c.FechaKey = f.FechaAlquilerKey)) AS AlquilerSinFecha,
    (SELECT COUNT(*) FROM bi.FactPenalidad f WHERE NOT EXISTS (SELECT 1 FROM bi.DimCalendario c WHERE c.FechaKey = f.FechaPenalidadKey)) AS PenalidadSinFecha,
    (SELECT COUNT(*) FROM bi.FactGasto f WHERE NOT EXISTS (SELECT 1 FROM bi.DimCalendario c WHERE c.FechaKey = f.FechaGastoKey)) AS GastoSinFecha,
    (SELECT COUNT(*) FROM bi.FactPago f WHERE NOT EXISTS (SELECT 1 FROM bi.DimCalendario c WHERE c.FechaKey = f.FechaPagoKey)) AS PagoSinFecha;
