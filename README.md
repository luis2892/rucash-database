# RUCASH Database

<div align="center">

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-17-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-Cloud-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)

**Schema y migraciones de base de datos para RUCASH**

</div>

---

## Proyecto Supabase

| Campo | Valor |
|---|---|
| Nombre | `rucash-db` |
| Región | `sa-east-1` (São Paulo) |
| Engine | PostgreSQL 17 |

---

## Tablas

### `clientes`
Empresas/tiendas registradas en RUCASH (multi-tenant).

| Columna | Tipo | Descripción |
|---|---|---|
| `id` | UUID PK | Identificador único |
| `nombre` | VARCHAR | Nombre de la tienda |
| `email` | VARCHAR | Email de contacto |
| `ruc` | VARCHAR | RUC empresarial |
| `plan` | ENUM | `BASICO`, `PRO`, `EMPRESA` |
| `estado` | ENUM | `PRUEBA`, `ACTIVO`, `VENCIDO` |
| `tipo_cambio_manual` | DECIMAL | Tipo de cambio USD→SOL |

### `usuarios`
Usuarios por cliente con roles.

| Columna | Tipo | Descripción |
|---|---|---|
| `id` | UUID PK | Identificador único |
| `cliente_id` | UUID FK | Referencia a `clientes` |
| `email` | VARCHAR UNIQUE | Email de login |
| `password_hash` | TEXT | bcrypt hash |
| `rol` | ENUM | `ADMIN`, `VENDEDOR`, `ALMACENERO` |
| `estado` | ENUM | `ACTIVO`, `INACTIVO`, `SUSPENDIDO` |

### `productos`
Catálogo de productos por cliente.

| Columna | Tipo | Descripción |
|---|---|---|
| `id` | UUID PK | Identificador único |
| `cliente_id` | UUID FK | Referencia a `clientes` |
| `nombre` | VARCHAR | Nombre del producto |
| `codigo_barras` | VARCHAR | EAN/código interno |
| `categoria` | VARCHAR | Categoría del producto |
| `precio_usd` | DECIMAL | Precio en dólares |
| `precio_sol` | DECIMAL | Precio en soles |
| `costo_usd` | DECIMAL | Costo de compra |
| `stock_tienda` | INT | Unidades en tienda |
| `stock_almacen` | INT | Unidades en almacén |
| `nivel_minimo_stock` | INT | Umbral de alerta |
| `discontinuado` | BOOLEAN | Fuera de catálogo |
| `proveedor` | VARCHAR | Nombre del proveedor |

### `categorias`
Categorías de productos por cliente.

| Columna | Tipo | Descripción |
|---|---|---|
| `id` | UUID PK | Identificador único |
| `cliente_id` | UUID FK | Referencia a `clientes` |
| `nombre` | VARCHAR | Nombre de la categoría |
| `icono` | TEXT | Emoji o URL de icono |
| `color` | VARCHAR(7) | Color hexadecimal |
| `orden` | INT | Posición de ordenamiento |

### `ventas`
Transacciones de venta.

| Columna | Tipo | Descripción |
|---|---|---|
| `id` | UUID PK | Identificador único |
| `cliente_id` | UUID FK | Referencia a `clientes` |
| `usuario_id` | UUID FK | Vendedor |
| `moneda` | ENUM | `USD`, `SOL` |
| `subtotal` | DECIMAL | Sin IGV |
| `impuesto` | DECIMAL | IGV 18% |
| `total` | DECIMAL | Con IGV |
| `metodo_pago` | ENUM | `EFECTIVO`, `TARJETA`, `YAPE`, `PLIN` |
| `estado` | ENUM | `COMPLETADA`, `ANULADA`, `PENDIENTE` |

### `venta_items`
Líneas de detalle de cada venta.

| Columna | Tipo | Descripción |
|---|---|---|
| `venta_id` | UUID FK | Referencia a `ventas` |
| `producto_id` | UUID FK | Referencia a `productos` |
| `cantidad` | INT | Unidades vendidas |
| `precio_unitario` | DECIMAL | Precio al momento de venta |
| `subtotal` | DECIMAL | cantidad × precio |

### `auditoria_productos`
Historial de cambios en productos.

| Columna | Tipo | Descripción |
|---|---|---|
| `producto_id` | UUID FK | Producto modificado |
| `usuario_id` | UUID FK | Quién hizo el cambio |
| `accion` | VARCHAR | `CREATE`, `UPDATE`, `DELETE`, `RESTOCK` |
| `campo_modificado` | VARCHAR | Campo que cambió |
| `valor_anterior` | TEXT | Valor antes del cambio |
| `valor_nuevo` | TEXT | Valor después |

### `historial_stock`
Movimientos de stock (entradas/salidas).

| Columna | Tipo | Descripción |
|---|---|---|
| `producto_id` | UUID FK | Producto afectado |
| `tipo` | VARCHAR | `VENTA`, `COMPRA`, `AJUSTE`, `DEVOLUCION` |
| `cantidad` | INT | Positivo=entrada, negativo=salida |
| `stock_anterior` | INT | Stock antes del movimiento |
| `stock_nuevo` | INT | Stock después |
| `ubicacion` | VARCHAR | `tienda` o `almacen` |

### Tablas Auth

| Tabla | Descripción |
|---|---|
| `user_2fa` | Configuración TOTP por usuario |
| `user_sessions` | Sesiones activas con device info |
| `password_resets` | Tokens de reset de contraseña |
| `security_events` | Log de eventos de seguridad |
| `alertas_stock` | Alertas de stock bajo/sin stock |

---

## Seguridad

Todas las tablas tienen **Row Level Security (RLS)** habilitado. Los usuarios solo pueden leer y modificar datos de su propio `cliente_id`.

---

## Índices de Rendimiento

```sql
idx_productos_cliente_id
idx_productos_categoria
idx_productos_discontinuado
idx_ventas_cliente_id
idx_ventas_usuario_id
idx_auditoria_productos_cliente_id
idx_auditoria_productos_producto_id
idx_historial_stock_cliente_id
idx_historial_stock_producto_id
idx_alertas_stock_estado
```

---

## Evolución del Schema

| Sprint | Tablas nuevas |
|---|---|
| Sprint 1 | `clientes`, `usuarios`, `password_resets` |
| Sprint 2 | `user_2fa`, `user_sessions`, `security_events` |
| Sprint 3 | `productos`, `ventas`, `venta_items` |
| Sprint 4 | `categorias`, `auditoria_productos`, `historial_stock`, `alertas_stock` |
| Sprint 5 | Tablas financiero — 🔜 |

---

<div align="center">
  <sub>Desarrollado por <strong>Luis Felix Rosas</strong> · TARUK Soluciones Tecnológicas · 2026</sub>
</div>
