/*
ModaEstilo BI | Pruebas de la sección 5.4 (calidad, seguridad y pruebas)
Base: ModaEstilo_BI_Demo. Las pruebas T-05 a T-10, T-14 y T-17 se completan con
powerbi/Pruebas_5_4.dax sobre el modelo de Power BI.
Las pruebas T-11 (caso fallido) y T-15 hacen cambios dentro de una transacción
y siempre terminan con ROLLBACK: la base queda igual que antes.
*/
USE ModaEstilo_BI_Demo;
SET NOCOUNT ON;

PRINT '=== T-01. Filas cargadas por el script 01 (esperado: 9, 7, 90, 46, 185, 323, 240, 378, 230, 102, 137, 566 y 1,096) ===';
SELECT N'Categoria' AS Tabla, COUNT(*) AS Filas FROM dbo.Categoria
UNION ALL SELECT N'Trabajador', COUNT(*) FROM dbo.Trabajador
UNION ALL SELECT N'Cliente', COUNT(*) FROM dbo.Cliente
UNION ALL SELECT N'Articulo', COUNT(*) FROM dbo.Articulo
UNION ALL SELECT N'Venta', COUNT(*) FROM dbo.Venta
UNION ALL SELECT N'DetalleVenta', COUNT(*) FROM dbo.DetalleVenta
UNION ALL SELECT N'Alquiler', COUNT(*) FROM dbo.Alquiler
UNION ALL SELECT N'DetalleAlquiler', COUNT(*) FROM dbo.DetalleAlquiler
UNION ALL SELECT N'Devolucion', COUNT(*) FROM dbo.Devolucion
UNION ALL SELECT N'Penalidad', COUNT(*) FROM dbo.Penalidad
UNION ALL SELECT N'Gasto', COUNT(*) FROM dbo.Gasto
UNION ALL SELECT N'Pago', COUNT(*) FROM dbo.Pago
UNION ALL SELECT N'DimFecha', COUNT(*) FROM dbo.DimFecha;

PRINT '=== T-02. Grano de las vistas de hechos: filas de la vista = filas del origen y 0 claves repetidas ===';
SELECT N'bi.FactVenta' AS Vista, (SELECT COUNT(*) FROM bi.FactVenta) AS FilasVista,
       (SELECT COUNT(*) FROM dbo.DetalleVenta) AS FilasOrigen,
       (SELECT COUNT(*) - COUNT(DISTINCT DetalleVentaKey) FROM bi.FactVenta) AS ClavesRepetidas
UNION ALL SELECT N'bi.FactAlquiler', (SELECT COUNT(*) FROM bi.FactAlquiler), (SELECT COUNT(*) FROM dbo.DetalleAlquiler),
       (SELECT COUNT(*) - COUNT(DISTINCT DetalleAlquilerKey) FROM bi.FactAlquiler)
UNION ALL SELECT N'bi.FactPenalidad', (SELECT COUNT(*) FROM bi.FactPenalidad), (SELECT COUNT(*) FROM dbo.Penalidad),
       (SELECT COUNT(*) - COUNT(DISTINCT PenalidadID) FROM bi.FactPenalidad)
UNION ALL SELECT N'bi.FactGasto', (SELECT COUNT(*) FROM bi.FactGasto), (SELECT COUNT(*) FROM dbo.Gasto),
       (SELECT COUNT(*) - COUNT(DISTINCT GastoID) FROM bi.FactGasto)
UNION ALL SELECT N'bi.FactPago', (SELECT COUNT(*) FROM bi.FactPago), (SELECT COUNT(*) FROM dbo.Pago),
       (SELECT COUNT(*) - COUNT(DISTINCT PagoID) FROM bi.FactPago);

PRINT '=== T-03. Regla de puntualidad: FuePuntual = 0 solo si la devolución real es posterior a la programada ===';
WITH c AS (SELECT DISTINCT AlquilerID, FuePuntual, DiasRetraso, EstadoAlquiler FROM bi.FactAlquiler)
SELECT COUNT(*) AS FilasPorContrato,
       COUNT(DISTINCT AlquilerID) AS Contratos,
       SUM(CASE WHEN FuePuntual = 0 THEN 1 ELSE 0 END) AS ConRetraso,
       SUM(CASE WHEN FuePuntual = 1 THEN 1 ELSE 0 END) AS Puntuales,
       SUM(CASE WHEN FuePuntual IS NULL THEN 1 ELSE 0 END) AS SinDevolucion,
       SUM(CASE WHEN (FuePuntual = 0 AND DiasRetraso <= 0) OR (FuePuntual = 1 AND DiasRetraso <> 0)
                  OR (FuePuntual IS NULL AND EstadoAlquiler = N'Devuelto')
                  OR (FuePuntual IS NOT NULL AND EstadoAlquiler <> N'Devuelto') THEN 1 ELSE 0 END) AS Contradicciones,
       MIN(CASE WHEN FuePuntual = 0 THEN DiasRetraso END) AS RetrasoMinDias,
       MAX(CASE WHEN FuePuntual = 0 THEN DiasRetraso END) AS RetrasoMaxDias
FROM c;
-- Cruce con las penalidades por mora: cada contrato con retraso debe tener una mora con los mismos días
WITH c AS (SELECT DISTINCT AlquilerID, DiasRetraso FROM bi.FactAlquiler WHERE FuePuntual = 0),
     m AS (SELECT AlquilerID, SUM(DiasRetrasoPenalidad) AS DiasMora FROM bi.FactPenalidad
           WHERE TipoPenalidad = N'Mora' GROUP BY AlquilerID)
SELECT (SELECT COUNT(*) FROM c) AS ContratosConRetraso,
       (SELECT COUNT(*) FROM m) AS ContratosConMora,
       (SELECT COUNT(*) FROM c LEFT JOIN m ON m.AlquilerID = c.AlquilerID WHERE m.AlquilerID IS NULL) AS RetrasoSinMora,
       (SELECT COUNT(*) FROM m LEFT JOIN c ON c.AlquilerID = m.AlquilerID WHERE c.AlquilerID IS NULL) AS MoraSinRetraso,
       (SELECT COUNT(*) FROM c JOIN m ON m.AlquilerID = c.AlquilerID WHERE m.DiasMora <> c.DiasRetraso) AS DiasDistintos;

PRINT '=== T-04. Fórmulas de los indicadores (Q1) ===';
SELECT v.IngresoVentas, a.IngresoAlquileres,
       v.IngresoVentas + a.IngresoAlquileres AS IngresoTotal,
       v.NumeroVentas + a.NumeroAlquileres AS NumeroOperaciones,
       CAST((v.IngresoVentas + a.IngresoAlquileres) / (v.NumeroVentas + a.NumeroAlquileres) AS DECIMAL(12,2)) AS TicketPromedio,
       v.CostoMercaderia,
       v.IngresoVentas - v.CostoMercaderia AS MargenCalculado,
       v.MargenVista,
       (SELECT SUM(total) FROM dbo.Venta) AS TotalCabeceraVentas,
       (SELECT SUM(total) FROM dbo.Alquiler) AS TotalCabeceraAlquileres
FROM (SELECT SUM(ImporteVenta) AS IngresoVentas, COUNT(DISTINCT VentaID) AS NumeroVentas,
             SUM(CostoMercaderia) AS CostoMercaderia, SUM(MargenBrutoVenta) AS MargenVista FROM bi.FactVenta) v
CROSS JOIN (SELECT SUM(ImporteAlquiler) AS IngresoAlquileres, COUNT(DISTINCT AlquilerID) AS NumeroAlquileres
            FROM bi.FactAlquiler) a;

PRINT '=== T-05 (lado SQL). Filas por vista (Q5) ===';
SELECT N'bi.DimCalendario' AS Vista, COUNT(*) AS Filas FROM bi.DimCalendario
UNION ALL SELECT N'bi.DimArticulo', COUNT(*) FROM bi.DimArticulo
UNION ALL SELECT N'bi.DimTrabajador', COUNT(*) FROM bi.DimTrabajador
UNION ALL SELECT N'bi.DimCliente', COUNT(*) FROM bi.DimCliente
UNION ALL SELECT N'bi.FactVenta', COUNT(*) FROM bi.FactVenta
UNION ALL SELECT N'bi.FactAlquiler', COUNT(*) FROM bi.FactAlquiler
UNION ALL SELECT N'bi.FactPenalidad', COUNT(*) FROM bi.FactPenalidad
UNION ALL SELECT N'bi.FactGasto', COUNT(*) FROM bi.FactGasto
UNION ALL SELECT N'bi.FactPago', COUNT(*) FROM bi.FactPago;

PRINT '=== T-06. Claves de hechos sin fila en su dimensión (esperado: 0 en todas) ===';
SELECT N'FactVenta' AS Hecho,
       (SELECT COUNT(*) FROM bi.FactVenta f WHERE NOT EXISTS (SELECT 1 FROM bi.DimCalendario d WHERE d.FechaKey = f.FechaVentaKey)) AS SinFecha,
       (SELECT COUNT(*) FROM bi.FactVenta f WHERE NOT EXISTS (SELECT 1 FROM bi.DimArticulo d WHERE d.ArticuloKey = f.ArticuloKey)) AS SinArticulo,
       (SELECT COUNT(*) FROM bi.FactVenta f WHERE NOT EXISTS (SELECT 1 FROM bi.DimCliente d WHERE d.ClienteKey = f.ClienteKey)) AS SinCliente,
       (SELECT COUNT(*) FROM bi.FactVenta f WHERE NOT EXISTS (SELECT 1 FROM bi.DimTrabajador d WHERE d.TrabajadorKey = f.TrabajadorKey)) AS SinTrabajador
UNION ALL SELECT N'FactAlquiler',
       (SELECT COUNT(*) FROM bi.FactAlquiler f WHERE NOT EXISTS (SELECT 1 FROM bi.DimCalendario d WHERE d.FechaKey = f.FechaAlquilerKey)),
       (SELECT COUNT(*) FROM bi.FactAlquiler f WHERE NOT EXISTS (SELECT 1 FROM bi.DimArticulo d WHERE d.ArticuloKey = f.ArticuloKey)),
       (SELECT COUNT(*) FROM bi.FactAlquiler f WHERE NOT EXISTS (SELECT 1 FROM bi.DimCliente d WHERE d.ClienteKey = f.ClienteKey)),
       (SELECT COUNT(*) FROM bi.FactAlquiler f WHERE NOT EXISTS (SELECT 1 FROM bi.DimTrabajador d WHERE d.TrabajadorKey = f.TrabajadorKey))
UNION ALL SELECT N'FactPenalidad',
       (SELECT COUNT(*) FROM bi.FactPenalidad f WHERE NOT EXISTS (SELECT 1 FROM bi.DimCalendario d WHERE d.FechaKey = f.FechaPenalidadKey)),
       (SELECT COUNT(*) FROM bi.FactPenalidad f WHERE f.ArticuloKey IS NOT NULL AND NOT EXISTS (SELECT 1 FROM bi.DimArticulo d WHERE d.ArticuloKey = f.ArticuloKey)),
       (SELECT COUNT(*) FROM bi.FactPenalidad f WHERE NOT EXISTS (SELECT 1 FROM bi.DimCliente d WHERE d.ClienteKey = f.ClienteKey)),
       (SELECT COUNT(*) FROM bi.FactPenalidad f WHERE NOT EXISTS (SELECT 1 FROM bi.DimTrabajador d WHERE d.TrabajadorKey = f.TrabajadorKey))
UNION ALL SELECT N'FactGasto',
       (SELECT COUNT(*) FROM bi.FactGasto f WHERE NOT EXISTS (SELECT 1 FROM bi.DimCalendario d WHERE d.FechaKey = f.FechaGastoKey)), NULL, NULL, NULL
UNION ALL SELECT N'FactPago',
       (SELECT COUNT(*) FROM bi.FactPago f WHERE NOT EXISTS (SELECT 1 FROM bi.DimCalendario d WHERE d.FechaKey = f.FechaPagoKey)), NULL,
       (SELECT COUNT(*) FROM bi.FactPago f WHERE NOT EXISTS (SELECT 1 FROM bi.DimCliente d WHERE d.ClienteKey = f.ClienteKey)),
       (SELECT COUNT(*) FROM bi.FactPago f WHERE NOT EXISTS (SELECT 1 FROM bi.DimTrabajador d WHERE d.TrabajadorKey = f.TrabajadorKey));
SELECT COUNT(*) AS ClavesForaneasDeclaradas FROM sys.foreign_keys WHERE is_disabled = 0;

PRINT '=== T-11. Reglas financieras del script (esperado: 0 incumplimientos) ===';
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

PRINT '=== T-11. Caso fallido controlado: se altera un total dentro de una transacción ===';
DECLARE @antes DECIMAL(12,2) = (SELECT total FROM dbo.Venta WHERE idVenta = 1);
BEGIN TRY
    BEGIN TRANSACTION;
    UPDATE dbo.Venta SET total = total + 10 WHERE idVenta = 1;
    IF EXISTS (SELECT 1 FROM dbo.Venta v OUTER APPLY (SELECT SUM(d.subtotal) t FROM dbo.DetalleVenta d WHERE d.idVenta = v.idVenta) x
               WHERE ABS(v.total - ISNULL(x.t, 0)) > 0.001)
        THROW 51001, 'Total de venta distinto a suma de sus detalles.', 1;
    COMMIT TRANSACTION;
    SELECT N'No se detectó el error' AS Resultado;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    SELECT ERROR_NUMBER() AS ErrorDetectado, ERROR_MESSAGE() AS Mensaje,
           @antes AS TotalAntes, (SELECT total FROM dbo.Venta WHERE idVenta = 1) AS TotalDespuesDelRollback,
           @@TRANCOUNT AS TransaccionesAbiertas;
END CATCH;

PRINT '=== T-12. Nulos en claves y medidas que usa el modelo ===';
SELECT N'bi.FactVenta' AS Vista,
       SUM(CASE WHEN VentaID IS NULL OR FechaVentaKey IS NULL OR ArticuloKey IS NULL OR ClienteKey IS NULL OR TrabajadorKey IS NULL THEN 1 ELSE 0 END) AS NulosEnClaves,
       SUM(CASE WHEN Cantidad IS NULL OR ImporteVenta IS NULL OR CostoMercaderia IS NULL OR MargenBrutoVenta IS NULL THEN 1 ELSE 0 END) AS NulosEnMedidas,
       NULL AS NulosJustificados
FROM bi.FactVenta
UNION ALL
SELECT N'bi.FactAlquiler',
       SUM(CASE WHEN AlquilerID IS NULL OR FechaAlquilerKey IS NULL OR ArticuloKey IS NULL OR ClienteKey IS NULL OR TrabajadorKey IS NULL THEN 1 ELSE 0 END),
       SUM(CASE WHEN Cantidad IS NULL OR ImporteAlquiler IS NULL THEN 1 ELSE 0 END),
       SUM(CASE WHEN FuePuntual IS NULL THEN 1 ELSE 0 END)
FROM bi.FactAlquiler
UNION ALL
SELECT N'bi.FactPenalidad',
       SUM(CASE WHEN PenalidadID IS NULL OR FechaPenalidadKey IS NULL OR ClienteKey IS NULL OR TrabajadorKey IS NULL THEN 1 ELSE 0 END),
       SUM(CASE WHEN MontoPenalidad IS NULL THEN 1 ELSE 0 END),
       SUM(CASE WHEN ArticuloKey IS NULL THEN 1 ELSE 0 END)
FROM bi.FactPenalidad
UNION ALL
SELECT N'bi.FactGasto', SUM(CASE WHEN GastoID IS NULL OR FechaGastoKey IS NULL THEN 1 ELSE 0 END),
       SUM(CASE WHEN MontoGasto IS NULL THEN 1 ELSE 0 END), NULL FROM bi.FactGasto
UNION ALL
SELECT N'bi.FactPago', SUM(CASE WHEN PagoID IS NULL OR FechaPagoKey IS NULL OR ClienteKey IS NULL OR TrabajadorKey IS NULL THEN 1 ELSE 0 END),
       SUM(CASE WHEN MontoPago IS NULL THEN 1 ELSE 0 END), NULL FROM bi.FactPago;
SELECT SUM(CASE WHEN FuePuntual IS NULL THEN 1 ELSE 0 END) AS LineasSinDevolucion,
       COUNT(DISTINCT CASE WHEN FuePuntual IS NULL THEN AlquilerID END) AS ContratosSinDevolucion
FROM bi.FactAlquiler;
SELECT TipoPenalidad, COUNT(*) AS Filas, SUM(CASE WHEN ArticuloKey IS NULL THEN 1 ELSE 0 END) AS SinArticulo
FROM bi.FactPenalidad GROUP BY TipoPenalidad;

PRINT '=== T-13. Rangos, fechas, horarios y duplicados ===';
SELECT
 (SELECT MIN(cantidad) FROM dbo.DetalleVenta) AS CantVentaMin, (SELECT MAX(cantidad) FROM dbo.DetalleVenta) AS CantVentaMax,
 (SELECT MIN(cantidad) FROM dbo.DetalleAlquiler) AS CantAlqMin, (SELECT MAX(cantidad) FROM dbo.DetalleAlquiler) AS CantAlqMax,
 (SELECT COUNT(*) FROM dbo.DetalleVenta WHERE subtotal <= 0) AS VentasMontoNoPositivo,
 (SELECT COUNT(*) FROM dbo.DetalleAlquiler WHERE subtotal <= 0) AS AlquileresMontoNoPositivo,
 (SELECT COUNT(*) FROM dbo.DetalleVenta WHERE subtotal - costoUnitario * cantidad < 0) AS VentasConMargenNegativo,
 (SELECT MIN(f) FROM (SELECT fechaVenta f FROM dbo.Venta UNION ALL SELECT fechaAlquiler FROM dbo.Alquiler UNION ALL SELECT fechaPago FROM dbo.Pago UNION ALL SELECT fechaGasto FROM dbo.Gasto) x) AS FechaMinima,
 (SELECT MAX(f) FROM (SELECT fechaVenta f FROM dbo.Venta UNION ALL SELECT fechaAlquiler FROM dbo.Alquiler UNION ALL SELECT fechaPago FROM dbo.Pago UNION ALL SELECT fechaGasto FROM dbo.Gasto) x) AS FechaMaxima,
 (SELECT COUNT(*) FROM (SELECT fechaVenta f FROM dbo.Venta UNION ALL SELECT fechaAlquiler FROM dbo.Alquiler UNION ALL SELECT fechaPago FROM dbo.Pago UNION ALL SELECT fechaGasto FROM dbo.Gasto) x
   WHERE CAST(f AS time) < '08:00' OR CAST(f AS time) > '18:00') AS FueraDeHorario,
 (SELECT COUNT(*) FROM dbo.Alquiler WHERE fechaDevolucionProgramada < fechaAlquiler OR fechaDevolucionReal < fechaEntrega) AS FechasIlogicas,
 (SELECT COUNT(*) - COUNT(DISTINCT dni) FROM dbo.Cliente) AS DniClienteRepetido,
 (SELECT COUNT(*) FROM (SELECT idVenta, idArticulo FROM dbo.DetalleVenta GROUP BY idVenta, idArticulo HAVING COUNT(*) > 1) x) AS ArticuloRepetidoEnVenta,
 (SELECT COUNT(*) FROM (SELECT idAlquiler, idArticulo FROM dbo.DetalleAlquiler GROUP BY idAlquiler, idArticulo HAVING COUNT(*) > 1) x) AS ArticuloRepetidoEnAlquiler;

PRINT '=== T-15. Usuario de solo lectura (db_datareader): SELECT sí, INSERT y DELETE no ===';
DECLARE @r TABLE (Operacion NVARCHAR(20), Resultado NVARCHAR(200));
BEGIN TRANSACTION;
    CREATE USER prueba_lector_bi WITHOUT LOGIN;
    ALTER ROLE db_datareader ADD MEMBER prueba_lector_bi;
    EXECUTE AS USER = 'prueba_lector_bi';
        BEGIN TRY
            DECLARE @n INT = (SELECT COUNT(*) FROM bi.FactVenta);
            INSERT INTO @r VALUES (N'SELECT', CONCAT(N'Permitido: ', @n, N' filas leídas'));
        END TRY
        BEGIN CATCH INSERT INTO @r VALUES (N'SELECT', CONCAT(N'Error ', ERROR_NUMBER(), N': ', ERROR_MESSAGE())); END CATCH;
        BEGIN TRY
            INSERT INTO dbo.Categoria (nombreCategoria, descripcion) VALUES (N'Prueba', N'No debe guardarse');
            INSERT INTO @r VALUES (N'INSERT', N'Permitido (falla de seguridad)');
        END TRY
        BEGIN CATCH INSERT INTO @r VALUES (N'INSERT', CONCAT(N'Error ', ERROR_NUMBER(), N': ', ERROR_MESSAGE())); END CATCH;
        BEGIN TRY
            DELETE FROM dbo.Gasto WHERE idGasto = 1;
            INSERT INTO @r VALUES (N'DELETE', N'Permitido (falla de seguridad)');
        END TRY
        BEGIN CATCH INSERT INTO @r VALUES (N'DELETE', CONCAT(N'Error ', ERROR_NUMBER(), N': ', ERROR_MESSAGE())); END CATCH;
    REVERT;
IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
SELECT * FROM @r;
SELECT COUNT(*) AS UsuarioDePruebaQueQueda FROM sys.database_principals WHERE name = N'prueba_lector_bi';
SELECT (SELECT COUNT(*) FROM dbo.Categoria) AS CategoriasDespues, (SELECT COUNT(*) FROM dbo.Gasto) AS GastosDespues;
