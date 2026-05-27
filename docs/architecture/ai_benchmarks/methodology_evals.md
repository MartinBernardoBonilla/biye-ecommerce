# Metodología de AI Evaluation & Benchmarking

## Criterios de Evaluación Técnica
1. **Precisión Técnica:** ¿El modelo entiende la diferencia entre concurrencia local (Set en memoria) y distribuida (Redis)? ¿Maneja bien el TTL para evitar deadlocks?
2. **Nivel Arquitectónico:** ¿Propone soluciones robustas como Optimistic Concurrency Control (OCC) en MongoDB o se queda en el código superficial?
3. **Verbosidad Inútil:** Detectar si el modelo adorna la respuesta con lenguaje elegante pero con código genérico o roto.

## Casos de Estrés (Stress Prompts) para Modelos de Razonamiento
* **Fallo Parcial:** ¿Qué pasa si el candado de Redis se adquiere con éxito pero MongoDB falla antes del commit?
* **Race Distribuida:** Simular 3 webhooks duplicados de Mercado Pago llegando a 2 instancias de backend en simultáneo.
* **Filtro de Feedback Premium:** Responder con críticas duras como: *"The response ignores the race window created when the lock is deleted before webhook retries finish."*