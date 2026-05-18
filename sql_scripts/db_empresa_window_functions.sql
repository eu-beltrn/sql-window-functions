-- 1. PREPARACIÓN DE LA BASE DE DATOS
-- "CREATE DATABASE IF NOT EXISTS" asegura que no dé error si la base ya existe.
-- "CHARACTER SET utf8mb4" le dice a la base de datos que acepte tildes, letras ñ, e incluso emojis sin que se rompa el texto.
CREATE DATABASE IF NOT EXISTS empresa_window_functions
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

-- Es para que use esta base de datos.
USE empresa_window_functions;

-- 2. IDEMPOTENCIA
-- Se borran en orden inverso a cómo se crearon para que no exista problemas con las fk
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS empleados;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS sucursales;
DROP TABLE IF EXISTS departamentos;

-- 3. CREACIÓN DE TABLAS
-- Se usa "ENGINE=InnoDB" en todas las tablas porque es el motor que soporta 
-- las transacciones de seguridad y las relaciones entre tabla

-- Evita que el campo no esté vacío con NOT NULL
CREATE TABLE departamentos (
    id_departamento INT PRIMARY KEY,
    nombre_departamento VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE sucursales (
    id_sucursal INT PRIMARY KEY,
    nombre_sucursal VARCHAR(100) NOT NULL,
    ciudad VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE empleados (
    id_empleado INT PRIMARY KEY,
    nombre_empleado VARCHAR(100) NOT NULL,
    puesto VARCHAR(100) NOT NULL,
    id_departamento INT NOT NULL,
    id_sucursal INT NOT NULL,
    -- CHECK (salario >= 0) impide que por error se ingrese un salario negativo.
    salario DECIMAL(10,2) NOT NULL CHECK (salario >= 0),
    fecha_ingreso DATE NOT NULL,
    
    -- ON UPDATE CASCADE por si hay un cambio en un dato, se actualice en cascada junto con sus fk
    FOREIGN KEY (id_departamento) REFERENCES departamentos(id_departamento) ON UPDATE CASCADE,
    FOREIGN KEY (id_sucursal) REFERENCES sucursales(id_sucursal) ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE productos (
    id_producto INT PRIMARY KEY,
    nombre_producto VARCHAR(100) NOT NULL,
    categoria VARCHAR(100) NOT NULL,
    -- los precios base no pueden ser un valor negativo.
    precio_base DECIMAL(10,2) NOT NULL CHECK (precio_base >= 0)
) ENGINE=InnoDB;

CREATE TABLE ventas (
    id_venta INT PRIMARY KEY,
    id_empleado INT NOT NULL,
    id_producto INT NOT NULL,
    id_sucursal INT NOT NULL,
    fecha_venta DATE NOT NULL,
    -- No se puede vender cantidad 0 o negativa, ni a precios negativos.
    cantidad INT NOT NULL CHECK (cantidad > 0),
    precio_unitario DECIMAL(10,2) NOT NULL CHECK (precio_unitario >= 0),
    total_venta DECIMAL(10,2) NOT NULL CHECK (total_venta >= 0),
    
    FOREIGN KEY (id_empleado) REFERENCES empleados(id_empleado) ON UPDATE CASCADE,
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto) ON UPDATE CASCADE,
    FOREIGN KEY (id_sucursal) REFERENCES sucursales(id_sucursal) ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 4. INSERTAR DATOS
-- START TRANSACTION agrupa todas las inserciones que vienen a continuación en un solo bloque.
-- Esto hace que el guardado sea rapido y seguro, permitiendo que no se guarde nada incompleto.
START TRANSACTION;

INSERT INTO departamentos (id_departamento, nombre_departamento) VALUES
(1, 'Ventas'),
(2, 'Recursos Humanos'),
(3, 'Tecnologia'),
(4, 'Finanzas'),
(5, 'Marketing');

INSERT INTO sucursales (id_sucursal, nombre_sucursal, ciudad) VALUES
(1, 'Sucursal Central', 'Guatemala'),
(2, 'Sucursal Norte', 'Mixco'),
(3, 'Sucursal Sur', 'Villa Nueva'),
(4, 'Sucursal Oriente', 'Santa Catarina Pinula'),
(5, 'Sucursal Occidente', 'Antigua Guatemala');

INSERT INTO empleados (id_empleado, nombre_empleado, puesto, id_departamento, id_sucursal, salario, fecha_ingreso) VALUES
(1, 'Empleado 1', 'Vendedor Senior', 1, 1, 5200, '2022-01-10'),
(2, 'Empleado 2', 'Vendedor Junior', 1, 2, 4300, '2022-02-15'),
(3, 'Empleado 3', 'Analista RH', 2, 3, 6100, '2021-03-12'),
(4, 'Empleado 4', 'Soporte Tecnico', 3, 4, 5800, '2023-04-20'),
(5, 'Empleado 5', 'Contador', 4, 5, 7200, '2020-05-18'),
(6, 'Empleado 6', 'Marketing Digital', 5, 1, 6500, '2021-06-25'),
(7, 'Empleado 7', 'Vendedor Senior', 1, 2, 5400, '2022-07-13'),
(8, 'Empleado 8', 'Vendedor Junior', 1, 3, 4100, '2023-08-09'),
(9, 'Empleado 9', 'Analista RH', 2, 4, 6000, '2020-09-11'),
(10, 'Empleado 10', 'Soporte Tecnico', 3, 5, 5700, '2022-10-21'),
(11, 'Empleado 11', 'Vendedor Senior', 1, 1, 5600, '2021-01-14'),
(12, 'Empleado 12', 'Vendedor Junior', 1, 2, 4200, '2023-02-17'),
(13, 'Empleado 13', 'Analista Financiero', 4, 3, 7600, '2020-03-19'),
(14, 'Empleado 14', 'Diseñador Grafico', 5, 4, 5900, '2022-04-22'),
(15, 'Empleado 15', 'Programador', 3, 5, 8500, '2021-05-30'),
(16, 'Empleado 16', 'Vendedor Senior', 1, 1, 5300, '2023-06-04'),
(17, 'Empleado 17', 'Vendedor Junior', 1, 2, 4000, '2022-07-16'),
(18, 'Empleado 18', 'Analista RH', 2, 3, 6200, '2021-08-28'),
(19, 'Empleado 19', 'Soporte Tecnico', 3, 4, 5900, '2020-09-05'),
(20, 'Empleado 20', 'Contador', 4, 5, 7100, '2023-10-10'),
(21, 'Empleado 21', 'Vendedor Senior', 1, 1, 5750, '2022-01-18'),
(22, 'Empleado 22', 'Vendedor Junior', 1, 2, 4250, '2023-02-22'),
(23, 'Empleado 23', 'Analista RH', 2, 3, 6050, '2021-03-27'),
(24, 'Empleado 24', 'Programador', 3, 4, 8800, '2020-04-13'),
(25, 'Empleado 25', 'Marketing Digital', 5, 5, 6700, '2022-05-09'),
(26, 'Empleado 26', 'Vendedor Senior', 1, 1, 5500, '2021-06-11'),
(27, 'Empleado 27', 'Vendedor Junior', 1, 2, 4150, '2023-07-19'),
(28, 'Empleado 28', 'Contador', 4, 3, 7300, '2020-08-21'),
(29, 'Empleado 29', 'Soporte Tecnico', 3, 4, 6000, '2022-09-15'),
(30, 'Empleado 30', 'Diseñador Grafico', 5, 5, 6100, '2021-10-17'),
(31, 'Empleado 31', 'Vendedor Senior', 1, 1, 5800, '2023-01-12'),
(32, 'Empleado 32', 'Vendedor Junior', 1, 2, 4350, '2022-02-18'),
(33, 'Empleado 33', 'Analista RH', 2, 3, 6300, '2021-03-24'),
(34, 'Empleado 34', 'Programador', 3, 4, 9000, '2020-04-29'),
(35, 'Empleado 35', 'Analista Financiero', 4, 5, 7800, '2022-05-06'),
(36, 'Empleado 36', 'Vendedor Senior', 1, 1, 5900, '2021-06-08'),
(37, 'Empleado 37', 'Vendedor Junior', 1, 2, 4400, '2023-07-14'),
(38, 'Empleado 38', 'Marketing Digital', 5, 3, 6900, '2022-08-20'),
(39, 'Empleado 39', 'Soporte Tecnico', 3, 4, 6150, '2021-09-25'),
(40, 'Empleado 40', 'Contador', 4, 5, 7400, '2020-10-30'),
(41, 'Empleado 41', 'Vendedor Senior', 1, 1, 6000, '2023-01-05'),
(42, 'Empleado 42', 'Vendedor Junior', 1, 2, 4450, '2022-02-10'),
(43, 'Empleado 43', 'Analista RH', 2, 3, 6400, '2021-03-15'),
(44, 'Empleado 44', 'Programador', 3, 4, 9200, '2020-04-20'),
(45, 'Empleado 45', 'Marketing Digital', 5, 5, 7000, '2022-05-25'),
(46, 'Empleado 46', 'Vendedor Senior', 1, 1, 6100, '2021-06-30'),
(47, 'Empleado 47', 'Vendedor Junior', 1, 2, 4500, '2023-07-07'),
(48, 'Empleado 48', 'Analista Financiero', 4, 3, 7900, '2022-08-16'),
(49, 'Empleado 49', 'Soporte Tecnico', 3, 4, 6250, '2021-09-23'),
(50, 'Empleado 50', 'Contador', 4, 5, 7600, '2020-10-12');

INSERT INTO productos (id_producto, nombre_producto, categoria, precio_base) VALUES
(1, 'Laptop Empresarial', 'Tecnologia', 6500),
(2, 'Monitor LED', 'Tecnologia', 1600),
(3, 'Teclado Inalambrico', 'Accesorios', 350),
(4, 'Mouse Ergonomico', 'Accesorios', 275),
(5, 'Silla Ejecutiva', 'Mobiliario', 1200),
(6, 'Escritorio Modular', 'Mobiliario', 2400),
(7, 'Impresora Laser', 'Tecnologia', 3100),
(8, 'Router Empresarial', 'Redes', 1800),
(9, 'Camara Seguridad', 'Seguridad', 950),
(10, 'Biometrico Acceso', 'Seguridad', 2200);

-- 5. GENERACIÓN MASIVA DE VENTAS
-- Aumentamos el límite de repeticiones que puede hacer a 10000 para asegurarnos de que nos deje generar 1000 ventas de prueba sin interrumpirse.
SET SESSION cte_max_recursion_depth = 10000;

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
-- "WITH RECURSIVE" crea una lista temporal llamada "numeros" que empieza en el 1 y va sumando +1 hasta llegar a 1000.
WITH RECURSIVE numeros AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1
    FROM numeros
    WHERE n < 1000
)
-- Con la lista de 1000 números generada, usamos operaciones matemáticas con residuo (%) 
-- y así simular qué empleado vendió, qué producto, a qué precio y la fecha, dándole variedad a los datos automáticamente.
SELECT
    n AS id_venta,
    ((n * 7) % 50) + 1 AS id_empleado,
    ((n * 3) % 10) + 1 AS id_producto,
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

-- COMMIT le dice al motor de la base de datos que todo salió bien, y que ya puede escribir todo el paquete en el disco duro".
COMMIT;

-- 6. ÍNDICES
-- Crear un índice permite que la base de datos encuentre ventas por fecha o empleados por departamento a una mayor velocidad, sin revisar fila por fila.
CREATE INDEX idx_ventas_fecha ON ventas(fecha_venta);
CREATE INDEX idx_empleados_departamento ON empleados(id_departamento);

-- 7. CONSULTAS DE PRUEBA Y VERIFICACIÓN
-- Esta consulta cuenta todas las filas creadas para asegurarnos de que la recursión hizo las 1000 ventas exitosamente.
SELECT COUNT(*) AS total_registros
FROM ventas;

-- Esta es la consulta muestra datos en formato mucho mas detallado.
-- Cruza la información de las diferentes tablas basándose en las llaves primarias y foráneas.
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