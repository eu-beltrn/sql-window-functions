use empresa_window_functions;

-- Consulta 6. Diferencia entre venta actual y venta anterior por empleado.
select 
    vendedor,
    fecha_venta,
    total_venta,
    venta_anterior,
    (total_venta - venta_anterior) as dif_anterior
from (
    select
        e.nombre_empleado as vendedor,
        v.fecha_venta,
        v.total_venta,
        lag(v.total_venta) over(
            partition by e.nombre_empleado
            order by v.id_venta
        ) as venta_anterior
    from ventas v
    join empleados e on e.id_empleado = v.id_empleado
) as t;


