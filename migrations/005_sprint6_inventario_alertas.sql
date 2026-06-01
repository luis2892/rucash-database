-- ========================================
-- SPRINT 6: INVENTARIO AVANZADO & ALERTAS DE STOCK
-- ========================================

-- 6.1: AGREGAR CAMPOS A PRODUCTOS
ALTER TABLE public.productos ADD COLUMN IF NOT EXISTS nivel_minimo_stock INTEGER DEFAULT 5;
ALTER TABLE public.productos ADD COLUMN IF NOT EXISTS nivel_maximo_stock INTEGER DEFAULT 100;
ALTER TABLE public.productos ADD COLUMN IF NOT EXISTS codigo_interno VARCHAR;

-- 6.2: CREAR TABLA ALERTAS_STOCK
CREATE TABLE IF NOT EXISTS public.alertas_stock (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  cliente_id UUID NOT NULL REFERENCES public.clientes(id) ON DELETE CASCADE,
  producto_id UUID NOT NULL REFERENCES public.productos(id) ON DELETE CASCADE,
  tipo VARCHAR NOT NULL CHECK (tipo IN ('STOCK_BAJO', 'SIN_STOCK', 'EXCESO')),
  nivel_minimo INTEGER,
  nivel_maximo INTEGER,
  stock_actual INTEGER,
  estado VARCHAR DEFAULT 'ACTIVA' CHECK (estado IN ('ACTIVA', 'RESUELTA', 'IGNORADA')),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Índices para alertas_stock
CREATE INDEX IF NOT EXISTS idx_alertas_stock_cliente_id ON public.alertas_stock(cliente_id);
CREATE INDEX IF NOT EXISTS idx_alertas_stock_producto_id ON public.alertas_stock(producto_id);
CREATE INDEX IF NOT EXISTS idx_alertas_stock_estado ON public.alertas_stock(estado);
CREATE INDEX IF NOT EXISTS idx_alertas_stock_tipo ON public.alertas_stock(tipo);
CREATE INDEX IF NOT EXISTS idx_alertas_stock_created_at ON public.alertas_stock(created_at);

-- RLS para alertas_stock
ALTER TABLE public.alertas_stock ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Usuarios ven alertas de su cliente"
  ON public.alertas_stock FOR SELECT
  USING (cliente_id IN (SELECT cliente_id FROM public.usuarios WHERE id = auth.uid()));

CREATE POLICY "Usuarios pueden actualizar alertas de su cliente"
  ON public.alertas_stock FOR UPDATE
  USING (cliente_id IN (SELECT cliente_id FROM public.usuarios WHERE id = auth.uid()))
  WITH CHECK (cliente_id IN (SELECT cliente_id FROM public.usuarios WHERE id = auth.uid()));

CREATE POLICY "Usuarios pueden crear alertas para su cliente"
  ON public.alertas_stock FOR INSERT
  WITH CHECK (cliente_id IN (SELECT cliente_id FROM public.usuarios WHERE id = auth.uid()));
