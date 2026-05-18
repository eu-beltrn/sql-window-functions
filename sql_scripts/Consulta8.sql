-- Es para que use esta base de datos.
USE empresa_window_functions;

-- Clasificación de tendencia usando Case
WITH TendenciasVentas AS (
    SELECT 
        v.id_empleado,
        e.nombre_empleado,
        v.fecha_venta,
        v.total_venta,
        LAG(v.total_venta) OVER (
            PARTITION BY v.id_empleado 
            ORDER BY v.fecha_venta ASC
        ) AS venta_anterior
    FROM ventas v
    INNER JOIN empleados e 
        ON v.id_empleado = e.id_empleado
)
SELECT 
    id_empleado,
    nombre_empleado,
    fecha_venta,
    total_venta,
    venta_anterior,
    -- Generación de dimensión categórica para segmentación
    CASE 
        WHEN venta_anterior IS NULL THEN 'Primera Venta'
        WHEN total_venta > venta_anterior THEN 'CRECIMIENTO'
        WHEN total_venta < venta_anterior THEN 'DISMINUCIÓN'
        ELSE 'ESTABILIDAD'
    END AS estado_tendencia
FROM TendenciasVentas
ORDER BY 
    id_empleado ASC, 
    fecha_venta ASC;