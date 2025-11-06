// StorageManager.ets - Simplified version
import dataStorage from '@ohos.data.storage';
import { BusinessError } from '@ohos.base';

const STORAGE_PATH: string = 'reflexChallenge/microsprint_storage';
const HIGH_SCORE_KEY: string = 'high_score';

class StorageManager {
  private static instance: StorageManager | null = null;
  private context: Context | null = null;

  private constructor() {}

  static getInstance(): StorageManager {
    if (!StorageManager.instance) {
      StorageManager.instance = new StorageManager();
    }
    return StorageManager.instance;
  }

  initialize(context: Context): void {
    this.context = context;
  }

  private getStorage(): Promise<dataStorage.Storage> {
    if (!this.context) {
      throw new Error('StorageManager not initialized');
    }
    return dataStorage.getStorage(STORAGE_PATH);
  }

  async saveHighScore(score: number): Promise<void> {
    try {
      const storage = await this.getStorage();
      await storage.put(HIGH_SCORE_KEY, score);
      await storage.flush();
      console.info('High score saved: ' + score);
    } catch (error) {
      console.error('Failed to save high score: ' + (error as BusinessError).message);
    }
  }

  async getHighScore(): Promise<number> {
    try {
      const storage = await this.getStorage();
      const highScore = await storage.get(HIGH_SCORE_KEY, 0);
      return Number(highScore);
    } catch (error) {
      console.error('Failed to get high score: ' + (error as BusinessError).message);
      return 0;
    }
  }
}

export default StorageManager;