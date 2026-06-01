-- ========================================
-- SPRINT 6: MARCAS & METAS GUIADAS
-- ========================================

-- 6.3: TABLA MARCAS
CREATE TABLE IF NOT EXISTS public.marcas (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  cliente_id UUID NOT NULL REFERENCES public.clientes(id) ON DELETE CASCADE,
  nombre VARCHAR NOT NULL,
  descripcion TEXT,
  logo_url VARCHAR,
  activo BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_marcas_cliente_id ON public.marcas(cliente_id);
CREATE INDEX IF NOT EXISTS idx_marcas_activo ON public.marcas(activo);

ALTER TABLE public.marcas ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Usuarios ven marcas de su cliente"
  ON public.marcas FOR SELECT
  USING (cliente_id IN (SELECT cliente_id FROM public.usuarios WHERE id = auth.uid()));

CREATE POLICY "Usuarios pueden actualizar marcas de su cliente"
  ON public.marcas FOR UPDATE
  USING (cliente_id IN (SELECT cliente_id FROM public.usuarios WHERE id = auth.uid()))
  WITH CHECK (cliente_id IN (SELECT cliente_id FROM public.usuarios WHERE id = auth.uid()));

CREATE POLICY "Usuarios pueden crear marcas para su cliente"
  ON public.marcas FOR INSERT
  WITH CHECK (cliente_id IN (SELECT cliente_id FROM public.usuarios WHERE id = auth.uid()));

-- Agregar columna marca_id a productos
ALTER TABLE public.productos ADD COLUMN IF NOT EXISTS marca_id UUID REFERENCES public.marcas(id) ON DELETE SET NULL;

-- 6.4: AGREGAR PERMISOS A CATEGORIAS
ALTER TABLE public.categorias ADD COLUMN IF NOT EXISTS permite_edicion_almacenero BOOLEAN DEFAULT FALSE;

-- 6.5: TABLA METAS
CREATE TABLE IF NOT EXISTS public.metas (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  cliente_id UUID NOT NULL REFERENCES public.clientes(id) ON DELETE CASCADE,
  usuario_id UUID NOT NULL REFERENCES public.usuarios(id) ON DELETE CASCADE,
  nombre VARCHAR NOT NULL,
  tipo VARCHAR NOT NULL CHECK (tipo IN ('VENTA_DIARIA', 'VENTA_MENSUAL', 'GANANCIA', 'CLIENTES_NUEVOS')),
  valor_objetivo DECIMAL(10,2) NOT NULL,
  valor_actual DECIMAL(10,2) DEFAULT 0,
  porcentaje_cumplimiento DECIMAL(5,2) DEFAULT 0,
  fecha_inicio DATE NOT NULL,
  fecha_fin DATE NOT NULL,
  prioridad VARCHAR DEFAULT 'MEDIA' CHECK (prioridad IN ('ALTA', 'MEDIA', 'BAJA')),
  estado VARCHAR DEFAULT 'ACTIVA' CHECK (estado IN ('ACTIVA', 'CUMPLIDA', 'NO_CUMPLIDA', 'CANCELADA')),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- TABLA MOVIMIENTOS_META
CREATE TABLE IF NOT EXISTS public.movimientos_meta (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  meta_id UUID NOT NULL REFERENCES public.metas(id) ON DELETE CASCADE,
  valor_registrado DECIMAL(10,2) NOT NULL,
  nota TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Índices para metas
CREATE INDEX IF NOT EXISTS idx_metas_cliente_id ON public.metas(cliente_id);
CREATE INDEX IF NOT EXISTS idx_metas_usuario_id ON public.metas(usuario_id);
CREATE INDEX IF NOT EXISTS idx_metas_estado ON public.metas(estado);
CREATE INDEX IF NOT EXISTS idx_metas_tipo ON public.metas(tipo);
CREATE INDEX IF NOT EXISTS idx_metas_fecha_inicio ON public.metas(fecha_inicio);
CREATE INDEX IF NOT EXISTS idx_movimientos_meta_meta_id ON public.movimientos_meta(meta_id);
CREATE INDEX IF NOT EXISTS idx_movimientos_meta_created_at ON public.movimientos_meta(created_at);

-- RLS para metas
ALTER TABLE public.metas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.movimientos_meta ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Usuarios ven metas de su cliente"
  ON public.metas FOR SELECT
  USING (cliente_id IN (SELECT cliente_id FROM public.usuarios WHERE id = auth.uid()));

CREATE POLICY "Usuarios pueden crear metas para su cliente"
  ON public.metas FOR INSERT
  WITH CHECK (cliente_id IN (SELECT cliente_id FROM public.usuarios WHERE id = auth.uid()));

CREATE POLICY "Usuarios pueden actualizar metas de su cliente"
  ON public.metas FOR UPDATE
  USING (cliente_id IN (SELECT cliente_id FROM public.usuarios WHERE id = auth.uid()))
  WITH CHECK (cliente_id IN (SELECT cliente_id FROM public.usuarios WHERE id = auth.uid()));

CREATE POLICY "Usuarios ven movimientos de metas de su cliente"
  ON public.movimientos_meta FOR SELECT
  USING (meta_id IN (SELECT id FROM public.metas WHERE cliente_id IN (SELECT cliente_id FROM public.usuarios WHERE id = auth.uid())));

CREATE POLICY "Usuarios pueden crear movimientos en metas de su cliente"
  ON public.movimientos_meta FOR INSERT
  WITH CHECK (meta_id IN (SELECT id FROM public.metas WHERE cliente_id IN (SELECT cliente_id FROM public.usuarios WHERE id = auth.uid())));
