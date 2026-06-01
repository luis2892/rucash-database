-- ========================================
-- SPRINT 6: SEED DATA
-- ========================================

-- Obtener IDs de usuarios para seed
DO $$
DECLARE
  v_cliente_enzo UUID;
  v_usuario_enzo UUID;
  v_cliente_test UUID;
  v_usuario_test UUID;
  v_marca1_id UUID;
  v_marca2_id UUID;
  v_marca3_id UUID;
  v_producto1_id UUID;
  v_producto2_id UUID;
  v_producto3_id UUID;
  v_meta1_id UUID;
BEGIN

-- ── ENZO@EMPRESA.COM ────────────────────────────────────────────────────────

-- Obtener cliente y usuario
SELECT c.id INTO v_cliente_enzo FROM clientes c
JOIN usuarios u ON u.cliente_id = c.id
WHERE u.email = 'enzo@empresa.com' LIMIT 1;

SELECT id INTO v_usuario_enzo FROM usuarios WHERE email = 'enzo@empresa.com' LIMIT 1;

IF v_cliente_enzo IS NOT NULL AND v_usuario_enzo IS NOT NULL THEN

  -- Insertar marcas
  INSERT INTO marcas (cliente_id, nombre, descripcion, activo)
  VALUES
    (v_cliente_enzo, 'Nike', 'Equipos deportivos premium', true),
    (v_cliente_enzo, 'Adidas', 'Ropa y calzado deportivo', true),
    (v_cliente_enzo, 'Puma', 'Accesorios y ropa deportiva', true)
  ON CONFLICT DO NOTHING;

  -- Obtener IDs de marcas creadas
  SELECT id INTO v_marca1_id FROM marcas WHERE cliente_id = v_cliente_enzo AND nombre = 'Nike' LIMIT 1;
  SELECT id INTO v_marca2_id FROM marcas WHERE cliente_id = v_cliente_enzo AND nombre = 'Adidas' LIMIT 1;
  SELECT id INTO v_marca3_id FROM marcas WHERE cliente_id = v_cliente_enzo AND nombre = 'Puma' LIMIT 1;

  -- Insertar productos
  INSERT INTO productos (
    cliente_id, nombre, codigo_barras, categoria, precio_usd, precio_sol,
    stock_tienda, stock_almacen, nivel_minimo_stock, nivel_maximo_stock,
    marca_id, activo
  ) VALUES
    (v_cliente_enzo, 'Zapatilla Running Nike', 'EAN123456789001', 'Calzado', 120.00, 456.00, 15, 40, 10, 50, v_marca1_id, true),
    (v_cliente_enzo, 'Polo Adidas Azul', 'EAN123456789002', 'Ropa', 45.00, 171.00, 8, 25, 5, 30, v_marca2_id, true),
    (v_cliente_enzo, 'Mochila Puma Gris', 'EAN123456789003', 'Accesorios', 85.00, 323.00, 3, 15, 5, 20, v_marca3_id, true)
  ON CONFLICT DO NOTHING;

  -- Obtener IDs de productos
  SELECT id INTO v_producto1_id FROM productos WHERE cliente_id = v_cliente_enzo AND codigo_barras = 'EAN123456789001' LIMIT 1;
  SELECT id INTO v_producto2_id FROM productos WHERE cliente_id = v_cliente_enzo AND codigo_barras = 'EAN123456789002' LIMIT 1;
  SELECT id INTO v_producto3_id FROM productos WHERE cliente_id = v_cliente_enzo AND codigo_barras = 'EAN123456789003' LIMIT 1;

  -- Insertar alertas de stock
  INSERT INTO alertas_stock (cliente_id, producto_id, tipo, nivel_minimo, nivel_maximo, stock_actual, estado)
  VALUES
    (v_cliente_enzo, v_producto2_id, 'STOCK_BAJO', 5, 30, 8, 'ACTIVA'),
    (v_cliente_enzo, v_producto3_id, 'STOCK_BAJO', 5, 20, 3, 'ACTIVA')
  ON CONFLICT DO NOTHING;

  -- Insertar metas
  INSERT INTO metas (
    cliente_id, usuario_id, nombre, tipo, valor_objetivo, valor_actual,
    porcentaje_cumplimiento, fecha_inicio, fecha_fin, prioridad, estado
  ) VALUES
    (v_cliente_enzo, v_usuario_enzo, 'Vender $5000 este mes', 'VENTA_MENSUAL', 5000.00, 2500.00, 50.00, CURRENT_DATE, (CURRENT_DATE + INTERVAL '30 days'), 'ALTA', 'ACTIVA'),
    (v_cliente_enzo, v_usuario_enzo, 'Ganar $1000 de ganancia', 'GANANCIA', 1000.00, 450.00, 45.00, CURRENT_DATE, (CURRENT_DATE + INTERVAL '30 days'), 'MEDIA', 'ACTIVA'),
    (v_cliente_enzo, v_usuario_enzo, 'Vender $300 hoy', 'VENTA_DIARIA', 300.00, 150.00, 50.00, CURRENT_DATE, CURRENT_DATE, 'BAJA', 'ACTIVA')
  ON CONFLICT DO NOTHING;

END IF;

-- ── TEST@MAIL.COM ──────────────────────────────────────────────────────────

-- Obtener cliente y usuario
SELECT c.id INTO v_cliente_test FROM clientes c
JOIN usuarios u ON u.cliente_id = c.id
WHERE u.email = 'test@mail.com' LIMIT 1;

SELECT id INTO v_usuario_test FROM usuarios WHERE email = 'test@mail.com' LIMIT 1;

IF v_cliente_test IS NOT NULL AND v_usuario_test IS NOT NULL THEN

  -- Insertar marcas
  INSERT INTO marcas (cliente_id, nombre, descripcion, activo)
  VALUES
    (v_cliente_test, 'Samsung', 'Electrónica y tecnología', true),
    (v_cliente_test, 'LG', 'Equipos electrónicos', true)
  ON CONFLICT DO NOTHING;

  -- Obtener IDs de marcas
  SELECT id INTO v_marca1_id FROM marcas WHERE cliente_id = v_cliente_test AND nombre = 'Samsung' LIMIT 1;
  SELECT id INTO v_marca2_id FROM marcas WHERE cliente_id = v_cliente_test AND nombre = 'LG' LIMIT 1;

  -- Insertar productos
  INSERT INTO productos (
    cliente_id, nombre, codigo_barras, categoria, precio_usd, precio_sol,
    stock_tienda, stock_almacen, nivel_minimo_stock, nivel_maximo_stock,
    marca_id, activo
  ) VALUES
    (v_cliente_test, 'Monitor Samsung 24"', 'EAN987654321001', 'Electrónica', 200.00, 760.00, 5, 20, 2, 15, v_marca1_id, true),
    (v_cliente_test, 'TV LG 55" 4K', 'EAN987654321002', 'Electrónica', 600.00, 2280.00, 2, 8, 1, 10, v_marca2_id, true),
    (v_cliente_test, 'Cable HDMI', 'EAN987654321003', 'Accesorios', 15.00, 57.00, 50, 100, 20, 150, NULL, true)
  ON CONFLICT DO NOTHING;

  -- Obtener IDs de productos
  SELECT id INTO v_producto1_id FROM productos WHERE cliente_id = v_cliente_test AND codigo_barras = 'EAN987654321001' LIMIT 1;
  SELECT id INTO v_producto2_id FROM productos WHERE cliente_id = v_cliente_test AND codigo_barras = 'EAN987654321002' LIMIT 1;

  -- Insertar alertas de stock
  INSERT INTO alertas_stock (cliente_id, producto_id, tipo, nivel_minimo, nivel_maximo, stock_actual, estado)
  VALUES
    (v_cliente_test, v_producto1_id, 'STOCK_BAJO', 2, 15, 5, 'ACTIVA'),
    (v_cliente_test, v_producto2_id, 'SIN_STOCK', 1, 10, 2, 'ACTIVA')
  ON CONFLICT DO NOTHING;

  -- Insertar metas
  INSERT INTO metas (
    cliente_id, usuario_id, nombre, tipo, valor_objetivo, valor_actual,
    porcentaje_cumplimiento, fecha_inicio, fecha_fin, prioridad, estado
  ) VALUES
    (v_cliente_test, v_usuario_test, 'Vender $10000 este mes', 'VENTA_MENSUAL', 10000.00, 5000.00, 50.00, CURRENT_DATE, (CURRENT_DATE + INTERVAL '30 days'), 'ALTA', 'ACTIVA'),
    (v_cliente_test, v_usuario_test, 'Ganar $2000 de ganancia', 'GANANCIA', 2000.00, 800.00, 40.00, CURRENT_DATE, (CURRENT_DATE + INTERVAL '30 days'), 'ALTA', 'ACTIVA')
  ON CONFLICT DO NOTHING;

END IF;

END $$;
