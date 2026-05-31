-- ========================================
-- SPRINT 5: REGISTRO & FINANCIERO BASE & CONFIGURACIÓN ADMIN
-- ========================================

-- 5.1: TABLA EMPRESAS_CONFIG
CREATE TABLE IF NOT EXISTS public.empresas_config (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  cliente_id UUID REFERENCES public.clientes(id) UNIQUE,
  moneda_preferida VARCHAR DEFAULT 'USD',
  logo_url VARCHAR,
  provincia VARCHAR,
  ciudad VARCHAR,
  industria VARCHAR,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_empresas_config_cliente_id ON public.empresas_config(cliente_id);

ALTER TABLE public.empresas_config ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Usuarios ven su propia empresa config"
  ON public.empresas_config FOR SELECT
  USING (cliente_id IN (SELECT cliente_id FROM public.usuarios WHERE id = auth.uid()));

CREATE POLICY "Usuarios pueden actualizar su propia empresa config"
  ON public.empresas_config FOR UPDATE
  USING (cliente_id IN (SELECT cliente_id FROM public.usuarios WHERE id = auth.uid()))
  WITH CHECK (cliente_id IN (SELECT cliente_id FROM public.usuarios WHERE id = auth.uid()));

-- 5.2: TABLAS SUSCRIPCIONES & LICENCIAS
CREATE TABLE IF NOT EXISTS public.suscripciones (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  cliente_id UUID REFERENCES public.clientes(id) UNIQUE,
  plan VARCHAR NOT NULL DEFAULT 'HOBBY_MENSUAL' CHECK (plan IN ('HOBBY_MENSUAL', 'PRO_MENSUAL', 'PRO_ANUAL', 'ENTERPRISE_MENSUAL', 'ENTERPRISE_ANUAL')),
  fecha_inicio TIMESTAMP DEFAULT NOW(),
  fecha_vencimiento TIMESTAMP NOT NULL,
  estado VARCHAR DEFAULT 'ACTIVO' CHECK (estado IN ('ACTIVO', 'ACTIVO_PRONTO_VENCE', 'VENCIDO_GRACE', 'BLOQUEADO', 'CANCELADO')),
  monto_pagado DECIMAL(10,2),
  metodo_pago VARCHAR,
  notas TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.alertas_suscripcion (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  cliente_id UUID REFERENCES public.clientes(id),
  tipo VARCHAR NOT NULL CHECK (tipo IN ('VENCE_7_DIAS', 'VENCE_3_DIAS', 'VENCE_HOY', 'VENCIDA')),
  enviado_a BOOLEAN DEFAULT FALSE,
  fecha_envio TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_suscripciones_cliente_id ON public.suscripciones(cliente_id);
CREATE INDEX IF NOT EXISTS idx_suscripciones_estado ON public.suscripciones(estado);
CREATE INDEX IF NOT EXISTS idx_alertas_suscripcion_cliente_id ON public.alertas_suscripcion(cliente_id);
CREATE INDEX IF NOT EXISTS idx_alertas_suscripcion_tipo ON public.alertas_suscripcion(tipo);

ALTER TABLE public.suscripciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.alertas_suscripcion ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admin ve todas suscripciones"
  ON public.suscripciones FOR ALL
  USING (auth.jwt() ->> 'es_admin_sistema' = 'true');

CREATE POLICY "Usuarios ven su suscripción"
  ON public.suscripciones FOR SELECT
  USING (cliente_id IN (SELECT cliente_id FROM public.usuarios WHERE id = auth.uid()));

CREATE POLICY "Admin ve todas alertas"
  ON public.alertas_suscripcion FOR ALL
  USING (auth.jwt() ->> 'es_admin_sistema' = 'true');

CREATE POLICY "Usuarios ven sus alertas"
  ON public.alertas_suscripcion FOR SELECT
  USING (cliente_id IN (SELECT cliente_id FROM public.usuarios WHERE id = auth.uid()));

-- 5.3: TABLAS CONFIG DEL SISTEMA
CREATE TABLE IF NOT EXISTS public.config_sistema (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nombre_empresa VARCHAR DEFAULT 'TARUK',
  logo_url VARCHAR,
  numero_whatsapp VARCHAR,
  numero_whatsapp_alternativo VARCHAR,
  email_soporte VARCHAR,
  telefono_soporte VARCHAR,
  precio_hobby_mensual DECIMAL(10,2) DEFAULT 0,
  precio_pro_mensual DECIMAL(10,2) DEFAULT 50,
  precio_pro_anual DECIMAL(10,2) DEFAULT 500,
  precio_enterprise_mensual DECIMAL(10,2) DEFAULT 200,
  precio_enterprise_anual DECIMAL(10,2) DEFAULT 2000,
  descripcion_hobby TEXT,
  descripcion_pro TEXT,
  descripcion_enterprise TEXT,
  updated_at TIMESTAMP DEFAULT NOW(),
  updated_by_usuario_id UUID REFERENCES public.usuarios(id),
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.config_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  campo_modificado VARCHAR,
  valor_anterior TEXT,
  valor_nuevo TEXT,
  usuario_id UUID REFERENCES public.usuarios(id),
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_config_logs_usuario_id ON public.config_logs(usuario_id);
CREATE INDEX IF NOT EXISTS idx_config_logs_created_at ON public.config_logs(created_at);

ALTER TABLE public.config_sistema ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.config_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admin solo"
  ON public.config_sistema FOR ALL
  USING (auth.jwt() ->> 'es_admin_sistema' = 'true');

CREATE POLICY "Admin solo logs"
  ON public.config_logs FOR ALL
  USING (auth.jwt() ->> 'es_admin_sistema' = 'true');

-- 5.5: TABLA PROVEEDORES
CREATE TABLE IF NOT EXISTS public.proveedores (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  cliente_id UUID REFERENCES public.clientes(id),
  nombre VARCHAR NOT NULL,
  email VARCHAR,
  telefono VARCHAR,
  numero_whatsapp VARCHAR,
  ciudad VARCHAR,
  direccion TEXT,
  ruc_proveedor VARCHAR,
  notas TEXT,
  activo BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_proveedores_cliente_id ON public.proveedores(cliente_id);
CREATE INDEX IF NOT EXISTS idx_proveedores_activo ON public.proveedores(activo);

ALTER TABLE public.proveedores ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Usuarios ven proveedores de su cliente"
  ON public.proveedores FOR ALL
  USING (cliente_id IN (SELECT cliente_id FROM public.usuarios WHERE id = auth.uid()));

-- Agregar columna proveedor_id a productos si no existe
ALTER TABLE public.productos ADD COLUMN IF NOT EXISTS proveedor_id UUID REFERENCES public.proveedores(id);

-- 5.6: TABLAS FINANCIERO
CREATE TABLE IF NOT EXISTS public.deudas (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  cliente_id UUID REFERENCES public.clientes(id),
  concepto VARCHAR NOT NULL,
  monto_usd DECIMAL(10,2) NOT NULL,
  interes_anual DECIMAL(5,2) DEFAULT 0,
  fecha_vencimiento DATE,
  acreedor VARCHAR,
  estado VARCHAR DEFAULT 'ACTIVA' CHECK (estado IN ('ACTIVA', 'PAGADA', 'PARCIAL')),
  monto_pagado DECIMAL(10,2) DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.pagos_deuda (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  deuda_id UUID REFERENCES public.deudas(id) ON DELETE CASCADE,
  monto_pagado DECIMAL(10,2),
  fecha_pago DATE,
  metodo_pago VARCHAR,
  comprobante_url VARCHAR,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.cuentas (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  cliente_id UUID REFERENCES public.clientes(id),
  banco VARCHAR,
  tipo_cuenta VARCHAR CHECK (tipo_cuenta IN ('AHORRO', 'CORRIENTE')),
  numero_cuenta VARCHAR,
  saldo DECIMAL(10,2) DEFAULT 0,
  moneda VARCHAR DEFAULT 'USD',
  activo BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.transacciones_financieras (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  cuenta_id UUID REFERENCES public.cuentas(id) ON DELETE CASCADE,
  tipo VARCHAR CHECK (tipo IN ('INGRESO', 'EGRESO')),
  monto DECIMAL(10,2),
  concepto VARCHAR,
  saldo_anterior DECIMAL(10,2),
  saldo_nuevo DECIMAL(10,2),
  created_at TIMESTAMP DEFAULT NOW()
);

-- Índices financiero
CREATE INDEX IF NOT EXISTS idx_deudas_cliente_id ON public.deudas(cliente_id);
CREATE INDEX IF NOT EXISTS idx_deudas_estado ON public.deudas(estado);
CREATE INDEX IF NOT EXISTS idx_pagos_deuda_deuda_id ON public.pagos_deuda(deuda_id);
CREATE INDEX IF NOT EXISTS idx_cuentas_cliente_id ON public.cuentas(cliente_id);
CREATE INDEX IF NOT EXISTS idx_transacciones_cuenta_id ON public.transacciones_financieras(cuenta_id);
CREATE INDEX IF NOT EXISTS idx_transacciones_created_at ON public.transacciones_financieras(created_at);

-- RLS Financiero
ALTER TABLE public.deudas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pagos_deuda ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cuentas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transacciones_financieras ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Usuarios ven deudas de su cliente"
  ON public.deudas FOR ALL
  USING (cliente_id IN (SELECT cliente_id FROM public.usuarios WHERE id = auth.uid()));

CREATE POLICY "Usuarios ven pagos de deudas"
  ON public.pagos_deuda FOR ALL
  USING (deuda_id IN (SELECT id FROM public.deudas WHERE cliente_id IN (SELECT cliente_id FROM public.usuarios WHERE id = auth.uid())));

CREATE POLICY "Usuarios ven cuentas de su cliente"
  ON public.cuentas FOR ALL
  USING (cliente_id IN (SELECT cliente_id FROM public.usuarios WHERE id = auth.uid()));

CREATE POLICY "Usuarios ven transacciones de sus cuentas"
  ON public.transacciones_financieras FOR ALL
  USING (cuenta_id IN (SELECT id FROM public.cuentas WHERE cliente_id IN (SELECT cliente_id FROM public.usuarios WHERE id = auth.uid())));
