USE empresa_window_functions;

WITH VentasPorDepartamento AS (
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
    departamento,
    vendedor,
    total_ventas,
    RANK() OVER (
        PARTITION BY departamento 
        ORDER BY total_ventas DESC
    ) AS ranking_por_departamento
FROM VentasPorDepartamento
ORDER BY departamento, ranking_por_departamento;