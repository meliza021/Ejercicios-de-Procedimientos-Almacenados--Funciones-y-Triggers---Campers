

-- 1. FUNCIÓN: Calcular subtotal de pizza
-- Suma el precio  + ingredientes extra
DELIMITER $$
CREATE FUNCTION fc_calcular_subtotal_pizza(p_pizza_id INT UNSIGNED)
RETURNS DECIMAL(10,2)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE v_precio_base DECIMAL(10,2) DEFAULT 0;
    DECLARE v_precio_ingredientes DECIMAL(10,2) DEFAULT 0;
    DECLARE v_total DECIMAL(10,2) DEFAULT 0;
    
    -- Obtener precio base de la pizza 
    SELECT precio INTO v_precio_base
    FROM producto_presentacion 
    WHERE producto_id = p_pizza_id AND presentacion_id = 2
    LIMIT 1;
    
    -- Si no existe precio base, devolver 0
    IF v_precio_base IS NULL THEN
        SET v_precio_base = 0;
    END IF;
    
  
    SELECT COALESCE(SUM(i.precio), 0) INTO v_precio_ingredientes
    FROM pizza_ingrediente pi
    JOIN ingrediente i ON pi.ingrediente_id = i.id
    WHERE pi.pizza_id = p_pizza_id;
    
    -- Sumar 
    SET v_total = v_precio_base + v_precio_ingredientes;
    
    RETURN v_total;
END$$
DELIMITER ;

-- 2. FUNCIÓN: Calcular descuento por cantidad

DELIMITER $$
CREATE FUNCTION fc_descuento_por_cantidad(p_cantidad INT, p_precio_unitario DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_descuento DECIMAL(10,2) DEFAULT 0;
    
   
    IF p_cantidad >= 5 THEN
        SET v_descuento = (p_precio_unitario * p_cantidad) * 0.10;
    ELSE
        SET v_descuento = 0;
    END IF;
    
    RETURN v_descuento;
END$$
DELIMITER ;

-- 3. FUNCIÓN: Precio final del pedido

DELIMITER $$
CREATE FUNCTION fc_precio_final_pedido(p_pedido_id INT UNSIGNED)
RETURNS DECIMAL(10,2)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE v_total DECIMAL(10,2) DEFAULT 0;
    DECLARE v_subtotal DECIMAL(10,2) DEFAULT 0;
    DECLARE v_descuento DECIMAL(10,2) DEFAULT 0;
    DECLARE v_producto_id INT UNSIGNED;
    DECLARE v_cantidad INT;
    DECLARE v_precio_unitario DECIMAL(10,2);
    DECLARE v_tipo_item VARCHAR(10);
    DECLARE done INT DEFAULT FALSE;
    
    
    DECLARE cur_detalles CURSOR FOR
        SELECT dp.cantidad, dp.tipo_item, 
               COALESCE(dpp.producto_id, 0) as producto_id,
               COALESCE(dpc.combo_id, 0) as combo_id
        FROM detalle_pedido dp
        LEFT JOIN detalle_pedido_producto dpp ON dp.id = dpp.detalle_id
        LEFT JOIN detalle_pedido_combo dpc ON dp.id = dpc.detalle_id
        WHERE dp.pedido_id = p_pedido_id;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur_detalles;
    
    read_loop: LOOP
        FETCH cur_detalles INTO v_cantidad, v_tipo_item, v_producto_id, v_combo_id;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Si es un producto
        IF v_tipo_item = 'producto' THEN
            -- Si es pizza, usar nuestra función especial
            IF v_producto_id IN (SELECT id FROM producto WHERE tipo_producto_id = 2) THEN
                SET v_precio_unitario = fc_calcular_subtotal_pizza(v_producto_id);
            ELSE
                -- Para otros productos, tomar precio de presentación mediana
                SELECT precio INTO v_precio_unitario
                FROM producto_presentacion 
                WHERE producto_id = v_producto_id AND presentacion_id = 2
                LIMIT 1;
                
                IF v_precio_unitario IS NULL THEN
                    SET v_precio_unitario = 0;
                END IF;
            END IF;
            
            -- Calcular subtotal
            SET v_subtotal = v_precio_unitario * v_cantidad;
            
            -- Aplicar descuento si corresponde
            SET v_descuento = fc_descuento_por_cantidad(v_cantidad, v_precio_unitario);
            
            -- Sumar al total
            SET v_total = v_total + v_subtotal - v_descuento;
            
        -- Si es un combo
        ELSEIF v_tipo_item = 'combo' THEN
            SELECT precio INTO v_precio_unitario
            FROM combo 
            WHERE id = v_combo_id;
            
            IF v_precio_unitario IS NULL THEN
                SET v_precio_unitario = 0;
            END IF;
            
            SET v_subtotal = v_precio_unitario * v_cantidad;
            SET v_descuento = fc_descuento_por_cantidad(v_cantidad, v_precio_unitario);
            SET v_total = v_total + v_subtotal - v_descuento;
        END IF;
        
    END LOOP;
    
    CLOSE cur_detalles;
    
    RETURN v_total;
END$$
DELIMITER ;

-- 4. FUNCIÓN: Obtener stock de ingrediente
DELIMITER $$
CREATE FUNCTION fc_obtener_stock_ingrediente(p_ingrediente_id INT UNSIGNED)
RETURNS INT
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE v_stock INT DEFAULT 0;
    
    -- Obtener el stock del ingrediente
    SELECT stock INTO v_stock
    FROM ingrediente 
    WHERE id = p_ingrediente_id;
    
    -- Si no existe el ingrediente, devolver 0
    IF v_stock IS NULL THEN
        SET v_stock = 0;
    END IF;
    
    RETURN v_stock;
END$$
DELIMITER ;

-- 5. FUNCIÓN: Verificar si pizza es popular
DELIMITER $$
CREATE FUNCTION fc_es_pizza_popular(p_pizza_id INT UNSIGNED)
RETURNS INT
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE v_total_pedidos INT DEFAULT 0;
    DECLARE v_es_popular INT DEFAULT 0;
    
    -- Contar cuántas veces se ha pedido esta pizza
    SELECT COALESCE(SUM(dp.cantidad), 0) INTO v_total_pedidos
    FROM detalle_pedido dp
    JOIN detalle_pedido_producto dpp ON dp.id = dpp.detalle_id
    WHERE dpp.producto_id = p_pizza_id
    AND dp.tipo_item = 'producto';
    
    -- Si se ha pedido más de 50 veces, es popular o en este  caso lo cambiare por 5 
    IF v_total_pedidos > 5 THEN
        SET v_es_popular = 1;
    ELSE
        SET v_es_popular = 0;
    END IF;
    
    RETURN v_es_popular;
END$$
DELIMITER ;

--se hacen las consultas para ver si sirvio estas 

-- Probar función 1: 
SELECT fc_calcular_subtotal_pizza(2) as 'Subtotal Pizza Jamón Queso';

-- Probar función 2:
SELECT fc_descuento_por_cantidad(3, 35000) as 'Descuento 3 unidades';
SELECT fc_descuento_por_cantidad(6, 35000) as 'Descuento 6 unidades';

-- Probar función 3:
SELECT fc_precio_final_pedido(1) as 'Total Pedido 1';

-- Probar función 4: 
SELECT fc_obtener_stock_ingrediente(1) as 'Stock Queso';

-- Probar función 5: Pizza popular
SELECT fc_es_pizza_popular(2) as '¿Pizza Popular?';

-- Agregar ingredientes base a la pizza
INSERT INTO pizza_ingrediente (pizza_id, ingrediente_id) VALUES
(2, 1), -- Pizza Jamón Queso tiene Queso
(2, 2); -- Pizza Jamón Queso tiene Bacon (como jamón)
