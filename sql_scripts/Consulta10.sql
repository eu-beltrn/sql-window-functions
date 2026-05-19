use empresa_window_functions;

-- Consulta 10. Consulta final combinando: RANK(), LAG(), LEAD(), PARTITION BY, ORDER BY
with base_ventas as (
    select
        e.nombre_empleado as vendedor,
        v.fecha_venta,
        v.total_venta,
        v.id_venta, -- incluimos el id para el orden final
        rank() over(
            partition by e.nombre_empleado
            order by v.total_venta desc
        ) as ranking_vendedor,
        lag(v.total_venta) over(
            partition by e.nombre_empleado
            order by v.id_venta
        ) as venta_anterior,
        lead(v.total_venta) over(
            partition by e.nombre_empleado
            order by v.id_venta
        ) as venta_siguiente
    from ventas v
    join empleados e on e.id_empleado = v.id_empleado
),
calculo_diferencias as (
    select 
        vendedor,
        fecha_venta,
        total_venta,
        id_venta,
        ranking_vendedor,
        venta_anterior,
        venta_siguiente,
        (total_venta - venta_anterior) as dif_anterior,
        (venta_siguiente - total_venta) as dif_siguiente
    from base_ventas
)
select 
    vendedor,
    fecha_venta,
    total_venta,
    ranking_vendedor,
    venta_anterior,
    venta_siguiente,
    dif_anterior,
    dif_siguiente,
    case 
        when dif_anterior > 0 then 'crecimiento'
        when dif_anterior < 0 then 'disminución'
        when dif_anterior = 0 then 'estabilidad'
        else 'inicio (sin historial)'
    end as tendencia
from calculo_diferencias
order by vendedor, id_venta; -- aquí ordenamos toda la tabla final cronológicamente



