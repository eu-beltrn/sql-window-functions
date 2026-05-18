use empresa_window_functions;

-- Consulta 4. Comparación de cada venta contra la venta anterior del mismo empleado.
select
    e.nombre_empleado as vendedor,
    v.fecha_venta,
    v.total_venta,
    lag(v.total_venta) over(
        partition by e.nombre_empleado
        order by v.id_venta
    ) as venta_anterior
from ventas v
join empleados e on e.id_empleado = v.id_empleado;
