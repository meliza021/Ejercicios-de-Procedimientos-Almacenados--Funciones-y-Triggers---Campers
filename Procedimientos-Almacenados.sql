--ACTIVIDAD 1

DELIMITER //

CREATE PROCEDURE ps_add_pizza_simple(
    IN p_nombre VARCHAR(100),
    IN p_precio DECIMAL(10,2),
    IN p_ingredientes TEXT,
    IN p_presentacion_id INT UNSIGNED
)
BEGIN
    DECLARE v_pizza_id INT UNSIGNED;
    
 
    IF p_presentacion_id IS NULL THEN
        SET p_presentacion_id = 2;
    END IF;
    

    -- Validaciones básicas
    IF p_precio <= 0 OR p_nombre IS NULL OR TRIM(p_nombre) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Datos inválidos';
    END IF;
    
    -- Crear la pizza
    INSERT INTO producto (nombre, tipo_producto_id) VALUES (p_nombre, 2);
    SET v_pizza_id = LAST_INSERT_ID();
    
    -- Asignar precio
    INSERT INTO producto_presentacion (producto_id, presentacion_id, precio) 
    VALUES (v_pizza_id, p_presentacion_id, p_precio);
    
    -- Agregar ingredientes (si los hay)
    IF p_ingredientes IS NOT NULL AND TRIM(p_ingredientes) != '' THEN
        SET @sql = CONCAT(
            'INSERT IGNORE INTO pizza_ingrediente (pizza_id, ingrediente_id) ',
            'SELECT ', v_pizza_id, ', id FROM ingrediente WHERE id IN (', p_ingredientes, ')'
        );
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
    
    -- Mostrar resultado
    SELECT v_pizza_id as pizza_id, p_nombre as nombre, 'Creada exitosamente' as mensaje;
    
END //

DELIMITER ;

-- practica

-- Pizza hawaiana mediana con queso(1) y bacon(2)
CALL ps_add_pizza_simple('Pizza Hawaiana', 45000, '1,2', 2);

-- Pizza suprema con todos los ingredientes  
CALL ps_add_pizza_simple('Pizza Suprema', 65000, '1,2,3', 3);

-- Pizza simple sin ingredientes extra (presentación por defecto)
CALL ps_add_pizza_simple('Pizza Simple', 28000, NULL, NULL);
*/






--ACTIVIDAD 2

-- Procedimiento para actualizar precio de pizza
DELIMITER //

CREATE PROCEDURE ps_actualizar_precio_pizza(
    IN p_pizza_id INT UNSIGNED,
    IN p_nuevo_precio DECIMAL(10,2)
)
BEGIN
    -- precio sea mayor que 0
    IF p_nuevo_precio <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El precio debe ser mayor que 0';
    END IF;
    
    -- e la pizza existe
    IF NOT EXISTS (SELECT 1 FROM producto WHERE id = p_pizza_id AND tipo_producto_id = 2) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La pizza especificada no existe';
    END IF;
    
    -- Actualizar el precio (asumiendo presentación mediana por defecto)
    UPDATE producto_presentacion 
    SET precio = p_nuevo_precio 
    WHERE producto_id = p_pizza_id;
    
    -- Mostrar resultado
    SELECT 
        p_pizza_id as pizza_id,
        p_nuevo_precio as nuevo_precio,
        'Precio actualizado exitosamente' as mensaje;
    
END //

DELIMITER ;


-- PRUEVAS DEL PROCEDIMIENTO ps_actualizar_precio_pizza

-- Actualizar precio de la pizza con ID 2 a $50,000
CALL ps_actualizar_precio_pizza(2, 50000);

-- Actualizar precio de la pizza con ID 4 a $42,500
CALL ps_actualizar_precio_pizza(4, 42500);

-- ESTE NO SERVIRA
CALL ps_actualizar_precio_pizza(2, -100);

-- Esto dará error si la pizza no existe
CALL ps_actualizar_precio_pizza(999, 30000);








--actividad 3
DELIMITER //

DROP PROCEDURE IF EXISTS ps_pedido_simple_json //

CREATE PROCEDURE ps_pedido_simple_json(
    IN p_cliente_id INT,
    IN p_pizza_id INT,
    IN p_cantidad INT,
    IN p_presentacion_id INT,
    IN p_metodo_pago_id INT
)
BEGIN
    DECLARE v_pedido_id INT;
    DECLARE v_precio DECIMAL(10,2);
    DECLARE v_total DECIMAL(10,2);
    
    -- Obtener precio
    SELECT precio INTO v_precio 
    FROM producto_presentacion 
    WHERE producto_id = p_pizza_id AND presentacion_id = p_presentacion_id;
    
    SET v_total = v_precio * p_cantidad;
    
    -- Crear pedido
    INSERT INTO pedido (cliente_id, fecha, metodo_pago_id, total) 
    VALUES (p_cliente_id, NOW(), p_metodo_pago_id, v_total);
    
    SET v_pedido_id = LAST_INSERT_ID();
    
    -- Agregar detalle
    INSERT INTO detalle_pedido (pedido_id, producto_id, cantidad, precio_unitario, subtotal)
    VALUES (v_pedido_id, p_pizza_id, p_cantidad, v_precio, v_total);
    
    -- Agregar detalle pizza
    INSERT INTO detalle_pedido_pizza (detalle_pedido_id, presentacion_id)
    VALUES (LAST_INSERT_ID(), p_presentacion_id);
    
    SELECT v_pedido_id as pedido_id, v_total as total, 'Pedido creado' as mensaje;
END //

DELIMITER ;
CALL ps_pedido_simple_json(1, 2, 2, 2, 1);



