-- Es para que use esta base de datos.
USE empresa_window_functions;

-- Ranking salarial por departamento.
SELECT 
    d.nombre_departamento,
    e.id_empleado,
    e.nombre_empleado,
    e.puesto,
    e.salario,
    -- Se agrupan salarios identicos con DENSE_RANK en la misma banda
    -- sin que interfiera la continuidad numérica para el siguiente empleado en caso existir un empate.
    DENSE_RANK() OVER (
        PARTITION BY e.id_departamento 
        ORDER BY e.salario DESC
    ) AS ranking_salarial_dpto
FROM empleados e
INNER JOIN departamentos d 
    ON e.id_departamento = d.id_departamento
ORDER BY 
    d.nombre_departamento ASC, 
    ranking_salarial_dpto ASC,
    -- Es requerido para determinar quien va primero y asegurar consistencia en auditorías
    e.id_empleado ASC;