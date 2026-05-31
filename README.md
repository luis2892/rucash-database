# 🗄️ RUCASH Database

Schema y migrations para RUCASH — PostgreSQL en Supabase.

## 📊 Tablas

### Sprint 1 — Auth Base
| Tabla | Descripción |
|-------|-------------|
| `clientes` | Tiendas registradas en la plataforma |
| `usuarios` | Empleados de cada tienda |
| `refresh_tokens` | Tokens de sesión |
| `audit_logs` | Log de acciones |

### Sprint 2 — Auth Avanzada
| Tabla | Descripción |
|-------|-------------|
| `user_2fa` | Secrets TOTP y backup codes |
| `email_verification` | Tokens de verificación de email |
| `password_reset` | Tokens de reset de contraseña |
| `oauth_accounts` | Cuentas OAuth (Google, etc.) |
| `user_sessions` | Sesiones activas por dispositivo |
| `security_events` | Eventos de seguridad |

### Sprint 3 — POS
| Tabla | Descripción |
|-------|-------------|
| `productos` | Catálogo de productos por tienda |
| `ventas` | Transacciones de venta |
| `detalles_venta` | Items de cada venta |

## 🔒 Seguridad

- ✅ RLS habilitado en todas las tablas
- ✅ Índices de performance creados
- ✅ Foreign keys con `ON DELETE CASCADE`
- ✅ Función `decrementar_stock()` para actualizar stock en ventas

## 📝 Migrations

```
migrations/
├── 001_initial_schema.sql        # Sprint 1: clientes, usuarios, tokens
├── 002_sprint2_advanced_auth.sql # Sprint 2: 2FA, sessions, events
└── 003_sprint3_pos.sql           # Sprint 3: productos, ventas
```

## 🔗 Repos relacionados

- [Frontend](https://github.com/luis2892/rucash-frontend)
- [Backend](https://github.com/luis2892/rucash-backend)
- [Documentación](https://github.com/luis2892/rucash-docs)

---
© 2026 TARUK · Desarrollado por Luis Felix Rosas
