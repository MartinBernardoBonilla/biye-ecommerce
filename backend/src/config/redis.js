// Redis mock - Sin conexión real para desarrollo rápido
console.log('⚠️  Redis desactivado (modo mock)');

const mockRedisClient = {
  get: async () => {
    console.log('📦 Redis mock: get() -> null');
    return null;
  },
  set: async () => {
    console.log('📦 Redis mock: set() -> OK');
    return 'OK';
  },
  setEx: async () => {
    console.log('📦 Redis mock: setEx() -> OK');
    return 'OK';
  },
  del: async () => {
    console.log('📦 Redis mock: del() -> 0');
    return 0;
  },
  connect: async () => {
    console.log('📦 Redis mock: connect() -> éxito');
    return true;
  },
  quit: async () => {
    console.log('📦 Redis mock: quit()');
    return true;
  },
  isReady: false,
  on: () => {} // Método dummy para eventos
};

export default mockRedisClient;
