USE empresa_window_functions;

SELECT 
    e.nombre_empleado AS vendedor,
    v.fecha_venta AS fecha_de_venta,
    -- Formato con signo de dólar para el total de la venta actual
    CONCAT('$', FORMAT(v.total_venta, 2)) AS total_de_venta,
    -- Formato con signo de dólar para la venta anterior (manejando el NULL si es la primera)
    CASE 
        WHEN LAG(v.total_venta) OVER (PARTITION BY e.id_empleado ORDER BY v.fecha_venta ASC) IS NULL THEN 'NULL'
        ELSE CONCAT('$', FORMAT(LAG(v.total_venta) OVER (PARTITION BY e.id_empleado ORDER BY v.fecha_venta ASC), 2))
    END AS venta_anterior,
    -- Formato para la diferencia (mantiene el signo menos si es negativo)
    CASE 
        WHEN LAG(v.total_venta) OVER (PARTITION BY e.id_empleado ORDER BY v.fecha_venta ASC) IS NULL THEN '$0.00'
        ELSE CONCAT(
            IF(v.total_venta - LAG(v.total_venta) OVER (PARTITION BY e.id_empleado ORDER BY v.fecha_venta ASC) < 0, '-', ''),
            '$', 
            FORMAT(ABS(v.total_venta - LAG(v.total_venta) OVER (PARTITION BY e.id_empleado ORDER BY v.fecha_venta ASC)), 2)
        )
    END AS diferencia_contra_la_venta_anterior
FROM ventas v
INNER JOIN empleados e ON v.id_empleado = e.id_empleado
ORDER BY LENGTH(vendedor), vendedor, fecha_de_venta;