USE empresa_window_functions;

WITH TotalVentasVendedores AS (
    SELECT 
        e.nombre_empleado AS vendedor,
        d.nombre_departamento AS departamento,
        SUM(v.total_venta) AS total_ventas
    FROM ventas v
    INNER JOIN empleados e ON v.id_empleado = e.id_empleado
    INNER JOIN departamentos d ON e.id_departamento = d.id_departamento
    GROUP BY e.id_empleado, e.nombre_empleado, d.nombre_departamento
)
SELECT 
    vendedor,
    departamento,
    total_ventas,
    RANK() OVER (ORDER BY total_ventas DESC) AS ranking_global_ventas
FROM TotalVentasVendedores
ORDER BY LENGTH(vendedor), vendedor;