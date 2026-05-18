-- Es para que use esta base de datos.
USE empresa_window_functions;

-- Diferencia porcentual entre venta actual y venta anterior por empleado.
WITH HistorialVentas AS (
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
    -- Evita dividir entre cero 'Division by Zero' mediante NULLIF. 
    -- Se redondea a 2 decimales para optimizar el almacenamiento.
    ROUND(
        ((total_venta - venta_anterior) / NULLIF(venta_anterior, 0)) * 100, 
        2
    ) AS variacion_porcentual
FROM HistorialVentas
ORDER BY 
    id_empleado ASC, 
    fecha_venta ASC;