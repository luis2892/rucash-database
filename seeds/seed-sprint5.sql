-- ========================================
-- SEED DATA - SPRINT 5
-- ========================================

-- Admin Usuario (Luis Félix)
INSERT INTO public.usuarios (cliente_id, email, nombre_completo, password_hash, rol, estado, es_admin_sistema)
VALUES (
  '00000000-0000-0000-0000-000000000001',
  'luis.felix.rosas@gmail.com',
  'Luis Félix',
  '$2b$10$YIVvlP5pLf9y8S1yZmLvkOfMqLfvKLh5QxKlEkZfxQhL6G5kGJDJ2',
  'ADMIN',
  'ACTIVO',
  TRUE
)
ON CONFLICT (email) DO NOTHING;

-- Cliente Test AAA
INSERT INTO public.clientes (nombre, email, ruc, plan, estado)
VALUES ('AAA Tienda', 'aaa@example.com', '12345678901', 'PRO_ANUAL', 'ACTIVO')
ON CONFLICT (ruc) DO NOTHING;

-- Empresa Config para AAA
INSERT INTO public.empresas_config (cliente_id, moneda_preferida, provincia, ciudad, industria)
SELECT id, 'USD', 'Lima', 'Lima', 'Retail'
FROM public.clientes WHERE ruc = '12345678901'
ON CONFLICT (cliente_id) DO NOTHING;

-- Suscripción para AAA
INSERT INTO public.suscripciones (cliente_id, plan, fecha_vencimiento, estado)
SELECT id, 'PRO_ANUAL', '2026-12-31', 'ACTIVO'
FROM public.clientes WHERE ruc = '12345678901'
ON CONFLICT (cliente_id) DO NOTHING;

-- Cliente Test BBB (vence pronto)
INSERT INTO public.clientes (nombre, email, ruc, plan, estado)
VALUES ('BBB Negocio', 'bbb@example.com', '98765432109', 'PRO_MENSUAL', 'ACTIVO')
ON CONFLICT (ruc) DO NOTHING;

-- Empresa Config para BBB
INSERT INTO public.empresas_config (cliente_id, moneda_preferida, provincia, ciudad, industria)
SELECT id, 'USD', 'Arequipa', 'Arequipa', 'Servicios'
FROM public.clientes WHERE ruc = '98765432109'
ON CONFLICT (cliente_id) DO NOTHING;

-- Suscripción para BBB (próxima a vencer)
INSERT INTO public.suscripciones (cliente_id, plan, fecha_vencimiento, estado)
SELECT id, 'PRO_MENSUAL', '2026-06-15', 'ACTIVO_PRONTO_VENCE'
FROM public.clientes WHERE ruc = '98765432109'
ON CONFLICT (cliente_id) DO NOTHING;

-- Config Sistema
INSERT INTO public.config_sistema (nombre_empresa, numero_whatsapp, email_soporte, precio_pro_mensual, precio_pro_anual)
VALUES ('TARUK', '+51 999 999 999', 'soporte@taruk.com', 50, 500)
ON CONFLICT DO NOTHING;

-- Proveedores para AAA
INSERT INTO public.proveedores (cliente_id, nombre, email, telefono, ciudad, ruc_proveedor)
SELECT id, 'Proveedor XYZ', 'xyz@prov.com', '951234567', 'Lima', '98765432100'
FROM public.clientes WHERE ruc = '12345678901'
ON CONFLICT DO NOTHING;

INSERT INTO public.proveedores (cliente_id, nombre, email, telefono, ciudad)
SELECT id, 'Distribuidor ABC', 'abc@dist.com', '952345678', 'Arequipa'
FROM public.clientes WHERE ruc = '12345678901'
ON CONFLICT DO NOTHING;

-- Deudas para AAA
INSERT INTO public.deudas (cliente_id, concepto, monto_usd, interes_anual, fecha_vencimiento, acreedor, estado)
SELECT id, 'Deuda proveedor XYZ', 5000, 0, '2026-07-15', 'Proveedor XYZ', 'ACTIVA'
FROM public.clientes WHERE ruc = '12345678901'
ON CONFLICT DO NOTHING;

INSERT INTO public.deudas (cliente_id, concepto, monto_usd, interes_anual, fecha_vencimiento, acreedor, estado)
SELECT id, 'Préstamo bancario', 20000, 8, '2026-12-31', 'Banco del Perú', 'ACTIVA'
FROM public.clientes WHERE ruc = '12345678901'
ON CONFLICT DO NOTHING;

-- Cuentas para AAA
INSERT INTO public.cuentas (cliente_id, banco, tipo_cuenta, numero_cuenta, saldo, moneda)
SELECT id, 'Banco del Perú', 'CORRIENTE', '9876543210', 15000, 'USD'
FROM public.clientes WHERE ruc = '12345678901'
ON CONFLICT DO NOTHING;

-- Transacciones para AAA
INSERT INTO public.transacciones_financieras (cuenta_id, tipo, monto, concepto, saldo_anterior, saldo_nuevo)
SELECT id, 'INGRESO', 5000, 'Venta del día', 10000, 15000
FROM public.cuentas WHERE numero_cuenta = '9876543210'
ON CONFLICT DO NOTHING;
