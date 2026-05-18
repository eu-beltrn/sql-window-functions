use empresa_window_functions;

-- Consulta 5. Comparación de cada venta contra la venta siguiente del mismo empleado.
select 
    vendedor,
    fecha_venta,
    total_venta,
    venta_siguiente,
    (venta_siguiente - total_venta) as dif_siguiente
from (
    select
        e.nombre_empleado as vendedor,
        v.fecha_venta,
        v.total_venta,
        lead(v.total_venta) over(
            partition by e.nombre_empleado
            order by v.id_venta
        ) as venta_siguiente
    from ventas v
    join empleados e on e.id_empleado = v.id_empleado
) as t;