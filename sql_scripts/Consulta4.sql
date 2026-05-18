use empresa_window_functions;

select * from departamentos;
select * from empleados;
select * from productos;
select * from sucursales;
select * from ventas;
-- 1. Primero defines la tabla y las columnas a insertar
INSERT INTO ventas (
    id_venta,
    id_empleado,
    id_producto,
    id_sucursal,
    fecha_venta,
    cantidad,
    precio_unitario,
    total_venta
)
-- 2. Luego colocas tu Common Table Expression (CTE)
WITH RECURSIVE numeros AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1
    FROM numeros
    WHERE n < 1000
)
-- 3. Finalmente el SELECT
SELECT
    n AS id_venta,
    ((n * 7) % 50) + 1 AS id_empleado,
    ((n * 3) % 10) + 1 AS id_producto,
    
    -- Nota: Cambié el multiplicador aquí (ver Bonus Track abajo)
    ((n * 7) % 5) + 1 AS id_sucursal, 
    
    DATE_ADD('2024-01-01', INTERVAL n DAY) AS fecha_venta,
    ((n * 4) % 9) + 1 AS cantidad,
    
    CASE ((n * 3) % 10) + 1
        WHEN 1 THEN 6500 + (n % 300)
        WHEN 2 THEN 1600 + (n % 200)
        WHEN 3 THEN 350 + (n % 80)
        WHEN 4 THEN 275 + (n % 60)
        WHEN 5 THEN 1200 + (n % 150)
        WHEN 6 THEN 2400 + (n % 250)
        WHEN 7 THEN 3100 + (n % 280)
        WHEN 8 THEN 1800 + (n % 180)
        WHEN 9 THEN 950 + (n % 120)
        WHEN 10 THEN 2200 + (n % 220)
    END AS precio_unitario,
    
    (((n * 4) % 9) + 1) * 
    CASE ((n * 3) % 10) + 1
        WHEN 1 THEN 6500 + (n % 300)
        WHEN 2 THEN 1600 + (n % 200)
        WHEN 3 THEN 350 + (n % 80)
        WHEN 4 THEN 275 + (n % 60)
        WHEN 5 THEN 1200 + (n % 150)
        WHEN 6 THEN 2400 + (n % 250)
        WHEN 7 THEN 3100 + (n % 280)
        WHEN 8 THEN 1800 + (n % 180)
        WHEN 9 THEN 950 + (n % 120)
        WHEN 10 THEN 2200 + (n % 220)
    END AS total_venta
FROM numeros;

SELECT COUNT(*) AS total_registros
FROM ventas;

SELECT
    v.id_venta,
    e.nombre_empleado,
    d.nombre_departamento,
    s.nombre_sucursal,
    p.nombre_producto,
    v.fecha_venta,
    v.cantidad,
    v.precio_unitario,
    v.total_venta
FROM ventas v
INNER JOIN empleados e 
    ON v.id_empleado = e.id_empleado
INNER JOIN departamentos d 
    ON e.id_departamento = d.id_departamento
INNER JOIN sucursales s 
    ON v.id_sucursal = s.id_sucursal
INNER JOIN productos p 
    ON v.id_producto = p.id_producto
ORDER BY v.fecha_venta;


-- Consulta 4. Comparación de cada venta contra la venta anterior del mismo empleado.
select
    e.nombre_empleado as vendedor,
    v.fecha_venta,
    v.total_venta,
    lag(total_venta) over(
		partition by vendedor
        order by id_venta
    ) as venta_anterior
from ventas v
join empleados e on e.id_empleado = v.id_empleado