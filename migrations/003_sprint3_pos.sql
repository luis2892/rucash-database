-- ========================================
-- SPRINT 3: TABLAS POS
-- ========================================

CREATE TABLE IF NOT EXISTS public.productos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  cliente_id UUID NOT NULL REFERENCES public.clientes(id) ON DELETE CASCADE,
  nombre TEXT NOT NULL,
  descripcion TEXT,
  codigo_barras TEXT NOT NULL,
  categoria TEXT,
  precio_usd DECIMAL(10,2) NOT NULL DEFAULT 0,
  precio_sol DECIMAL(10,2) NOT NULL DEFAULT 0,
  costo_usd DECIMAL(10,2),
  stock_tienda INTEGER DEFAULT 0,
  stock_almacen INTEGER DEFAULT 0,
  activo BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(cliente_id, codigo_barras)
);

CREATE TABLE IF NOT EXISTS public.ventas (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  cliente_id UUID NOT NULL REFERENCES public.clientes(id) ON DELETE CASCADE,
  usuario_id UUID NOT NULL REFERENCES public.usuarios(id),
  moneda VARCHAR(3) NOT NULL DEFAULT 'USD',
  subtotal DECIMAL(10,2) NOT NULL DEFAULT 0,
  impuesto DECIMAL(10,2) NOT NULL DEFAULT 0,
  total DECIMAL(10,2) NOT NULL DEFAULT 0,
  metodo_pago VARCHAR(50) NOT NULL DEFAULT 'EFECTIVO',
  monto_pagado DECIMAL(10,2) NOT NULL DEFAULT 0,
  cambio DECIMAL(10,2) NOT NULL DEFAULT 0,
  estado VARCHAR(50) DEFAULT 'COMPLETADA',
  notas TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.detalles_venta (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  venta_id UUID NOT NULL REFERENCES public.ventas(id) ON DELETE CASCADE,
  producto_id UUID NOT NULL REFERENCES public.productos(id),
  cantidad INTEGER NOT NULL DEFAULT 1,
  precio_unitario DECIMAL(10,2) NOT NULL,
  subtotal DECIMAL(10,2) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_productos_cliente_id ON public.productos(cliente_id);
CREATE INDEX IF NOT EXISTS idx_productos_codigo_barras ON public.productos(codigo_barras);
CREATE INDEX IF NOT EXISTS idx_ventas_cliente_id ON public.ventas(cliente_id);
CREATE INDEX IF NOT EXISTS idx_ventas_created_at ON public.ventas(created_at);
CREATE INDEX IF NOT EXISTS idx_detalles_venta_venta_id ON public.detalles_venta(venta_id);

-- RLS
ALTER TABLE public.productos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ventas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.detalles_venta ENABLE ROW LEVEL SECURITY;

-- Función para decrementar stock
CREATE OR REPLACE FUNCTION public.decrementar_stock(p_producto_id UUID, p_cantidad INTEGER)
RETURNS void AS $$
BEGIN
  UPDATE public.productos
  SET stock_tienda = GREATEST(0, stock_tienda - p_cantidad), updated_at = NOW()
  WHERE id = p_producto_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
