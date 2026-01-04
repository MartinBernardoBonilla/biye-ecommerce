import redisClient from '../config/redis.js';

class SafeCache {
  constructor() {
    this.isReady = false;
    this.checkConnection();
  }

  async checkConnection() {
    try {
      if (redisClient && redisClient.isReady) {
        this.isReady = true;
      }
    } catch (error) {
      this.isReady = false;
    }
  }

  async get(key) {
    try {
      await this.checkConnection();
      if (!this.isReady) {
        console.log(`⚠️  Cache deshabilitado para get(${key})`);
        return null;
      }
      const value = await redisClient.get(key);
      return value ? JSON.parse(value) : null;
    } catch (error) {
      console.error(`❌ Error en cache.get(${key}):`, error.message);
      return null;
    }
  }

  async set(key, value, ttl = 3600) {
    try {
      await this.checkConnection();
      if (!this.isReady) {
        console.log(`⚠️  Cache deshabilitado para set(${key})`);
        return false;
      }
      
      const stringValue = JSON.stringify(value);
      if (ttl) {
        await redisClient.setEx(key, ttl, stringValue);
      } else {
        await redisClient.set(key, stringValue);
      }
      return true;
    } catch (error) {
      console.error(`❌ Error en cache.set(${key}):`, error.message);
      return false;
    }
  }

  async del(key) {
    try {
      await this.checkConnection();
      if (!this.isReady) return false;
      
      await redisClient.del(key);
      return true;
    } catch (error) {
      console.error(`❌ Error en cache.del(${key}):`, error.message);
      return false;
    }
  }
}

export default new SafeCache();
