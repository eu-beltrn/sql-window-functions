-- Es para que use esta base de datos.
USE empresa_window_functions;

-- Ranking salarial por departamento usando CTE.
WITH JerarquiaSalarial AS (
    SELECT 
        d.nombre_departamento,
        e.id_empleado,
        e.nombre_empleado,
        e.puesto,
        e.salario,
        -- Se agrupan salarios idénticos con DENSE_RANK en la misma banda
        -- sin que interfiera la continuidad numérica para el siguiente empleado en caso de existir un empate.
        DENSE_RANK() OVER (
            PARTITION BY e.id_departamento 
            ORDER BY e.salario DESC
        ) AS ranking_salarial_dpto
    FROM empleados e
    INNER JOIN departamentos d 
        ON e.id_departamento = d.id_departamento
)
SELECT 
    nombre_departamento,
    id_empleado,
    nombre_empleado,
    puesto,
    salario,
    ranking_salarial_dpto
FROM JerarquiaSalarial
ORDER BY 
    nombre_departamento ASC, 
    ranking_salarial_dpto ASC,
    -- Es requerido para determinar quién va primero y asegurar consistencia en auditorías
    id_empleado ASC;