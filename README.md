# 🍕 Ejercicios de Procedimientos Almacenados, Funciones y Triggers - Base de Datos Pizzas

Este proyecto contiene una serie de ejercicios prácticos orientados a fortalecer el uso de **procedimientos almacenados**, **funciones** y **triggers** en MySQL, utilizando como contexto una base de datos de gestión de pedidos de pizzas.

---

## 🧩 Estructura del Proyecto

### 📂 Procedimientos Almacenados

1. **`ps_add_pizza_con_ingredientes`**  
   Inserta una nueva pizza y sus ingredientes en las tablas correspondientes.

2. **`ps_actualizar_precio_pizza`**  
   Actualiza el precio de una pizza con validación previa.

3. **`ps_generar_pedido`**  
   Inserta un pedido completo (con detalles y pizzas) dentro de una transacción.

4. **`ps_cancelar_pedido`**  
   Cancela un pedido, elimina sus detalles y devuelve la cantidad de líneas eliminadas.

5. **`ps_facturar_pedido`**  
   Genera una factura para un pedido, calculando su total.

---

### 🧮 Funciones

1. **`fc_calcular_subtotal_pizza`**  
   Calcula el subtotal de una pizza (precio base + ingredientes).

2. **`fc_descuento_por_cantidad`**  
   Aplica un 10% de descuento si la cantidad es mayor o igual a 5.

3. **`fc_precio_final_pedido`**  
   Calcula el precio final de un pedido aplicando descuentos.

4. **`fc_obtener_stock_ingrediente`**  
   Devuelve el stock disponible de un ingrediente.

5. **`fc_es_pizza_popular`**  
   Determina si una pizza es popular (más de 50 pedidos).

---

### ⚙️ Triggers

1. **`tg_before_insert_detalle_pedido`**  
   Valida que la cantidad sea mayor o igual a 1 antes de insertar.

2. **`tg_after_insert_detalle_pedido_pizza`**  
   Descuenta del stock los ingredientes usados en una pizza.

3. **`tg_after_update_pizza_precio`**  
   Guarda en auditoría el cambio de precio de una pizza.

4. **`tg_before_delete_pizza`**  
   Impide eliminar una pizza que esté en un pedido.

5. **`tg_after_insert_factura`**  
   Marca el pedido asociado como facturado.

6. **`tg_after_delete_detalle_pedido_pizza`**  
   Restaura el stock de los ingredientes al eliminar una pizza de un pedido.

7. **`tg_after_update_ingrediente_stock`**  
   Crea una notificación si el stock de un ingrediente baja de 10 unidades.

---

## 🗄️ Base de Datos

La base de datos utilizada se llama `pizzas`, e incluye entidades como:

- `cliente`, `pedido`, `factura`
- `producto`, `presentacion`, `combo`, `ingrediente`
- Tablas intermedias como `detalle_pedido`, `detalle_pedido_producto`, `detalle_pedido_combo`, etc.

Incluye datos precargados para facilitar las pruebas de los procedimientos y funciones.

---

## ▶️ Cómo usar

1. **Importa la base de datos** desde el archivo `.sql` incluido.
2. **Crea los procedimientos, funciones y triggers** según los ejercicios.
3. **Ejecuta pruebas** usando `CALL`, `SELECT`, y manipulaciones en las tablas.

---

## 🚀 Objetivos de Aprendizaje

- Aplicar procedimientos almacenados para operaciones complejas.
- Validar reglas de negocio con funciones y triggers.
- Utilizar transacciones para mantener la integridad de los datos.
- Automatizar procesos con eventos reactivos en la base de datos.

---

## 📄 Licencia

Este proyecto es solo para fines educativos.

---

## ✨ Autor

Elaborado como parte de ejercicios prácticos de SQL Avanzado.

---
