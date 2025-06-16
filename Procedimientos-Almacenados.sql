

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

