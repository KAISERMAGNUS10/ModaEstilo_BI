/* =====================================================================
   PROCEDIMIENTO DE REPLICACION: CONSULTAS DEL ETL (OLTP -> OLAP)
   Base: ModaEstilo_BI_Demo (crear antes con 01_ModaEstilo_BI_Demo.sql).
   Uso: seleccionar SOLO el bloque del paso (desde "PASO" hasta el
   siguiente), pulsar F5 y tomar la captura con Windows + Shift + S.
   ===================================================================== */

-- PASO 2. Versión de SQL Server  (captura 2)
SELECT @@VERSION AS Version;
SELECT SERVERPROPERTY('ProductVersion') AS ProductVersion,
       SERVERPROPERTY('ProductLevel')   AS ProductLevel,
       SERVERPROPERTY('Edition')        AS Edition,
       SERVERPROPERTY('Collation')      AS Collation;


-- PASO 7. Extracción: datos de origen OLTP (captura 7)
USE ModaEstilo_BI_Demo;
SELECT TOP 5 idVenta, idCliente, idTrabajador, fechaVenta, estado, total FROM dbo.Venta ORDER BY idVenta;
SELECT TOP 5 idDetalleVenta, idVenta, idArticulo, cantidad, precioUnitario, costoUnitario, subtotal
FROM dbo.DetalleVenta ORDER BY idDetalleVenta;


-- PASO 8. Calidad: reglas de validación (todas deben dar 0) (captura 8)
USE ModaEstilo_BI_Demo;
SELECT
 (SELECT COUNT(*) FROM dbo.Venta v OUTER APPLY (SELECT SUM(d.subtotal) t FROM dbo.DetalleVenta d WHERE d.idVenta = v.idVenta) x
   WHERE ABS(v.total - ISNULL(x.t, 0)) > 0.001) AS R51001_VentaVsDetalle,
 (SELECT COUNT(*) FROM dbo.Alquiler a OUTER APPLY (SELECT SUM(d.subtotal) t FROM dbo.DetalleAlquiler d WHERE d.idAlquiler = a.idAlquiler) x
   WHERE ABS(a.total - ISNULL(x.t, 0)) > 0.001) AS R51002_AlquilerVsDetalle,
 (SELECT COUNT(*) FROM dbo.Venta v OUTER APPLY (SELECT SUM(p.monto) t FROM dbo.Pago p WHERE p.tipoOperacion = N'VENTA' AND p.idVenta = v.idVenta AND p.estadoPago = N'Confirmado') x
   WHERE ISNULL(x.t, 0) > v.total) AS R51003_PagoVenta,
 (SELECT COUNT(*) FROM dbo.Alquiler a OUTER APPLY (SELECT SUM(p.monto) t FROM dbo.Pago p WHERE p.tipoOperacion = N'ALQUILER' AND p.idAlquiler = a.idAlquiler AND p.estadoPago = N'Confirmado') x
   WHERE ISNULL(x.t, 0) > a.total) AS R51004_PagoAlquiler,
 (SELECT COUNT(*) FROM dbo.Penalidad e OUTER APPLY (SELECT SUM(p.monto) t FROM dbo.Pago p WHERE p.tipoOperacion = N'PENALIDAD' AND p.idPenalidad = e.idPenalidad AND p.estadoPago = N'Confirmado') x
   WHERE ISNULL(x.t, 0) > e.monto) AS R51005_PagoPenalidad,
 (SELECT COUNT(*) FROM dbo.Alquiler a JOIN dbo.Devolucion d ON a.idAlquiler = d.idAlquiler
   WHERE a.fechaDevolucionReal <> d.fechaDevolucion OR a.estado <> N'Devuelto') AS R51006_Devolucion;


-- PASO 9. Transformación: dimensión de tiempo (captura 9)
USE ModaEstilo_BI_Demo;
SELECT TOP 5 FechaKey, Fecha, Anio, Trimestre, MesNombre, AnioMes, DiaSemanaNombre FROM bi.DimCalendario ORDER BY FechaKey;
SELECT COUNT(*) AS DiasCalendario, MIN(Fecha) AS Desde, MAX(Fecha) AS Hasta FROM bi.DimCalendario;


-- PASO 10. Transformación: dimensión artículo (artículo + categoría) (captura 10)
USE ModaEstilo_BI_Demo;
SELECT TOP 5 ArticuloKey, Codigo, Articulo, Categoria, Talla, Color, PrecioListaVenta, StockActual, StockMinimo
FROM bi.DimArticulo ORDER BY ArticuloKey;


-- PASO 11. Transformación: hecho de ventas (clave de fecha, costo y margen) (captura 11)
USE ModaEstilo_BI_Demo;
SELECT TOP 5 DetalleVentaKey, VentaID, FechaVentaKey, ClienteKey, TrabajadorKey, ArticuloKey,
       Cantidad, ImporteVenta, CostoMercaderia, MargenBrutoVenta
FROM bi.FactVenta ORDER BY DetalleVentaKey;


-- PASO 12. Transformación: hecho de alquileres (días de retraso y puntualidad) (captura 12)
USE ModaEstilo_BI_Demo;
SELECT TOP 5 AlquilerID, FechaAlquilerKey, FechaDevolucionProgramadaKey, FechaDevolucionRealKey,
       EstadoAlquiler, ImporteAlquiler, DiasRetraso, FuePuntual
FROM bi.FactAlquiler WHERE FuePuntual = 0 ORDER BY AlquilerID;


-- PASO 13. Validación: OLTP frente a OLAP (mismas filas y mismos importes) (captura 13)
USE ModaEstilo_BI_Demo;
SELECT N'Ventas (filas)' AS Control, CAST((SELECT COUNT(*) FROM dbo.DetalleVenta) AS DECIMAL(12,2)) AS OLTP,
       CAST((SELECT COUNT(*) FROM bi.FactVenta) AS DECIMAL(12,2)) AS OLAP
UNION ALL SELECT N'Alquileres (filas)', (SELECT COUNT(*) FROM dbo.DetalleAlquiler), (SELECT COUNT(*) FROM bi.FactAlquiler)
UNION ALL SELECT N'Penalidades (filas)', (SELECT COUNT(*) FROM dbo.Penalidad), (SELECT COUNT(*) FROM bi.FactPenalidad)
UNION ALL SELECT N'Gastos (filas)', (SELECT COUNT(*) FROM dbo.Gasto), (SELECT COUNT(*) FROM bi.FactGasto)
UNION ALL SELECT N'Pagos (filas)', (SELECT COUNT(*) FROM dbo.Pago), (SELECT COUNT(*) FROM bi.FactPago)
UNION ALL SELECT N'Ingreso por ventas (S/)', (SELECT SUM(total) FROM dbo.Venta), (SELECT SUM(ImporteVenta) FROM bi.FactVenta)
UNION ALL SELECT N'Ingreso por alquileres (S/)', (SELECT SUM(total) FROM dbo.Alquiler), (SELECT SUM(ImporteAlquiler) FROM bi.FactAlquiler);
